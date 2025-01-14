<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\Employee;
use App\Models\EmployeeAddress;
use Illuminate\Support\Facades\Log;

class ProfileController extends Controller
{
    public function show(Request $request)
    {
        try {
            Log::info('Profile request received', [
                'email' => $request->user()->email,
                'request_path' => $request->path(),
            ]);

            $employee = Employee::where('email', $request->user()->email)->first();
            
            if (!$employee) {
                Log::warning('Employee not found', ['email' => $request->user()->email]);
                return response()->json([
                    'message' => 'Employee not found'
                ], 404);
            }

            $address = $employee->address;
            Log::info('Employee data retrieved', [
                'employee_id' => $employee->employee_id,
                'has_address' => $address ? 'yes' : 'no'
            ]);

            return response()->json([
                'id' => $employee->id,
                'employee_id' => $employee->employee_id,
                'first_name' => $employee->first_name,
                'last_name' => $employee->last_name,
                'email' => $employee->email,
                'phone' => $employee->phone,
                'department' => $employee->department?->name,
                'position' => $employee->position?->name,
                'status' => $employee->status,
                'address' => $address ? [
                    'street_address' => $address->street_address,
                    'city' => $address->city,
                    'state' => $address->state,
                    'postal_code' => $address->postal_code,
                    'country' => $address->country,
                ] : null,
            ]);
        } catch (\Exception $e) {
            Log::error('Profile fetch error', [
                'error' => $e->getMessage(),
                'file' => $e->getFile(),
                'line' => $e->getLine(),
            ]);
            return response()->json([
                'message' => 'Failed to fetch profile data'
            ], 500);
        }
    }

    public function requestUpdate(Request $request)
    {
        try {
            Log::info('Profile update request received', [
                'changes' => $request->input('changes'),
                'user_email' => $request->user()->email
            ]);

            $employee = Employee::where('email', $request->user()->email)->first();
            
            if (!$employee) {
                Log::warning('Employee not found for update request', [
                    'email' => $request->user()->email
                ]);
                return response()->json([
                    'message' => 'Employee not found'
                ], 404);
            }

            $changes = $request->input('changes');

            // Handle address updates
            if (isset($changes['address'])) {
                $employee->address()->updateOrCreate(
                    ['employee_id' => $employee->id],
                    [
                        'street_address' => $changes['address'],
                        'city' => $changes['city'] ?? '',
                        'state' => $changes['state'] ?? null,
                        'postal_code' => $changes['postal_code'] ?? '',
                        'country' => $changes['country'] ?? 'Philippines',
                    ]
                );
            }

            // Handle other profile updates
            $allowedFields = ['first_name', 'last_name', 'phone'];
            $updates = array_intersect_key($changes, array_flip($allowedFields));
            
            if (!empty($updates)) {
                $employee->update($updates);
            }

            Log::info('Profile update successful', [
                'employee_id' => $employee->id,
                'changes' => $changes
            ]);

            return response()->json(['message' => 'Update request submitted successfully']);
        } catch (\Exception $e) {
            Log::error('Profile update error', [
                'error' => $e->getMessage(),
                'file' => $e->getFile(),
                'line' => $e->getLine()
            ]);
            return response()->json([
                'message' => 'Failed to update profile: ' . $e->getMessage()
            ], 500);
        }
    }
} 