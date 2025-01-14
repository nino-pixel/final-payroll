<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Facades\Schema;

class ReportController extends Controller
{
    public function getDashboardStats(Request $request)
    {
        try {
            $year = $request->year ?? date('Y');
            $month = $request->month ?? date('m');
            $query = DB::table('employees as e')
                ->join('departments as d', 'e.department_id', '=', 'd.id');

            if ($request->department) {
                $query->where('d.name', $request->department);
            }
            if ($request->employee_id) {
                $query->where('e.id', $request->employee_id);
            }

            // Get employee stats by status
            $employeeStats = DB::table('employees as e')
                ->join('departments as d', 'e.department_id', '=', 'd.id')
                ->select(
                    DB::raw('COUNT(*) as totalEmployees'),
                    DB::raw('SUM(CASE WHEN e.status = "active" THEN 1 ELSE 0 END) as activeEmployees'),
                    DB::raw('SUM(CASE WHEN e.status = "inactive" THEN 1 ELSE 0 END) as inactiveEmployees'),
                    DB::raw('SUM(CASE WHEN e.status = "on_leave" THEN 1 ELSE 0 END) as onLeaveEmployees')
                )
                ->when($request->department, function($query) use ($request) {
                    return $query->where('d.name', $request->department);
                })
                ->when($request->employee_id, function($query) use ($request) {
                    return $query->where('e.id', $request->employee_id);
                })
                ->first();

            // Calculate total monthly earnings and deductions
            $employees = $query->select(
                'e.base_salary',
                'e.status'
            )->get();

            $monthlyTotalPayroll = 0;
            $totalDeductions = 0;
            $activeCount = 0;

            foreach ($employees as $employee) {
                if ($employee->status !== 'active') {
                    continue;
                }

                $activeCount++;
                $baseSalary = $employee->base_salary;

                // Calculate monthly earnings
                $monthlyEarnings = $this->calculateMonthlyEarnings($baseSalary);
                $monthlyTotalPayroll += $monthlyEarnings;

                // Calculate monthly deductions
                $deductions = $this->calculateDeductions($baseSalary);
                $totalDeductions += $deductions;
            }

            // Calculate average salary for active employees
            $averageSalary = $activeCount > 0 ? $monthlyTotalPayroll / $activeCount : 0;

            return response()->json([
                'totalPayroll' => round($monthlyTotalPayroll, 2),
                'period' => 'monthly',
                'month' => $month,
                'year' => $year,
                'totalEmployees' => $employeeStats->totalEmployees,
                'activeEmployees' => $employeeStats->activeEmployees,
                'inactiveEmployees' => $employeeStats->inactiveEmployees,
                'onLeaveEmployees' => $employeeStats->onLeaveEmployees,
                'averageSalary' => round($averageSalary, 2),
                'totalDeductions' => round($totalDeductions, 2)
            ]);

        } catch (\Exception $e) {
            Log::error('Dashboard Stats Error: ' . $e->getMessage());
            return response()->json(['error' => 'Error fetching dashboard statistics'], 500);
        }
    }

