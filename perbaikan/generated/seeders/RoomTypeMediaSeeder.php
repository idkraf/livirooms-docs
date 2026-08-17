<?php

namespace Database\Seeders;

use App\Models\RoomType;
use Illuminate\Database\Seeder;

class RoomTypeMediaSeeder extends Seeder
{
    public function run(): void
    {
        $mediaMap = [
            'Executive Room' => 'hotels/gallery/merlynn_2.jpg',
            'Prada Suite' => 'hotels/gallery/merlynn_3.jpg',
            'Family Suite' => 'hotels/gallery/merlynn_4.jpg',
            'Presidential Suite' => 'hotels/gallery/merlynn_1.jpg',
            'Superior Room' => 'hotels/gallery/cemara_1.jpg',
            'Deluxe Family Suite' => 'hotels/gallery/cemara_2.jpg',
            'YELLO Room' => 'hotels/gallery/yello_1.jpg',
            'YELLO Urban Room' => 'hotels/gallery/yello_2.jpg',
            'YELLO Suite' => 'hotels/gallery/yello_3.jpg',
            'Studio 20' => 'hotels/gallery/artotel_1.jpg',
            'Studio 25' => 'hotels/gallery/artotel_2.jpg',
            'Studio 40' => 'hotels/gallery/artotel_3.jpg',
            'Happiness Room' => 'hotels/gallery/maxone_1.jpg',
            'Warmth Room' => 'hotels/gallery/maxone_2.jpg',
            'Love Suite' => 'hotels/gallery/maxone_3.jpg',
        ];

        foreach ($mediaMap as $roomTypeName => $url) {
            $roomType = RoomType::where('name', $roomTypeName)->first();
            if (!$roomType) {
                continue;
            }

            \App\Models\RoomTypeMedia::create([
                'room_type_id' => $roomType->id,
                'url' => $url,
                'caption' => $roomTypeName,
                'sort_order' => 0,
            ]);
        }
    }
}
