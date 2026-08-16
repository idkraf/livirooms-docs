import 'property_detail.dart';
import 'unit_pricing.dart';

/// Fixtures transcribed from the mockups in
/// `docs/properties/screen/property_detail_screen/` and
/// `docs/properties/screen/rincian_unit_screen/`.
///
/// They exist so both screens run standalone (`SampleData.detail` / the three
/// `SampleData.*Pricing` getters) before the API sections land. Swap them for
/// `PropertyDetail.fromJson` / `UnitPricing.fromJson` once the endpoints in
/// `docs/properties/system.md` expose these fields.
class SampleData {
  SampleData._();

  static const String _placeholder =
      'https://placehold.co/800x600/EEEEEE/9E9E9E?text=Sewain';

  // ------------------------------------------------- property_detail_screen_1

  /// `property_detail_screen_1.jpg` — no reviews yet, so the action row shows
  /// the `NEW` badge and the review summary card is absent.
  static PropertyDetail get detail => PropertyDetail(
        id: 1,
        title: 'Peaceful Living in Spacious 3BR at Apartment '
            'Lucky Tower Residence By Travelio',
        typeLabel: 'Apartment',
        areaLabel: 'Pinangsia',
        gallery: const [
          GalleryItem(url: _placeholder),
          GalleryItem(url: _placeholder, kind: MediaKind.video),
          GalleryItem(url: _placeholder, kind: MediaKind.panorama),
          GalleryItem(url: _placeholder),
        ],
        extraMediaCount: 38,
        specs: const [
          SpecItem(iconKey: 'furnished', label: 'Full Furnished'),
          SpecItem(iconKey: 'bedroom', label: '3'),
          SpecItem(iconKey: 'bathroom', label: '2'),
          SpecItem(iconKey: 'size', label: '100m2'),
          SpecItem(iconKey: 'electricity', label: '5500 W'),
        ],
        bedFacilities: const [
          FacilityItem(
              iconKey: 'king_bed', label: 'King Bed', note: '(180x200)'),
          FacilityItem(
              iconKey: 'single_bed',
              label: 'Super Single Bed',
              note: '(120x200)'),
          FacilityItem(
              iconKey: 'single_bed', label: 'Single Bed', note: '(90x200)'),
        ],
        buildingFacilities: const [
          FacilityItem(iconKey: 'pool', label: 'Kolam Renang'),
          FacilityItem(iconKey: 'security', label: 'Keamanan 24 Jam'),
          FacilityItem(iconKey: 'access_card', label: 'Kartu Akses'),
          FacilityItem(iconKey: 'elevator', label: 'Lift'),
        ],
        buildingFacilitiesAll: const [
          '24-Hour Security',
          'Access Card',
          'Elevator',
          'Gym',
          'Swimming Pool',
        ],
        roomFurniture: const [
          FacilityItem(
              iconKey: 'water_heater', label: 'Water Heater', count: 2),
          FacilityItem(iconKey: 'kitchen_utensil', label: 'Kitchen Utensil'),
          FacilityItem(
              iconKey: 'washing_machine', label: 'Washing Machine'),
          FacilityItem(iconKey: 'ac', label: 'AC', count: 4),
        ],
        roomFurnitureGroups: const [
          RoomFurnitureGroup(
            roomName: 'Master Bedroom',
            items: [
              'King Bed (180x200)',
              'Mirror',
              'Wardrobe',
              'Air Conditioner',
              'Iron',
              'Iron Board',
              'Standing Lamp',
            ],
            bedConfig: ['1 King Bed (180x200)'],
          ),
          RoomFurnitureGroup(
            roomName: 'Second Bedroom',
            items: [
              'Super Single Bed (120x200)',
              'Wardrobe',
              'Air Conditioner',
              'Standing Lamp',
            ],
            bedConfig: ['1 Super Single Bed (120x200)'],
          ),
          RoomFurnitureGroup(
            roomName: 'Third Bedroom',
            items: [
              'Single Bed (90x200)',
              'Wardrobe',
              'Air Conditioner',
              'Standing Lamp',
            ],
            bedConfig: ['1 Single Bed (90x200)'],
          ),
        ],
        checkInNotes: const [
          InfoNote(
            iconKey: 'info',
            tone: InfoTone.warning,
            title: 'Info',
            paragraphs: [
              'Harap mengatur waktu check-in Anda di aplikasi 4 jam '
                  'sebelum kedatangan',
            ],
          ),
          InfoNote(
            iconKey: 'cleaning',
            tone: InfoTone.brand,
            title: 'Cleaning',
            paragraphs: [
              'Unit dan linen hanya akan dibersihkan setelah check-out. '
                  'Permintaan tambahan selama menginap tersedia dengan biaya '
                  'tambahan',
            ],
          ),
          InfoNote(
            iconKey: 'terms',
            tone: InfoTone.info,
            title: 'Syarat & Ketentuan Gedung',
            paragraphs: [
              'Penggunaan fasilitas gedung dan parkir mengikuti aturan yang '
                  'berlaku dari masing-masing gedung / building management '
                  'apartment dan ketentuan dapat berubah sewaktu-waktu.',
            ],
          ),
        ],
        depositAmount: 11175000,
        depositNotes: const [
          InfoNote(
            iconKey: 'info',
            tone: InfoTone.info,
            title: 'Pemesanan Tahunan',
            paragraphs: [
              'Jika tagihan pemakaian listrik dan air tidak dapat langsung '
                  'dipotong, biaya akan dihitung berdasarkan tagihan dari '
                  'Pengelola Gedung (Tagihan diterbitkan sebelum tanggal 10 '
                  'di bulan berikutnya setelah check-out)',
              'Pengembalian dana melalui transfer bank: hingga 7 hari kerja',
              'Kartu kredit: hingga 21 hari kerja setelah tagihan diterima '
                  'dan semua informasi yang diperlukan telah lengkap',
              'Penggunaan kartu debit tidak disarankan untuk pembayaran '
                  'deposit. Sebelum melakukan pembayaran, pastikan kartu Anda '
                  'mendukung transaksi pengembalian dana.',
            ],
          ),
        ],
        unitDetailRows: const [
          UnitDetailRow(
            iconKey: 'building',
            label: 'Gedung',
            value: 'Apartemen Lucky Tower Residence',
          ),
          UnitDetailRow(iconKey: 'building', label: 'Tower', value: '1'),
          UnitDetailRow(iconKey: 'building', label: 'Lantai', value: '16'),
          UnitDetailRow(
            iconKey: 'calendar',
            label: 'Property Tayang Sejak',
            value: '14 Agt 2026',
          ),
          UnitDetailRow(
            iconKey: 'car',
            label: 'Parkir',
            groups: [
              UnitDetailGroup(
                title: 'Mobil',
                lines: [
                  LabeledAmount(label: 'Biaya kartu', amount: 50000),
                  LabeledAmount(label: 'Biaya perbulan', amount: 500000),
                ],
              ),
              UnitDetailGroup(
                title: 'Motor',
                lines: [
                  LabeledAmount(label: 'Biaya kartu', amount: 25000),
                  LabeledAmount(label: 'Biaya perbulan', amount: 150000),
                ],
              ),
            ],
          ),
        ],
        intro: 'Cari hunian 3BR yang nyaman? Sewa unit di ApartEmen Lucky '
            'Tower Residence untuk pengalaman tinggal praktis, luas, dan '
            'menyenangkan! Reservasi hari ini hanya di Travelio!',
        description: 'Nikmati hunian yang tenang dan luas di unit ini. '
            'Unit 3 kamar tidur ini memiliki 3 kamar tidur, 2 kamar mandi, '
            'dan luas 100 sqm, sehingga cocok untuk keluarga, kelompok, '
            'maupun profesional yang mencari hunian nyaman',
        descriptionExtra: const [
          'Apartemen Lucky Tower Residence berada di kawasan Pinangsia, '
              'Taman Sari — sepuluh menit dari Kota Tua dan terhubung '
              'langsung ke Stasiun Jakarta Kota.',
          'Gedung ini dilengkapi keamanan 24 jam, kartu akses, lift, gym, '
              'serta kolam renang.',
        ],
        descriptionExtraHeading: 'Rekomendasi Tempat Rekreasi Terdekat:',
        address: 'Jl. Pancoran Raya No.42A, RT.2/RW.6, Pinangsia, '
            'Taman Sari, Jakarta Barat, DKI Jakarta, 11110',
        latitude: -6.1385,
        longitude: 106.8156,
        nearbyPlaces: const [
          NearbyPlace(name: 'Cafe Batavia', tone: 0),
          NearbyPlace(name: 'Museum Bank Mandiri', tone: 1),
          NearbyPlace(name: 'Pasar Asemka', tone: 2),
          NearbyPlace(name: 'Pasar Petak Sembilan', tone: 3),
          NearbyPlace(name: 'Toko Merah', tone: 4),
          NearbyPlace(name: 'Candra Naya', tone: 0),
        ],
        guestMedia: const [
          GalleryItem(url: _placeholder, kind: MediaKind.video),
        ],
        buildingUnits: const BuildingUnitsTeaser(
          buildingName: 'Apartemen Lucky Tower Residence',
          imageUrl: _placeholder,
          availableUnits: 3,
        ),
        priceCaption: 'per bulan mulai dari',
        priceAmount: 14100000,
        isFlashSale: true,
      );

