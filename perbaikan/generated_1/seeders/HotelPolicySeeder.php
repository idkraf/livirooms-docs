<?php

namespace Database\Seeders;

use App\Models\Hotel;
use Illuminate\Database\Seeder;

class HotelPolicySeeder extends Seeder
{
    public function run(): void
    {
        $policies = [
            'Merlynn Park Hotel' => [
                'receptionist_24h' => true,
                'allow_children' => true,
                'extra_bed_available' => true,
                'child_policy' => 'Anak usia 0-5 tahun menginap gratis jika menggunakan tempat tidur yang ada.',
                'extra_bed_policy' => null,
                'smoking_policy' => 'Semua kamar adalah bebas rokok (Non-Smoking). Area khusus merokok tersedia.',
                'deposit_amount' => 500000,
                'deposit_currency' => 'IDR',
            ],
            'Grand Cemara Hotel' => [
                'receptionist_24h' => true,
                'allow_children' => true,
                'extra_bed_available' => true,
                'child_policy' => null,
                'extra_bed_policy' => null,
                'smoking_policy' => null,
                'deposit_amount' => 100000,
                'deposit_currency' => 'IDR',
            ],
            'YELLO Hotel Harmoni' => [
                'receptionist_24h' => true,
                'allow_children' => true,
                'extra_bed_available' => true,
                'child_policy' => null,
                'extra_bed_policy' => null,
                'smoking_policy' => 'Non-Smoking hotel dengan smoking area di teras lantai 1.',
                'deposit_amount' => 200000,
                'deposit_currency' => 'IDR',
            ],
            'Artotel Harmoni Jakarta' => [
                'receptionist_24h' => true,
                'allow_children' => true,
                'extra_bed_available' => true,
                'child_policy' => null,
                'extra_bed_policy' => null,
                'smoking_policy' => null,
                'deposit_amount' => 300000,
                'deposit_currency' => 'IDR',
            ],
            'MaxOne Platinum Hayam Wuruk' => [
                'receptionist_24h' => true,
                'allow_children' => true,
                'extra_bed_available' => true,
                'child_policy' => null,
                'extra_bed_policy' => null,
                'smoking_policy' => null,
                'deposit_amount' => 150000,
                'deposit_currency' => 'IDR',
            ],
        ];

        foreach ($policies as $hotelName => $data) {
            $hotel = Hotel::whereHas('property', function ($q) use ($hotelName) {
                $q->where('name', $hotelName);
            })->first();

            if (!$hotel) {
                continue;
            }

            \App\Models\HotelPolicy::create([
                'hotel_id' => $hotel->id,
                ...$data,
            ]);
        }
    }
}