    private function calculateMonthlyEarnings($hourlyRate)
    {
        try {
            $year = date('Y');

            // Fix table name from 'attendance' to 'attendances'
            $attendance = DB::table('attendances')
                ->join('employees', 'attendances.employee_id', '=', 'employees.id')
                ->where('employees.base_salary', $hourlyRate)
                ->whereYear('attendances.date', $year)
                ->select(
                    DB::raw('SUM(CASE 
                        WHEN TIMESTAMPDIFF(HOUR, time_in, time_out) <= 8 
                        THEN TIMESTAMPDIFF(HOUR, time_in, time_out)
                        ELSE 8 
                    END) as regular_hours'),
                    
                    // Overtime hours (beyond 8 hours)
                    DB::raw('SUM(CASE 
                        WHEN TIMESTAMPDIFF(HOUR, time_in, time_out) > 8 
                        THEN TIMESTAMPDIFF(HOUR, time_in, time_out) - 8 
                        ELSE 0 
                    END) as overtime_hours'),
                    
                    // Weekend days
                    DB::raw('COUNT(CASE 
                        WHEN DAYNAME(date) IN ("Sunday", "Saturday") 
                        THEN 1 
                    END) as weekend_days'),
                    
                    // Total days worked
                    DB::raw('COUNT(DISTINCT date) as days_worked')
                )
                ->first();

            if (!$attendance) {
                return 0;
            }

            // Calculate different types of pay
            $regularPay = $attendance->regular_hours * $hourlyRate;
            $overtimePay = $attendance->overtime_hours * ($hourlyRate * 1.25); // 25% overtime premium
            
            // Weekend/Rest Day Pay (30% premium)
            $weekendHours = $attendance->weekend_days * 8; // Assuming 8 hours per weekend day
            $weekendPay = $weekendHours * ($hourlyRate * 1.30);
            
            // Calculate total earnings
            $totalEarnings = $regularPay + $overtimePay + $weekendPay;

            return $totalEarnings;

        } catch (\Exception $e) {
            Log::error('Error calculating monthly earnings: ' . $e->getMessage());
            return 0;
        }
    }

    private function calculateDeductions($baseSalary)
    {
        try {
            // Get monthly earnings first
            $monthlyEarnings = $this->calculateMonthlyEarnings($baseSalary);
            $totalDeductions = 0;

            // SSS Contribution based on monthly earnings
            if ($monthlyEarnings <= 3250) {
                $sssDeduction = 135;
            } elseif ($monthlyEarnings > 24750) {
                $sssDeduction = 1125;
            } else {
                $sssDeduction = ceil(($monthlyEarnings * 0.045) / 5) * 5;
            }
            $totalDeductions += $sssDeduction;

            // PhilHealth Contribution
            if ($monthlyEarnings <= 10000) {
                $philhealthDeduction = 400;
            } elseif ($monthlyEarnings >= 80000) {
                $philhealthDeduction = 3200;
            } else {
                $philhealthDeduction = $monthlyEarnings * 0.04;
            }
            $totalDeductions += $philhealthDeduction;

            // Pag-IBIG Contribution
            if ($monthlyEarnings > 1500) {
                $pagibigDeduction = min($monthlyEarnings * 0.02, 100);
            } else {
                $pagibigDeduction = $monthlyEarnings * 0.01;
            }
            $totalDeductions += $pagibigDeduction;

            // Withholding Tax based on annual projection
            $annualProjection = $monthlyEarnings * 12;
            $monthlyTax = 0;

            if ($annualProjection > 250000) {
                if ($annualProjection <= 400000) {
                    $monthlyTax = (($annualProjection - 250000) * 0.15) / 12;
                } elseif ($annualProjection <= 800000) {
                    $monthlyTax = ((150000 * 0.15) + ($annualProjection - 400000) * 0.20) / 12;
                } elseif ($annualProjection <= 2000000) {
                    $monthlyTax = ((150000 * 0.15) + (400000 * 0.20) + ($annualProjection - 800000) * 0.25) / 12;
                } elseif ($annualProjection <= 8000000) {
                    $monthlyTax = ((150000 * 0.15) + (400000 * 0.20) + (1200000 * 0.25) + ($annualProjection - 2000000) * 0.30) / 12;
                } else {
                    $monthlyTax = ((150000 * 0.15) + (400000 * 0.20) + (1200000 * 0.25) + (6000000 * 0.30) + ($annualProjection - 8000000) * 0.35) / 12;
                }
            }
            $totalDeductions += $monthlyTax;

            return $totalDeductions;

        } catch (\Exception $e) {
            Log::error('Error calculating deductions: ' . $e->getMessage());
            return 0;
        }
    }

