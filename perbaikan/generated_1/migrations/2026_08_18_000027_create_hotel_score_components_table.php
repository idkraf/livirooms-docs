<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('hotel_score_components', function (Blueprint $table) {
            $table->id();
            $table->foreignId('hotel_id')->constrained('hotels')->cascadeOnDelete();
            $table->string('component');
            $table->decimal('score', 3, 2);
            $table->timestamps();

            $table->unique(['hotel_id', 'component']);
            $table->index(['hotel_id', 'component']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('hotel_score_components');
    }
};
