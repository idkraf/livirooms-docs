<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('property_review_summaries', function (Blueprint $table) {
            $table->id();
            $table->foreignId('property_id')->constrained('properties')->cascadeOnDelete()->unique();
            $table->decimal('average', 3, 2)->nullable();
            $table->unsignedInteger('total')->default(0);
            $table->string('label')->nullable();
            $table->timestamps();
        });

        Schema::create('property_review_breakdowns', function (Blueprint $table) {
            $table->id();
            $table->foreignId('property_review_summary_id')->constrained('property_review_summaries')->cascadeOnDelete();
            $table->unsignedInteger('rating');
            $table->unsignedInteger('count')->default(0);
            $table->timestamps();

            $table->index(['property_review_summary_id', 'rating']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('property_review_breakdowns');
        Schema::dropIfExists('property_review_summaries');
    }
};
