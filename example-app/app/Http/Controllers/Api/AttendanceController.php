<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Attendance;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Log;
use Carbon\Carbon;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Validator;
use Barryvdh\DomPDF\Facade\Pdf;
use App\Models\Department;
use App\Models\Employee;
use Maatwebsite\Excel\Facades\Excel;
use App\Exports\AttendanceExport;

class AttendanceController extends Controller
{
    // Add these methods to your existing AttendanceController class

public function getAvailableYears()
{
    try {
        $years = Attendance::selectRaw('DISTINCT YEAR(date) as year')
                          ->orderBy('year', 'desc')
                          ->pluck('year');
                          
        // If no data exists, return current year and previous year
        if ($years->isEmpty()) {
            $currentYear = date('Y');
            $years = collect([$currentYear - 1, $currentYear]);
        }

        return response()->json($years);
    } catch (\Exception $e) {
        Log::error('Error getting available years: ' . $e->getMessage());
        return response()->json(['error' => 'Failed to fetch available years'], 500);
    }
}

public function getMonthlyRates(Request $request)
{
    try {
        $year = $request->query('year', date('Y'));
        $currentMonth = date('n');

        Log::info('Starting getMonthlyRates', [
            'year' => $year,
            'currentMonth' => $currentMonth
        ]);

        // Get all departments with their employee counts
        $departments = Department::withCount('employees')->get();
        $actualData = [];
        $predictedData = [];

        foreach ($departments as $dept) {
            $actualData[$dept->name] = array_fill(1, 12, 0);
            $predictedData[$dept->name] = array_fill(1, 12, 0);

            for ($month = 1; $month <= 12; $month++) {
                // Get working days in month (excluding weekends)
                $workingDays = $this->getWorkingDays($year, $month);
                
                // Total possible attendance = employees × working days
                $totalPossibleAttendance = $dept->employees_count * $workingDays;

                // Get actual attendance count for this department and month
                $actualAttendance = DB::table('attendances')
                    ->join('employees', 'attendances.employee_id', '=', 'employees.id')
                    ->where('employees.department_id', $dept->id)
                    ->whereYear('attendances.date', $year)
                    ->whereMonth('attendances.date', $month)
                    ->where('attendances.status', 'present')
                    ->count();

                // Calculate percentage: (actual attendance / total possible attendance) × 100
                $percentage = $totalPossibleAttendance > 0 
                    ? ($actualAttendance / $totalPossibleAttendance) * 100 
                    : 0;

                $actualData[$dept->name][$month] = round($percentage, 2);

                Log::info("Department: {$dept->name}, Month: {$month}", [
                    'employees' => $dept->employees_count,
                    'working_days' => $workingDays,
                    'possible_attendance' => $totalPossibleAttendance,
                    'actual_attendance' => $actualAttendance,
                    'percentage' => $percentage
                ]);
            }
        }

        // Generate predictions for future months
        foreach ($departments as $dept) {
            for ($month = $currentMonth + 1; $month <= 12; $month++) {
                // Use average of last 3 months for prediction
                $lastMonths = [];
                for ($i = 1; $i <= 3; $i++) {
                    $prevMonth = $month - $i;
                    if ($prevMonth > 0 && isset($actualData[$dept->name][$prevMonth])) {
                        $lastMonths[] = $actualData[$dept->name][$prevMonth];
                    }
                }

                if (count($lastMonths) > 0) {
                    $avg = array_sum($lastMonths) / count($lastMonths);
                    $variation = rand(-5, 5);
                    $predictedData[$dept->name][$month] = round(max(0, min(100, $avg + $variation)), 2);
                } else {
                    $predictedData[$dept->name][$month] = 75.00; // Default prediction
                }
            }
        }

        return response()->json([
            'actual' => $actualData,
            'predicted' => $predictedData,
            'currentMonth' => $currentMonth
        ]);

    } catch (\Exception $e) {
        Log::error('Error in getMonthlyRates: ' . $e->getMessage());
        Log::error('Stack trace: ' . $e->getTraceAsString());
        
        return response()->json([
            'error' => 'Failed to fetch monthly rates',
            'message' => $e->getMessage()
        ], 500);
    }
}

private function getWorkingDays($year, $month)
{
    $startDate = Carbon::create($year, $month, 1);
    $endDate = $startDate->copy()->endOfMonth();
    $workingDays = 0;

    while ($startDate <= $endDate) {
        // Check if it's not a weekend (1 = Monday, 7 = Sunday)
        if ($startDate->dayOfWeek !== Carbon::SATURDAY && $startDate->dayOfWeek !== Carbon::SUNDAY) {
            $workingDays++;
        }
        $startDate->addDay();
    }

    return $workingDays;
}
    public function getMonthlyAttendanceCounts()
    {
        try {
            $currentYear = request('year', date('Y'));
            Log::info('Fetching monthly counts for year: ' . $currentYear);
            
            $counts = DB::table('attendances')
                ->select(DB::raw('MONTH(date) as month'), DB::raw('COUNT(*) as count'))
                ->whereYear('date', $currentYear)
                ->groupBy(DB::raw('MONTH(date)'))
                ->get()
                ->pluck('count', 'month')
                ->toArray();

            // Initialize all months with zero
            $result = array_fill(1, 12, 0);
            
            // Update months that have records
            foreach ($counts as $month => $count) {
                $result[$month] = $count;
            }

            return response()->json($result);

        } catch (\Exception $e) {
            Log::error('Error getting monthly counts: ' . $e->getMessage());
            return response()->json([
                'error' => 'Failed to fetch monthly counts',
                'message' => $e->getMessage()
            ], 500);
        }
    }

    
public function getAttendance(Request $request)
{
    try {
        $validator = Validator::make($request->all(), [
            'year' => 'required|integer',
            'month' => 'required|integer',
            'status' => 'nullable|string|in:present,absent,late,on_leave',
            'department_id' => 'nullable|integer'
        ]);

        if ($validator->fails()) {
            return response()->json(['status' => 'error', 'message' => $validator->errors()], 400);
        }

        $query = Attendance::with(['employee.department'])
            ->whereYear('date', $request->year)
            ->whereMonth('date', $request->month);

        // Add department filter
        if ($request->department_id) {
            $query->whereHas('employee', function($q) use ($request) {
                $q->where('department_id', $request->department_id);
            });
        }

        $attendances = $query->get()->map(function ($attendance) {
            $timeIn = $attendance->time_in ? \Carbon\Carbon::parse($attendance->time_in)->format('H:i') : null;
            $timeOut = $attendance->time_out ? \Carbon\Carbon::parse($attendance->time_out)->format('H:i') : null;

            return [
                'id' => $attendance->id,
                'employee_id' => $attendance->employee ? $attendance->employee->employee_id : 'N/A',
                'employee_name' => $attendance->employee ? 
                    $attendance->employee->first_name . ' ' . $attendance->employee->last_name : 'Unknown',
                'department' => $attendance->employee?->department?->name ?? 'N/A',
                'date' => $attendance->date,
                'time_in' => $timeIn,
                'time_out' => $timeOut,
                'status' => $attendance->status
            ];
        });

        return response()->json(['status' => 'success', 'data' => $attendances]);
    } catch (\Exception $e) {
        Log::error('Error fetching attendance: ' . $e->getMessage());
        return response()->json(['status' => 'error', 'message' => 'Failed to fetch attendance records'], 500);
    }
}

