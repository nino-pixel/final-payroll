<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Deduction extends Model
{
    use HasFactory;

    protected $fillable = [
        'employee_id',
        'deduction_type',
        'amount',
        'deduction_date'
    ];

    public function employee()
    {
        return $this->belongsTo(Employee::class);
    }
}