  // -------------------------------------- property_detail_screen_1_with_reviews

  /// `property_detail_screen_1_with_reviews.jpeg` + the `ULASAN` sheet —
  /// a different listing (Tokyo Riverside PIK 2) that already has ratings.
  static PropertyDetail get detailWithReviews => PropertyDetail(
        id: 2,
        title: 'Nice Studio near Tokyo Hub at Tokyo Riverside PIK 2 '
            'Apartment By Travelio',
        typeLabel: 'Apartment',
        areaLabel: 'PIK 2',
        gallery: detail.gallery,
        extraMediaCount: 21,
        specs: const [
          SpecItem(iconKey: 'furnished', label: 'Full Furnished'),
          SpecItem(iconKey: 'bedroom', label: '1'),
          SpecItem(iconKey: 'bathroom', label: '1'),
          SpecItem(iconKey: 'size', label: '21m2'),
          SpecItem(iconKey: 'electricity', label: '2200 W'),
        ],
        reviewSummary: const ReviewSummary(
          average: 5.0,
          total: 2,
          label: 'Istimewa',
          breakdown: [
            ReviewScore(iconKey: 'cleaning', label: 'Kebersihan', value: 5),
            ReviewScore(iconKey: 'staff', label: 'Staf', value: 5),
            ReviewScore(
                iconKey: 'clock', label: 'Check-In / Out', value: 5),
            ReviewScore(
                iconKey: 'value', label: 'Keterjangkauan', value: 5),
            ReviewScore(iconKey: 'place', label: 'Lokasi', value: 5),
            ReviewScore(iconKey: 'satisfaction', label: 'Kepuasan', value: 5),
          ],
        ),
        reviews: [
          PropertyReview(
            authorName: 'Muhammad Cahyo Budianto Laksono',
            score: 5,
            periodLabel: 'Sewa Harian',
            createdAt: DateTime(2026, 7, 19),
            comment: 'Baik',
          ),
          PropertyReview(
            authorName: 'Nurul Baswandi',
            score: 5,
            periodLabel: 'Sewa Bulanan',
            createdAt: DateTime(2025, 11, 29),
            comment: 'Ok',
          ),
        ],
        bedFacilities: detail.bedFacilities,
        buildingFacilities: detail.buildingFacilities,
        buildingFacilitiesAll: detail.buildingFacilitiesAll,
        roomFurniture: detail.roomFurniture,
        roomFurnitureGroups: detail.roomFurnitureGroups,
        checkInNotes: detail.checkInNotes,
        depositAmount: detail.depositAmount,
        depositNotes: detail.depositNotes,
        unitDetailRows: detail.unitDetailRows,
        intro: detail.intro,
        description: 'Nikmati perpaduan sempurna antara gaya, kenyamanan, '
            'dan kemudahan dalam unit studio seluas 21 m² di Apartemen '
            'Tokyo Riverside PIK 2. Berlokasi di Lemo, Kabupaten Tangerang, '
            'unit ini sangat cocok untuk profesional, mahasiswa, atau '
            'traveler yang mencari hunian modern dan minimalis. Unit ini '
            'sudah dilengkapi dengan fasilitas seperti TV dan kulkas, ideal '
            'untuk kebutuhan tinggal harian di kawasan baru yang berkembang '
            'pesat di PIK 2.',
        descriptionExtra: const [
          'Tokyo Riverside PIK 2 merupakan bagian dari kawasan mega proyek '
              'Pantai Indah Kapuk 2 yang menghadirkan suasana urban modern '
              'dengan sentuhan ruang terbuka hijau dan pemandangan tepi air. '
              'Apartemen ini memiliki fasilitas lengkap seperti keamanan 24 '
              'jam, elevator, minimarket, kafe, area bermain anak, lapangan '
              'basket, lapangan tenis, serta kolam renang berbayar.',
        ],
        descriptionExtraHeading: 'Rekomendasi Tempat Rekreasi Terdekat:',
        address: 'Tokyo Riverside PIK 2, Lemo, Kabupaten Tangerang, Banten',
        latitude: -6.0664,
        longitude: 106.6572,
        nearbyPlaces: detail.nearbyPlaces,
        guestMedia: detail.guestMedia,
        buildingUnits: detail.buildingUnits,
        priceCaption: 'per bulan mulai dari',
        priceAmount: 3208500,
        isFlashSale: true,
      );

