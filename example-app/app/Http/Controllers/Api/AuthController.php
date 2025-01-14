<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Employee;
use App\Models\User;
use App\Models\EmployeeAuth;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Validator;
use Illuminate\Support\Facades\Log;

class AuthController extends Controller
{
    public function register(Request $request)
    {
        try {
            Log::info('Registration attempt', ['data' => $request->all()]);

            $validator = Validator::make($request->all(), [
                'name' => 'required|string|max:255',
                'email' => 'required|string|email|unique:users,email',
                'password' => [
                    'required',
                    'string',
                    'min:8',
                    'confirmed',
                    'regex:/^(?=.*[A-Z])(?=.*[a-z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$/'
                ]
            ], [
                'password.regex' => 'Password must contain at least one uppercase letter, one lowercase letter, one number and one special character'
            ]);

            if ($validator->fails()) {
                return response()->json([
                    'message' => 'Validation failed',
                    'errors' => $validator->errors()
                ], 422);
            }

            $user = User::create([
                'name' => $request->name,
                'email' => $request->email,
                'password' => Hash::make($request->password)
            ]);

            $token = $user->createToken('auth_token')->plainTextToken;

            return response()->json([
                'message' => 'Registration successful',
                'user' => $user,
                'token' => $token
            ], 201);

        } catch (\Exception $e) {
            Log::error('Registration error', [
                'error' => $e->getMessage(),
                'trace' => $e->getTraceAsString()
            ]);

            return response()->json([
                'message' => 'Registration failed',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    public function login(Request $request)
    {
        try {
            $validator = Validator::make($request->all(), [
                'email' => 'required|email',
                'password' => 'required'
            ]);

            if ($validator->fails()) {
                return response()->json([
                    'message' => 'Validation error',
                    'errors' => $validator->errors()
                ], 422);
            }

            if (!Auth::attempt($request->only('email', 'password'))) {
                return response()->json([
                    'message' => 'Invalid login credentials'
                ], 401);
            }

            $user = User::where('email', $request->email)->firstOrFail();
            
            // Check if the request is from mobile
            if ($request->header('X-Platform') === 'mobile') {
                $token = $user->createToken('mobile-token')->plainTextToken;
            } else {
                $token = $user->createToken('web-token')->plainTextToken;
            }

            return response()->json([
                'message' => 'Login successful',
                'user' => $user,
                'token' => $token
            ]);

        } catch (\Exception $e) {
            return response()->json([
                'message' => 'Login failed',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    public function mobileLogin(Request $request)
    {
        try {
            $credentials = $request->validate([
                'email' => 'required|email',
                'password' => 'required'
            ]);

            if (Auth::attempt($credentials)) {
                $user = Auth::user();
                $employee = $user->employee;
                
                // Add debug logging
                Log::info('Mobile login attempt', [
                    'user_id' => $user->id,
                    'email' => $user->email,
                    'has_employee' => $employee ? 'yes' : 'no',
                    'employee_data' => $employee
                ]);

                if (!$employee) {
                    Log::warning('No employee record found for user', [
                        'user_id' => $user->id,
                        'email' => $user->email
                    ]);
                    return response()->json([
                        'message' => 'Employee record not found'
                    ], 404);
                }

                $token = $user->createToken('mobile-token')->plainTextToken;

                return response()->json([
                    'token' => $token,
                    'employee_data' => $employee
                ]);
            }

            return response()->json([
                'message' => 'Invalid credentials'
            ], 401);
        } catch (\Exception $e) {
            Log::error('Login error', [
                'error' => $e->getMessage(),
                'trace' => $e->getTraceAsString()
            ]);
            return response()->json([
                'message' => 'Login failed'
            ], 500);
        }
    }

    public function logout(Request $request)
    {
        try {
            $request->user()->currentAccessToken()->delete();
            return response()->json([
                'message' => 'Successfully logged out'
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'message' => 'Logout failed',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    public function mobileLogout(Request $request)
    {
        try {
            $request->user()->tokens()->where('name', 'mobile-token')->delete();
            return response()->json([
                'message' => 'Successfully logged out from mobile'
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'message' => 'Logout failed',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    public function setEmployeePassword(Request $request, $employeeId)
    {
        try {
            $validator = Validator::make($request->all(), [
                'password' => [
                    'required',
                    'string',
                    'min:8',
                    'confirmed',
                    'regex:/^(?=.*[A-Z])(?=.*[a-z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$/'
                ]
            ], [
                'password.regex' => 'Password must contain at least one uppercase letter, one lowercase letter, one number and one special character'
            ]);

            if ($validator->fails()) {
                return response()->json([
                    'message' => 'Validation error',
                    'errors' => $validator->errors()
                ], 422);
            }

            $employee = Employee::findOrFail($employeeId);
            
            // Create or update employee auth record
            EmployeeAuth::updateOrCreate(
                ['employee_id' => $employee->id],
                ['password' => Hash::make($request->password)]
            );

            return response()->json([
                'message' => 'Employee password set successfully'
            ]);

        } catch (\Exception $e) {
            Log::error('Setting employee password failed', [
                'error' => $e->getMessage(),
                'employee_id' => $employeeId
            ]);

            return response()->json([
                'message' => 'Failed to set employee password',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    public function resetEmployeePassword(Request $request)
    {
        try {
            $validator = Validator::make($request->all(), [
                'email' => 'required|email',
                'old_password' => 'required',
                'password' => [
                    'required',
                    'string',
                    'min:8',
                    'confirmed',
                    'regex:/^(?=.*[A-Z])(?=.*[a-z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$/'
                ]
            ]);

            if ($validator->fails()) {
                return response()->json([
                    'message' => 'Validation error',
                    'errors' => $validator->errors()
                ], 422);
            }

            $employee = Employee::where('email', $request->email)->first();
            
            if (!$employee) {
                return response()->json([
                    'message' => 'Employee not found'
                ], 404);
            }

            $employeeAuth = EmployeeAuth::where('employee_id', $employee->id)->first();

            if (!$employeeAuth || !Hash::check($request->old_password, $employeeAuth->password)) {
                return response()->json([
                    'message' => 'Invalid old password'
                ], 401);
            }

            $employeeAuth->password = Hash::make($request->password);
            $employeeAuth->save();

            return response()->json([
                'message' => 'Password reset successfully'
            ]);

        } catch (\Exception $e) {
            Log::error('Password reset failed', [
                'error' => $e->getMessage()
            ]);

            return response()->json([
                'message' => 'Password reset failed',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    public function validateToken(Request $request)
    {
        try {
            // The token is already validated by the auth middleware
            return response()->json([
                'valid' => true
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'valid' => false
            ], 401);
        }
    }
}