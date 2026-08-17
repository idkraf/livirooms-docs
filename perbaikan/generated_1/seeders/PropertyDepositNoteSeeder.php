<?php

namespace Database\Seeders;

use App\Models\Property;
use Illuminate\Database\Seeder;

class PropertyDepositNoteSeeder extends Seeder
{
    public function run(): void
    {
        $notes = [
            'Sunset Beach Apartment' => [
                ['icon' => 'info', 'title' => 'Pemesanan Tahunan', 'text' => "Jika tagihan pemakaian listrik dan air tidak dapat langsung dipotong, biaya akan dihitung berdasarkan tagihan dari Pengelola Gedung.\nPengembalian dana melalui transfer bank: hingga 7 hari kerja.\nKartu kredit: hingga 21 hari kerja setelah tagihan diterima."],
            ],
        ];

        foreach ($notes as $propertyName => $items) {
            $property = Property::where('name', $propertyName)->first();
            if (!$property) {
                continue;
            }

            foreach ($items as $index => $item) {
                \App\Models\PropertyDepositNote::create([
                    'property_id' => $property->id,
                    ...$item,
                    'sort_order' => $index,
                ]);
            }
        }
    }
}
