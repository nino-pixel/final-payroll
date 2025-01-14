<?php

namespace App\Exports;

use Maatwebsite\Excel\Concerns\FromCollection;
use Maatwebsite\Excel\Concerns\WithHeadings;
use Illuminate\Support\Collection;

class AttendanceExport implements FromCollection, WithHeadings
{
    protected $attendances;

    public function __construct($attendances)
    {
        $this->attendances = $attendances;
    }

    public function collection()
    {
        return collect($this->attendances)->map(function ($attendance) {
            return [
                'Date' => $attendance->date,
                'Employee ID' => $attendance->employee->employee_id ?? 'N/A',
                'Name' => $attendance->employee->full_name ?? 'N/A',
                'Time In' => $attendance->time_in ? Carbon::parse($attendance->time_in)->format('h:i A') : '-',
                'Time Out' => $attendance->time_out ? Carbon::parse($attendance->time_out)->format('h:i A') : '-',
                'Status' => ucfirst($attendance->status)
            ];
        });
    }

    public function headings(): array
    {
        return [
            'Date',
            'Employee ID',
            'Name',
            'Time In',
            'Time Out',
            'Status'
        ];
    }
} 