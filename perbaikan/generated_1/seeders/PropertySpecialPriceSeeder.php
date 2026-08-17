<?php

namespace Database\Seeders;

use App\Models\Property;
use Illuminate\Database\Seeder;

class PropertySpecialPriceSeeder extends Seeder
{
    public function run(): void
    {
        $defaults = [
            ['min_nights' => 7, 'discount_percent' => 5],
            ['min_nights' => 14, 'discount_percent' => 10],
            ['min_nights' => 30, 'discount_percent' => 20],
        ];

        Property::all()->each(function ($property) use ($defaults) {
            foreach ($defaults as $data) {
                \App\Models\PropertySpecialPrice::create([
                    'property_id' => $property->id,
                    ...$data,
                ]);
            }
        });
    }
}
