<?php

namespace Database\Seeders;

use App\Models\Property;
use Illuminate\Database\Seeder;

class PropertiesOtherSeeder extends Seeder
{
    public function run(): void
    {
        $property = Property::where('name', 'Sunset Beach Apartment')->first();
        if (!$property) {
            return;
        }

        $data = [
            'province' => 'Bali',
            'cover' => 'https://example.com/gallery1/1.jpg',
            'cover_image' => 'https://example.com/gallery1/1.jpg',
            'price_from' => 500000,
            'rating' => 4.8,
            'review_count' => 12,
            'star_rating' => null,
            'check_in_time' => null,
            'check_out_time' => null,
            'has_breakfast' => false,
            'type_label' => 'Apartment',
            'area_label' => 'Bali',
            'extra_media_count' => 0,
            'specs' => [
                ['icon' => 'furnished', 'label' => 'Full Furnished'],
                ['icon' => 'bedroom', 'label' => '2'],
                ['icon' => 'bathroom', 'label' => '2'],
                ['icon' => 'size', 'label' => '100m2'],
            ],
            'is_favorite' => false,
            'intro' => 'Cari hunian nyaman? Sewa unit ini untuk pengalaman tinggal praktis dan menyenangkan.',
            'description_extra' => [
                'Apartemen ini berada di kawasan pantai indah dengan akses mudah ke tempat wisata.',
                'Gedung ini dilengkapi keamanan 24 jam, lift, gym, serta kolam renang.',
            ],
            'description_extra_heading' => 'Rekomendasi Tempat Rekreasi Terdekat:',
            'map_preview' => 'https://example.com/map_preview.jpg',
            'price_caption' => 'per bulan mulai dari',
            'is_flash_sale' => true,
            'bed_facilities' => [
                ['icon' => 'king_bed', 'label' => 'King Bed', 'note' => '(180x200)', 'count' => null],
                ['icon' => 'single_bed', 'label' => 'Single Bed', 'note' => '(120x200)', 'count' => 1],
            ],
            'building_facilities' => [
                ['icon' => 'pool', 'label' => 'Kolam Renang'],
                ['icon' => 'security', 'label' => 'Keamanan 24 Jam'],
                ['icon' => 'access_card', 'label' => 'Kartu Akses'],
                ['icon' => 'elevator', 'label' => 'Lift'],
            ],
            'building_facilities_all' => [
                '24-Hour Security',
                'Access Card',
                'Elevator',
                'Gym',
                'Swimming Pool',
            ],
            'room_furniture' => [
                ['icon' => 'water_heater', 'label' => 'Water Heater', 'count' => 2],
                ['icon' => 'kitchen_utensil', 'label' => 'Kitchen Utensil', 'count' => null],
                ['icon' => 'washing_machine', 'label' => 'Washing Machine', 'count' => null],
                ['icon' => 'ac', 'label' => 'AC', 'count' => 4],
            ],
            'room_furniture_groups' => [
                [
                    'room' => 'Master Bedroom',
                    'items' => [
                        'King Bed (180x200)',
                        'Mirror',
                        'Wardrobe',
                        'Air Conditioner',
                        'Iron',
                        'Iron Board',
                        'Standing Lamp',
                    ],
                    'bed_config' => ['1 King Bed (180x200)'],
                ],
                [
                    'room' => 'Second Bedroom',
                    'items' => [
                        'Super Single Bed (120x200)',
                        'Wardrobe',
                        'Air Conditioner',
                        'Standing Lamp',
                    ],
                    'bed_config' => ['1 Super Single Bed (120x200)'],
                ],
            ],
            'check_in_notes' => [
                [
                    'icon' => 'info',
                    'tone' => 'warning',
                    'title' => 'Info',
                    'paragraphs' => [
                        'Harap mengatur waktu check-in Anda di aplikasi 4 jam sebelum kedatangan.',
                    ],
                ],
                [
                    'icon' => 'cleaning',
                    'tone' => 'brand',
                    'title' => 'Cleaning',
                    'paragraphs' => [
                        'Unit dan linen hanya akan dibersihkan setelah check-out.',
                        'Permintaan tambahan selama menginap tersedia dengan biaya tambahan.',
                    ],
                ],
                [
                    'icon' => 'terms',
                    'tone' => 'info',
                    'title' => 'Syarat & Ketentuan Gedung',
                    'paragraphs' => [
                        'Penggunaan fasilitas gedung dan parkir mengikuti aturan yang berlaku dari masing-masing gedung.',
                    ],
                ],
            ],
            'deposit_amount' => 11175000,
            'deposit_notes' => [
                [
                    'icon' => 'info',
                    'tone' => 'info',
                    'title' => 'Pemesanan Tahunan',
                    'paragraphs' => [
                        'Jika tagihan pemakaian listrik dan air tidak dapat langsung dipotong, biaya akan dihitung berdasarkan tagihan dari Pengelola Gedung.',
                        'Pengembalian dana melalui transfer bank: hingga 7 hari kerja.',
                        'Kartu kredit: hingga 21 hari kerja setelah tagihan diterima.',
                    ],
                ],
            ],
            'unit_detail' => [
                ['icon' => 'building', 'label' => 'Gedung', 'value' => 'Apartemen Sunset Towers'],
                ['icon' => 'building', 'label' => 'Tower', 'value' => '1'],
                ['icon' => 'building', 'label' => 'Lantai', 'value' => '5'],
                ['icon' => 'calendar', 'label' => 'Property Tayang Sejak', 'value' => '14 Agt 2026'],
                [
                    'icon' => 'car',
                    'label' => 'Parkir',
                    'groups' => [
                        [
                            'title' => 'Mobil',
                            'lines' => [
                                ['label' => 'Biaya kartu', 'amount' => 50000],
                                ['label' => 'Biaya perbulan', 'amount' => 500000],
                            ],
                        ],
                        [
                            'title' => 'Motor',
                            'lines' => [
                                ['label' => 'Biaya kartu', 'amount' => 25000],
                                ['label' => 'Biaya perbulan', 'amount' => 150000],
                            ],
                        ],
                    ],
                ],
            ],
            'nearby' => [
                ['name' => 'Cafe Batavia', 'icon' => 'place', 'tone' => 0],
                ['name' => 'Museum Bank Mandiri', 'icon' => 'place', 'tone' => 1],
                ['name' => 'Pasar Asemka', 'icon' => 'place', 'tone' => 2],
                ['name' => 'Pasar Petak Sembilan', 'icon' => 'place', 'tone' => 3],
                ['name' => 'Toko Merah', 'icon' => 'place', 'tone' => 4],
                ['name' => 'Candra Naya', 'icon' => 'place', 'tone' => 0],
            ],
            'guest_media' => [],
            'building_units' => [
                'building_name' => 'Apartemen Sunset Towers',
                'image' => 'https://example.com/building_units.jpg',
                'available_units' => 3,
            ],
            'review_summary' => [
                'average' => 4.7,
                'total' => 12,
                'label' => 'Istimewa',
                'breakdown' => [
                    ['icon' => 'cleaning', 'label' => 'Kebersihan', 'value' => 5],
                    ['icon' => 'staff', 'label' => 'Staf', 'value' => 5],
                    ['icon' => 'clock', 'label' => 'Check-In / Out', 'value' => 5],
                    ['icon' => 'value', 'label' => 'Keterjangkauan', 'value' => 4.5],
                    ['icon' => 'place', 'label' => 'Lokasi', 'value' => 5],
                    ['icon' => 'satisfaction', 'label' => 'Kepuasan', 'value' => 5],
                ],
            ],
        ];

        $property->other()->updateOrCreate(
            ['property_id' => $property->id],
            $data
        );
    }
}