    public function getTaxReport(Request $request)
    {
        try {
            $year = $request->year ?? date('Y');
            $query = DB::table('employees as e')
                ->join('departments as d', 'e.department_id', '=', 'd.id')
                ->where('e.status', 'active');

            // Apply filters
            if ($request->department) {
                $query->where('d.name', $request->department);
            }
            if ($request->employee_id) {
                $query->where('e.id', $request->employee_id);
            }

            // Get employee earnings for the selected year
            $employeeEarnings = DB::table('attendances')
                ->join('employees', 'attendances.employee_id', '=', 'employees.id')
                ->join('departments', 'employees.department_id', '=', 'departments.id')
                ->whereYear('attendances.date', $year)
                ->when($request->department, function($query) use ($request) {
                    return $query->where('departments.name', $request->department);
                })
                ->when($request->employee_id, function($query) use ($request) {
                    return $query->where('employees.id', $request->employee_id);
                })
                ->select(
                    'employees.id',
                    'employees.base_salary',
                    'employees.first_name',
                    'employees.last_name',
                    'departments.name as department',
                    DB::raw('SUM(CASE 
                        WHEN TIMESTAMPDIFF(HOUR, time_in, time_out) <= 8 
                        THEN TIMESTAMPDIFF(HOUR, time_in, time_out)
                        ELSE 8 
                    END) * employees.base_salary as total_earnings')
                )
                ->groupBy('employees.id', 'employees.base_salary', 'employees.first_name', 
                         'employees.last_name', 'departments.name')
                ->get();

            // Handle case when no earnings data is found
            if ($employeeEarnings->isEmpty()) {
                return response()->json([
                    'brackets' => $this->getEmptyBrackets(),
                    'deductions' => [
                        ['type' => 'SSS', 'amount' => 0, 'percentage' => 0],
                        ['type' => 'PhilHealth', 'amount' => 0, 'percentage' => 0],
                        ['type' => 'Pag-IBIG', 'amount' => 0, 'percentage' => 0],
                        ['type' => 'Withholding Tax', 'amount' => 0, 'percentage' => 0]
                    ],
                    'totalMonthlyPayroll' => 0
                ]);
            }

            // Calculate tax brackets based on annual salary (2024 PH Tax Table)
            $brackets = [
                [
                    'name' => '0%',
                    'range' => '₱' . number_format(0) . ' - ₱' . number_format(250000),
                    'min' => 0,
                    'max' => 250000,
                    'rate' => 0
                ],
                [
                    'name' => '15%',
                    'range' => '₱' . number_format(250001) . ' - ₱' . number_format(400000),
                    'min' => 250001,
                    'max' => 400000,
                    'rate' => 0.15
                ],
                [
                    'name' => '20%',
                    'range' => '₱400,001 - ₱800,000',
                    'min' => 400001,
                    'max' => 800000,
                    'rate' => 0.20
                ],
                [
                    'name' => '25%',
                    'range' => '₱800,001 - ₱2,000,000',
                    'min' => 800001,
                    'max' => 2000000,
                    'rate' => 0.25
                ],
                [
                    'name' => '30%',
                    'range' => '₱2,000,001 - ₱8,000,000',
                    'min' => 2000001,
                    'max' => 8000000,
                    'rate' => 0.30
                ],
                [
                    'name' => '35%',
                    'range' => 'Over ₱8,000,000',
                    'min' => 8000001,
                    'max' => PHP_FLOAT_MAX,
                    'rate' => 0.35
                ]
            ];

            $totalEmployees = $employeeEarnings->count();
            foreach ($brackets as &$bracket) {
                $employeesInBracket = $employeeEarnings->filter(function($e) use ($bracket) {
                    $annualProjection = $e->total_earnings * 12;
                    return $annualProjection >= $bracket['min'] && $annualProjection <= $bracket['max'];
                })->count();
                
                $bracket['employees'] = $employeesInBracket;
                $bracket['percentage'] = $totalEmployees > 0 
                    ? round(($employeesInBracket / $totalEmployees) * 100, 2) 
                    : 0;
            }

            // Calculate statutory deductions for the selected year
            $deductions = [];
            $totalMonthlyPayroll = $employeeEarnings->sum('total_earnings');

            // SSS Contribution (2024 rates)
            $sssTotal = 0;
            foreach ($employeeEarnings as $employee) {
                $monthlyEarnings = $employee->total_earnings;
                // SSS Table computation
                if ($monthlyEarnings <= 3250) {
                    $sssTotal += 135;
                } elseif ($monthlyEarnings > 24750) {
                    $sssTotal += 1125; // Maximum contribution
                } else {
                    // Compute based on salary range
                    $sssTotal += ceil(($monthlyEarnings * 0.045) / 5) * 5;
                }
            }
            $deductions[] = [
                'type' => 'SSS',
                'amount' => $sssTotal,
                'percentage' => round(($sssTotal / $totalMonthlyPayroll) * 100, 2)
            ];

            // PhilHealth Contribution (2024 rates - 4% of monthly basic salary)
            $philhealthTotal = $employeeEarnings->sum(function($employee) {
                $monthlyEarnings = $employee->total_earnings;
                if ($monthlyEarnings <= 10000) {
                    return 400; // Minimum contribution
                } elseif ($monthlyEarnings >= 80000) {
                    return 3200; // Maximum contribution
                }
                return $monthlyEarnings * 0.04;
            });
            $deductions[] = [
                'type' => 'PhilHealth',
                'amount' => $philhealthTotal,
                'percentage' => round(($philhealthTotal / $totalMonthlyPayroll) * 100, 2)
            ];

            // Pag-IBIG Contribution (2024 rates)
            $pagibigTotal = $employeeEarnings->sum(function($employee) {
                $monthlyEarnings = $employee->total_earnings;
                if ($monthlyEarnings > 1500) {
                    return min($monthlyEarnings * 0.02, 100); // 2% of monthly basic salary, max of 100
                }
                return $monthlyEarnings * 0.01; // 1% for salary <= 1500
            });
            $deductions[] = [
                'type' => 'Pag-IBIG',
                'amount' => $pagibigTotal,
                'percentage' => round(($pagibigTotal / $totalMonthlyPayroll) * 100, 2)
            ];

            // Withholding Tax
            $withholdingTaxTotal = $employeeEarnings->sum(function($employee) use ($brackets) {
                $annualSalary = $employee->total_earnings * 12;
                foreach ($brackets as $bracket) {
                    if ($annualSalary >= $bracket['min'] && $annualSalary <= $bracket['max']) {
                        return ($annualSalary * $bracket['rate']) / 12; // Monthly tax
                    }
                }
                return 0;
            });
            $deductions[] = [
                'type' => 'Withholding Tax',
                'amount' => $withholdingTaxTotal,
                'percentage' => round(($withholdingTaxTotal / $totalMonthlyPayroll) * 100, 2)
            ];

            return response()->json([
                'brackets' => $brackets,
                'deductions' => $deductions,
                'totalMonthlyPayroll' => $totalMonthlyPayroll,
                'employees' => $employeeEarnings->map(function($employee) {
                    return [
                        'id' => $employee->id,
                        'name' => $employee->first_name . ' ' . $employee->last_name,
                        'department' => $employee->department,
                        'earnings' => round($employee->total_earnings, 2)
                    ];
                })
            ]);

        } catch (\Exception $e) {
            Log::error('Tax Report Error: ' . $e->getMessage());
            return response()->json(['error' => 'Error generating tax report'], 500);
        }
    }

