<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\Api\EmployeeController;
use App\Http\Controllers\Api\DepartmentController;
use App\Http\Controllers\Api\PositionController;
use App\Http\Controllers\Api\AttendanceController;
use App\Http\Controllers\Api\PayrollController;
use App\Http\Controllers\Api\SalaryAdjustmentController;
use App\Http\Controllers\Api\ShiftScheduleController;
use App\Http\Controllers\Api\ReportController;
use App\Http\Controllers\Api\LeaveController;
use App\Http\Controllers\Api\ProfileController;
use Illuminate\Support\Facades\Log;

// Add this at the top of your routes file
Route::options('/{any}', function() {
    return response()->json([], 200);
})->where('any', '.*');

// Web Auth routes
Route::post('/auth/register', [AuthController::class, 'register']);
Route::post('/auth/login', [AuthController::class, 'login']);

// Mobile Employee Auth routes
Route::prefix('mobile')->group(function () {
    Route::post('/login', [AuthController::class, 'mobileLogin']);
    Route::post('/reset-password', [AuthController::class, 'resetEmployeePassword']);
    // Remove or restrict employee registration as needed
    // Route::post('/register', [AuthController::class, 'mobileRegister']);
});

// Protected Routes
Route::middleware('auth:sanctum')->group(function () {
    // Common routes
    Route::get('/user', function (Request $request) {
        return $request->user();
    });

    // Web routes
    Route::prefix('auth')->group(function () {
        Route::post('/logout', [AuthController::class, 'logout']);
    });

    // Mobile routes
    Route::prefix('mobile')->group(function () {
        Route::post('/logout', [AuthController::class, 'mobileLogout']);
        Route::get('/employee/profile', [EmployeeController::class, 'getProfile']);
        
        Route::get('/attendance/history', [AttendanceController::class, 'getAttendanceHistory']);
        Route::post('/attendance/mark', [AttendanceController::class, 'markAttendance']);
        Route::get('/payroll/history', [PayrollController::class, 'getEmployeePayrollHistory']);
    });

    // Employee routes
    Route::apiResource('employees', EmployeeController::class);
    Route::get('/employee-search', [EmployeeController::class, 'search']);
    
    // Department routes
    Route::get('/departments/salary-distribution', [AttendanceController::class, 'getDepartmentSalaries']);
    Route::get('/departments/{id}/positions', [DepartmentController::class, 'getPositions']);
    Route::get('/departments/employee-counts', [DepartmentController::class, 'getEmployeeCounts']);
    Route::apiResource('departments', DepartmentController::class);
    Route::get('/departments', [DepartmentController::class, 'index']);
    
    // Position routes
    Route::apiResource('positions', PositionController::class);
    
    // Attendance routes
    Route::get('/attendance/monthly-counts', [AttendanceController::class, 'getMonthlyAttendanceCounts']);
    Route::get('/attendance/history', [AttendanceController::class, 'getAttendanceHistory']);
    Route::get('/attendance/employee/{employee}', [AttendanceController::class, 'getEmployeeAttendance']);
    Route::post('/attendance/mark', [AttendanceController::class, 'markAttendance']);
    Route::post('/attendance/report', [AttendanceController::class, 'generateReport']);
    Route::post('/attendance/manual', [AttendanceController::class, 'markManualAttendance']);
    Route::get('/attendance/available-years', [AttendanceController::class, 'getAvailableYears']);
    Route::get('/attendance/monthly-rates', [AttendanceController::class, 'getMonthlyRates']);
    Route::get('/attendance/getHistory', [AttendanceController::class, 'getHistory']);
    Route::get('/attendance/getAttendanceHistory', [AttendanceController::class, 'getAttendanceHistory']);
    Route::get('/attendance/current-status', [AttendanceController::class, 'getCurrentStatus']);

    // Payroll routes
    Route::post('/payroll/generate', [PayrollController::class, 'generatePayroll']);
    Route::get('/payroll/history', [PayrollController::class, 'getPaymentHistory']);
    Route::get('/payroll/{id}', [PayrollController::class, 'show']);
    Route::get('payroll/{payroll}/download', [PayrollController::class, 'downloadPayslip']);
    
    // Salary Adjustment routes
    Route::apiResource('salary-adjustments', SalaryAdjustmentController::class);

    // Deductions and Bonuses routes
    Route::post('/deductions', [EmployeeController::class, 'storeDeduction']);
    Route::post('/bonuses', [EmployeeController::class, 'storeBonus']);

    // Global Deductions
    Route::post('/global-deductions', [EmployeeController::class, 'updateGlobalDeductions']);

    // Admin routes for managing employee authentication
    Route::post('/employees/{employeeId}/set-password', [AuthController::class, 'setEmployeePassword']);

    Route::post('/mobile/attendance/mark', [AttendanceController::class, 'markAttendance']);
    Route::get('/mobile/attendance/history', [AttendanceController::class, 'getAttendanceHistory']);

    Route::apiResource('shift-schedules', ShiftScheduleController::class);

    Route::get('/dashboard/stats', [AttendanceController::class, 'getDashboardStats']);

    // Reports and Analytics routes
    Route::prefix('reports')->group(function () {
        Route::get('/dashboard-stats', [ReportController::class, 'getDashboardStats']);
        Route::get('/attendance-stats', [ReportController::class, 'getAttendanceStats']);
        Route::get('/tax-report', [ReportController::class, 'getTaxReport']);
        Route::get('/performance-metrics', [ReportController::class, 'getPerformanceMetrics']);
        Route::get('/employees', [ReportController::class, 'getEmployees']);
    });

    Route::get('/employees', [EmployeeController::class, 'index']);

    // Reports Routes
    Route::get('/reports/dashboard-stats', [ReportController::class, 'getDashboardStats']);
    Route::get('/reports/attendance-stats', [ReportController::class, 'getAttendanceStats']);
    Route::get('/reports/performance-metrics', [ReportController::class, 'getPerformanceMetrics']);
    Route::get('/reports/tax-report', [ReportController::class, 'getTaxReport']);
    Route::get('/reports/salary-trends', [ReportController::class, 'getSalaryTrends']);
    Route::get('/reports/employees', [ReportController::class, 'getEmployees']);

    Route::put('/salary/adjust/{id}', [SalaryAdjustmentController::class, 'update']);

    Route::get('/mobile/validate-token', [AuthController::class, 'validateToken']);

    // Mobile Attendance routes
    Route::prefix('mobile/attendance')->group(function () {
        Route::get('status', [AttendanceController::class, 'getCurrentStatus']);
        Route::post('mark', [AttendanceController::class, 'markAttendance']);
        Route::get('history', [AttendanceController::class, 'getMobileHistory']);
    });

    // Mobile Leave routes
    Route::prefix('mobile/leave')->group(function () {
        Route::get('balances', [LeaveController::class, 'getBalances']);
        Route::post('request', [LeaveController::class, 'submitRequest']);
        Route::get('history', [LeaveController::class, 'getHistory']);
    });

    Route::prefix('mobile/payroll')->group(function () {
        Route::get('payment-history', [PayrollController::class, 'getPaymentHistory']);
    });

    // Profile routes - remove any api prefix since we're already in api.php
    Route::prefix('profile')->group(function () {
        Route::get('/', [ProfileController::class, 'show']);
        Route::post('update-request', [ProfileController::class, 'requestUpdate']);
        Route::post('upload-picture', [ProfileController::class, 'uploadProfilePicture']);
        Route::get('pending-requests', [ProfileController::class, 'getPendingRequests']);
        Route::post('approve-request/{id}', [ProfileController::class, 'approveRequest']);
    });
});

// Add this route for testing
Route::get('/test-shift-schedules', function() {
    return response()->json([
        'schedules' => \App\Models\ShiftSchedule::all(),
        'message' => 'API is working'
    ]);
});

// Add this at the top for debugging
Route::get('/debug/routes', function() {
    Log::info('Available routes', [
        'routes' => collect(\Route::getRoutes())->map(function($route) {
            return [
                'uri' => $route->uri(),
                'methods' => $route->methods(),
                'name' => $route->getName(),
                'middleware' => $route->middleware()
            ];
        })->toArray()
    ]);
    return response()->json(['message' => 'Routes logged']);
});