    public function index(Request $request)
    {
        return $this->getAttendance($request);
    }

    public function getEmployeeAttendance(Request $request, $employee)
    {
        try {
            $attendance = Attendance::with('employee')
                ->where('employee_id', $employee)
                ->orderBy('date', 'desc')
                ->get();

            return response()->json([
                'status' => 'success',
                'data' => $attendance
            ]);
        } catch (\Exception $e) {
            Log::error('Error fetching employee attendance:', [
                'error' => $e->getMessage(),
                'trace' => $e->getTraceAsString()
            ]);

            return response()->json([
                'status' => 'error',
                'message' => 'Failed to fetch employee attendance records'
            ], 500);
        }
    }
   

    public function generateReport(Request $request)
    {
        try {
            $validator = Validator::make($request->all(), [
                'type' => 'required|string|in:monthly,status,employee',
                'month' => 'nullable|integer|min:1|max:12',
                'status' => 'nullable|string|in:present,absent,late,on_leave,all',
                'employeeId' => 'nullable|integer|exists:employees,id',
                'startDate' => 'required|date',
                'endDate' => 'required|date',
                'format' => 'required|string|in:pdf,excel,csv'
            ]);

            if ($validator->fails()) {
                return response()->json(['status' => 'error', 'message' => $validator->errors()], 400);
            }

            // Get report data
            $reportData = $this->generateReportData($request->all());

            // Generate report based on format
            switch ($request->format) {
                case 'pdf':
                    $pdf = PDF::loadView('reports.attendance', [
                        'type' => $request->type,
                        'month' => $request->month,
                        'year' => Carbon::now()->year,
                        'startDate' => $request->startDate,
                        'endDate' => $request->endDate,
                        'status' => $request->status,
                        'attendances' => $reportData,
                        'generatedAt' => Carbon::now()->format('M d, Y h:i A')
                    ]);
                    return $pdf->download('attendance_report.pdf');

                case 'excel':
                    return Excel::download(new AttendanceExport($reportData), 'attendance_report.xlsx');

                case 'csv':
                    return Excel::download(new AttendanceExport($reportData), 'attendance_report.csv');

                default:
                    return response()->json(['status' => 'error', 'message' => 'Unsupported format'], 400);
            }

        } catch (\Exception $e) {
            Log::error('Error generating report: ' . $e->getMessage());
            return response()->json(['status' => 'error', 'message' => 'Failed to generate report'], 500);
        }
    }


    
    private function generateReportData($params)
    {
        $query = Attendance::with(['employee'])
            ->whereBetween('date', [$params['startDate'], $params['endDate']]);

        if ($params['type'] === 'employee' && !empty($params['employeeId'])) {
            $query->where('employee_id', $params['employeeId']);
        }

        if (!empty($params['status']) && $params['status'] !== 'all') {
            $query->where('status', $params['status']);
        }

        return $query->orderBy('date', 'asc')->get();
    }
public function updateAttendance(Request $request, $id)
{
    try {
        $validator = Validator::make($request->all(), [
            'time_in' => 'nullable|date_format:H:i',
            'time_out' => 'nullable|date_format:H:i',
            'status' => 'required|string|in:present,absent,late,on_leave'
        ]);

        if ($validator->fails()) {
            return response()->json(['status' => 'error', 'message' => $validator->errors()], 400);
        }

        $attendance = Attendance::findOrFail($id);

        if ($request->status === 'absent' || $request->status === 'on_leave') {
            $attendance->time_in = null;
            $attendance->time_out = null;
        } else {
            $attendance->time_in = $request->time_in;
            $attendance->time_out = $request->time_out;
        }

        $attendance->status = $request->status;
        $attendance->save();

        return response()->json(['status' => 'success', 'attendance' => $attendance]);
    } catch (\Exception $e) {
        Log::error('Error updating attendance: ' . $e->getMessage());
        return response()->json(['status' => 'error', 'message' => 'Failed to update attendance record'], 500);
    }
    }

