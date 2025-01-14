<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\LeaveBalance;
use App\Models\LeaveRequest;
use App\Models\LeaveType;
use App\Models\Employee;
use Carbon\Carbon;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Validator;

class LeaveController extends Controller
{
    public function getBalances(Request $request)
    {
        try {
            $validator = Validator::make($request->query(), [
                'employee_id' => 'required|string|exists:employees,employee_id'
            ]);

            if ($validator->fails()) {
                return response()->json([
                    'message' => 'Validation error',
                    'errors' => $validator->errors()
                ], 400);
            }

            $employee = Employee::where('employee_id', $request->employee_id)->first();
            $currentYear = Carbon::now()->year;

            // First check if leave balances exist, if not create them
            $leaveTypes = LeaveType::where('is_active', true)->get();
            foreach ($leaveTypes as $leaveType) {
                LeaveBalance::firstOrCreate(
                    [
                        'employee_id' => $employee->id,
                        'leave_type_id' => $leaveType->id,
                        'year' => $currentYear,
                    ],
                    [
                        'total_days' => $leaveType->default_days_per_year,
                        'used_days' => 0
                    ]
                );
            }

            $balances = LeaveBalance::with('leaveType')
                ->where('employee_id', $employee->id)
                ->where('year', $currentYear)
                ->get()
                ->map(function ($balance) {
                    return [
                        'leave_type' => [
                            'id' => $balance->leaveType->id,
                            'name' => $balance->leaveType->name,
                            'code' => $balance->leaveType->code,
                        ],
                        'total_days' => $balance->total_days,
                        'used_days' => $balance->used_days,
                        'remaining_days' => $balance->remaining_days
                    ];
                });

            return response()->json(['data' => $balances]);

        } catch (\Exception $e) {
            Log::error('Error fetching leave balances', [
                'error' => $e->getMessage(),
                'trace' => $e->getTraceAsString(),
                'employee_id' => $request->employee_id ?? null
            ]);
            return response()->json([
                'message' => 'Failed to fetch leave balances: ' . $e->getMessage()
            ], 500);
        }
    }

    public function submitRequest(Request $request)
    {
        try {
            Log::info('Leave request received:', $request->all());

            $validator = Validator::make($request->all(), [
                'employee_id' => 'required|string|exists:employees,employee_id',
                'leave_type_id' => 'required|integer|exists:leave_types,id',
                'start_date' => 'required|date',
                'end_date' => 'required|date|after_or_equal:start_date',
                'reason' => 'required|string',
                'total_days' => 'required|numeric|min:0.5'
            ]);

            if ($validator->fails()) {
                Log::warning('Leave request validation failed:', [
                    'errors' => $validator->errors()->toArray(),
                    'request_data' => $request->all()
                ]);
                return response()->json([
                    'message' => 'Validation error',
                    'errors' => $validator->errors(),
                    'received_data' => $request->all()
                ], 400);
            }

            $employee = Employee::where('employee_id', $request->employee_id)->first();
            
            // Check leave balance
            $balance = LeaveBalance::where([
                'employee_id' => $employee->id,
                'leave_type_id' => $request->leave_type_id,
                'year' => Carbon::now()->year
            ])->first();

            if (!$balance || $balance->remaining_days < $request->total_days) {
                return response()->json([
                    'message' => 'Insufficient leave balance'
                ], 400);
            }

            // Create leave request
            $leaveRequest = LeaveRequest::create([
                'employee_id' => $employee->id,
                'leave_type_id' => $request->leave_type_id,
                'start_date' => $request->start_date,
                'end_date' => $request->end_date,
                'total_days' => $request->total_days,
                'reason' => $request->reason,
                'status' => 'pending'
            ]);

            // Update leave balance when request is approved
            if ($leaveRequest->status === 'approved') {
                $balance->used_days += $request->total_days;
                $balance->save();
            }

            return response()->json([
                'message' => 'Leave request submitted successfully',
                'data' => $leaveRequest
            ]);

        } catch (\Exception $e) {
            Log::error('Error submitting leave request', [
                'error' => $e->getMessage(),
                'trace' => $e->getTraceAsString(),
                'employee_id' => $request->employee_id ?? null
            ]);
            return response()->json([
                'message' => 'Failed to submit leave request: ' . $e->getMessage()
            ], 500);
        }
    }

    public function getHistory(Request $request)
    {
        try {
            $validator = Validator::make($request->query(), [
                'employee_id' => 'required|string|exists:employees,employee_id'
            ]);

            if ($validator->fails()) {
                return response()->json([
                    'message' => 'Validation error',
                    'errors' => $validator->errors()
                ], 400);
            }

            $employee = Employee::where('employee_id', $request->employee_id)->first();

            $history = LeaveRequest::with(['leaveType'])
                ->where('employee_id', $employee->id)
                ->orderBy('created_at', 'desc')
                ->get()
                ->map(function ($request) {
                    return [
                        'id' => $request->id,
                        'leave_type' => $request->leaveType->name,
                        'start_date' => $request->start_date,
                        'end_date' => $request->end_date,
                        'total_days' => $request->total_days,
                        'status' => $request->status,
                        'reason' => $request->reason,
                        'created_at' => $request->created_at->format('Y-m-d H:i:s')
                    ];
                });

            return response()->json(['data' => $history]);

        } catch (\Exception $e) {
            Log::error('Error fetching leave history', [
                'error' => $e->getMessage(),
                'trace' => $e->getTraceAsString(),
                'employee_id' => $request->employee_id ?? null
            ]);
            return response()->json([
                'message' => 'Failed to fetch leave history'
            ], 500);
        }
    }
} 