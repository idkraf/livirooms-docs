<?php

namespace Database\Seeders;

use App\Models\Hotel;
use Illuminate\Database\Seeder;

class HotelTransportPointSeeder extends Seeder
{
    public function run(): void
    {
        $points = [
            'Merlynn Park Hotel' => [
                ['name' => 'Stasiun Gambir', 'type' => 'train', 'distance' => '2.1 km', 'duration' => '8 mnt berkendara', 'icon' => 'train'],
                ['name' => 'Stasiun Juanda', 'type' => 'train', 'distance' => '1.8 km', 'duration' => '6 mnt berkendara', 'icon' => 'train'],
                ['name' => 'Halte TransJakarta Petojo', 'type' => 'bus', 'distance' => '350 m', 'duration' => '4 mnt jalan kaki', 'icon' => 'bus'],
                ['name' => 'Monumen Nasional (Monas)', 'type' => 'attraction', 'distance' => '1.9 km', 'duration' => '7 mnt berkendara', 'icon' => 'map-pin'],
                ['name' => 'Bandara Internasional Soekarno-Hatta (CGK)', 'type' => 'airport', 'distance' => '23.4 km', 'duration' => '30 mnt via Tol', 'icon' => 'plane'],
            ],
            'Grand Cemara Hotel' => [
                ['name' => 'Stasiun Gondangdia', 'type' => 'train', 'distance' => '450 m', 'duration' => '6 mnt jalan kaki', 'icon' => 'train'],
                ['name' => 'Pusat Kuliner Sabang', 'type' => 'attraction', 'distance' => '600 m', 'duration' => '8 mnt jalan kaki', 'icon' => 'map-pin'],
            ],
            'YELLO Hotel Harmoni' => [
                ['name' => 'Halte Harmoni Central Busway', 'type' => 'bus', 'distance' => '150 m', 'duration' => '2 mnt jalan kaki', 'icon' => 'bus'],
                ['name' => 'Stasiun Juanda', 'type' => 'train', 'distance' => '1.2 km', 'duration' => '5 mnt berkendara', 'icon' => 'train'],
                ['name' => 'Monumen Nasional (Monas)', 'type' => 'attraction', 'distance' => '1.4 km', 'duration' => '6 mnt berkendara', 'icon' => 'map-pin'],
                ['name' => 'Gajah Mada Plaza', 'type' => 'mall', 'distance' => '800 m', 'duration' => '10 mnt jalan kaki', 'icon' => 'shopping-bag'],
            ],
            'Artotel Harmoni Jakarta' => [
                ['name' => 'Halte Harmoni TransJakarta', 'type' => 'bus', 'distance' => '300 m', 'duration' => '4 mnt jalan kaki', 'icon' => 'bus'],
                ['name' => 'Istana Merdeka', 'type' => 'attraction', 'distance' => '1.1 km', 'duration' => '5 mnt berkendara', 'icon' => 'map-pin'],
                ['name' => 'Stasiun Gambir', 'type' => 'train', 'distance' => '2.2 km', 'duration' => '8 mnt berkendara', 'icon' => 'train'],
                ['name' => 'Monas', 'type' => 'attraction', 'distance' => '1.6 km', 'duration' => '6 mnt berkendara', 'icon' => 'map-pin'],
            ],
            'MaxOne Platinum Hayam Wuruk' => [
                ['name' => 'Halte Harmoni', 'type' => 'bus', 'distance' => '200 m', 'duration' => '3 mnt jalan kaki', 'icon' => 'bus'],
                ['name' => 'Stasiun Sawah Besar', 'type' => 'train', 'distance' => '1.1 km', 'duration' => '5 mnt berkendara', 'icon' => 'train'],
                ['name' => 'Monas', 'type' => 'attraction', 'distance' => '1.3 km', 'duration' => '5 mnt berkendara', 'icon' => 'map-pin'],
                ['name' => 'Pasar Baru Jakarta', 'type' => 'attraction', 'distance' => '1.5 km', 'duration' => '6 mnt berkendara', 'icon' => 'map-pin'],
            ],
        ];

        foreach ($points as $hotelName => $hotelPoints) {
            $hotel = Hotel::whereHas('property', function ($q) use ($hotelName) {
                $q->where('name', $hotelName);
            })->first();

            if (!$hotel) {
                continue;
            }

            foreach ($hotelPoints as $index => $point) {
                \App\Models\HotelTransportPoint::create([
                    'hotel_id' => $hotel->id,
                    ...$point,
                    'sort_order' => $index,
                ]);
            }
        }
    }
}
