<?php

namespace Database\Seeders;

use App\Models\Property;
use Illuminate\Database\Seeder;

class PropertyOtherCoreSeeder extends Seeder
{
    public function run(): void
    {
        $properties = Property::all();

        foreach ($properties as $property) {
            \App\Models\PropertyOtherCore::updateOrCreate(
                ['property_id' => $property->id],
                [
                    'province' => 'DKI Jakarta',
                    'price_from' => $property->prices()->min('amount') ?? 0,
                    'rating' => 4.5,
                    'review_count' => 0,
                    'star_rating' => null,
                    'check_in_time' => '14:00:00',
                    'check_out_time' => '12:00:00',
                    'has_breakfast' => false,
                    'type_label' => ucfirst(str_replace('_', ' ', $property->property_type)),
                    'area_label' => $property->city?->name ?? '',
                    'extra_media_count' => 0,
                    'intro' => $property->description ?? '',
                    'description_extra_heading' => 'Deskripsi Properti:',
                    'map_preview' => 'https://example.com/map_preview.jpg',
                    'price_caption' => 'per bulan mulai dari',
                    'is_flash_sale' => false,
                    'deposit_amount' => 0,
                    'schedule_note' => '*Simulasi hanya mencakup biaya layanan; diskon dan biaya lainnya tidak termasuk',
                ]
            );
        }
    }
}
