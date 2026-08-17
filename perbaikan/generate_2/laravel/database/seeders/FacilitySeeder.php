<?php

namespace Database\Seeders;

use App\Models\Facility;
use App\Models\Property;
use Illuminate\Database\Seeder;

class FacilitySeeder extends Seeder
{
    public function run(): void
    {
        $facilities = [
            ['name' => 'wifi', 'icon' => 'wifi', 'category' => 'property', 'is_active' => true],
            ['name' => 'ac', 'icon' => 'ac', 'category' => 'room', 'is_active' => true],
            ['name' => 'kitchen', 'icon' => 'kitchen', 'category' => 'property', 'is_active' => true],
            ['name' => 'parking', 'icon' => 'parking', 'category' => 'property', 'is_active' => true],
            ['name' => 'swimming_pool', 'icon' => 'pool', 'category' => 'property', 'is_active' => true],
            ['name' => 'tv', 'icon' => 'tv', 'category' => 'room', 'is_active' => true],
            ['name' => 'washing_machine', 'icon' => 'washing_machine', 'category' => 'property', 'is_active' => true],
            ['name' => 'security', 'icon' => 'security', 'category' => 'property', 'is_active' => true],
            ['name' => 'elevator', 'icon' => 'elevator', 'category' => 'property', 'is_active' => true],
            ['name' => 'Kolam Renang Infinity', 'icon' => 'pool', 'category' => 'property', 'is_active' => true],
            ['name' => 'Kolam Renang Anak', 'icon' => 'pool', 'category' => 'property', 'is_active' => true],
            ['name' => 'Pusat Kebugaran / Gym', 'icon' => 'fitness', 'category' => 'property', 'is_active' => true],
            ['name' => 'Spa & Sauna', 'icon' => 'spa', 'category' => 'property', 'is_active' => true],
            ['name' => 'Restoran Internasional', 'icon' => 'restaurant', 'category' => 'property', 'is_active' => true],
            ['name' => 'Bar Lobi & Lounge', 'icon' => 'bar', 'category' => 'property', 'is_active' => true],
            ['name' => 'Wi-Fi Gratis di Semua Area', 'icon' => 'wifi', 'category' => 'property', 'is_active' => true],
            ['name' => 'Resepsionis 24 Jam', 'icon' => 'concierge', 'category' => 'property', 'is_active' => true],
            ['name' => 'Area Parkir Gratis', 'icon' => 'parking', 'category' => 'property', 'is_active' => true],
            ['name' => 'Bathtub di Setiap Kamar', 'icon' => 'bathtub', 'category' => 'room', 'is_active' => true],
            ['name' => 'Layanan Kamar 24 Jam', 'icon' => 'room_service', 'category' => 'property', 'is_active' => true],
            ['name' => 'Antar-Jemput Bandara', 'icon' => 'airport_shuttle', 'category' => 'property', 'is_active' => true],
            ['name' => 'Kolam Renang Luar Ruangan', 'icon' => 'pool', 'category' => 'property', 'is_active' => true],
            ['name' => 'Cemara Resto & Bar', 'icon' => 'restaurant', 'category' => 'property', 'is_active' => true],
            ['name' => 'WOKnTOK Restaurant 24 Jam', 'icon' => 'restaurant', 'category' => 'property', 'is_active' => true],
            ['name' => 'Gaming Station & NetZone', 'icon' => 'sports_esports', 'category' => 'property', 'is_active' => true],
            ['name' => 'Chill Spot Lounge', 'icon' => 'lounge', 'category' => 'property', 'is_active' => true],
            ['name' => 'Wi-Fi Kecepatan Tinggi Gratis', 'icon' => 'wifi', 'category' => 'property', 'is_active' => true],
            ['name' => 'Layanan Kamar', 'icon' => 'room_service', 'category' => 'property', 'is_active' => true],
            ['name' => 'Ruang Pertemuan Kreatif', 'icon' => 'business_center', 'category' => 'property', 'is_active' => true],
            ['name' => 'Area Parkir', 'icon' => 'parking', 'category' => 'property', 'is_active' => true],
            ['name' => 'Kolam Renang Outdoor', 'icon' => 'pool', 'category' => 'property', 'is_active' => true],
            ['name' => 'ROCA Restaurant & Bar', 'icon' => 'restaurant', 'category' => 'property', 'is_active' => true],
            ['name' => 'ARTSPACE Gallery', 'icon' => 'gallery', 'category' => 'property', 'is_active' => true],
            ['name' => 'Pusat Kebugaran / Gym', 'icon' => 'fitness', 'category' => 'property', 'is_active' => true],
            ['name' => 'Wi-Fi Gratis di Seluruh Area', 'icon' => 'wifi', 'category' => 'property', 'is_active' => true],
            ['name' => 'Layanan Kamar 24 Jam', 'icon' => 'room_service', 'category' => 'property', 'is_active' => true],
            ['name' => 'Mesin Kopi Dolce Gusto di Kamar', 'icon' => 'coffee', 'category' => 'room', 'is_active' => true],
            ['name' => 'SkyMax Rooftop Bar & Bistro', 'icon' => 'bar', 'category' => 'property', 'is_active' => true],
            ['name' => 'Max Spa & Reflexology', 'icon' => 'spa', 'category' => 'property', 'is_active' => true],
            ['name' => 'Ruang Rapat Bisnis', 'icon' => 'business_center', 'category' => 'property', 'is_active' => true],
        ];

        foreach ($facilities as $facility) {
            Facility::updateOrCreate(
                ['name' => $facility['name'], 'category' => $facility['category']],
                $facility
            );
        }
    }
}