  // ----------------------------------------------------- rincian_unit_screen

  static final DateTime _checkIn = DateTime(2026, 8, 16);

  /// `tab_harian_1.jpg` + `tab_harian_2.jpg`.
  static UnitPricing get dailyPricing => UnitPricing(
        period: RentalPeriod.daily,
        propertyName: 'Apartemen Lucky Tower Residence',
        thumbnailUrl: _placeholder,
        bedrooms: 3,
        bathrooms: 2,
        checkIn: _checkIn,
        checkOut: DateTime(2026, 8, 17),
        basePrice: 1020000,
        serviceFee: 260000,
        inclusions: const InclusionList(
          included: [
            'Electricity + Water',
            'Ammenities',
            'Use of towel and linen',
          ],
          excluded: ['Parking', 'Internet'],
        ),
        specialPrices: const [
          SpecialPriceTier(minNights: 4, discountPercent: 5),
          SpecialPriceTier(minNights: 7, discountPercent: 10),
          SpecialPriceTier(minNights: 14, discountPercent: 20),
        ],
        addOns: const [
          AddOn(
            id: 'insurance',
            name: 'Personal Insurance',
            durationNote: '1 Malam',
            price: 4100,
            info: 'Perlindungan atas kerusakan tidak disengaja selama masa '
                'sewa, hingga IDR 5,000,000.',
            selectedByDefault: true,
          ),
        ],
        promo: const AppliedPromo(code: 'AGD30', savings: 50000),
      );

