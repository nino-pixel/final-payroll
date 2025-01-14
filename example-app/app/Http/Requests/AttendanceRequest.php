<?php

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;

class AttendanceRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        $rules = [
            'time_in' => 'required|date_format:H:i',
            'time_out' => 'nullable|date_format:H:i|after:time_in',
            'status' => 'required|in:present,absent,late,half_day,on_leave',
            'notes' => 'nullable|string'
        ];

        // Only require employee_id and date for new records
        if ($this->isMethod('POST')) {
            $rules['employee_id'] = 'required|exists:employees,id';
            $rules['date'] = 'required|date';
        }

        return $rules;
    }

    public function messages(): array
    {
        return [
            'time_out.after' => 'Time out must be after time in.',
        ];
    }
}