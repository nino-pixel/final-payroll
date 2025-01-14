<?php

namespace App\Console\Commands;

use Illuminate\Console\Command;
use App\Models\LeaveType;

class SetupLeaveTypes extends Command
{
    protected $signature = 'setup:leave-types';
    protected $description = 'Setup initial leave types';

    public function handle()
    {
        $leaveTypes = [
            [
                'name' => 'Vacation Leave',
                'code' => 'VL',
                'description' => 'Annual vacation leave',
                'default_days_per_year' => 12,
                'requires_approval' => true,
                'is_active' => true
            ],
            [
                'name' => 'Sick Leave',
                'code' => 'SL',
                'description' => 'Medical leave with or without certificate',
                'default_days_per_year' => 15,
                'requires_approval' => true,
                'is_active' => true
            ],
            [
                'name' => 'Emergency Leave',
                'code' => 'EL',
                'description' => 'Leave for urgent personal matters',
                'default_days_per_year' => 3,
                'requires_approval' => true,
                'is_active' => true
            ],
            [
                'name' => 'Maternity Leave',
                'code' => 'ML',
                'description' => 'Leave for childbirth (105 days)',
                'default_days_per_year' => 105,
                'requires_approval' => true,
                'is_active' => true
            ],
            [
                'name' => 'Paternity Leave',
                'code' => 'PL',
                'description' => 'Leave for male employees (7 days)',
                'default_days_per_year' => 7,
                'requires_approval' => true,
                'is_active' => true
            ]
        ];

        foreach ($leaveTypes as $type) {
            LeaveType::updateOrCreate(
                ['code' => $type['code']],
                $type
            );
        }

        $this->info('Leave types have been set up successfully!');
    }
} 