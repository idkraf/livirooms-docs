<?php

namespace Database\Seeders;

use App\Models\Property;
use Illuminate\Database\Seeder;

class PropertyBuildingFacilityAllSeeder extends Seeder
{
    public function run(): void
    {
        $facilities = [
            'Sunset Beach Apartment' => [
                '24-Hour Security',
                'Access Card',
                'Elevator',
                'Gym',
                'Swimming Pool',
            ],
        ];

        foreach ($facilities as $propertyName => $items) {
            $property = Property::where('name', $propertyName)->first();
            if (!$property) {
                continue;
            }

            foreach ($items as $index => $name) {
                \App\Models\PropertyBuildingFacilityAll::create([
                    'property_id' => $property->id,
                    'name' => $name,
                    'sort_order' => $index,
                ]);
            }
        }
    }
}