    private function getEmptyBrackets()
    {
        return [
            [
                'name' => '0%',
                'range' => '₱0 - ₱250,000',
                'min' => 0,
                'max' => 250000,
                'rate' => 0,
                'employees' => 0,
                'percentage' => 0
            ],
            [
                'name' => '15%',
                'range' => '₱250,001 - ₱400,000',
                'min' => 250001,
                'max' => 400000,
                'rate' => 0.15,
                'employees' => 0,
                'percentage' => 0
            ],
            // ... rest of the brackets with zero values
        ];
    }

    public function getAttendanceStats(Request $request)
    {
        try {
            $year = $request->year ?? date('Y');

            // Get base query for employees
            $query = DB::table('employees as e')
                ->join('departments as d', 'e.department_id', '=', 'd.id')
                ->where('e.status', 'active');

            if ($request->department) {
                $query->where('d.name', $request->department);
            }
            if ($request->employee_id) {
                $query->where('e.id', $request->employee_id);
            }

            // Get total active employees
            $totalEmployees = $query->count();

            // Get attendance statistics for the selected year
            $attendanceStats = DB::table('attendances as a')
                ->join('employees as e', 'a.employee_id', '=', 'e.id')
                ->join('departments as d', 'e.department_id', '=', 'd.id')
                ->where('e.status', 'active')
                ->whereYear('a.date', $year)
                ->when($request->department, function($query) use ($request) {
                    return $query->where('d.name', $request->department);
                })
                ->when($request->employee_id, function($query) use ($request) {
                    return $query->where('e.id', $request->employee_id);
                })
                ->select(
                    DB::raw('COUNT(CASE WHEN a.status = "present" THEN 1 END) as present_count'),
                    DB::raw('COUNT(CASE WHEN a.status = "absent" THEN 1 END) as absent_count'),
                    DB::raw('COUNT(CASE WHEN a.status = "late" THEN 1 END) as late_count'),
                    DB::raw('COUNT(CASE WHEN a.status = "half_day" THEN 1 END) as half_day_count')
                )
                ->first();

            // Get monthly attendance data for the entire year
            $monthlyData = DB::table('attendances as a')
                ->join('employees as e', 'a.employee_id', '=', 'e.id')
                ->join('departments as d', 'e.department_id', '=', 'd.id')
                ->where('e.status', 'active')
                ->whereYear('a.date', $year)
                ->when($request->department, function($query) use ($request) {
                    return $query->where('d.name', $request->department);
                })
                ->when($request->employee_id, function($query) use ($request) {
                    return $query->where('e.id', $request->employee_id);
                })
                ->select(
                    DB::raw('MONTH(a.date) as month'),
                    DB::raw('COUNT(CASE WHEN a.status = "present" THEN 1 END) as present_count'),
                    DB::raw('COUNT(CASE WHEN a.status = "absent" THEN 1 END) as absent_count'),
                    DB::raw('COUNT(CASE WHEN a.status IN ("late", "half_day") THEN 1 END) as other_count')
                )
                ->groupBy('month')
                ->orderBy('month')
                ->get();

            // Calculate percentages
            $totalAttendances = $attendanceStats->present_count + 
                               $attendanceStats->absent_count + 
                               $attendanceStats->late_count + 
                               $attendanceStats->half_day_count;

            $presentPercentage = $totalAttendances > 0 ? 
                ($attendanceStats->present_count / $totalAttendances) * 100 : 0;
            $absentPercentage = $totalAttendances > 0 ? 
                ($attendanceStats->absent_count / $totalAttendances) * 100 : 0;
            $latePercentage = $totalAttendances > 0 ? 
                ($attendanceStats->late_count / $totalAttendances) * 100 : 0;

            // Prepare monthly data arrays
            $months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
            $presentData = array_fill(0, 12, 0);
            $absentData = array_fill(0, 12, 0);
            $otherData = array_fill(0, 12, 0);

            foreach ($monthlyData as $data) {
                $monthIndex = $data->month - 1;
                $total = $data->present_count + $data->absent_count + $data->other_count;
                if ($total > 0) {
                    $presentData[$monthIndex] = round(($data->present_count / $total) * 100, 1);
                    $absentData[$monthIndex] = round(($data->absent_count / $total) * 100, 1);
                    $otherData[$monthIndex] = round(($data->other_count / $total) * 100, 1);
                }
            }

            return response()->json([
                'presentPercentage' => round($presentPercentage, 1),
                'absentPercentage' => round($absentPercentage, 1),
                'latePercentage' => round($latePercentage, 1),
                'labels' => $months,
                'presentData' => $presentData,
                'absentData' => $absentData,
                'leaveData' => $otherData, // Combined late and half-day data
                'details' => [
                    'totalEmployees' => $totalEmployees,
                    'presentCount' => $attendanceStats->present_count,
                    'absentCount' => $attendanceStats->absent_count,
                    'lateCount' => $attendanceStats->late_count,
                    'halfDayCount' => $attendanceStats->half_day_count
                ]
            ]);

        } catch (\Exception $e) {
            Log::error('Attendance Stats Error: ' . $e->getMessage());
            return response()->json(['error' => 'Error fetching attendance statistics'], 500);
        }
    }

