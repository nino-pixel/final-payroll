<?php

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;

class SalaryAdjustmentRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        $rules = [
            'type' => 'required|in:bonus,deduction,overtime,allowance,tax',
            'amount' => 'required|numeric|min:0',
            'effective_date' => 'required|date',
            'description' => 'required|string',
            'frequency' => 'required|in:one_time,recurring',
            'is_active' => 'boolean'
        ];

        // Only require employee_id for new records
        if ($this->isMethod('POST')) {
            $rules['employee_id'] = 'required|exists:employees,id';
        }

        return $rules;
    }
}