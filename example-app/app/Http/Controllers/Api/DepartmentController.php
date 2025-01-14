<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Requests\DepartmentRequest;
use App\Models\Department;
use App\Models\Position;
use Illuminate\Http\Request;
use Illuminate\Http\Response;
use Illuminate\Support\Facades\Log;

class DepartmentController extends Controller
{
    public function index(Request $request)
    {
        try {
            $departments = Department::with(['positions', 'employees'])
                ->when($request->search, function($query) use ($request) {
                    $query->where('name', 'like', "%{$request->search}%")
                        ->orWhere('code', 'like', "%{$request->search}%");
                })
                ->orderBy($request->sort_by ?? 'name', $request->sort_order ?? 'asc')
                ->get();

            $formattedDepartments = $departments->map(function($department) {
                return [
                    'id' => $department->id,
                    'name' => $department->name,
                    'code' => $department->code,
                    'positions' => $department->positions ?? [],
                    'employees' => $department->employees ?? [],
                    'employee_count' => $department->employees->count(),
                    'created_at' => $department->created_at,
                    'updated_at' => $department->updated_at
                ];
            });

            return response()->json(['data' => $formattedDepartments]);
        } catch (\Exception $e) {
            Log::error('Error fetching departments: ' . $e->getMessage());
            return response()->json([
                'message' => 'Failed to fetch departments',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    public function positions($id)
    {
        $department = Department::findOrFail($id);
        return response()->json($department->positions);
    }

    public function store(DepartmentRequest $request)
    {
        $department = Department::create($request->validated());
        return response()->json($department, Response::HTTP_CREATED);
    }

    public function show(Department $department)
    {
        return response()->json($department->load([
            'employees' => function($query) {
                $query->where('status', 'active');
            }
        ]));
    }

    public function getEmployeeCounts()
    {
        try {
            $departments = Department::select('departments.id', 'departments.name')
                ->leftJoin('employees', function($join) {
                    $join->on('departments.id', '=', 'employees.department_id')
                        ->whereNull('employees.deleted_at');
                })
                ->groupBy('departments.id', 'departments.name')
                ->selectRaw('
                    COUNT(DISTINCT CASE WHEN employees.status = "active" THEN employees.id END) as active_count,
                    COUNT(DISTINCT CASE WHEN employees.status = "inactive" THEN employees.id END) as inactive_count,
                    COUNT(DISTINCT CASE WHEN employees.status = "on_leave" THEN employees.id END) as on_leave_count,
                    COUNT(DISTINCT employees.id) as total_count
                ')
                ->orderBy('departments.name')
                ->get()
                ->map(function($department) {
                    return [
                        'id' => $department->id,
                        'name' => $department->name,
                        'active_count' => (int)$department->active_count,
                        'inactive_count' => (int)$department->inactive_count,
                        'on_leave_count' => (int)$department->on_leave_count,
                        'total_count' => (int)$department->total_count
                    ];
                });

            return response()->json($departments);
        } catch (\Exception $e) {
            Log::error('Error getting department counts: ' . $e->getMessage());
            Log::error($e->getTraceAsString());
            return response()->json([
                'message' => 'Failed to fetch department data',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    public function getPositions($departmentId)
    {
        try {
            $positions = Position::where('department_id', $departmentId)
                ->where('status', 'Active')
                ->get(['id', 'title', 'base_salary']);

            return response()->json($positions);
        } catch (\Exception $e) {
            Log::error('Error getting positions: ' . $e->getMessage());
            return response()->json([
                'message' => 'Failed to fetch positions',
                'error' => $e->getMessage()
            ], 500);
        }
    }
}