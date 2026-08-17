<?php

namespace Database\Seeders;

use App\Models\Facility;
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
                $facility = Facility::where('name', $name)->first();
                \App\Models\ModelHasFacility::create([
                    'facility_id' => $facility?->id,
                    'model_type' => \App\Models\RoomType::class,
                    'model_id' => $roomType->id,
                    'is_available' => true,
                    'badge' => null,
                    'sort_order' => $index,
                ]);
            }
        });
    }
}
