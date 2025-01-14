<?php
use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

class CreateDeductionsTable extends Migration
{
    public function up()
    {
        Schema::create('deductions', function (Blueprint $table) {
            $table->id();
            $table->foreignId('employee_id')->constrained('employees')->onDelete('cascade')->onUpdate('cascade');
            $table->string('deduction_type', 100);
            $table->decimal('amount', 10, 2);
            $table->date('deduction_date');
            $table->timestamps();
        });
    }

    public function down()
    {
        Schema::dropIfExists('deductions');
    }
}