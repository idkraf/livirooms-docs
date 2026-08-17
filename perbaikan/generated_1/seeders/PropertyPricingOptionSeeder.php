<?php

namespace Database\Seeders;

use App\Models\Property;
use Illuminate\Database\Seeder;

class PropertyPricingOptionSeeder extends Seeder
{
    public function run(): void
    {
        $defaults = [1, 2, 3, 6, 12];

        Property::all()->each(function ($property) use ($defaults) {
            foreach ($defaults as $index => $nights) {
                \App\Models\PropertyPricingOption::create([
                    'property_id' => $property->id,
                    'nights' => $nights,
                    'sort_order' => $index,
                ]);
            }
        });
    }
}
