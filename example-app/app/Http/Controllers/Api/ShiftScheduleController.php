<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\ShiftSchedule;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Log;

class ShiftScheduleController extends Controller
{
    public function index()
    {
        try {
            $schedules = ShiftSchedule::select('id', 'name', 'start_time', 'end_time')->get();
            
            Log::info('Fetched shift schedules:', [
                'count' => $schedules->count(),
                'schedules' => $schedules->toArray()
            ]);

            return response()->json($schedules);
            
        } catch (\Exception $e) {
            Log::error('Error fetching shift schedules:', [
                'error' => $e->getMessage(),
                'trace' => $e->getTraceAsString()
            ]);

            return response()->json([
                'message' => 'Failed to fetch shift schedules',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    public function store(Request $request)
    {
        try {
            $validated = $request->validate([
                'name' => 'required|string|max:255',
                'start_time' => 'required|date_format:H:i',
                'end_time' => 'required|date_format:H:i'
            ]);

            $schedule = ShiftSchedule::create($validated);

            Log::info('Created new shift schedule:', $schedule->toArray());

            return response()->json($schedule, 201);

        } catch (\Exception $e) {
            Log::error('Error creating shift schedule:', [
                'error' => $e->getMessage(),
                'trace' => $e->getTraceAsString(),
                'request_data' => $request->all()
            ]);

            return response()->json([
                'message' => 'Failed to create shift schedule',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    public function update(Request $request, $id)
    {
        try {
            $schedule = ShiftSchedule::findOrFail($id);

            $validated = $request->validate([
                'name' => 'required|string|max:255',
                'start_time' => 'required|date_format:H:i',
                'end_time' => 'required|date_format:H:i'
            ]);

            $schedule->update($validated);

            Log::info('Updated shift schedule:', [
                'id' => $id,
                'updated_data' => $schedule->fresh()->toArray()
            ]);

            return response()->json($schedule);

        } catch (\Exception $e) {
            Log::error('Error updating shift schedule:', [
                'error' => $e->getMessage(),
                'trace' => $e->getTraceAsString(),
                'schedule_id' => $id,
                'request_data' => $request->all()
            ]);

            return response()->json([
                'message' => 'Failed to update shift schedule',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    public function destroy($id)
    {
        try {
            $schedule = ShiftSchedule::findOrFail($id);
            
            // Check if schedule is being used by employees
            if ($schedule->employees()->exists()) {
                return response()->json([
                    'message' => 'Cannot delete schedule that is assigned to employees'
                ], 422);
            }

            $schedule->delete();

            Log::info('Deleted shift schedule:', ['id' => $id]);

            return response()->json([
                'message' => 'Shift schedule deleted successfully'
            ]);

        } catch (\Exception $e) {
            Log::error('Error deleting shift schedule:', [
                'error' => $e->getMessage(),
                'trace' => $e->getTraceAsString(),
                'schedule_id' => $id
            ]);

            return response()->json([
                'message' => 'Failed to delete shift schedule',
                'error' => $e->getMessage()
            ], 500);
        }
    }
} 