    public function getPerformanceMetrics(Request $request)
    {
        try {
            $year = $request->year ?? date('Y');
            $month = date('m');

            $query = DB::table('employees as e')
                ->join('departments as d', 'e.department_id', '=', 'd.id')
                ->where('e.status', 'active');

            if ($request->department) {
                $query->where('d.name', $request->department);
            }
            if ($request->employee_id) {
                $query->where('e.id', $request->employee_id);
            }

            // Get attendance data for calculations
            $attendanceData = DB::table('attendances as a')
                ->join('employees as e', 'a.employee_id', '=', 'e.id')
                ->join('departments as d', 'e.department_id', '=', 'd.id')
                ->where('e.status', 'active')
                ->whereYear('a.date', $year)
                ->when($request->department, function($query) use ($request) {
                    return $query->where('d.name', $request->department);
                })
                ->when($request->employee_id, function($query) use ($request) {
                    return $query->where('e.id', $request->employee_id);
                })
                ->select(
                    DB::raw('COUNT(*) as total_days'),
                    DB::raw('COUNT(CASE WHEN a.status = "present" THEN 1 END) as present_days'),
                    DB::raw('COUNT(CASE WHEN a.status = "absent" THEN 1 END) as absent_days'),
                    DB::raw('COUNT(CASE WHEN a.status = "late" THEN 1 END) as late_days'),
                    DB::raw('SUM(CASE 
                        WHEN TIMESTAMPDIFF(MINUTE, time_in, time_out) > 480 
                        THEN TIMESTAMPDIFF(MINUTE, time_in, time_out) - 480 
                        ELSE 0 
                    END) as overtime_minutes'),
                    DB::raw('COUNT(CASE WHEN TIME(time_in) <= "09:00:00" THEN 1 END) as on_time_days')
                )
                ->first();

            // Calculate metrics
            $totalWorkDays = $attendanceData->total_days ?: 1; // Avoid division by zero

            // Attendance Compliance (Present days / Total working days)
            $attendanceCompliance = ($attendanceData->present_days / $totalWorkDays) * 100;

            // Punctuality (On-time arrivals / Total present days)
            $punctuality = $attendanceData->present_days > 0 
                ? ($attendanceData->on_time_days / $attendanceData->present_days) * 100 
                : 0;

            // Efficiency (Based on overtime and completion of regular hours)
            $efficiency = $attendanceData->present_days > 0 
                ? (($attendanceData->present_days * 8 * 60 + $attendanceData->overtime_minutes) 
                    / ($attendanceData->present_days * 8 * 60)) * 100 
                : 0;

            // Cap metrics at 100%
            $efficiency = min($efficiency, 100);

            return response()->json([
                'attendanceCompliance' => round($attendanceCompliance, 1),
                'punctuality' => round($punctuality, 1),
                'efficiency' => round($efficiency, 1),
                'details' => [
                    'totalDays' => $attendanceData->total_days,
                    'presentDays' => $attendanceData->present_days,
                    'lateDays' => $attendanceData->late_days,
                    'overtimeHours' => round($attendanceData->overtime_minutes / 60, 1)
                ]
            ]);

        } catch (\Exception $e) {
            Log::error('Performance Metrics Error: ' . $e->getMessage());
            return response()->json(['error' => 'Error fetching performance metrics'], 500);
        }
    }