  /// `tab_bulanan_1.jpg` + `tab_bulanan_2.jpg`.
  static UnitPricing get monthlyPricing => UnitPricing(
        period: RentalPeriod.monthly,
        propertyName: 'Apartemen Lucky Tower Residence',
        thumbnailUrl: _placeholder,
        bedrooms: 3,
        bathrooms: 2,
        checkIn: _checkIn,
        checkOut: DateTime(2026, 9, 16),
        duration: 1,
        durationOptions: const [1, 2, 3, 6, 12],
        basePrice: 14250000,
        serviceFee: 750000,
        inclusions: const InclusionList(
          included: [
            'IPL, Service Charge, Sinking Fund, PJU dan Iuran Penghuni '
                'Lainnya (Gratis untuk sewa bulanan)',
            'Water',
            'Use of towel and linen',
          ],
          excluded: [
            'Cleaning',
            'Parking Charges',
            'Electricity',
            'Linen',
            'Internet',
            'Amenities',
          ],
        ),
        addOns: const [
          AddOn(
            id: 'insurance',
            name: 'Personal Insurance',
            durationNote: '1 Bulan',
            price: 35500,
            info: 'Perlindungan atas kerusakan tidak disengaja selama masa '
                'sewa, hingga IDR 5,000,000.',
            selectedByDefault: true,
          ),
          AddOn(
            id: 'linen',
            name: 'Linen with Weekly Cleaning',
            price: 940000,
            info: 'Penggantian linen dan pembersihan unit satu kali per '
                'minggu selama masa sewa.',
            selectedByDefault: true,
          ),
          AddOn(
            id: 'dust_mite',
            name: 'Dust Mite Cleaning Service',
            info: 'Pembersihan tungau pada kasur dan sofa. Harga mengikuti '
                'jumlah furnitur di unit.',
          ),
        ],
        promo: const AppliedPromo(code: 'FS26M30', savings: 150000),
      );

