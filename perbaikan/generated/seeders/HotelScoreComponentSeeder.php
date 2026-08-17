<?php

namespace Database\Seeders;

use App\Models\Hotel;
use Illuminate\Database\Seeder;

class HotelScoreComponentSeeder extends Seeder
{
    public function run(): void
    {
        $scores = [
            'Merlynn Park Hotel' => [
                ['component' => 'basic', 'score' => 4.8],
                ['component' => 'reward', 'score' => 0.5],
                ['component' => 'inventory', 'score' => 4.7],
                ['component' => 'content', 'score' => 5.0],
                ['component' => 'review', 'score' => 4.8],
                ['component' => 'rate_competitiveness', 'score' => 4.6],
            ],
            'Grand Cemara Hotel' => [
                ['component' => 'basic', 'score' => 4.5],
                ['component' => 'reward', 'score' => 0.5],
                ['component' => 'inventory', 'score' => 4.4],
                ['component' => 'content', 'score' => 4.8],
                ['component' => 'review', 'score' => 4.5],
                ['component' => 'rate_competitiveness', 'score' => 4.6],
            ],
            'YELLO Hotel Harmoni' => [
                ['component' => 'basic', 'score' => 4.7],
                ['component' => 'reward', 'score' => 0.5],
                ['component' => 'inventory', 'score' => 4.6],
                ['component' => 'content', 'score' => 4.9],
                ['component' => 'review', 'score' => 4.7],
                ['component' => 'rate_competitiveness', 'score' => 4.8],
            ],
            'Artotel Harmoni Jakarta' => [
                ['component' => 'basic', 'score' => 4.6],
                ['component' => 'reward', 'score' => 0.5],
                ['component' => 'inventory', 'score' => 4.7],
                ['component' => 'content', 'score' => 5.0],
                ['component' => 'review', 'score' => 4.6],
                ['component' => 'rate_competitiveness', 'score' => 4.7],
            ],
            'MaxOne Platinum Hayam Wuruk' => [
                ['component' => 'basic', 'score' => 4.5],
                ['component' => 'reward', 'score' => 0.5],
                ['component' => 'inventory', 'score' => 4.5],
                ['component' => 'content', 'score' => 4.8],
                ['component' => 'review', 'score' => 4.5],
                ['component' => 'rate_competitiveness', 'score' => 4.8],
            ],
        ];

        foreach ($scores as $hotelName => $components) {
            $hotel = Hotel::whereHas('property', function ($q) use ($hotelName) {
                $q->where('name', $hotelName);
            })->first();

            if (!$hotel) {
                continue;
            }

            foreach ($components as $index => $component) {
                \App\Models\HotelScoreComponent::create([
                    'hotel_id' => $hotel->id,
                    ...$component,
                ]);
            }
        }
    }
}
