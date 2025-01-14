<?php

namespace Database\Seeders;

use App\Models\Department;
use App\Models\Position;
use App\Models\Employee;
use Illuminate\Database\Seeder;

class RestoreDeletedRecordsSeeder extends Seeder
{
    public function run()
    {
        // Restore soft-deleted departments
        $deletedDepartments = Department::onlyTrashed()->get();
        foreach ($deletedDepartments as $department) {
            $department->restore();
            $this->command->info("Restored department: {$department->name}");
        }

        // Restore soft-deleted positions
        $deletedPositions = Position::onlyTrashed()->get();
        foreach ($deletedPositions as $position) {
            $position->restore();
            $this->command->info("Restored position: {$position->title}");
        }

        // Restore soft-deleted employees
        $deletedEmployees = Employee::onlyTrashed()->get();
        foreach ($deletedEmployees as $employee) {
            $employee->restore();
            $this->command->info("Restored employee: {$employee->first_name} {$employee->last_name}");
        }
    }
} 