    public function getMonthlyAttendanceRates(Request $request)
    {
        try {
            $year = $request->query('year', Carbon::now()->year);
            $currentMonth = Carbon::now()->month;
            $departments = Department::all();
            $actualRates = [];
            $predictedRates = [];
    
            Log::info('Fetching monthly attendance rates for year: ' . $year);
    
            foreach ($departments as $department) {
                $actual = [];
                $predicted = [];
                
                // Get actual data up to current month
                for ($month = 1; $month <= $currentMonth; $month++) {
                    $monthName = Carbon::create()->month($month)->format('F');
                    
                    $totalDays = DB::table('attendances')
                        ->join('employees', 'attendances.employee_id', '=', 'employees.id')
                        ->where('employees.department_id', $department->id)
                        ->whereYear('attendances.date', $year)
                        ->whereMonth('attendances.date', $month)
                        ->count();
    
                    $presentDays = DB::table('attendances')
                        ->join('employees', 'attendances.employee_id', '=', 'employees.id')
                        ->where('employees.department_id', $department->id)
                        ->whereYear('attendances.date', $year)
                        ->whereMonth('attendances.date', $month)
                        ->where('attendances.status', 'present')
                        ->count();
    
                    Log::info("Department: {$department->name}, Month: {$monthName}, Total Days: {$totalDays}, Present Days: {$presentDays}");
    
                    $rate = $totalDays > 0 ? ($presentDays / $totalDays) * 100 : 0;
                    $actual[$monthName] = round($rate, 2);
                    $predicted[$monthName] = round($rate, 2); // Use actual data for past months
                }
    
                // Calculate predictions from current month onwards
                for ($month = $currentMonth; $month <= 12; $month++) {
                    $monthName = Carbon::create()->month($month)->format('F');
                    
                    // Get last 3 months of actual data for prediction
                    $historicalRates = [];
                    for ($i = 1; $i <= 3; $i++) {
                        $pastMonth = $month - $i;
                        if ($pastMonth > 0) {
                            $pastMonthName = Carbon::create()->month($pastMonth)->format('F');
                            $historicalRates[] = $actual[$pastMonthName] ?? null;
                        }
                    }
                    
                    // Remove null values
                    $historicalRates = array_filter($historicalRates, function($value) {
                        return $value !== null;
                    });
    
                    if (count($historicalRates) > 0) {
                        // Calculate prediction
                        $avgRate = array_sum($historicalRates) / count($historicalRates);
                        $trend = 0;
                        
                        if (count($historicalRates) >= 2) {
                            $trend = end($historicalRates) - reset($historicalRates);
                        }
    
                        // Calculate prediction with trend and seasonal factors
                        $monthsAhead = $month - $currentMonth + 1;
                        $prediction = $avgRate + ($trend * 0.3 * $monthsAhead); // Reduced trend impact
                        
                        // Add seasonal variation
                        $seasonalFactor = sin(($month - 1) * pi() / 6) * 1.5; // Reduced seasonal impact
                        $prediction += $seasonalFactor;
                        
                        // Add small random variation
                        $variation = rand(-1, 1);
                        $prediction = max(0, min(100, $prediction + $variation));
                        
                        $predicted[$monthName] = round($prediction, 2);
                    } else {
                        // Fallback using department's average if no historical data
                        $departmentAvg = array_sum($actual) / count($actual);
                        $predicted[$monthName] = round($departmentAvg, 2);
                    }
                }
    
                $actualRates[$department->name] = $actual;
                $predictedRates[$department->name] = $predicted;
            }
    
            Log::info('Final actual rates:', $actualRates);
            Log::info('Final predicted rates:', $predictedRates);
    
            return response()->json([
                'actual' => $actualRates,
                'predicted' => $predictedRates,
                'currentMonth' => $currentMonth
            ]);
    
        } catch (\Exception $e) {
            Log::error('Error getting monthly attendance rates: ' . $e->getMessage());
            return response()->json(['error' => 'Failed to fetch attendance rates'], 500);
        }
    }

