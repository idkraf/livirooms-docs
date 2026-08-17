<?php

namespace Database\Seeders;

use App\Models\Property;
use Illuminate\Database\Seeder;

class PropertyBuildingFacilitySeeder extends Seeder
{
    public function run(): void
    {
        $facilities = [
            'Sunset Beach Apartment' => [
                ['icon' => 'pool', 'label' => 'Kolam Renang', 'is_highlighted' => true],
                ['icon' => 'security', 'label' => 'Keamanan 24 Jam', 'is_highlighted' => true],
                ['icon' => 'access_card', 'label' => 'Kartu Akses', 'is_highlighted' => false],
                ['icon' => 'elevator', 'label' => 'Lift', 'is_highlighted' => false],
            ],
        ];

        foreach ($facilities as $propertyName => $items) {
            $property = Property::where('name', $propertyName)->first();
            if (!$property) {
                continue;
            }

            foreach ($items as $index => $item) {
                \App\Models\PropertyBuildingFacility::create([
                    'property_id' => $property->id,
                    ...$item,
                    'sort_order' => $index,
                ]);
            }
        }
    }
}
