<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class ProfileUpdateRequest extends Model
{
    protected $fillable = [
        'employee_id',
        'requested_changes',
        'status',
        'remarks'
    ];

    protected $casts = [
        'requested_changes' => 'array'
    ];

    public function employee()
    {
        return $this->belongsTo(Employee::class);
    }
} 