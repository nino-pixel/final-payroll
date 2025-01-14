<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

class CreateBonusesTable extends Migration
{
    public function up()
    {
        Schema::create('bonuses', function (Blueprint $table) {
            $table->id();
            $table->foreignId('employee_id')->constrained('employees')->onDelete('cascade')->onUpdate('cascade');
            $table->string('bonus_type', 100);
            $table->decimal('amount', 10, 2);
            $table->date('bonus_date');
            $table->timestamps();
        });
    }

    public function down()
    {
        Schema::dropIfExists('bonuses');
    }
}