    public function getEmployees(Request $request)
    {
        try {
            Log::info('Fetching employees', [
                'department' => $request->department,
                'timestamp' => now()->toDateTimeString()
            ]);

            $query = DB::table('employees as e')
                ->join('departments as d', 'e.department_id', '=', 'd.id')
                ->where('e.status', 'active')
                ->select('e.id', 'e.first_name', 'e.last_name', 'd.name as department_name');

            if ($request->department) {
                $query->where('d.name', $request->department);
            }

            $employees = $query->get();

            Log::info('Employees fetched successfully', [
                'count' => $employees->count(),
                'department' => $request->department,
                'query' => $query->toSql(),
                'bindings' => $query->getBindings()
            ]);

            return response()->json([
                'data' => $employees->map(function($employee) {
                    return [
                        'id' => $employee->id,
                        'name' => $employee->first_name . ' ' . $employee->last_name,
                        'department' => $employee->department_name
                    ];
                })
            ]);

        } catch (\Exception $e) {
            Log::error('Error fetching employees', [
                'error' => $e->getMessage(),
                'department' => $request->department,
                'trace' => $e->getTraceAsString()
            ]);
            return response()->json(['error' => 'Error fetching employees'], 500);
        }
    }

    public function getSalaryTrends(Request $request) {
        try {
            $year = $request->year ?? date('Y');
            $department = $request->department;

            // Calculate year-over-year growth rate using salary adjustments
            $currentYearSalaries = DB::table('employees as e')
                ->leftJoin('salary_adjustments as sa', function($join) use ($year) {
                    $join->on('e.id', '=', 'sa.employee_id')
                        ->whereYear('sa.adjustment_date', $year);
                })
                ->join('departments as d', 'e.department_id', '=', 'd.id')
                ->where('e.status', 'active')
                ->when($department, function($query) use ($department) {
                    return $query->where('d.name', $department);
                })
                ->select(
                    'e.id',
                    'e.base_salary',
                    DB::raw('COALESCE(SUM(sa.adjustment_amount), 0) as total_adjustments')
                )
                ->groupBy('e.id', 'e.base_salary')
                ->get();

            $lastYearSalaries = DB::table('employees as e')
                ->leftJoin('salary_adjustments as sa', function($join) use ($year) {
                    $join->on('e.id', '=', 'sa.employee_id')
                        ->whereYear('sa.adjustment_date', $year - 1);
                })
                ->join('departments as d', 'e.department_id', '=', 'd.id')
                ->where('e.status', 'active')
                ->when($department, function($query) use ($department) {
                    return $query->where('d.name', $department);
                })
                ->select(
                    'e.id',
                    'e.base_salary',
                    DB::raw('COALESCE(SUM(sa.adjustment_amount), 0) as total_adjustments')
                )
                ->groupBy('e.id', 'e.base_salary')
                ->get();

            $currentYearAvg = $currentYearSalaries->avg(function($salary) {
                return $salary->base_salary + $salary->total_adjustments;
            });

            $lastYearAvg = $lastYearSalaries->avg(function($salary) {
                return $salary->base_salary + $salary->total_adjustments;
            });

            $growthRate = $lastYearAvg > 0 
                ? (($currentYearAvg - $lastYearAvg) / $lastYearAvg) * 100 
                : 0;

            // Get monthly salary averages
            $monthlyAverages = DB::table('salary_adjustments as sa')
                ->join('employees as e', 'sa.employee_id', '=', 'e.id')
                ->join('departments as d', 'e.department_id', '=', 'd.id')
                ->whereYear('sa.adjustment_date', $year)
                ->when($department, function($query) use ($department) {
                    return $query->where('d.name', $department);
                })
                ->select(
                    DB::raw('MONTH(sa.adjustment_date) as month'),
                    DB::raw('AVG(e.base_salary) + COALESCE(SUM(sa.adjustment_amount), 0) as average_salary'),
                    DB::raw('COUNT(DISTINCT e.id) as employee_count')
                )
                ->groupBy(DB::raw('MONTH(sa.adjustment_date)'))
                ->orderBy('month')
                ->get();

            // If no salary adjustments found, use current base salaries
            if ($monthlyAverages->isEmpty()) {
                $monthlyAverages = collect(range(1, 12))->map(function($month) use ($department) {
                    $avgSalary = DB::table('employees as e')
                        ->join('departments as d', 'e.department_id', '=', 'd.id')
                        ->where('e.status', 'active')
                        ->when($department, function($query) use ($department) {
                            return $query->where('d.name', $department);
                        })
                        ->avg('e.base_salary');
                    
                    return (object)[
                        'month' => $month,
                        'average_salary' => $avgSalary,
                        'employee_count' => DB::table('employees as e')
                            ->join('departments as d', 'e.department_id', '=', 'd.id')
                            ->where('e.status', 'active')
                            ->when($department, function($query) use ($department) {
                                return $query->where('d.name', $department);
                            })
                            ->count()
                    ];
                });
            }

            return response()->json([
                'monthlyAverages' => $monthlyAverages,
                'departmentComparisons' => $departmentComparisons,
                'growthRate' => round($growthRate, 2),
                'statistics' => [
                    'currentYearAvg' => round($currentYearAvg, 2),
                    'lastYearAvg' => round($lastYearAvg, 2),
                    'year' => $year
                ]
            ]);

        } catch (\Exception $e) {
            Log::error('Salary Trends Error: ' . $e->getMessage());
            Log::error('Stack trace: ' . $e->getTraceAsString());
            return $this->getDefaultSalaryTrends($year, $department);
        }
    }

