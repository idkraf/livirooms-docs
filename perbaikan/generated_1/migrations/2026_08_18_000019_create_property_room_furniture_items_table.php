<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('property_room_furniture_items', function (Blueprint $table) {
            $table->id();
            $table->foreignId('property_room_furniture_group_id')->constrained('property_room_furniture_groups')->cascadeOnDelete();
            $table->string('icon')->nullable();
            $table->string('label');
            $table->unsignedInteger('sort_order')->default(0);
            $table->timestamps();

            $table->index(['property_room_furniture_group_id', 'sort_order']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('property_room_furniture_items');
    }
};
