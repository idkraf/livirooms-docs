<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('hotel_policies', function (Blueprint $table) {
            $table->id();
            $table->foreignId('hotel_id')->constrained('hotels')->cascadeOnDelete()->unique();
            $table->boolean('receptionist_24h')->default(false);
            $table->boolean('allow_children')->default(false);
            $table->boolean('extra_bed_available')->default(false);
            $table->text('child_policy')->nullable();
            $table->text('extra_bed_policy')->nullable();
            $table->text('smoking_policy')->nullable();
            $table->decimal('deposit_amount', 12, 2)->nullable();
            $table->string('deposit_currency', 3)->nullable();
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('hotel_policies');
    }
};
