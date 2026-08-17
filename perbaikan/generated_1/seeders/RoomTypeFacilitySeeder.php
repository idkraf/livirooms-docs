<?php

namespace Database\Seeders;

use App\Models\RoomType;
use Illuminate\Database\Seeder;

class RoomTypeFacilitySeeder extends Seeder
{
    public function run(): void
    {
        $defaults = [
            'AC', 'TV Kabel', 'Kulkas Mini', 'Brankas', 'Bathtub Marmer',
        ];

        RoomType::all()->each(function ($roomType) use ($defaults) {
            foreach ($defaults as $index => $name) {
                \App\Models\RoomTypeFacility::create([
                    'room_type_id' => $roomType->id,
                    'name' => $name,
                    'is_available' => true,
                    'sort_order' => $index,
                ]);
            }
        });
    }
}
