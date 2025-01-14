<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class PayrollDetail extends Model
{
    protected $fillable = [
        'payroll_id',
        'type',
        'name',
        'amount',
        'description'
    ];

    public function payroll()
    {
        return $this->belongsTo(Payroll::class);
    }
}