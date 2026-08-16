<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('properties_other', function (Blueprint $table) {
            $table->id();
            $table->foreignId('property_id')->constrained('properties')->cascadeOnDelete()->unique();
            $table->string('province')->nullable();
            $table->string('cover')->nullable();
            $table->string('cover_image')->nullable();
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
            $table->json('specs')->nullable();
            $table->boolean('is_favorite')->default(false);
            $table->text('intro')->nullable();
            $table->json('description_extra')->nullable();
            $table->string('description_extra_heading')->nullable();
            $table->string('map_preview')->nullable();
            $table->string('price_caption')->default('per bulan mulai dari');
            $table->boolean('is_flash_sale')->default(false);
            $table->json('bed_facilities')->nullable();
            $table->json('building_facilities')->nullable();
            $table->json('building_facilities_all')->nullable();
            $table->json('room_furniture')->nullable();
            $table->json('room_furniture_groups')->nullable();
            $table->json('check_in_notes')->nullable();
            $table->decimal('deposit_amount', 15, 2)->nullable();
            $table->json('deposit_notes')->nullable();
            $table->json('unit_detail')->nullable();
            $table->json('nearby')->nullable();
            $table->json('guest_media')->nullable();
            $table->json('building_units')->nullable();
            $table->json('review_summary')->nullable();
            $table->timestamps();

            $table->index(['property_id']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('properties_other');
    }
};
