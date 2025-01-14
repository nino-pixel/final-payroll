<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Payroll;
use App\Models\Employee;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Facades\Schema;
use Carbon\Carbon;
use Illuminate\Support\Facades\Validator;

class PayrollController extends Controller
{
    public function generatePayroll(Request $request)
    {
        try {
            Log::info('Received payroll data:', $request->all());
            Log::info('Increases data:', $request->input('increases', []));
            Log::info('Deductions data:', $request->input('deductions', []));

            DB::beginTransaction();

            // Create payroll record
            $payroll = new Payroll();
            $payroll->employee_id = $request->employee_id;
            $payroll->period_start = $request->period_start;
            $payroll->period_end = $request->period_end;
            $payroll->base_salary = $request->base_salary;
            $payroll->total_increases = $request->total_increases;
            $payroll->total_deductions = $request->total_deductions;
            $payroll->net_salary = $request->net_salary;
            $payroll->status = 'pending';
            $payroll->save();

            Log::info('Created payroll record:', $payroll->toArray());

            // Create payroll details record
            $details = [
                'payroll_id' => $payroll->id,
                'description' => 'Payroll details for ' . $request->period_start . ' to ' . $request->period_end
            ];

            // Merge increases and deductions
            $details = array_merge(
                $details,
                $request->input('increases', []),
                $request->input('deductions', [])
            );

            Log::info('Creating payroll details with:', $details);

            DB::table('payroll_details')->insert($details);

            DB::commit();

            return response()->json([
                'message' => 'Payroll generated successfully',
                'payroll' => $payroll->load('employee')
            ], 201);

        } catch (\Exception $e) {
            DB::rollBack();
            Log::error('Payroll generation failed: ' . $e->getMessage());
            Log::error('Stack trace: ' . $e->getTraceAsString());
            
            return response()->json([
                'message' => 'Failed to generate payroll',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    private function calculateAmount($item, $baseSalary) {
        if ($item['type'] === 'percentage') {
            return ($baseSalary * $item['amount']) / 100;
        }
        return $item['amount'];
    }

    public function getPaymentHistory(Request $request)
    {
        try {
            // For mobile app requests
            if ($request->has('employee_id')) {
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
                $payrolls = Payroll::with(['employee', 'details']) // Include the details relationship
                    ->where('employee_id', $employee->id)
                    ->orderBy('created_at', 'desc')
                    ->get()
                    ->map(function ($payroll) {
                        return [
                            'id' => $payroll->id,
                            'period_start' => $payroll->period_start,
                            'period_end' => $payroll->period_end,
                            'base_salary' => (float)$payroll->base_salary,
                            'total_increases' => (float)$payroll->total_increases,
                            'total_deductions' => (float)$payroll->total_deductions,
                            'net_salary' => (float)$payroll->net_salary,
                            'status' => $payroll->status,
                            'attendance_summary' => $payroll->attendance_summary,
                            'details' => $payroll->details // Include the details in response
                        ];
                    });

                return response()->json($payrolls);
            }
            // ... rest of the code for web requests

            $payrolls = Payroll::with(['employee', 'details'])
                ->where('employee_id', $request->employee_id)
                ->orderBy('created_at', 'desc')
                ->get();

            return response()->json($payrolls);
        } catch (\Exception $e) {
            Log::error('Failed to fetch payment history: ' . $e->getMessage());
            return response()->json([
                'message' => 'Failed to fetch payment history',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    public function show($id)
    {
        try {
            $payroll = Payroll::with(['employee.department'])->findOrFail($id);
            
            return response()->json([
                'id' => $payroll->id,
                'name' => $payroll->employee->first_name . ' ' . $payroll->employee->last_name,
                'department' => $payroll->employee->department->name,
                'amount' => $payroll->net_salary,
                'date' => $payroll->created_at->format('Y-m-d'),
                'status' => $payroll->status,
                'summary' => [
                    'base_salary' => $payroll->base_salary,
                    'total_increases' => $payroll->total_increases,
                    'total_deductions' => $payroll->total_deductions,
                    'net_salary' => $payroll->net_salary,
                    'attendance_summary' => $payroll->attendance_summary
                ]
            ]);

        } catch (\Exception $e) {
            Log::error('Payroll show error: ' . $e->getMessage());
            return response()->json([
                'message' => 'Failed to fetch payroll details',
                'error' => $e->getMessage()
            ], 500);
        }
    }
}