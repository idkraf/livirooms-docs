<?php

namespace Database\Seeders;

use App\Models\Hotel;
use Illuminate\Database\Seeder;

class HotelFacilityGroupSeeder extends Seeder
{
    public function run(): void
    {
        $groups = [
            'Merlynn Park Hotel' => [
                ['name' => 'Fasilitas Utama', 'icon' => 'star', 'items' => [
                    ['name' => '3 Kolam Renang (Infinity Pool & Kolam Anak)', 'is_available' => true, 'badge' => null],
                    ['name' => 'Pusat Kebugaran / Gym Modern', 'is_available' => true, 'badge' => null],
                    ['name' => 'Man Salon & Spa with Sauna', 'is_available' => true, 'badge' => null],
                    ['name' => 'Wi-Fi Kecepatan Tinggi Gratis', 'is_available' => true, 'badge' => null],
                    ['name' => 'Resepsionis & Keamanan 24 Jam', 'is_available' => true, 'badge' => null],
                    ['name' => 'Parkir Valet Gratis', 'is_available' => true, 'badge' => null],
                    ['name' => 'Bathtub di Semua Kamar', 'is_available' => true, 'badge' => null],
                ]],
                ['name' => 'Makanan & Minuman', 'icon' => 'restaurant', 'items' => [
                    ['name' => 'Grand Central Restaurant (Prasmanan Nusantara & Western)', 'is_available' => true, 'badge' => null],
                    ['name' => 'Grand City Restaurant (Authentic Chinese Cuisine)', 'is_available' => true, 'badge' => null],
                    ['name' => 'Times Square Bar & Lounge', 'is_available' => true, 'badge' => null],
                    ['name' => 'Layanan Kamar 24 Jam', 'is_available' => true, 'badge' => null],
                ]],
                ['name' => 'Kesehatan & Rekreasi', 'icon' => 'spa', 'items' => [
                    ['name' => 'Kolam Renang Lantai 5 (Semi-Outdoor & Sun Lounger)', 'is_available' => true, 'badge' => null],
                    ['name' => 'Pusat Kebugaran dengan Instruktur', 'is_available' => true, 'badge' => null],
                    ['name' => 'Ruang Sauna & Steam Room', 'is_available' => true, 'badge' => null],
                    ['name' => 'Layanan Pijat & Perawatan Spa Tradisional', 'is_available' => true, 'badge' => null],
                ]],
                ['name' => 'Transportasi & Sekitar', 'icon' => 'directions_car', 'items' => [
                    ['name' => 'Layanan Antar-Jemput Bandara CGK / Halim', 'is_available' => true, 'badge' => null],
                    ['name' => 'Rental Mobil Berpengemudi', 'is_available' => true, 'badge' => null],
                    ['name' => 'Akses Taksi & Transportasi Online 24 Jam', 'is_available' => true, 'badge' => null],
                ]],
                ['name' => 'Bisnis & Acara', 'icon' => 'business_center', 'items' => [
                    ['name' => 'Merlynn Grand Ballroom (Kapasitas hingga 1.500 Orang)', 'is_available' => true, 'badge' => null],
                    ['name' => '15 Ruang Rapat & Konferensi Modern', 'is_available' => true, 'badge' => null],
                    ['name' => 'Pusat Bisnis & Layanan Fotokopi/Pencetakan', 'is_available' => true, 'badge' => null],
                ]],
            ],
            'Grand Cemara Hotel' => [
                ['name' => 'Fasilitas Utama', 'icon' => 'star', 'items' => [
                    ['name' => 'Kolam Renang Luar Ruangan', 'is_available' => true, 'badge' => null],
                    ['name' => 'Cemara Resto & Bar', 'is_available' => true, 'badge' => null],
                    ['name' => 'Wi-Fi Gratis', 'is_available' => true, 'badge' => null],
                    ['name' => 'Resepsionis 24 Jam', 'is_available' => true, 'badge' => null],
                ]],
            ],
            'YELLO Hotel Harmoni' => [
                ['name' => 'Fasilitas Utama', 'icon' => 'star', 'items' => [
                    ['name' => 'Restoran WOKnTOK 24 Jam', 'is_available' => true, 'badge' => null],
                    ['name' => 'Gaming Station & NetZone', 'is_available' => true, 'badge' => null],
                    ['name' => 'Gym Modern', 'is_available' => true, 'badge' => null],
                    ['name' => 'Wi-Fi Kecepatan Tinggi', 'is_available' => true, 'badge' => null],
                    ['name' => 'Resepsionis 24 Jam', 'is_available' => true, 'badge' => null],
                ]],
                ['name' => 'Hiburan & Komunitas', 'icon' => 'sports_esports', 'items' => [
                    ['name' => 'Gaming Zone PlayStation & Gadget', 'is_available' => true, 'badge' => null],
                    ['name' => 'Chill Spot & Co-Working Corner', 'is_available' => true, 'badge' => null],
                    ['name' => 'Koleksi Street Art Gallery', 'is_available' => true, 'badge' => null],
                ]],
            ],
            'Artotel Harmoni Jakarta' => [
                ['name' => 'Fasilitas Utama', 'icon' => 'star', 'items' => [
                    ['name' => 'Kolam Renang Outdoor', 'is_available' => true, 'badge' => null],
                    ['name' => 'ROCA Restaurant & Lounge Bar', 'is_available' => true, 'badge' => null],
                    ['name' => 'ARTSPACE Galeri Seni', 'is_available' => true, 'badge' => null],
                    ['name' => 'Gym Modern', 'is_available' => true, 'badge' => null],
                    ['name' => 'Wi-Fi Cepat', 'is_available' => true, 'badge' => null],
                ]],
            ],
            'MaxOne Platinum Hayam Wuruk' => [
                ['name' => 'Fasilitas Utama', 'icon' => 'star', 'items' => [
                    ['name' => 'SkyMax Rooftop Resto & Bar', 'is_available' => true, 'badge' => null],
                    ['name' => 'Max Spa & Pijat', 'is_available' => true, 'badge' => null],
                    ['name' => 'Wi-Fi Gratis', 'is_available' => true, 'badge' => null],
                    ['name' => 'Resepsionis 24 Jam', 'is_available' => true, 'badge' => null],
                ]],
            ],
        ];

        foreach ($groups as $hotelName => $hotelGroups) {
            $hotel = Hotel::whereHas('property', function ($q) use ($hotelName) {
                $q->where('name', $hotelName);
            })->first();

            if (!$hotel) {
                continue;
            }

            foreach ($hotelGroups as $groupIndex => $group) {
                $groupModel = \App\Models\HotelFacilityGroup::create([
                    'hotel_id' => $hotel->id,
                    'name' => $group['name'],
                    'icon' => $group['icon'],
                    'sort_order' => $groupIndex,
                ]);

                foreach ($group['items'] as $itemIndex => $item) {
                    \App\Models\HotelFacility::create([
                        'hotel_facility_group_id' => $groupModel->id,
                        ...$item,
                        'sort_order' => $itemIndex,
                    ]);
                }
            }
        }
    }
}
