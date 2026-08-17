<?php

namespace Database\Seeders;

use App\Models\Hotel;
use Illuminate\Database\Seeder;

class HotelFaqSeeder extends Seeder
{
    public function run(): void
    {
        $faqs = [
            'Merlynn Park Hotel' => [
                ['question' => 'Berapa jarak Merlynn Park Hotel ke Monas?', 'answer' => 'Merlynn Park Hotel berjarak sekitar 1,9 km dari Monas.', 'author_name' => 'Manager akomodasi', 'author_role' => 'Staff Hotel'],
                ['question' => 'Apakah sarapan tersedia di hotel?', 'answer' => 'Ya, sarapan prasmanan disajikan di Grand Central Restaurant.', 'author_name' => 'Manager akomodasi', 'author_role' => 'Staff Hotel'],
                ['question' => 'Berapa deposit yang dibutuhkan saat check-in?', 'answer' => 'Deposit jaminan sebesar Rp 500.000 per kamar (refundable).', 'author_name' => 'Manager akomodasi', 'author_role' => 'Staff Hotel'],
                ['question' => 'Apakah semua tipe kamar dilengkapi bathtub?', 'answer' => 'Ya, seluruh tipe kamar di Merlynn Park Hotel dilengkapi bathtub.', 'author_name' => 'Manager akomodasi', 'author_role' => 'Staff Hotel'],
            ],
            'Grand Cemara Hotel' => [
                ['question' => 'Apakah dekat ke Stasiun Gondangdia?', 'answer' => 'Ya, hanya sekitar 450 meter jalan kaki.', 'author_name' => 'Manager akomodasi', 'author_role' => 'Staff Hotel'],
            ],
            'YELLO Hotel Harmoni' => [
                ['question' => 'Apakah ada tempat bermain game untuk tamu?', 'answer' => 'Ya, tersedia Gaming Station gratis di area lobi dengan konsol game modern.', 'author_name' => 'Manager akomodasi', 'author_role' => 'Staff Hotel'],
                ['question' => 'Apakah sarapan tersedia?', 'answer' => 'Ya, sarapan disajikan di WOKnTOK Restaurant mulai pukul 06:00 - 10:00 WIB.', 'author_name' => 'Manager akomodasi', 'author_role' => 'Staff Hotel'],
            ],
            'Artotel Harmoni Jakarta' => [
                ['question' => 'Apakah ada galeri seni di dalam hotel?', 'answer' => 'Ya, ARTSPACE di area lobi menyelenggarakan pameran karya seni berkala.', 'author_name' => 'Manager akomodasi', 'author_role' => 'Staff Hotel'],
            ],
            'MaxOne Platinum Hayam Wuruk' => [
                ['question' => 'Apakah ada restoran rooftop di hotel?', 'answer' => 'Ya, SkyMax Rooftop Bistro berada di lantai teratas dengan pemandangan kota Jakarta.', 'author_name' => 'Manager akomodasi', 'author_role' => 'Staff Hotel'],
            ],
        ];

        foreach ($faqs as $hotelName => $items) {
            $hotel = Hotel::whereHas('property', function ($q) use ($hotelName) {
                $q->where('name', $hotelName);
            })->first();

            if (!$hotel) {
                continue;
            }

            foreach ($items as $index => $item) {
                \App\Models\HotelFaq::create([
                    'hotel_id' => $hotel->id,
                    ...$item,
                    'sort_order' => $index,
                ]);
            }
        }
    }
}
