<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Transaction;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Str;
use Illuminate\Support\Facades\DB;

class TransactionController extends Controller
{
    private $xenditApiKey;

    public function __construct()
    {
        $this->xenditApiKey = config('services.xendit.secret_key');
    }

    private function checkApiKey()
    {
        if (empty($this->xenditApiKey)) {
            throw new \Exception('XENDIT_SECRET_KEY is missing in .env file. Please add it and restart the server.');
        }
    }

    /**
     * Create Top Up Transaction
     */
    public function store(Request $request)
    {
        $this->checkApiKey();

        $request->validate([
            'amount' => 'required|numeric|min:1',
        ]);

        $user = $request->user();
        $amount = $request->amount;
        $externalId = 'TOPUP-' . time() . '-' . $user->id;

        // Call Xendit API
        try {
            $response = Http::withBasicAuth($this->xenditApiKey, '')
                ->post('https://api.xendit.co/v2/invoices', [
                    'external_id' => $externalId,
                    'amount' => $amount,
                    'description' => 'Top Up Balance for ' . $user->name,
                    'customer' => [
                        'email' => $user->email,
                        'given_names' => $user->name,
                    ],
                ]);

            if ($response->successful()) {
                $data = $response->json();

                // Save to DB
                $transaction = Transaction::create([
                    'user_id' => $user->id,
                    'external_id' => $externalId,
                    'amount' => $amount,
                    'status' => 'PENDING',
                    'payment_url' => $data['invoice_url'],
                ]);

                return response()->json([
                    'success' => true,
                    'message' => 'Invoice created successfully',
                    'data' => $transaction,
                ]);
            } else {
                \Illuminate\Support\Facades\Log::error('Xendit Create Invoice Failed', [
                    'status' => $response->status(),
                    'body' => $response->body()
                ]);

                return response()->json([
                    'success' => false,
                    'message' => 'Failed to create invoice with Xendit',
                    'error' => $response->body()
                ], 500);
            }

        } catch (\Exception $e) {
            \Illuminate\Support\Facades\Log::error('Xendit Exception', [
                'message' => $e->getMessage(),
                'trace' => $e->getTraceAsString()
            ]);

            return response()->json([
                'success' => false,
                'message' => 'Server Error: ' . $e->getMessage(),
            ], 500);
        }
    }

    /**
     * Check Transaction Status
     */
    public function checkStatus($externalId)
    {
        $this->checkApiKey();

        \Illuminate\Support\Facades\Log::info('Checking status for: ' . $externalId);

        $transaction = Transaction::where('external_id', $externalId)->firstOrFail();

        if ($transaction->status === 'PAID') {
            return response()->json([
                'success' => true,
                'status' => 'PAID',
                'message' => 'Transaction already paid'
            ]);
        }

        try {
            // Use query parameter to search by external_id
            $response = Http::withBasicAuth($this->xenditApiKey, '')
                ->get('https://api.xendit.co/v2/invoices', [
                    'external_id' => $transaction->external_id
                ]);

            \Illuminate\Support\Facades\Log::info('Xendit Check Response: ' . $response->body());

            if ($response->successful()) {
                $data = $response->json();

                // Response is an array of invoices, take the first one
                if (empty($data)) {
                    return response()->json(['success' => false, 'message' => 'Invoice not found at Xendit'], 404);
                }

                $invoice = $data[0];
                $status = $invoice['status']; // PENDING, SETTLED, PAID, EXPIRED

                if ($status === 'PAID' || $status === 'SETTLED') {
                    // Update Transaction & User Balance
                    DB::transaction(function () use ($transaction, $status) {
                        // Double check to prevent double balance increment if status is already PAID
                        if ($transaction->status !== 'PAID') {
                            \Illuminate\Support\Facades\Log::info('Updating transaction to ' . $status);

                            $transaction->update(['status' => $status]); // Use explicit status from Xendit

                            $user = $transaction->user;
                            \Illuminate\Support\Facades\Log::info('Current User Balance (Before): ' . $user->balance);
                            \Illuminate\Support\Facades\Log::info('Incrementing by: ' . $transaction->amount);

                            // Reload user to be safe and increment
                            $user->fresh()->increment('balance', $transaction->amount);

                            \Illuminate\Support\Facades\Log::info('User Balance (After Increment): ' . $user->fresh()->balance);
                        } else {
                            \Illuminate\Support\Facades\Log::info('Transaction already marked as PAID, skipping balance update.');
                        }
                    });

                    return response()->json([
                        'success' => true,
                        'status' => 'PAID',
                        'message' => 'Payment successful, balance updated'
                    ]);
                } elseif ($status === 'EXPIRED') {
                    $transaction->update(['status' => 'EXPIRED']);
                    return response()->json(['success' => true, 'status' => 'EXPIRED']);
                }

                return response()->json(['success' => true, 'status' => 'PENDING']);
            }

            return response()->json(['success' => false, 'message' => 'Failed to check status'], 500);

        } catch (\Exception $e) {
            \Illuminate\Support\Facades\Log::error('Check Status Error: ' . $e->getMessage());
            return response()->json(['success' => false, 'message' => $e->getMessage()], 500);
        }
    }
}