    public function markManualAttendance(Request $request)
    {
        try {
            // Modify validation rules based on status
            $baseRules = [
                'employee_id' => 'required|exists:employees,id',
                'date' => 'required|date',
                'status' => 'required|in:present,absent,late,on_leave',
                'isNightShift' => 'boolean'
            ];

            // Add time validation only for present and late status
            if (in_array($request->status, ['present', 'late'])) {
                $baseRules['time_in'] = 'required';
                $baseRules['time_out'] = 'required';
            }

            $validator = Validator::make($request->all(), $baseRules);

            if ($validator->fails()) {
                return response()->json([
                    'status' => 'error',
                    'message' => $validator->errors()
                ], 400);
            }

            // Check for existing attendance on the same date
            $existingAttendance = Attendance::where('employee_id', $request->employee_id)
                ->whereDate('date', $request->date)
                ->first();

            if ($existingAttendance) {
                return response()->json([
                    'status' => 'error',
                    'message' => 'Employee already has an attendance record for this date'
                ], 400);
            }

            // Create attendance record
            $attendance = new Attendance();
            $attendance->employee_id = $request->employee_id;
            $attendance->date = $request->date;
            $attendance->status = $request->status;
            
            // Only set time fields for present/late status
            if (in_array($request->status, ['present', 'late'])) {
                $attendance->time_in = $request->date . ' ' . $request->time_in;
                $attendance->time_out = $request->isNightShift 
                    ? date('Y-m-d', strtotime($request->date . ' +1 day')) . ' ' . $request->time_out
                    : $request->date . ' ' . $request->time_out;
                $attendance->is_night_shift = $request->isNightShift;
            } else {
                $attendance->time_in = null;
                $attendance->time_out = null;
                $attendance->is_night_shift = false;
            }

            $attendance->save();

            return response()->json([
                'status' => 'success',
                'message' => 'Attendance recorded successfully',
                'data' => $attendance
            ]);

        } catch (\Exception $e) {
            Log::error('Error marking manual attendance: ' . $e->getMessage());
            return response()->json([
                'status' => 'error',
                'message' => 'Failed to record attendance: ' . $e->getMessage()
            ], 500);
        }
    }

