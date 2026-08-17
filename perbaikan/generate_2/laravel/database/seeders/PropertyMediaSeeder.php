<?php

namespace Database\Seeders;

use App\Models\Property;
use Illuminate\Database\Seeder;

class PropertyMediaSeeder extends Seeder
{
    public function run(): void
    {
        $mediaMap = [
            'Peaceful Living in Spacious 3BR at Apartment Lucky Tower Residence By Travelio' => [
                'properties/gallery/peaceful-3br-1.jpg',
                'properties/gallery/peaceful-3br-2.jpg',
            ],
            'Big and Cozy 3BR Apartment Lucky Tower Residence By Travelio' => [
                'properties/gallery/big-3br-1.jpg',
                'properties/gallery/big-3br-2.jpg',
            ],
            'Fabulous 2BR Apartment Lucky Tower Residence By Travelio' => [
                'properties/gallery/fabulous-2br-1.jpg',
                'properties/gallery/fabulous-2br-2.jpg',
            ],
            'Modern Look 2BR at Lucky Tower Residence Apartment By Travelio' => [
                'properties/gallery/modern-2br-1.jpg',
                'properties/gallery/modern-2br-2.jpg',
            ],
            'Sunset Beach Apartment' => [
                'https://example.com/gallery1/1.jpg',
            ],
            'Merlynn Park Hotel' => [
                'hotels/gallery/merlynn_1.jpg',
                'hotels/gallery/merlynn_2.jpg',
                'hotels/gallery/merlynn_3.jpg',
                'hotels/gallery/merlynn_4.jpg',
                'hotels/gallery/merlynn_5.jpg',
            ],
            'Grand Cemara Hotel' => [
                'hotels/gallery/cemara_1.jpg',
                'hotels/gallery/cemara_2.jpg',
                'hotels/gallery/cemara_3.jpg',
                'hotels/gallery/cemara_4.jpg',
            ],
            'YELLO Hotel Harmoni' => [
                'hotels/gallery/yello_1.jpg',
                'hotels/gallery/yello_2.jpg',
                'hotels/gallery/yello_3.jpg',
                'hotels/gallery/yello_4.jpg',
            ],
            'Artotel Harmoni Jakarta' => [
                'hotels/gallery/artotel_1.jpg',
                'hotels/gallery/artotel_2.jpg',
                'hotels/gallery/artotel_3.jpg',
                'hotels/gallery/artotel_4.jpg',
            ],
            'MaxOne Platinum Hayam Wuruk' => [
                'hotels/gallery/maxone_1.jpg',
                'hotels/gallery/maxone_2.jpg',
                'hotels/gallery/maxone_3.jpg',
                'hotels/gallery/maxone_4.jpg',
            ],
        ];

        foreach ($mediaMap as $propertyName => $urls) {
            $property = Property::where('name', $propertyName)->first();
            if (!$property) {
                continue;
            }

            foreach ($urls as $index => $url) {
                \App\Models\Media::create([
                    'model_type' => \App\Models\Property::class,
                    'model_id' => $property->id,
                    'url' => $url,
                    'caption' => null,
                    'is_cover' => $index === 0,
                    'sort_order' => $index,
                ]);
            }
        }
    }
}
