<?php

namespace App\Console\Commands;

use Illuminate\Console\Command;
use App\Models\Employee;
use App\Models\LeaveType;
use App\Models\LeaveBalance;
use Carbon\Carbon;

class InitializeLeaveBalances extends Command
{
    protected $signature = 'setup:leave-balances';
    protected $description = 'Initialize leave balances for all employees';

    public function handle()
    {
        $currentYear = Carbon::now()->year;
        $employees = Employee::all();
        $leaveTypes = LeaveType::where('is_active', true)->get();
        $count = 0;

        foreach ($employees as $employee) {
            foreach ($leaveTypes as $leaveType) {
                // Skip special leaves like ML/PL unless needed
                if (in_array($leaveType->code, ['ML', 'PL'])) {
                    continue;
                }

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
                $count++;
            }
        }

        $this->info("Created $count leave balance records!");
    }
} 