    public function getHistory(Request $request)
    {
        try {
            Log::info('Web attendance history request:', $request->all());

            $validator = Validator::make($request->all(), [
                'year' => 'required|integer',
                'month' => 'required|integer|between:1,12',
                'department_id' => 'nullable|integer|exists:departments,id'
            ]);

            if ($validator->fails()) {
                Log::warning('Validation failed:', $validator->errors()->toArray());
                return response()->json([
                    'status' => 'error',
                    'message' => $validator->errors()
                ], 400);
            }

            // Build the query
            $query = Attendance::with(['employee.department'])
                ->whereYear('date', $request->year)
                ->whereMonth('date', $request->month);

            // Add department filter if provided
            if ($request->department_id) {
                $query->whereHas('employee', function($q) use ($request) {
                    $q->where('department_id', $request->department_id);
                });
            }

            // Get the attendance records
            $attendances = $query->get();
            
            $formattedAttendances = $attendances->map(function ($attendance) {
                return [
                    'id' => $attendance->id,
                    'employeeId' => $attendance->employee->employee_id ?? 'N/A',
                    'name' => $attendance->employee 
                        ? $attendance->employee->first_name . ' ' . $attendance->employee->last_name 
                        : 'Unknown',
                    'department' => $attendance->employee->department->name ?? 'Unknown',
                    'date' => $attendance->date->format('Y-m-d'),
                    'timeIn' => $attendance->time_in ? Carbon::parse($attendance->time_in)->format('H:i') : null,
                    'timeOut' => $attendance->time_out ? Carbon::parse($attendance->time_out)->format('H:i') : null,
                    'status' => $attendance->status
                ];
            });

            Log::info('Attendance records found:', ['count' => $attendances->count()]);

            return response()->json([
                'status' => 'success',
                'data' => $formattedAttendances
            ]);

        } catch (\Exception $e) {
            Log::error('Error fetching attendance history:', [
                'error' => $e->getMessage(),
                'trace' => $e->getTraceAsString()
            ]);

            return response()->json([
                'status' => 'error',
                'message' => 'Failed to fetch attendance records'
            ], 500);
        }
    }

