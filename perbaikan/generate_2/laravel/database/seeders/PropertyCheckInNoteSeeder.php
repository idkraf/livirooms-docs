<?php

namespace Database\Seeders;

use App\Models\Property;
use Illuminate\Database\Seeder;

class PropertyCheckInNoteSeeder extends Seeder
{
    public function run(): void
    {
        $notes = [
            'Sunset Beach Apartment' => [
                ['icon' => 'info', 'title' => 'Info', 'text' => 'Harap mengatur waktu check-in Anda di aplikasi 4 jam sebelum kedatangan.', 'tone' => 'warning'],
                ['icon' => 'cleaning', 'title' => 'Cleaning', 'text' => "Unit dan linen hanya akan dibersihkan setelah check-out.\nPermintaan tambahan selama menginap tersedia dengan biaya tambahan.", 'tone' => 'brand'],
                ['icon' => 'terms', 'title' => 'Syarat & Ketentuan Gedung', 'text' => 'Penggunaan fasilitas gedung dan parkir mengikuti aturan yang berlaku dari masing-masing gedung.', 'tone' => 'info'],
            ],
        ];

        foreach ($notes as $propertyName => $items) {
            $property = Property::where('name', $propertyName)->first();
            if (!$property) {
                continue;
            }

            foreach ($items as $index => $item) {
                \App\Models\PropertyCheckInNote::create([
                    'property_id' => $property->id,
                    ...$item,
                    'sort_order' => $index,
                ]);
            }
        }
    }
}