    private function getDefaultSalaryTrends($year, $department) {
        try {
            $avgSalary = DB::table('employees as e')
                ->join('departments as d', 'e.department_id', '=', 'd.id')
                ->where('e.status', 'active')
                ->when($department, function($query) use ($department) {
                    return $query->where('d.name', $department);
                })
                ->avg('e.base_salary') ?? 0;
            
            return response()->json([
                'monthlyAverages' => collect(range(1, 12))->map(function($month) use ($avgSalary) {
                    return [
                        'month' => $month,
                        'average_salary' => $avgSalary,
                        'employee_count' => 0
                    ];
                }),
                'departmentComparisons' => DB::table('employees as e')
                    ->join('departments as d', 'e.department_id', '=', 'd.id')
                    ->select(
                        'd.name as department',
                        DB::raw('AVG(e.base_salary) as average_salary'),
                        DB::raw('MIN(e.base_salary) as min_salary'),
                        DB::raw('MAX(e.base_salary) as max_salary'),
                        DB::raw('COUNT(e.id) as employee_count')
                    )
                    ->where('e.status', 'active')
                    ->groupBy('d.id', 'd.name')
                    ->get(),
                'growthRate' => 0,
                'statistics' => [
                    'currentYearAvg' => round($avgSalary, 2),
                    'lastYearAvg' => round($avgSalary, 2),
                    'year' => $year
                ]
            ]);
        } catch (\Exception $e) {
            Log::error('Default Salary Trends Error: ' . $e->getMessage());
            return response()->json([
                'monthlyAverages' => [],
                'departmentComparisons' => [],
                'growthRate' => 0,
                'statistics' => [
                    'currentYearAvg' => 0,
                    'lastYearAvg' => 0,
                    'year' => $year
                ]
            ]);
        }
    }

    public function getOvertimeAnalysis(Request $request) {
        // Implementation for overtime analysis
    }

    public function getLeavePatterns(Request $request) {
        // Implementation for leave patterns
    }

    public function getDepartmentCosts(Request $request) {
        // Implementation for department costs
    }

    public function getTurnoverMetrics(Request $request) {
        // Implementation for turnover metrics
    }

    public function getIndustryComparison(Request $request) {
        // Implementation for industry comparisons
    }
} 