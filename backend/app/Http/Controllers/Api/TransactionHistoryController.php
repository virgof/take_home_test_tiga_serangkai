<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;
use App\Services\TransactionService;

class TransactionHistoryController extends Controller
{
    protected $transactionService;

    public function __construct(TransactionService $transactionService)
    {
        $this->transactionService = $transactionService;
    }

    /**
     * Get transaction history
     */
    public function index(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'page' => 'integer|min:1',
            'per_page' => 'integer|min:1|max:100',
            'sort_by' => 'in:created_at,amount,type',
            'sort_order' => 'in:asc,desc',
            'type' => 'in:credit,debit',
            'category' => 'in:deposit,transfer_in,transfer_out',
            'date_from' => 'date',
            'date_to' => 'date|after_or_equal:date_from',
            'min_amount' => 'numeric|min:0',
            'max_amount' => 'numeric|min:0'
        ]);

        if ($validator->fails()) {
            return response()->json([
                'status' => 'error',
                'errors' => $validator->errors()
            ], 422);
        }

        try {
            $history = $this->transactionService->getTransactionHistory(
                $request->user(),
                $request->all()
            );

            return response()->json([
                'status' => 'success',
                'data' => $history
            ], 200);
        } catch (\Exception $e) {
            return response()->json([
                'status' => 'error',
                'message' => $e->getMessage()
            ], 500);
        }
    }
}
