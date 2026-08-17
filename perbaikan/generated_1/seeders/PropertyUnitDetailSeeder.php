<?php

namespace Database\Seeders;

use App\Models\Property;
use Illuminate\Database\Seeder;

class PropertyUnitDetailSeeder extends Seeder
{
    public function run(): void
    {
        $units = [
            'Sunset Beach Apartment' => [
                ['icon' => 'building', 'label' => 'Gedung', 'value' => 'Apartemen Sunset Towers'],
                ['icon' => 'building', 'label' => 'Tower', 'value' => '1'],
                ['icon' => 'building', 'label' => 'Lantai', 'value' => '5'],
                ['icon' => 'calendar', 'label' => 'Property Tayang Sejak', 'value' => '14 Agt 2026'],
                ['icon' => 'car', 'label' => 'Parkir', 'value' => 'Mobil: Biaya kartu 50000, Biaya perbulan 500000; Motor: Biaya kartu 25000, Biaya perbulan 150000'],
            ],
        ];

        foreach ($units as $propertyName => $items) {
            $property = Property::where('name', $propertyName)->first();
            if (!$property) {
                continue;
            }

            foreach ($items as $index => $item) {
                \App\Models\PropertyUnitDetail::create([
                    'property_id' => $property->id,
                    ...$item,
                    'sort_order' => $index,
                ]);
            }
        }
    }
}