    public function getAttendanceHistory(Request $request)
    {
        try {
            $validator = Validator::make($request->all(), [
                'employee_id' => 'required|exists:employees,id',
                'year' => 'required|integer',
                'month' => 'required|integer|between:1,12'
            ]);

            if ($validator->fails()) {
                return response()->json([
                    'status' => 'error',
                    'message' => $validator->errors()
                ], 400);
            }

            $attendances = Attendance::where('employee_id', $request->employee_id)
                ->whereYear('date', $request->year)
                ->whereMonth('date', $request->month)
                ->orderBy('date', 'desc')
                ->get()
                ->map(function ($attendance) {
                    return [
                        'id' => $attendance->id,
                        'date' => $attendance->date,
                        'time_in' => $attendance->time_in,
                        'time_out' => $attendance->time_out,
                        'status' => $attendance->status,
                        'is_night_shift' => $attendance->is_night_shift
                    ];
                });

            return response()->json([
                'status' => 'success',
                'data' => $attendances
            ]);

        } catch (\Exception $e) {
            Log::error('Error fetching attendance history:', [
                'error' => $e->getMessage(),
                'trace' => $e->getTraceAsString()
            ]);

            return response()->json([
                'status' => 'error',
                'message' => 'Failed to fetch attendance records'
            ], 500);
        }
    }

    public function markAttendance(Request $request)
    {
        try {
            Log::info('Attendance mark attempt', [
                'employee_id' => $request->employee_id,
                'type' => $request->type,
                'time' => $request->time
            ]);

            $validator = Validator::make($request->all(), [
                'employee_id' => 'required|string',
                'type' => 'required|in:in,out',
                'time' => 'required|date'
            ]);

            if ($validator->fails()) {
                Log::warning('Attendance validation failed', [
                    'errors' => $validator->errors()->toArray()
                ]);
                return response()->json([
                    'message' => 'Validation error',
                    'errors' => $validator->errors()
                ], 400);
            }

            $employee = Employee::where('employee_id', $request->employee_id)->first();
            $today = Carbon::today();

            // Check if there's already an attendance record for today
            $existingAttendance = Attendance::where('employee_id', $employee->id)
                ->whereDate('date', $today)
                ->first();

            if ($request->type === 'in') {
                if ($existingAttendance && $existingAttendance->time_in) {
                    return response()->json([
                        'message' => 'Already timed in for today',
                        'last_time_in' => $existingAttendance->time_in->format('h:i A')
                    ], 400);
                }

                // Check last attendance record for 14-hour rule
                $lastAttendance = Attendance::where('employee_id', $employee->id)
                    ->where('id', '!=', $existingAttendance?->id ?? 0)
                    ->orderBy('date', 'desc')
                    ->orderBy('time_in', 'desc')
                    ->first();

                if ($lastAttendance) {
                    $hoursSinceLastAttendance = Carbon::parse($lastAttendance->time_out ?? $lastAttendance->time_in)
                        ->diffInHours(Carbon::now());

                    if ($hoursSinceLastAttendance < 14) {
                        return response()->json([
                            'message' => 'You can only time in after 14 hours from your last attendance',
                            'hours_remaining' => 14 - $hoursSinceLastAttendance
                        ], 400);
                    }
                }

                $attendance = $existingAttendance ?? new Attendance([
                    'employee_id' => $employee->id,
                    'date' => $today,
                    'status' => 'present'
                ]);
                
                $attendance->time_in = $request->time;
                $attendance->save();

                Log::info('Time in recorded', [
                    'employee_id' => $employee->id,
                    'attendance_id' => $attendance->id,
                    'time' => $request->time
                ]);
            } else {
                if (!$existingAttendance || !$existingAttendance->time_in) {
                    return response()->json([
                        'message' => 'Must time in first'
                    ], 400);
                }

                if ($existingAttendance->time_out) {
                    return response()->json([
                        'message' => 'Already timed out for today'
                    ], 400);
                }

                $existingAttendance->update([
                    'time_out' => $request->time
                ]);

                Log::info('Time out recorded', [
                    'employee_id' => $employee->id,
                    'attendance_id' => $existingAttendance->id,
                    'time' => $request->time
                ]);
            }

            return response()->json(['message' => 'Attendance marked successfully']);
        } catch (\Exception $e) {
            Log::error('Error marking attendance', [
                'error' => $e->getMessage(),
                'employee_id' => $request->employee_id ?? null,
                'type' => $request->type ?? null
            ]);
            return response()->json(['message' => 'Failed to mark attendance'], 500);
        }
    }

