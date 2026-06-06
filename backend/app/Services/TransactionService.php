<?php

namespace App\Services;

use App\Models\User;
use App\Models\Transaction;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Cache;
use Illuminate\Support\Str;

class TransactionService
{
    public function getDashboard(User $user): array
    {
        return [
            'user' => [
                'id' => $user->id,
                'name' => $user->name,
                'email' => $user->email,
            ],
            'balance' => [
                'current' => number_format($user->balance, 2, ',', '.'),
                'raw' => $user->balance,
                'formatted' => 'Rp' . number_format($user->balance, 2, ',', '.')
            ],
            'statistics' => $this->getUserStatistics($user),
        ];
    }

    public function transfer(User $sender, string $recipientEmail, float $amount, string $description = null): array
    {
        if ($amount <= 0) {
            throw new \Exception('Nominal transfer harus lebih besar dari 0', 400);
        }

        $recipient = User::where('email', $recipientEmail)->first();
        if (!$recipient) {
            throw new \Exception('Penerima tidak ditemukan', 404);
        }

        if ($sender->id === $recipient->id) {
            throw new \Exception('Tidak dapat transfer ke akun sendiri', 400);
        }

        $sender = User::where('id', $sender->id)->lockForUpdate()->first();

        if ($sender->balance < $amount) {
            throw new \Exception('Saldo tidak mencukupi', 400);
        }

        $referenceId = $this->generateReferenceId();

        DB::beginTransaction();
        try {
            $this->processTransfer($sender, $recipient, $amount, $referenceId, $description);

            DB::commit();

            $this->clearUserCache($sender->id);
            $this->clearUserCache($recipient->id);

            return [
                'success' => true,
                'reference_id' => $referenceId,
                'amount' => number_format($amount, 2, ',', '.'),
                'recipient' => $recipient->name,
                'balance_after' => 'Rp' . number_format($sender->fresh()->balance, 2, ',', '.')
            ];
        } catch (\Exception $e) {
            DB::rollBack();
            throw new \Exception('Transfer gagal: ' . $e->getMessage(), 500);
        }
    }

    private function processTransfer(User $sender, User $recipient, float $amount, string $referenceId, ?string $description): void
    {
        try {
            $senderBalanceBefore = $sender->balance;

            $sender->balance -= $amount;
            $sender->last_transaction_at = now();
            $sender->save();

            $senderTransaction = $this->createTransaction([
                'user_id' => $sender->id,
                'type' => 'debit',
                'category' => 'transfer_out',
                'amount' => $amount,
                'balance_before' => $senderBalanceBefore,
                'balance_after' => $sender->balance,
                'related_user_id' => $recipient->id,
                'reference_id' => $referenceId,
                'description' => $description ?? 'Transfer ke ' . $recipient->email,
                'ip_address' => request()->ip(),
                'user_agent' => request()->userAgent()
            ]);

            $recipientBalanceBefore = $recipient->balance;

            $recipient->balance += $amount;
            $recipient->last_transaction_at = now();
            $recipient->save();

            $recipientTransaction = $this->createTransaction([
                'user_id' => $recipient->id,
                'type' => 'credit',
                'category' => 'transfer_in',
                'amount' => $amount,
                'balance_before' => $recipientBalanceBefore,
                'balance_after' => $recipient->balance,
                'related_user_id' => $sender->id,
                'reference_id' => $referenceId,
                'description' => $description ?? 'Transfer dari ' . $sender->email,
                'ip_address' => request()->ip(),
                'user_agent' => request()->userAgent()
            ]);
        } catch (\Exception $e) {
            throw new \Exception('Failed to create transaction records: ' . $e->getMessage());
        }
    }

    private function createTransaction(array $data, int $attempt = 1): Transaction
    {
        try {
            return Transaction::create($data);
        } catch (\Illuminate\Database\QueryException $e) {
            if ($e->errorInfo[1] == 1062 && $attempt <= 3) {
                $data['reference_id'] = $this->generateReferenceId();
                return $this->createTransaction($data, $attempt + 1);
            }
            throw $e;
        }
    }

