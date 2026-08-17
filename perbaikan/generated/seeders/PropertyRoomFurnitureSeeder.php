<?php

namespace Database\Seeders;

use App\Models\Property;
use Illuminate\Database\Seeder;

class PropertyRoomFurnitureSeeder extends Seeder
{
    public function run(): void
    {
        $furniture = [
            'Sunset Beach Apartment' => [
                ['icon' => 'water_heater', 'label' => 'Water Heater', 'count' => 2],
                ['icon' => 'kitchen_utensil', 'label' => 'Kitchen Utensil', 'count' => null],
                ['icon' => 'washing_machine', 'label' => 'Washing Machine', 'count' => null],
                ['icon' => 'ac', 'label' => 'AC', 'count' => 4],
            ],
        ];

        foreach ($furniture as $propertyName => $items) {
            $property = Property::where('name', $propertyName)->first();
            if (!$property) {
                continue;
            }

            foreach ($items as $index => $item) {
                \App\Models\PropertyRoomFurniture::create([
                    'property_id' => $property->id,
                    ...$item,
                    'sort_order' => $index,
                ]);
            }
        }
    }
}
