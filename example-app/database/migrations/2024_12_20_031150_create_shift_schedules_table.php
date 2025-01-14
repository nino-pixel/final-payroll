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
        Schema::create('shift_schedules', function (Blueprint $table) {
            $table->id();
            $table->string('name')->unique();
            $table->time('start_time')->nullable();
            $table->time('end_time')->nullable();
            $table->boolean('is_custom')->default(false);
            $table->timestamps();
        });

        // Insert default shifts
        DB::table('shift_schedules')->insert([
            [
                'name' => 'Day Shift',
                'start_time' => '06:00:00',
                'end_time' => '15:00:00',
                'is_custom' => false,
                'created_at' => now(),
                'updated_at' => now()
            ],
            [
                'name' => 'Night Shift',
                'start_time' => '15:00:00',
                'end_time' => '00:00:00',
                'is_custom' => false,
                'created_at' => now(),
                'updated_at' => now()
            ],
            [
                'name' => 'Graveyard Shift',
                'start_time' => '00:00:00',
                'end_time' => '06:00:00',
                'is_custom' => false,
                'created_at' => now(),
                'updated_at' => now()
            ],
            [
                'name' => 'Custom Shift',
                'start_time' => null,
                'end_time' => null,
                'is_custom' => true,
                'created_at' => now(),
                'updated_at' => now()
            ]
        ]);
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('shift_schedules');
    }
}; 