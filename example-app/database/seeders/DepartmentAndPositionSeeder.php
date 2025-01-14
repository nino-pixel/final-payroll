<?php

namespace Database\Seeders;

use App\Models\Department;
use App\Models\Position;
use Illuminate\Database\Seeder;

class DepartmentAndPositionSeeder extends Seeder
{
    public function run()
    {
        // Get existing departments from database
        $departments = Department::with('positions')->get();

        foreach ($departments as $department) {
            // Get positions for this department
            $positions = Position::where('department_id', $department->id)->get();

            // You can process or update the data here
            foreach ($positions as $position) {
                // Example: Update salary ranges based on existing data
                $position->update([
                    'base_salary' => $position->base_salary * 1.1, // 10% increase
                    'status' => $position->status ?? 'Active'
                ]);
            }
        }
    }
}