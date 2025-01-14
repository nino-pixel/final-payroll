<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Requests\EmployeeRequest;
use App\Models\Employee;
use App\Models\SalaryAdjustment;
use App\Models\Deduction;
use App\Models\Bonus;
use Illuminate\Http\Request;
use Illuminate\Http\Response;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Facades\Validator;
use Illuminate\Validation\Rule;

class EmployeeController extends Controller
{
    public function index(Request $request)
    {
        $employees = Employee::with(['department', 'position'])
            ->when($request->search, function($query) use ($request) {
                $query->where(function($q) use ($request) {
                    $q->where('first_name', 'like', "%{$request->search}%")
                      ->orWhere('last_name', 'like', "%{$request->search}%")
                      ->orWhere('employee_id', 'like', "%{$request->search}%");
                });
            })
            ->when($request->department_id, function($query) use ($request) {
                $query->where('department_id', $request->department_id);
            })
            ->when($request->status, function($query) use ($request) {
                $query->where('status', $request->status);
            })
            ->orderBy($request->sort_by ?? 'first_name', $request->sort_order ?? 'asc')
            ->get();

        return response()->json($employees);
    }

    public function store(Request $request)
    {
        try {
            $validated = $request->validate([
                'employee_id' => 'required|string|unique:employees,employee_id',
                'first_name' => 'required|string|max:255',
                'last_name' => 'required|string|max:255',
                'email' => 'required|email|unique:employees,email',
                'phone' => 'required|string|max:20',
                'department_id' => 'required|exists:departments,id',
                'position_id' => 'required|exists:positions,id',
                'base_salary' => 'required|numeric|min:0',
                'shift_schedule_id' => 'required|exists:shift_schedules,id',
                'status' => 'required|in:Active,Inactive,On Leave'
            ]);

            $employee = Employee::create($validated);

            Log::info('Employee created successfully:', ['id' => $employee->id]);

            return response()->json([
                'message' => 'Employee created successfully',
                'employee' => $employee->load(['department', 'position'])
            ], 201);

        } catch (\Exception $e) {
            Log::error('Error creating employee:', [
                'error' => $e->getMessage(),
                'trace' => $e->getTraceAsString()
            ]);

            return response()->json([
                'error' => 'Failed to create employee',
                'message' => $e->getMessage()
            ], 500);
        }
    }

    public function show($id)
    {
        try {
            $employee = Employee::with(['department', 'position'])
                ->where('id', $id)
                ->first();

            if (!$employee) {
                return response()->json(['message' => 'Employee not found'], 404);
            }

            return response()->json($employee);
        } catch (\Exception $e) {
            return response()->json(['message' => 'Error fetching employee details'], 500);
        }
    }

    public function update(Request $request, $id)
    {
        try {
            $employee = Employee::findOrFail($id);

            $validated = $request->validate([
                'employee_id' => 'required|string|unique:employees,employee_id,' . $id,
                'first_name' => 'required|string|max:255',
                'last_name' => 'required|string|max:255',
                'email' => 'required|email|unique:employees,email,' . $id,
                'phone' => 'nullable|string|max:255',
                'department_id' => 'required|exists:departments,id',
                'position_id' => 'required|exists:positions,id',
                'base_salary' => 'required|numeric|min:0|max:999999.99',
                'hire_date' => 'required|date',
                'status' => 'required|in:active,inactive,on_leave',
                'shift_schedule_id' => 'nullable|exists:shift_schedules,id',
                'custom_start_time' => 'nullable|date_format:H:i:s',
                'custom_end_time' => 'nullable|date_format:H:i:s'
            ]);

            $employee->update($validated);

            return response()->json([
                'message' => 'Employee updated successfully',
                'employee' => $employee->fresh(['department', 'position'])
            ]);

        } catch (\Exception $e) {
            Log::error('Error updating employee:', [
                'error' => $e->getMessage(),
                'trace' => $e->getTraceAsString()
            ]);

            return response()->json([
                'message' => 'Failed to update employee',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    public function destroy(Employee $employee)
    {
        $employee->delete();
        return response()->json(null, Response::HTTP_NO_CONTENT);
    }

    public function getAttendanceSummary(Employee $employee, Request $request)
    {
        $startDate = $request->start_date ?? now()->startOfMonth();
        $endDate = $request->end_date ?? now()->endOfMonth();

        $summary = $employee->attendances()
            ->whereBetween('date', [$startDate, $endDate])
            ->selectRaw('
                COUNT(*) as total_days,
                SUM(CASE WHEN status = "present" THEN 1 ELSE 0 END) as present_days,
                SUM(CASE WHEN status = "absent" THEN 1 ELSE 0 END) as absent_days,
                SUM(CASE WHEN status = "late" THEN 1 ELSE 0 END) as late_days,
                SUM(CASE WHEN status = "half_day" THEN 1 ELSE 0 END) as half_days,
                SUM(CASE WHEN status = "on_leave" THEN 1 ELSE 0 END) as leave_days
            ')
            ->first();

        return response()->json($summary);
    }

    public function getSalaryHistory(Employee $employee)
    {
        $history = $employee->payrolls()
            ->with('details')
            ->latest()
            ->take(12)
            ->get()
            ->map(function($payroll) {
                return [
                    'payroll_id' => $payroll->payroll_id,
                    'period' => $payroll->start_date->format('M Y'),
                    'gross_salary' => $payroll->gross_salary,
                    'net_salary' => $payroll->net_salary,
                    'status' => $payroll->status,
                    'payment_date' => $payroll->payment_date?->format('Y-m-d'),
                ];
            });

        return response()->json($history);
    }

    public function updateGlobalDeductions(Request $request)
    {
        $deductions = $request->only(['sss', 'philhealth', 'pagibig', 'tax']);

        $request->validate([
            'sss' => 'required|numeric|min:0|max:100',
            'philhealth' => 'required|numeric|min:0|max:100',
            'pagibig' => 'required|numeric|min:0',
            'tax' => 'required|numeric|min:0|max:100',
        ]);

        Deduction::query()->update($deductions);

        return response()->json(['message' => 'Deductions updated successfully.']);
    }

    public function storeSalaryAdjustment(Request $request)
    {
        $request->validate([
            'employee_id' => 'required|exists:employees,id',
            'adjustment_type' => 'required|string',
            'adjustment_amount' => 'required|numeric',
            'adjustment_date' => 'required|date',
            'reason' => 'nullable|string',
        ]);

        SalaryAdjustment::create($request->all());

        return response()->json(['message' => 'Salary adjustment recorded successfully.']);
    }

    public function storeDeduction(Request $request)
    {
        $request->validate([
            'employee_id' => 'required|exists:employees,id',
            'deduction_type' => 'required|string',
            'amount' => 'required|numeric',
            'deduction_date' => 'required|date',
        ]);

        Deduction::create($request->all());

        return response()->json(['message' => 'Deduction recorded successfully.']);
    }

    public function storeBonus(Request $request)
    {
        $request->validate([
            'employee_id' => 'required|exists:employees,id',
            'bonus_type' => 'required|string',
            'amount' => 'required|numeric',
            'bonus_date' => 'required|date',
        ]);

        Bonus::create($request->all());

        return response()->json(['message' => 'Bonus recorded successfully.']);
    }
}