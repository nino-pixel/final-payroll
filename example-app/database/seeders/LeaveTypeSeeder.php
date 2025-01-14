<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\LeaveType;

class LeaveTypeSeeder extends Seeder
{
    public function run()
    {
        $leaveTypes = [
            [
                'name' => 'Sick Leave',
                'code' => 'SL',
                'description' => 'Leave for medical reasons',
                'default_days_per_year' => 15,
                'requires_approval' => true,
            ],
            [
                'name' => 'Vacation Leave',
                'code' => 'VL',
                'description' => 'Annual vacation leave',
                'default_days_per_year' => 15,
                'requires_approval' => true,
            ],
            [
                'name' => 'Emergency Leave',
                'code' => 'EL',
                'description' => 'Leave for emergencies',
                'default_days_per_year' => 5,
                'requires_approval' => true,
            ],
            [
                'name' => 'Bereavement Leave',
                'code' => 'BL',
                'description' => 'Leave for death in immediate family',
                'default_days_per_year' => 3,
                'requires_approval' => true,
            ]
        ];

        foreach ($leaveTypes as $type) {
            LeaveType::create($type);
        }
    }
} 