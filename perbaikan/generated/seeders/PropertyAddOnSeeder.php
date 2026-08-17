<?php

namespace Database\Seeders;

use App\Models\Property;
use Illuminate\Database\Seeder;

class PropertyAddOnSeeder extends Seeder
{
    public function run(): void
    {
        $defaults = [
            ['name' => 'Asuransi', 'duration_note' => 'per malam', 'price' => 25000, 'info' => 'Perlindungan asuransi untuk tamu'],
            ['name' => 'Late Checkout', 'duration_note' => 'per malam', 'price' => 100000, 'info' => 'Check-out sampai 18:00'],
            ['name' => 'Early Checkin', 'duration_note' => 'per malam', 'price' => 100000, 'info' => 'Check-in dari 10:00'],
        ];

        Property::all()->each(function ($property) use ($defaults) {
            foreach ($defaults as $index => $data) {
                \App\Models\PropertyAddOn::create([
                    'property_id' => $property->id,
                    ...$data,
                    'is_selected' => false,
                    'sort_order' => $index,
                ]);
            }
        });
    }
}
