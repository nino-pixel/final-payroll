<?php

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;

class PayrollDetailRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        $rules = [
            'description' => 'required|string',
            'type' => 'required|in:earning,deduction',
            'amount' => 'required|numeric|min:0'
        ];

        // Only require payroll_id for new records
        if ($this->isMethod('POST')) {
            $rules['payroll_id'] = 'required|exists:payrolls,id';
        }

        return $rules;
    }
}