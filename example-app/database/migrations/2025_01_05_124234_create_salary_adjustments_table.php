<?php
use Illuminate\Database\Migrations\Migration;
   use Illuminate\Database\Schema\Blueprint;
   use Illuminate\Support\Facades\Schema;

   class CreateSalaryAdjustmentsTable extends Migration
   {
       public function up()
       {
           Schema::create('salary_adjustments', function (Blueprint $table) {
               $table->id();
               $table->foreignId('employee_id')->constrained('employees')->onDelete('cascade');
               $table->string('adjustment_type', 100);
               $table->decimal('adjustment_amount', 10, 2);
               $table->date('adjustment_date');
               $table->text('reason')->nullable();
               $table->timestamps();
               $table->softDeletes();
           });
       }

       public function down()
       {
           Schema::dropIfExists('salary_adjustments');
       }
   }