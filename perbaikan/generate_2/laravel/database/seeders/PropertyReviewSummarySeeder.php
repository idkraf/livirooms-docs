<?php

namespace Database\Seeders;

use App\Models\Property;
use Illuminate\Database\Seeder;

class PropertyReviewSummarySeeder extends Seeder
{
    public function run(): void
    {
        $summaries = [
            'Sunset Beach Apartment' => [
                'average' => 4.7,
                'total' => 12,
                'label' => 'Istimewa',
                'breakdown' => [
                    ['rating' => 5, 'count' => 8],
                    ['rating' => 4, 'count' => 3],
                    ['rating' => 3, 'count' => 1],
                ],
            ],
        ];

        foreach ($summaries as $propertyName => $data) {
            $property = Property::where('name', $propertyName)->first();
            if (!$property) {
                continue;
            }

            $summary = \App\Models\PropertyReviewSummary::create([
                'property_id' => $property->id,
                'average' => $data['average'],
                'total' => $data['total'],
                'label' => $data['label'],
            ]);

            foreach ($data['breakdown'] as $item) {
                \App\Models\PropertyReviewBreakdown::create([
                    'property_review_summary_id' => $summary->id,
                    'rating' => $item['rating'],
                    'count' => $item['count'],
                ]);
            }
        }
    }
}
