<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('model_has_facilities', function (Blueprint $table) {
            $table->id();
            $table->foreignId('facility_id')->constrained('facilities')->cascadeOnDelete();
            $table->string('model_type');
            $table->unsignedBigInteger('model_id');
            $table->boolean('is_available')->default(true);
            $table->string('badge')->nullable();
            $table->unsignedInteger('sort_order')->default(0);
            $table->timestamps();

            $table->unique(['facility_id', 'model_type', 'model_id']);
            $table->index(['model_type', 'model_id', 'sort_order']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('model_has_facilities');
    }
};
