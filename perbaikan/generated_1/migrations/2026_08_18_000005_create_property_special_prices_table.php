<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('property_special_prices', function (Blueprint $table) {
            $table->id();
            $table->foreignId('property_id')->constrained('properties')->cascadeOnDelete();
            $table->unsignedInteger('min_nights');
            $table->unsignedInteger('discount_percent');
            $table->timestamps();

            $table->index(['property_id', 'min_nights']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('property_special_prices');
    }
};
