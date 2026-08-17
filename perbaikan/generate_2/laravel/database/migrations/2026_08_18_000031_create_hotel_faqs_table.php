<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('hotel_faqs', function (Blueprint $table) {
            $table->id();
            $table->foreignId('hotel_id')->constrained('hotels')->cascadeOnDelete();
            $table->text('question');
            $table->text('answer')->nullable();
            $table->string('author_name')->nullable();
            $table->string('author_role')->nullable();
            $table->unsignedInteger('sort_order')->default(0);
            $table->timestamps();

            $table->index(['hotel_id', 'sort_order']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('hotel_faqs');
    }
};
