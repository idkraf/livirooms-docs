<?php

namespace Database\Seeders;

use App\Models\Property;
use Illuminate\Database\Seeder;

class PropertyExtraDescriptionSeeder extends Seeder
{
    public function run(): void
    {
        $descriptions = [
            'Sunset Beach Apartment' => [
                'Apartemen ini berada di kawasan pantai indah dengan akses mudah ke tempat wisata.',
                'Gedung ini dilengkapi keamanan 24 jam, lift, gym, serta kolam renang.',
            ],
        ];

        foreach ($descriptions as $propertyName => $texts) {
            $property = Property::where('name', $propertyName)->first();
            if (!$property) {
                continue;
            }

            foreach ($texts as $index => $text) {
                \App\Models\PropertyExtraDescription::create([
                    'property_id' => $property->id,
                    'text' => $text,
                    'sort_order' => $index,
                ]);
            }
        }
    }
}
