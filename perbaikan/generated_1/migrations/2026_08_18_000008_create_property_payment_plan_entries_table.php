<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('property_payment_plan_entries', function (Blueprint $table) {
            $table->id();
            $table->foreignId('property_payment_plan_id')->constrained('property_payment_plans')->cascadeOnDelete();
            $table->date('date');
            $table->decimal('amount', 15, 2);
            $table->timestamps();

            $table->index(['property_payment_plan_id', 'date']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('property_payment_plan_entries');
    }
};
