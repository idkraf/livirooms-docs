<?php

namespace Database\Seeders;

use App\Models\Property;
use Illuminate\Database\Seeder;

class PropertyPromoSeeder extends Seeder
{
    public function run(): void
    {
        Property::all()->each(function ($property) {
            \App\Models\PropertyPromo::create([
                'property_id' => $property->id,
                'code' => 'WELCOME' . strtoupper(substr($property->name, 0, 3)),
                'discount_type' => 'percent',
                'discount_value' => 10,
                'valid_from' => now()->subMonth()->format('Y-m-d'),
                'valid_until' => now()->addMonths(3)->format('Y-m-d'),
                'is_active' => true,
            ]);
        });
    }
}
