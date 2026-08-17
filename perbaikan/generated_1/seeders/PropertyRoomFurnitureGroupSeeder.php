<?php

namespace Database\Seeders;

use App\Models\Property;
use Illuminate\Database\Seeder;

class PropertyRoomFurnitureGroupSeeder extends Seeder
{
    public function run(): void
    {
        $groups = [
            'Sunset Beach Apartment' => [
                ['name' => 'Master Bedroom', 'items' => ['King Bed (180x200)', 'Mirror', 'Wardrobe', 'Air Conditioner', 'Iron', 'Iron Board', 'Standing Lamp']],
                ['name' => 'Second Bedroom', 'items' => ['Super Single Bed (120x200)', 'Wardrobe', 'Air Conditioner', 'Standing Lamp']],
            ],
        ];

        foreach ($groups as $propertyName => $roomGroups) {
            $property = Property::where('name', $propertyName)->first();
            if (!$property) {
                continue;
            }

            foreach ($roomGroups as $groupIndex => $group) {
                $groupModel = \App\Models\PropertyRoomFurnitureGroup::create([
                    'property_id' => $property->id,
                    'name' => $group['name'],
                    'sort_order' => $groupIndex,
                ]);

                foreach ($group['items'] as $itemIndex => $label) {
                    \App\Models\PropertyRoomFurnitureItem::create([
                        'property_room_furniture_group_id' => $groupModel->id,
                        'icon' => null,
                        'label' => $label,
                        'sort_order' => $itemIndex,
                    ]);
                }
            }
        }
    }
}
