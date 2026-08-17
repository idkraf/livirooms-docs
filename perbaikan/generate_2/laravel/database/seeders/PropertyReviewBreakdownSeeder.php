<?php

namespace Database\Seeders;

use App\Models\Property;
use App\Models\PropertyReviewSummary;
use Illuminate\Database\Seeder;

class PropertyReviewBreakdownSeeder extends Seeder
{
    public function run(): void
    {
        PropertyReviewSummary::all()->each(function ($summary) {
            $breakdowns = [
                ['rating' => 5, 'count' => 8],
                ['rating' => 4, 'count' => 3],
                ['rating' => 3, 'count' => 1],
            ];

            foreach ($breakdowns as $item) {
                \App\Models\PropertyReviewBreakdown::create([
                    'property_review_summary_id' => $summary->id,
                    ...$item,
                ]);
            }
        });
    }
}
