<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\SoftDeletes;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;

class Payroll extends Model
{
    use SoftDeletes;

    protected $fillable = [
        'employee_id',
        'period_start',
        'period_end',
        'base_salary',
        'total_increases',
        'total_deductions',
        'net_salary',
        'status',
        'attendance_summary'
    ];

    protected $casts = [
        'attendance_summary' => 'array',
        'base_salary' => 'decimal:2',
        'total_increases' => 'decimal:2',
        'total_deductions' => 'decimal:2',
        'net_salary' => 'decimal:2'
    ];

    public function employee(): BelongsTo
    {
        return $this->belongsTo(Employee::class);
    }

    public function details(): HasMany
    {
        return $this->hasMany(PayrollDetail::class);
    }
}