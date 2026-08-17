<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('hotel_facilities', function (Blueprint $table) {
            $table->id();
            $table->foreignId('hotel_facility_group_id')->constrained('hotel_facility_groups')->cascadeOnDelete();
            $table->string('name');
            $table->boolean('is_available')->default(true);
            $table->string('badge')->nullable();
            $table->unsignedInteger('sort_order')->default(0);
            $table->timestamps();

            $table->index(['hotel_facility_group_id', 'sort_order']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('hotel_facilities');
    }
};
