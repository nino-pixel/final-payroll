<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\HasMany;

class ShiftSchedule extends Model
{
    protected $fillable = [
        'name',
        'start_time',
        'end_time'
    ];

    protected $casts = [
        'start_time' => 'string',
        'end_time' => 'string'
    ];

    public function employees(): HasMany
    {
        return $this->hasMany(Employee::class);
    }
} 