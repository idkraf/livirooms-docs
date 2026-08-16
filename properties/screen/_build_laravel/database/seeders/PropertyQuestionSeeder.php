<?php

namespace Database\Seeders;

use App\Models\Property;
use App\Models\PropertyQuestion;
use Illuminate\Database\Seeder;

class PropertyQuestionSeeder extends Seeder
{
    public function run(): void
    {
        $property = Property::where('name', 'Sunset Beach Apartment')->first();
        if (!$property) {
            return;
        }

        $questions = [
            [
                'property_id' => $property->id,
                'asked_by' => null,
                'question' => 'Apakah ada lift?',
                'answer' => 'Ya, ada 2 lift.',
                'created_at' => '2026-07-15 10:00:00',
            ],
            [
                'property_id' => $property->id,
                'asked_by' => null,
                'question' => 'Bisa check-in lebih awal?',
                'answer' => null,
                'created_at' => '2026-07-14 08:00:00',
            ],
        ];

        foreach ($questions as $data) {
            PropertyQuestion::create($data);
        }
    }
}
