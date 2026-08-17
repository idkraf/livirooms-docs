<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('property_other_core', function (Blueprint $table) {
            $table->id();
            $table->foreignId('property_id')->constrained('properties')->cascadeOnDelete()->unique();
            $table->string('province')->nullable();
            $table->decimal('price_from', 15, 2)->nullable();
            $table->decimal('rating', 3, 2)->nullable();
            $table->unsignedInteger('review_count')->default(0);
            $table->unsignedTinyInteger('star_rating')->nullable();
            $table->time('check_in_time')->nullable();
            $table->time('check_out_time')->nullable();
            $table->boolean('has_breakfast')->default(false);
            $table->string('type_label')->nullable();
            $table->string('area_label')->nullable();
            $table->unsignedInteger('extra_media_count')->default(0);
            $table->text('intro')->nullable();
            $table->string('description_extra_heading')->nullable();
            $table->string('map_preview')->nullable();
            $table->string('price_caption')->default('per bulan mulai dari');
            $table->boolean('is_flash_sale')->default(false);
            $table->decimal('deposit_amount', 15, 2)->nullable();
            $table->text('schedule_note')->nullable();
            $table->timestamps();

            $table->index(['property_id']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('property_other_core');
    }
};
