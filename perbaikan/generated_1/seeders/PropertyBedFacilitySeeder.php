<?php

namespace Database\Seeders;

use App\Models\Property;
use Illuminate\Database\Seeder;

class PropertyBedFacilitySeeder extends Seeder
{
    public function run(): void
    {
        $bedFacilities = [
            'Sunset Beach Apartment' => [
                ['icon' => 'king_bed', 'label' => 'King Bed', 'note' => '(180x200)', 'count' => null],
                ['icon' => 'single_bed', 'label' => 'Single Bed', 'note' => '(120x200)', 'count' => 1],
            ],
        ];

        foreach ($bedFacilities as $propertyName => $items) {
            $property = Property::where('name', $propertyName)->first();
            if (!$property) {
                continue;
            }

            foreach ($items as $index => $item) {
                \App\Models\PropertyBedFacility::create([
                    'property_id' => $property->id,
                    ...$item,
                    'sort_order' => $index,
                ]);
            }
        }
    }
}
