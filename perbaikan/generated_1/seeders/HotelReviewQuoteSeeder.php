<?php

namespace Database\Seeders;

use App\Models\Hotel;
use Illuminate\Database\Seeder;

class HotelReviewQuoteSeeder extends Seeder
{
    public function run(): void
    {
        $quotes = [
            'Merlynn Park Hotel' => [
                ['quote' => 'Kamarnya sangat luas, bersih, dan bathtub-nya sangat nyaman.', 'author_name' => 'Tamu', 'author_role' => 'Domestic', 'rating' => 5],
                ['quote' => 'Pilihan menu sarapan sangat bervariasi dan lezat. Pelayanan staf sangat ramah.', 'author_name' => 'Tamu', 'author_role' => 'Domestic', 'rating' => 5],
                ['quote' => 'Kolam renang lantai 5 sangat bagus dengan view cakrawala kota Jakarta.', 'author_name' => 'Tamu', 'author_role' => 'International', 'rating' => 5],
            ],
            'Grand Cemara Hotel' => [
                ['quote' => 'Lokasi sangat strategis dekat stasiun dan pusat kuliner Sabang.', 'author_name' => 'Tamu', 'author_role' => 'Domestic', 'rating' => 5],
            ],
            'YELLO Hotel Harmoni' => [
                ['quote' => 'Desain hotelnya sangat ceria dan kekinian, kamar bersih dan internet sangat cepat!', 'author_name' => 'Tamu', 'author_role' => 'Domestic', 'rating' => 5],
                ['quote' => 'Lokasi tepat di seberang halte Harmoni, sangat mudah bepergian ke mana saja.', 'author_name' => 'Tamu', 'author_role' => 'Domestic', 'rating' => 5],
            ],
            'Artotel Harmoni Jakarta' => [
                ['quote' => 'Hotel butik bernuansa seni yang sangat estetik dan fotogenik di setiap sudutnya.', 'author_name' => 'Tamu', 'author_role' => 'International', 'rating' => 5],
                ['quote' => 'Makanan di ROCA sangat enak dan suasananya nyaman untuk bersantai.', 'author_name' => 'Tamu', 'author_role' => 'Domestic', 'rating' => 5],
            ],
            'MaxOne Platinum Hayam Wuruk' => [
                ['quote' => 'Rooftopnya sangat asyik untuk nongkrong malam, harga kamar sangat terjangkau di pusat kota.', 'author_name' => 'Tamu', 'author_role' => 'Domestic', 'rating' => 5],
            ],
        ];

        foreach ($quotes as $hotelName => $items) {
            $hotel = Hotel::whereHas('property', function ($q) use ($hotelName) {
                $q->where('name', $hotelName);
            })->first();

            if (!$hotel) {
                continue;
            }

            foreach ($items as $index => $item) {
                \App\Models\HotelReviewQuote::create([
                    'hotel_id' => $hotel->id,
                    ...$item,
                    'sort_order' => $index,
                ]);
            }
        }
    }
}