  /// `tab_tahunan_default.jpg` … `tab_tahunan_filter_2.jpg`.
  ///
  /// No promo is applied here, which is why the row renders as the empty
  /// `Gunakan Kupon` button instead of a code chip.
  static UnitPricing get yearlyPricing => UnitPricing(
        period: RentalPeriod.yearly,
        propertyName: 'Apartemen Lucky Tower Residence',
        thumbnailUrl: _placeholder,
        bedrooms: 3,
        bathrooms: 2,
        checkIn: _checkIn,
        checkOut: DateTime(2027, 8, 16),
        duration: 1,
        durationOptions: const [1, 2, 3],
        basePrice: 111750000,
        serviceFee: 2230000,
        inclusions: const InclusionList(
          excluded: [
            'Cleaning',
            'Parking Charges',
            'Electricity',
            'IPL, Service Charge, Sinking Fund, PJU dan Iuran Penghuni '
                'Lainnya (Gratis untuk sewa bulanan)',
            'Linen',
            'Internet',
            'Amenities',
          ],
        ),
        addOns: const [
          AddOn(
            id: 'insurance',
            name: 'Personal Insurance',
            durationNote: '1 Tahun',
            price: 271000,
            info: 'Perlindungan atas kerusakan tidak disengaja selama masa '
                'sewa, hingga IDR 5,000,000.',
            selectedByDefault: true,
          ),
          AddOn(
            id: 'dust_mite',
            name: 'Dust Mite Cleaning Service',
            info: 'Pembersihan tungau pada kasur dan sofa. Harga mengikuti '
                'jumlah furnitur di unit.',
          ),
        ],
        plans: paymentPlans,
        scheduleNote: '*Simulasi hanya mencakup biaya layanan; diskon dan '
            'biaya lainnya tidak termasuk',
      );

  /// The six options of `PILIH RENCANA PEMBAYARAN`
  /// (`tab_tahunan_filter_show_select_screen_cicilan.jpg`).
  static List<InstallmentPlan> get paymentPlans => [
        const InstallmentPlan(
          id: 'full',
          name: 'Bayar Penuh',
          installments: 1,
          total: 113980000,
        ),
        InstallmentPlan(
          id: 'x2',
          name: 'Cicilan 2x',
          cadence: 'bayar setiap 6 bulan',
          installments: 2,
          entries: _schedule(const [30260625, 84956875], monthStep: 6),
          total: 115217500,
        ),
        InstallmentPlan(
          id: 'x3',
          name: 'Cicilan 3x',
          cadence: 'bayar setiap 4 bulan',
          installments: 3,
          entries:
              _schedule(const [30260625, 42978437, 42978438], monthStep: 4),
          total: 116217500,
        ),
        InstallmentPlan(
          id: 'x4',
          name: 'Cicilan 4x',
          cadence: 'bayar setiap 3 bulan',
          installments: 4,
          entries: _schedule(
            const [30260625, 28985625, 28985625, 28985625],
            monthStep: 3,
          ),
          total: 117217500,
        ),
        InstallmentPlan(
          id: 'x6',
          name: 'Cicilan 6x',
          cadence: 'bayar setiap 2 bulan',
          installments: 6,
          entries: _schedule(
            const [
              30260625,
              20191375,
              20191375,
              20191375,
              20191375,
              10191375,
            ],
            monthStep: 2,
          ),
          total: 121217500,
        ),
        InstallmentPlan(
          id: 'x12',
          name: 'Cicilan 12x',
          cadence: 'bayar setiap bulan',
          installments: 12,
          entries: _schedule(
            const [
              30260625,
              11488125,
              11488125,
              11488125,
              11488125,
              11488125,
              11488125,
              11488125,
              11488125,
              11488125,
              2946875,
              2946875,
            ],
          ),
          // Printed verbatim from `tab_tahunan_filter_1.jpg`; the screenshot's
          // own `Total` row does not equal the sum of its visible rows, so the
          // value is stored rather than derived. See README.
          total: 135217500,
        ),
      ];

  /// Builds the `Jadwal Pembayaran` dates: the first instalment falls on
  /// check-in, the rest on the 11th, `monthStep` months apart.
  static List<InstallmentEntry> _schedule(
    List<num> amounts, {
    int monthStep = 1,
  }) {
    final entries = <InstallmentEntry>[];
    for (var i = 0; i < amounts.length; i++) {
      entries.add(
        InstallmentEntry(
          date: i == 0
              ? _checkIn
              : DateTime(_checkIn.year, _checkIn.month + i * monthStep, 11),
          amount: amounts[i],
        ),
      );
    }
    return entries;
  }
}
