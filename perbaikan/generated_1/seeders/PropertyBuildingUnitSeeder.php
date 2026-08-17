<?php

namespace Database\Seeders;

use App\Models\Property;
use Illuminate\Database\Seeder;

class PropertyBuildingUnitSeeder extends Seeder
{
    public function run(): void
    {
        $units = [
            'Sunset Beach Apartment' => [
                ['type' => 'Apartemen', 'count' => 3, 'icon' => 'apartment'],
            ],
        ];

        foreach ($units as $propertyName => $items) {
            $property = Property::where('name', $propertyName)->first();
            if (!$property) {
                continue;
            }

            foreach ($items as $index => $item) {
                \App\Models\PropertyBuildingUnit::create([
                    'property_id' => $property->id,
                    ...$item,
                    'sort_order' => $index,
                ]);
            }
        }
    }
}