    // Add this method to check current attendance status
    public function getCurrentStatus(Request $request)
    {
        try {
            $validator = Validator::make($request->query(), [
                'employee_id' => 'required|string|exists:employees,employee_id'
            ]);

            if ($validator->fails()) {
                return response()->json([
                    'status' => 'error',
                    'message' => $validator->errors()
                ], 400);
            }

            $employee = Employee::where('employee_id', $request->employee_id)->first();
            $today = Carbon::now()->toDateString();

            $attendance = Attendance::where('employee_id', $employee->id)
                ->whereDate('date', $today)
                ->first();

            $canTimeOut = false;
            if ($attendance && $attendance->time_in && !$attendance->time_out) {
                $minutesSinceTimeIn = Carbon::parse($attendance->time_in)->diffInMinutes(Carbon::now());
                Log::info('Time since clock in:', [
                    'minutes' => $minutesSinceTimeIn,
                    'time_in' => $attendance->time_in,
                    'current_time' => Carbon::now()
                ]);
                $canTimeOut = $minutesSinceTimeIn >= 1; // Change to 60 for 1 hour
            }

            return response()->json([
                'data' => [
                    'last_time_in' => $attendance?->time_in?->format('h:i A'),
                    'last_time_out' => $attendance?->time_out?->format('h:i A'),
                    'can_time_in' => !$attendance || ($attendance->time_in && $attendance->time_out),
                    'can_time_out' => $canTimeOut,
                    'minutes_since_in' => $attendance && $attendance->time_in ? Carbon::parse($attendance->time_in)->diffInMinutes(Carbon::now()) : 0
                ]
            ]);

        } catch (\Exception $e) {
            Log::error('Error getting current status', [
                'error' => $e->getMessage(),
                'employee_id' => $request->employee_id ?? null
            ]);
            return response()->json([
                'message' => 'Failed to get current status'
            ], 500);
        }
    }

