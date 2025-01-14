<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Employee;
use App\Models\SalaryAdjustment;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Log;

class SalaryAdjustmentController extends Controller
{
    public function index()
    {
        try {
            $employees = Employee::with(['department', 'position'])
                ->whereNull('deleted_at')
                ->where('status', '!=', 'deleted')
                ->where('status', 'Active')
                ->orderBy('id', 'asc')  // Added this line to sort by ID ascending
                ->get()
                ->map(function ($employee) {
                    return [
                        'id' => $employee->id,
                        'name' => $employee->first_name . ' ' . $employee->last_name,
                        'department' => $employee->department->name,
                        'position' => $employee->position->title,
                        'ratePerHour' => $employee->base_salary,
                        'status' => $employee->status,
                        'deductions' => [
                            'sss' => 4.5,
                            'philhealth' => 3,
                            'pagibig' => 100,
                            'tax' => 15
                        ]
                    ];
                });

            return response()->json($employees);
        } catch (\Exception $e) {
            Log::error('Error fetching salary data: ' . $e->getMessage());
            return response()->json(['error' => 'Failed to fetch salary data'], 500);
        }
    }

    public function show($id) 
    {
        try {
            $adjustments = SalaryAdjustment::where('employee_id', $id)
                ->orderBy('adjustment_date', 'desc')
                ->get();
                
            if ($adjustments->isEmpty()) {
                return response()->json(['message' => 'No salary adjustment found for this employee.'], 404);
            }
            
            return response()->json($adjustments);
        } catch (\Exception $e) {
            Log::error('Error fetching salary adjustment: ' . $e->getMessage());
            return response()->json(['error' => 'Failed to fetch salary adjustment'], 500);
        }
    }

    public function store(Request $request)
    {
        try {
            $validated = $request->validate([
                'employeeId' => 'required|exists:employees,id',
                'newRate' => 'required|numeric|min:0|max:999999.99',
            ]);

            $employee = Employee::findOrFail($request->employeeId);
            
            // Store previous salary for history
            $previousSalary = $employee->base_salary;
            
            // Calculate adjustment amount and type
            $adjustmentAmount = $request->newRate - $previousSalary;
            $adjustmentType = $adjustmentAmount >= 0 ? 'Increase' : 'Decrease';
            
            // Update employee base salary only
            $employee->base_salary = $request->newRate;
            $employee->save();

            // Create salary adjustment record
            $adjustment = SalaryAdjustment::create([
                'employee_id' => $employee->id,
                'adjustment_type' => $adjustmentType,
                'adjustment_amount' => abs($adjustmentAmount),
                'adjustment_date' => now(),
                'reason' => 'Salary adjustment - ' . $adjustmentType
            ]);

            Log::info('Salary adjustment created:', [
                'employee_id' => $employee->id,
                'previous_salary' => $previousSalary,
                'new_salary' => $request->newRate,
                'adjustment_type' => $adjustmentType,
                'adjustment_amount' => abs($adjustmentAmount)
            ]);

            return response()->json([
                'message' => 'Salary adjustment saved successfully',
                'employee' => [
                    'id' => $employee->id,
                    'name' => $employee->first_name . ' ' . $employee->last_name,
                    'department' => $employee->department->name,
                    'position' => $employee->position->title,
                    'base_salary' => $employee->base_salary,
                    'previous_salary' => $previousSalary
                ]
            ]);

        } catch (\Exception $e) {
            Log::error('Error saving salary adjustment:', [
                'error' => $e->getMessage(),
                'trace' => $e->getTraceAsString()
            ]);
            
            return response()->json([
                'error' => 'Failed to save salary adjustment',
                'message' => $e->getMessage()
            ], 500);
        }
    }

    public function update(Request $request, $id)
    {
        try {
            $employee = Employee::findOrFail($id);
            
            $validated = $request->validate([
                'new_base_salary' => 'required|numeric|min:0',
            ]);

            // Store the previous salary before updating
            $previousSalary = $employee->base_salary;
            
            // Calculate adjustment amount and type
            $adjustmentAmount = $validated['new_base_salary'] - $previousSalary;
            $adjustmentType = $adjustmentAmount >= 0 ? 'Increase' : 'Decrease';

            // Update the employee's base salary
            $employee->base_salary = $validated['new_base_salary'];
            $employee->save();

            // Create salary adjustment record
            SalaryAdjustment::create([
                'employee_id' => $id,
                'adjustment_type' => $adjustmentType,
                'adjustment_amount' => abs($adjustmentAmount),
                'adjustment_date' => now(),
                'reason' => 'Salary adjustment - ' . $adjustmentType,
                'previous_salary' => $previousSalary,
                'new_salary' => $validated['new_base_salary']
            ]);

            return response()->json([
                'message' => 'Salary adjusted successfully',
                'employee' => $employee,
                'adjustment' => [
                    'previous_salary' => $previousSalary,
                    'new_salary' => $validated['new_base_salary'],
                    'adjustment_type' => $adjustmentType,
                    'adjustment_amount' => abs($adjustmentAmount)
                ]
            ]);
        } catch (\Exception $e) {
            \Log::error('Salary adjustment error: ' . $e->getMessage());
            return response()->json([
                'message' => 'Failed to adjust salary',
                'error' => $e->getMessage()
            ], 500);
        }
    }
}