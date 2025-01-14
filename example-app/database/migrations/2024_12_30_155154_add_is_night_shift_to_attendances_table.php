<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up()
    {
        Schema::table('attendances', function (Blueprint $table) {
            if (!Schema::hasColumn('attendances', 'is_night_shift')) {
                $table->boolean('is_night_shift')->default(false)->after('status');
            }
        });
    }

    public function down()
    {
        Schema::table('attendances', function (Blueprint $table) {
            if (Schema::hasColumn('attendances', 'is_night_shift')) {
                $table->dropColumn('is_night_shift');
            }
        });
    }
}; 