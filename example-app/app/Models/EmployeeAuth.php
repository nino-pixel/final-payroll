<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class EmployeeAuth extends Model
{
    protected $table = 'employee_auth';

    protected $fillable = [
        'employee_id',
        'password'
    ];

    protected $hidden = [
        'password',
        'created_at',
        'updated_at'
    ];

    public function employee(): BelongsTo
    {
        return $this->belongsTo(Employee::class);
    }
}
