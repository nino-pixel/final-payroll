<?php

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;

class EmployeeRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'employee_id' => 'nullable|string|unique:employees,employee_id,' . $this->employee?->id,
            'first_name' => 'required|string|max:255',
            'last_name' => 'required|string|max:255',
            'email' => 'required|email|unique:employees,email,' . $this->employee?->id,
            'phone' => [
                'required',
                'string',
                'unique:employees,phone,' . $this->employee?->id,
                'regex:/^[09]\d{9,10}$/' // Starts with 0 or 9 and has 10-11 digits
            ],
            'department_id' => 'required|exists:departments,id',
            'position_id' => 'required|exists:positions,id',
            'base_salary' => 'required|numeric|min:0|max:999999.99',
            'hire_date' => 'required|date',
            'status' => 'required|in:active,inactive,on_leave'
        ];
    }

    public function messages(): array
    {
        return [
            'email.unique' => 'This email address is already registered to another employee',
            'phone.unique' => 'This phone number is already registered to another employee',
            'base_salary.max' => 'The salary amount cannot exceed ₱999,999.99',
            'base_salary.min' => 'The salary amount must be a positive number',
            'phone.regex' => 'Please enter a valid number',
            'phone.required' => 'Please enter a valid number'
        ];
    }
}