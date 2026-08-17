<?php

namespace Database\Seeders;

use App\Models\Facility;
use App\Models\Property;
use Illuminate\Database\Seeder;

class PropertyFacilitySeeder extends Seeder
{
    public function run(): void
    {
        $facilitiesMap = [
            'Peaceful Living in Spacious 3BR at Apartment Lucky Tower Residence By Travelio' => [
                'wifi', 'ac', 'kitchen', 'parking', 'swimming_pool', 'tv', 'washing_machine', 'security', 'elevator',
            ],
            'Big and Cozy 3BR Apartment Lucky Tower Residence By Travelio' => [
                'wifi', 'ac', 'kitchen', 'parking', 'swimming_pool', 'tv', 'washing_machine', 'security', 'elevator',
            ],
            'Fabulous 2BR Apartment Lucky Tower Residence By Travelio' => [
                'wifi', 'ac', 'kitchen', 'parking', 'swimming_pool', 'tv', 'security', 'elevator',
            ],
            'Modern Look 2BR at Lucky Tower Residence Apartment By Travelio' => [
                'wifi', 'ac', 'kitchen', 'parking', 'swimming_pool', 'tv', 'security', 'elevator',
            ],
            'Sunset Beach Apartment' => [],
            'Merlynn Park Hotel' => [
                'Kolam Renang Infinity', 'Kolam Renang Anak', 'Pusat Kebugaran / Gym',
                'Spa & Sauna', 'Restoran Internasional', 'Bar Lobi & Lounge',
                'Wi-Fi Gratis di Semua Area', 'Resepsionis 24 Jam', 'Area Parkir Gratis',
                'Bathtub di Setiap Kamar', 'Layanan Kamar 24 Jam', 'Antar-Jemput Bandara',
            ],
            'Grand Cemara Hotel' => [
                'Kolam Renang Luar Ruangan', 'Pusat Kebugaran / Gym', 'Cemara Resto & Bar',
                'Wi-Fi Gratis', 'Resepsionis 24 Jam', 'Area Parkir Gratis',
            ],
            'YELLO Hotel Harmoni' => [
                'WOKnTOK Restaurant 24 Jam', 'Gaming Station & NetZone', 'Pusat Kebugaran / Gym',
                'Chill Spot Lounge', 'Wi-Fi Kecepatan Tinggi Gratis', 'Resepsionis 24 Jam',
                'Layanan Kamar', 'Ruang Pertemuan Kreatif', 'Area Parkir',
            ],
            'Artotel Harmoni Jakarta' => [
                'Kolam Renang Outdoor', 'ROCA Restaurant & Bar', 'ARTSPACE Gallery',
                'Pusat Kebugaran / Gym', 'Wi-Fi Gratis di Seluruh Area', 'Resepsionis 24 Jam',
                'Layanan Kamar 24 Jam', 'Mesin Kopi Dolce Gusto di Kamar',
            ],
            'MaxOne Platinum Hayam Wuruk' => [
                'SkyMax Rooftop Bar & Bistro', 'Max Spa & Reflexology', 'Wi-Fi Kecepatan Tinggi Gratis',
                'Resepsionis 24 Jam', 'Ruang Rapat Bisnis', 'Layanan Kamar', 'Area Parkir',
            ],
        ];

        foreach ($facilitiesMap as $propertyName => $facilities) {
            $property = Property::where('name', $propertyName)->first();
            if (!$property) {
                continue;
            }

            foreach ($facilities as $index => $name) {
                $facility = Facility::where('name', $name)->first();
                \App\Models\ModelHasFacility::create([
                    'facility_id' => $facility?->id,
                    'model_type' => \App\Models\Property::class,
                    'model_id' => $property->id,
                    'is_available' => true,
                    'badge' => null,
                    'sort_order' => $index,
                ]);
            }
        }
    }
}
