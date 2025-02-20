<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Position extends Model
{
    protected $fillable = ['department_id', 'title', 'description'];

    public function department()
    {
        return $this->belongsTo(Department::class);
    }
    public function employees()
    {
        return $this->hasMany(Employee::class); // Add this method
    }
}