<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;
use Illuminate\Support\Facades\DB;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        Schema::create('attendances', function (Blueprint $table) {
            $table->id();
            $table->foreignId('employee_id')->constrained();
            $table->date('date');
            $table->dateTime('time_in');
            $table->dateTime('time_out')->nullable();
            $table->enum('status', ['present', 'absent', 'late', 'half_day']);
            $table->boolean('is_night_shift')->default(false);
            $table->timestamps();
        });

        // Insert sample attendance data
        DB::table('attendances')->insert([
            [
                'employee_id' => 42,
                'date' => '2024-12-29',
                'time_in' => '2024-12-29 03:02:00',
                'time_out' => '2024-12-29 15:02:00',
                'status' => 'present',
                'created_at' => '2024-12-28 15:02:47',
                'updated_at' => '2024-12-28 15:02:47',
                'is_night_shift' => false
            ]
        ]);
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('attendances');
    }
};
