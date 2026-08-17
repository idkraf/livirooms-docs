<?php

namespace Database\Seeders;

use App\Models\Property;
use Illuminate\Database\Seeder;

class PropertyNearbyPlaceSeeder extends Seeder
{
    public function run(): void
    {
        $nearby = [
            'Sunset Beach Apartment' => [
                ['name' => 'Cafe Batavia', 'type' => 'mall', 'distance' => '1.2 km', 'icon' => 'place'],
                ['name' => 'Museum Bank Mandiri', 'type' => 'attraction', 'distance' => '1.5 km', 'icon' => 'place'],
                ['name' => 'Pasar Asemka', 'type' => 'mall', 'distance' => '2.0 km', 'icon' => 'place'],
                ['name' => 'Pasar Petak Sembilan', 'type' => 'mall', 'distance' => '2.3 km', 'icon' => 'place'],
                ['name' => 'Toko Merah', 'type' => 'attraction', 'distance' => '1.8 km', 'icon' => 'place'],
                ['name' => 'Candra Naya', 'type' => 'attraction', 'distance' => '1.4 km', 'icon' => 'place'],
            ],
        ];

        foreach ($nearby as $propertyName => $places) {
            $property = Property::where('name', $propertyName)->first();
            if (!$property) {
                continue;
            }

            foreach ($places as $index => $place) {
                \App\Models\PropertyNearbyPlace::create([
                    'property_id' => $property->id,
                    ...$place,
                    'sort_order' => $index,
                ]);
            }
        }
    }
}
