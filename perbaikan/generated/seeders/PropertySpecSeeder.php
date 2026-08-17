<?php

namespace Database\Seeders;

use App\Models\Property;
use Illuminate\Database\Seeder;

class PropertySpecSeeder extends Seeder
{
    public function run(): void
    {
        $specs = [
            'Sunset Beach Apartment' => [
                ['icon' => 'furnished', 'label' => 'Full Furnished'],
                ['icon' => 'bedroom', 'label' => '2'],
                ['icon' => 'bathroom', 'label' => '2'],
                ['icon' => 'size', 'label' => '100m2'],
            ],
        ];

        foreach ($specs as $propertyName => $items) {
            $property = Property::where('name', $propertyName)->first();
            if (!$property) {
                continue;
            }

            foreach ($items as $index => $item) {
                \App\Models\PropertySpec::create([
                    'property_id' => $property->id,
                    ...$item,
                    'sort_order' => $index,
                ]);
            }
        }
    }
}
