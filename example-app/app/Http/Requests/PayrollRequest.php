<?php

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;

class PayrollRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        if ($this->isMethod('POST')) {
            return [
                'employee_id' => 'required|exists:employees,id',
                'start_date' => 'required|date',
                'end_date' => 'required|date|after:start_date',
                'total_working_days' => 'required|integer|min:0',
                'days_worked' => 'required|integer|min:0|lte:total_working_days',
                'overtime_hours' => 'integer|min:0',
                'status' => 'required|in:draft,pending,approved,paid',
                'payment_method' => 'nullable|string',
                'notes' => 'nullable|string',
                'details' => 'array',
                'details.*.description' => 'required|string',
                'details.*.type' => 'required|in:earning,deduction',
                'details.*.amount' => 'required|numeric|min:0'
            ];
        }

        return [
            'status' => 'required|in:draft,pending,approved,paid',
            'payment_date' => 'nullable|date',
            'payment_method' => 'nullable|string',
            'notes' => 'nullable|string'
        ];
    }

    public function messages(): array
    {
        return [
            'days_worked.lte' => 'Days worked cannot exceed total working days.',
            'details.*.description.required' => 'Each payroll detail must have a description.',
            'details.*.type.in' => 'Payroll detail type must be either earning or deduction.',
            'details.*.amount.min' => 'Payroll detail amount must be greater than zero.'
        ];
    }
}