    public function getDepartmentSalaries(Request $request)
{
    try {
        $year = $request->query('year', date('Y'));
        $month = $request->query('month', date('n'));

        Log::info('getDepartmentSalaries method called', ['year' => $year, 'month' => $month]);
        
        $query = DB::table('departments as d')
            ->leftJoin('employees as e', 'd.id', '=', 'e.department_id')
            ->leftJoin('attendances as a', function($join) use ($year, $month) {
                $join->on('e.id', '=', 'a.employee_id')
                    ->whereMonth('a.date', '=', $month)
                    ->whereYear('a.date', '=', $year);
            })
            ->select(
                'd.name',
                DB::raw('SUM(
                    CASE 
                        WHEN a.status IN ("present", "late") 
                        THEN e.base_salary * (
                            TIMESTAMPDIFF(HOUR, a.time_in, a.time_out)
                        )
                        ELSE 0 
                    END
                ) as total_salary')
            )
            ->groupBy('d.id', 'd.name');

        Log::info('Query:', ['sql' => $query->toSql(), 'bindings' => $query->getBindings()]);
        
        $departmentSalaries = $query->get();

        Log::info('Department salaries calculated:', ['data' => $departmentSalaries]);
        return response()->json($departmentSalaries);
    } catch (\Exception $e) {
        Log::error('Error calculating department salaries: ' . $e->getMessage());
        Log::error('Stack trace: ' . $e->getTraceAsString());
        return response()->json(['error' => 'Failed to fetch salary distribution'], 500);
    }
}

public function getDashboardStats()
{
    try {
        // Get total positions
        $totalPositions = DB::table('positions')->count();

        // Get current month attendance percentage
        $currentMonth = now()->month;
        $currentYear = now()->year;
        
        $totalPossibleAttendance = DB::table('employees')
            ->where('status', 'active')
            ->count() * now()->daysInMonth;
            
        $actualAttendance = DB::table('attendances')
            ->whereMonth('date', $currentMonth)
            ->whereYear('date', $currentYear)
            ->where('status', 'present')
            ->count();
            
        $attendancePercentage = $totalPossibleAttendance > 0 
            ? round(($actualAttendance / $totalPossibleAttendance) * 100, 2)
            : 0;

        // Get total monthly salary distribution
        $totalMonthlySalary = DB::table('departments as d')
            ->leftJoin('employees as e', 'd.id', '=', 'e.department_id')
            ->leftJoin('attendances as a', function($join) use ($currentMonth, $currentYear) {
                $join->on('e.id', '=', 'a.employee_id')
                    ->whereMonth('a.date', '=', $currentMonth)
                    ->whereYear('a.date', '=', $currentYear);
            })
            ->where('e.status', 'active')
            ->sum(DB::raw('
                CASE 
                    WHEN a.status IN ("present", "late") 
                    THEN e.base_salary * (
                        TIMESTAMPDIFF(HOUR, a.time_in, a.time_out)
                    )
                    ELSE 0 
                END
            '));

        // Get total departments count
        $totalDepartments = DB::table('departments')->count();

        // Get highest paid employee info
        $highestPaidEmployee = DB::table('employees as e')
            ->join('departments as d', 'e.department_id', '=', 'd.id')
            ->where('e.status', 'active')
            ->select('e.first_name', 'e.last_name', 'd.name as department', 'e.base_salary')
            ->orderBy('e.base_salary', 'desc')
            ->first();

        return response()->json([
            'total_positions' => $totalPositions,
            'current_month_attendance' => $attendancePercentage,
            'total_monthly_salary' => $totalMonthlySalary,
            'total_departments' => $totalDepartments,
            'highest_paid_employee' => [
                'name' => $highestPaidEmployee ? $highestPaidEmployee->first_name . ' ' . $highestPaidEmployee->last_name : 'N/A',
                'department' => $highestPaidEmployee ? $highestPaidEmployee->department : 'N/A',
                'salary' => $highestPaidEmployee ? $highestPaidEmployee->base_salary : 0
            ]
        ]);
    } catch (\Exception $e) {
        Log::error('Error getting dashboard stats: ' . $e->getMessage());
        return response()->json([
            'error' => 'Failed to fetch dashboard stats',
            'total_positions' => 0,
            'current_month_attendance' => 0,
            'total_monthly_salary' => 0,
            'total_departments' => 0,
            'highest_paid_employee' => [
                'name' => 'N/A',
                'department' => 'N/A',
                'salary' => 0
            ]
        ], 500);
    }
}

// Add this new method for mobile attendance history
public function getMobileHistory(Request $request)
{
    try {
        Log::info('Fetching mobile attendance history', [
            'employee_id' => $request->employee_id
        ]);

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
        
        $attendances = Attendance::where('employee_id', $employee->id)
            ->orderBy('date', 'desc')
            ->take(30)
            ->get()
            ->map(function ($attendance) {
                return [
                    'date' => $attendance->date->format('Y-m-d'),
                    'time_in' => $attendance->time_in?->format('h:i A'),
                    'time_out' => $attendance->time_out?->format('h:i A'),
                    'status' => $attendance->status,
                    'is_night_shift' => $attendance->is_night_shift
                ];
            });

        Log::info('Mobile attendance records found', [
            'count' => $attendances->count()
        ]);

        return response()->json([
            'data' => $attendances->values()->all()
        ]);

    } catch (\Exception $e) {
        Log::error('Error fetching mobile attendance history', [
            'error' => $e->getMessage(),
            'employee_id' => $request->employee_id ?? null
        ]);
        return response()->json([
            'message' => 'Failed to fetch attendance history'
        ], 500);
    }
}
}