    public function getTransactionHistory(User $user, array $filters = []): array
    {
        $query = Transaction::where('user_id', $user->id);

        if (!empty($filters['type'])) {
            $query->where('type', $filters['type']);
        }

        if (!empty($filters['category'])) {
            $query->where('category', $filters['category']);
        }

        if (!empty($filters['date_from'])) {
            $query->whereDate('created_at', '>=', $filters['date_from']);
        }

        if (!empty($filters['date_to'])) {
            $query->whereDate('created_at', '<=', $filters['date_to']);
        }

        if (!empty($filters['min_amount'])) {
            $query->where('amount', '>=', $filters['min_amount']);
        }

        if (!empty($filters['max_amount'])) {
            $query->where('amount', '<=', $filters['max_amount']);
        }

        $sortBy = $filters['sort_by'] ?? 'created_at';
        $sortOrder = $filters['sort_order'] ?? 'desc';

        $allowedSortColumns = ['created_at', 'amount', 'type'];
        if (in_array($sortBy, $allowedSortColumns)) {
            $query->orderBy($sortBy, $sortOrder);
        } else {
            $query->orderBy('created_at', 'desc');
        }

        $perPage = min($filters['per_page'] ?? 15, 100); // Max 100 per page
        $transactions = $query->paginate($perPage);

        return [
            'current_page' => $transactions->currentPage(),
            'data' => $transactions->map(function ($transaction) {
                return [
                    'id' => $transaction->id,
                    'date' => $transaction->created_at->format('d/m/Y H:i:s'),
                    'type' => $transaction->type === 'credit' ? 'Pemasukan' : 'Pengeluaran',
                    'category' => $this->getCategoryText($transaction->category),
                    'amount' => 'Rp' . number_format($transaction->amount, 2, ',', '.'),
                    'amount_raw' => $transaction->amount,
                    'balance_before' => 'Rp' . number_format($transaction->balance_before, 2, ',', '.'),
                    'balance_after' => 'Rp' . number_format($transaction->balance_after, 2, ',', '.'),
                    'description' => $transaction->description,
                    'reference_id' => $transaction->reference_id,
                    'related_user' => $transaction->relatedUser ? $transaction->relatedUser->name : null,
                ];
            }),
            'total' => $transactions->total(),
            'per_page' => $transactions->perPage(),
            'last_page' => $transactions->lastPage(),
            'from' => $transactions->firstItem(),
            'to' => $transactions->lastItem(),
        ];
    }

    private function getUserStatistics(User $user): array
    {
        $totalTransfersOut = Transaction::where('user_id', $user->id)
            ->where('category', 'transfer_out')
            ->sum('amount');

        $totalTransfersIn = Transaction::where('user_id', $user->id)
            ->where('category', 'transfer_in')
            ->sum('amount');

        $totalTransactions = Transaction::where('user_id', $user->id)->count();

        return [
            'total_transactions' => $totalTransactions,
            'total_sent' => 'Rp' . number_format($totalTransfersOut, 2, ',', '.'),
            'total_received' => 'Rp' . number_format($totalTransfersIn, 2, ',', '.'),
            'member_since' => $user->created_at->format('d F Y'),
        ];
    }

    private function generateReferenceId(): string
    {
        $maxAttempts = 5;
        $attempt = 0;

        while ($attempt < $maxAttempts) {
            $referenceId = 'TRX-' . date('Ymd') . '-' . Str::upper(Str::random(6));

            if (!Transaction::where('reference_id', $referenceId)->exists()) {
                return $referenceId;
            }

            $attempt++;
        }

        return 'TRX-' . date('YmdHis') . '-' . Str::upper(Str::random(4));
    }

    private function getCategoryText(string $category): string
    {
        return [
            'deposit' => 'Deposit',
            'transfer_in' => 'Transfer Masuk',
            'transfer_out' => 'Transfer Keluar',
        ][$category] ?? $category;
    }

    private function clearUserCache(int $userId): void
    {
        Cache::forget("user_balance_{$userId}");
        Cache::forget("user_transactions_{$userId}");
    }
}
