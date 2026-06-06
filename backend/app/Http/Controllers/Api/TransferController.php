<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;
use App\Services\TransactionService;

class TransferController extends Controller
{
    protected $transactionService;

    public function __construct(TransactionService $transactionService)
    {
        $this->transactionService = $transactionService;
    }

    public function transfer(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'recipient_email' => 'required|email|exists:users,email',
            'amount' => 'required|numeric|min:1|max:100000000',
            'description' => 'nullable|string|max:255'
        ], [
            'recipient_email.exists' => 'Email penerima tidak terdaftar di sistem. Pastikan email sudah benar dan user sudah register.',
            'recipient_email.required' => 'Email penerima wajib diisi.',
            'recipient_email.email' => 'Format email penerima tidak valid.',
            'amount.required' => 'Nominal transfer wajib diisi.',
            'amount.numeric' => 'Nominal transfer harus berupa angka.',
            'amount.min' => 'Nominal transfer minimal Rp0,01',
            'amount.max' => 'Nominal transfer maksimal Rp100.000.000',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'status' => 'error',
                'message' => 'Validasi gagal',
                'errors' => $validator->errors()
            ], 422);
        }

        try {
            $result = $this->transactionService->transfer(
                $request->user(),
                $request->recipient_email,
                (float) $request->amount,
                $request->description
            );

            return response()->json([
                'status' => 'success',
                'message' => 'Transfer berhasil',
                'data' => $result
            ], 200);
        } catch (\Exception $e) {
            $statusCode = in_array($e->getCode(), [400, 404]) ? $e->getCode() : 500;
            return response()->json([
                'status' => 'error',
                'message' => $e->getMessage()
            ], $statusCode);
        }
    }
}
