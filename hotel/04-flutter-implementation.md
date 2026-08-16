# 04. Implementasi Frontend Flutter & Deep Linking (Daily Hotel Booking)

Dokumen ini mendokumentasikan implementasi frontend **Flutter** untuk modul pencarian & filter harian hotel berbasis UI referensi OTA (Lokasi, Tanggal Check-in/Check-out, Kamar & Tamu, Quick Filter Chips). Seluruh kode dirancang agar selaras dengan arsitektur eksisting yang menggunakan **`http` + `provider`**, **`ApiTransport`** (`_RealApiClient` & `DummyApiClient`), serta handler deep linking **`app_links`** dengan skema `sewain://`.

---

## 1. Ekstensi Model Eksisting (`flutter/lib/models/booking.dart`)

File [`flutter/lib/models/booking.dart`](file:///d:/Project/Fastwork/rental.apartemen/flutter/lib/models/booking.dart) diperbarui secara aditif dengan nilai default defensif agar payload eksisting dari server tetap dapat di-parse tanpa error.

```dart
class Booking {
  final int id;
  final String bookingCode;
  final int propertyId;
  final int userId;
  final DateTime checkIn;
  final DateTime checkOut;
  final String durationType;
  final String bookingType; // 'unit' | 'room' (Baru)
  final int roomsCount;    // Baru (Default 1)
  final int adults;        // Baru (Default 1)
  final int children;      // Baru (Default 0)
  final bool hasInsurance; // Baru (Asuransi Stay Protection)
  final double insuranceFee;// Baru
  final String status;
  final double totalPrice;
  final bool hostConfirmed;

  Booking({
    required this.id,
    required this.bookingCode,
    required this.propertyId,
    required this.userId,
    required this.checkIn,
    required this.checkOut,
    required this.durationType,
    this.bookingType = 'unit',
    this.roomsCount = 1,
    this.adults = 1,
    this.children = 0,
    this.hasInsurance = false,
    this.insuranceFee = 0.0,
    required this.status,
    required this.totalPrice,
    required this.hostConfirmed,
  });

  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      id: json['id'] as int,
      bookingCode: json['booking_code'] as String? ?? '',
      propertyId: json['property_id'] as int,
      userId: json['user_id'] as int,
      checkIn: DateTime.parse(json['check_in'] as String),
      checkOut: DateTime.parse(json['check_out'] as String),
      durationType: json['duration_type'] as String? ?? 'daily',
      bookingType: json['booking_type'] as String? ?? 'unit',
      roomsCount: json['rooms_count'] as int? ?? 1,
      adults: json['adults'] as int? ?? 1,
      children: json['children'] as int? ?? 0,
      hasInsurance: json['has_insurance'] == true || json['has_insurance'] == 1,
      insuranceFee: (json['insurance_fee'] as num? ?? 0.0).toDouble(),
      status: json['status'] as String? ?? 'waiting_confirmation',
      totalPrice: (json['total_price'] as num).toDouble(),
      hostConfirmed: json['host_confirmed'] == true ||
          json['host_confirmed'] == 1 ||
          json['host_confirmed'] == '1',
    );
  }
}
```

---

## 2. Value Object Filter & Serialisasi URL (`HotelSearchQuery`)

Dibuat immutable model untuk merepresentasikan status filter aktif dan dikonversi otomatis ke URL Query String maupun Deep Link URI.

```dart
// flutter/lib/models/hotel_search_query.dart

import '../utils/formatters.dart';

class HotelSearchQuery {
  final String? query;
  final int? cityId;
  final String? cityName;
  final DateTime checkIn;
  final DateTime checkOut;
  final int roomsCount;
  final int adults;
  final int children;
  final List<int> starRating;
  final List<String> facilities;
  final bool breakfastIncluded;
  final double? minPrice;
  final double? maxPrice;
  final String sort;

  HotelSearchQuery({
    this.query,
    this.cityId,
    this.cityName,
    DateTime? checkIn,
    DateTime? checkOut,
    this.roomsCount = 1,
    this.adults = 2,
    this.children = 0,
    this.starRating = const [],
    this.facilities = const [],
    this.breakfastIncluded = false,
    this.minPrice,
    this.maxPrice,
    this.sort = 'newest',
  })  : checkIn = checkIn ?? DateTime.now().add(const Duration(days: 1)),
        checkOut = checkOut ?? DateTime.now().add(const Duration(days: 2));

  int get nights => checkOut.difference(checkIn).inDays;

  // Konversi ke Query Parameters HTTP Request
  Map<String, String> toQueryParams() {
    final params = <String, String>{
      'booking_mode': 'room',
      'check_in': formatApiDate(checkIn),
      'check_out': formatApiDate(checkOut),
      'rooms_count': roomsCount.toString(),
      'adults': adults.toString(),
      'children': children.toString(),
      'breakfast_included': breakfastIncluded ? '1' : '0',
      'sort': sort,
    };

    if (query != null && query!.isNotEmpty) params['q'] = query!;
    if (cityId != null) params['city_id'] = cityId.toString();
    if (starRating.isNotEmpty) params['star_rating'] = starRating.join(',');
    if (facilities.isNotEmpty) params['facilities'] = facilities.join(',');
    if (minPrice != null) params['min_price'] = minPrice.toString();
    if (maxPrice != null) params['max_price'] = maxPrice.toString();

    return params;
  }

  // Parse dari Deep Link / Query Parameters URI
  factory HotelSearchQuery.fromUri(Uri uri) {
    final params = uri.queryParameters;
    return HotelSearchQuery(
      query: params['q'],
      cityId: params['city_id'] != null ? int.tryParse(params['city_id']!) : null,
      cityName: params['city_name'],
      checkIn: params['check_in'] != null ? DateTime.tryParse(params['check_in']!) : null,
      checkOut: params['check_out'] != null ? DateTime.tryParse(params['check_out']!) : null,
      roomsCount: int.tryParse(params['rooms_count'] ?? '1') ?? 1,
      adults: int.tryParse(params['adults'] ?? '2') ?? 2,
      children: int.tryParse(params['children'] ?? '0') ?? 0,
      starRating: params['star_rating'] != null
          ? params['star_rating']!.split(',').map((e) => int.parse(e.trim())).toList()
          : [],
      facilities: params['facilities'] != null ? params['facilities']!.split(',') : [],
      breakfastIncluded: params['breakfast_included'] == '1' || params['breakfast_included'] == 'true',
      sort: params['sort'] ?? 'newest',
    );
  }

  // Serialisasi ke Deep Link URI (sewain://search?...)
  Uri toDeepLinkUri() {
    return Uri(
      scheme: 'sewain',
      host: 'search',
      queryParameters: toQueryParams(),
    );
  }

  HotelSearchQuery copyWith({
    String? query,
    int? cityId,
    String? cityName,
    DateTime? checkIn,
    DateTime? checkOut,
    int? roomsCount,
    int? adults,
    int? children,
    List<int>? starRating,
    List<String>? facilities,
    bool? breakfastIncluded,
    double? minPrice,
    double? maxPrice,
    String? sort,
  }) {
    return HotelSearchQuery(
      query: query ?? this.query,
      cityId: cityId ?? this.cityId,
      cityName: cityName ?? this.cityName,
      checkIn: checkIn ?? this.checkIn,
      checkOut: checkOut ?? this.checkOut,
      roomsCount: roomsCount ?? this.roomsCount,
      adults: adults ?? this.adults,
      children: children ?? this.children,
      starRating: starRating ?? this.starRating,
      facilities: facilities ?? this.facilities,
      breakfastIncluded: breakfastIncluded ?? this.breakfastIncluded,
      minPrice: minPrice ?? this.minPrice,
      maxPrice: maxPrice ?? this.maxPrice,
      sort: sort ?? this.sort,
    );
  }
}
```

---

## 3. Provider State Management & Anti-Race Condition Controller

`HotelSearchProvider` menangani eksekusi auto-filter *real-time* dengan menyertakan token pemanggilan bertahap (*monotonic request token*) untuk membuang respon HTTP yang sudah basi (*stale response*).

```dart
// flutter/lib/providers/hotel_search_provider.dart

import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/hotel_search_query.dart';
import '../models/property.dart';
import '../services/property_service.dart';

class HotelSearchProvider extends ChangeNotifier {
  final PropertyService _propertyService;

  HotelSearchQuery _query = HotelSearchQuery();
  List<Property> _properties = [];
  bool _isLoading = false;
  String? _errorMessage;
  int _requestId = 0; // Monotonic token pembatal respon basi
  Timer? _debounceTimer;

  HotelSearchProvider(this._propertyService);

  HotelSearchQuery get query => _query;
  List<Property> get properties => _properties;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  void updateQuery(HotelSearchQuery newQuery, {bool immediate = false}) {
    _query = newQuery;
    notifyListeners();

    if (immediate) {
      executeSearch();
    } else {
      // Debounce 300ms untuk input cepat/filter chip
      _debounceTimer?.cancel();
      _debounceTimer = Timer(const Duration(milliseconds: 300), () {
        executeSearch();
      });
    }
  }

  Future<void> executeSearch() async {
    final currentToken = ++_requestId;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final results = await _propertyService.searchHotels(_query);

      // Hanya perbarui state jika token masih yang terbaru
      if (currentToken == _requestId) {
        _properties = results.items;
        _isLoading = false;
        notifyListeners();
      }
    } catch (e) {
      if (currentToken == _requestId) {
        _errorMessage = e.toString();
        _isLoading = false;
        notifyListeners();
      }
    }
  }

  // Quick Filter Toggles
  void toggleStarRating(int star) {
    final list = List<int>.from(_query.starRating);
    if (list.contains(star)) {
      list.remove(star);
    } else {
      list.add(star);
    }
    updateQuery(_query.copyWith(starRating: list));
  }

  void toggleBreakfast() {
    updateQuery(_query.copyWith(breakfastIncluded: !_query.breakfastIncluded));
  }

  void toggleFacility(String facilitySlug) {
    final list = List<String>.from(_query.facilities);
    if (list.contains(facilitySlug)) {
      list.remove(facilitySlug);
    } else {
      list.add(facilitySlug);
    }
    updateQuery(_query.copyWith(facilities: list));
  }
}
```

---

## 4. Ekstensi Handler Deep Link (`flutter/lib/services/deep_link_handler.dart`)

Mendukung navigasi otomatis dari URL skema `sewain://search?city_id=10&check_in=2026-08-28&check_out=2026-08-29&star_rating=4`.

```dart
// Modifikasi pada file flutter/lib/services/deep_link_handler.dart

void _handleUri(Uri uri) {
  if (uri.scheme != 'sewain') return;

  if (uri.host == 'search') {
    final hotelQuery = HotelSearchQuery.fromUri(uri);
    navigatorKey.currentState?.pushNamed(
      Routes.searchResults,
      arguments: hotelQuery,
    );
  } else if (uri.host == 'payment-result') {
    // Alur penanganan status pembayaran eksisting tetap utuh
    final status = uri.queryParameters['status'];
    final bookingId = uri.queryParameters['booking_id'];
    navigatorKey.currentState?.pushNamed(
      Routes.paymentResult,
      arguments: {'status': status, 'bookingId': bookingId},
    );
  }
}
```

---

## 5. Pendaftaran Route pada `DummyApiClient` & Client HTTP Real

Seluruh request API baru diikutsertakan pada pendaftaran route tabel di [`flutter/lib/services/dummy_api_client.dart`](file:///d:/Project/Fastwork/rental.apartemen/flutter/lib/services/dummy_api_client.dart) dan penyediaan fixture mock JSON di `assets/json/`.

### A. Registrasi `DummyApiClient`

```dart
// Pendaftaran route di DummyApiClient (flutter/lib/services/dummy_api_client.dart)
static const Map<String, String> routes = <String, String>{
  'GET properties': 'GET_properties',
  'GET properties/{id}': 'GET_properties_id',
  'GET insurance/plans': 'GET_insurance_plans',
  'GET bookings': 'GET_bookings',
  'GET bookings/{id}': 'GET_bookings_id',
  'POST bookings': 'POST_bookings',
  // ...
};
```

### B. Fixture Mock Assets JSON (`assets/json/`)

Seluruh fixture mock JSON telah diperbarui sesuai skema data terbaru:

1. **`GET_properties.json`**:
   Mendukung pencarian properti unit maupun hotel OTA (`booking_mode: "room"`, `star_rating: 4`, `check_in_time`, `check_out_time`, `has_breakfast: true`, `price_from: 750000`).

2. **`GET_properties_id.json`**:
   Detail properti lengkap dengan metadata hotel dan `cover_image`.

3. **`GET_insurance_plans.json`**:
   Daftar paket proteksi menginap aktif (`zurich_stay_basic`, `zurich_stay_deluxe`) beserta rincian premi & santunan.

4. **`GET_bookings.json` & `GET_bookings_id.json`**:
   Riwayat & detail pemesanan hotel (`booking_type: "room"`, `rooms_count`, `adults`, `children`, `has_insurance`, `insurance_fee`, `booking_rooms`, dan objek `insurance` tertanggung).

5. **`POST_bookings.json`**:
   Respon pembuatan booking + order baru yang menyertakan rincian proteksi dan subtotal order.


---

## 6. Integrasi Formatter Terpusat (`flutter/lib/utils/formatters.dart`)

Mencegah duplikasi helper format tanggal `yyyy-MM-dd` di berbagai file service:

```dart
// flutter/lib/utils/formatters.dart

String formatApiDate(DateTime date) {
  final year = date.year.toString().padLeft(4, '0');
  final month = date.month.toString().padLeft(2, '0');
  final day = date.day.toString().padLeft(2, '0');
  return '$year-$month-$day';
}

String formatHotelDateRange(DateTime checkIn, DateTime checkOut) {
  final nights = checkOut.difference(checkIn).inDays;
  final inFormatted = formatDate(checkIn); // Jum, 28 Agt
  final outFormatted = formatDate(checkOut); // Sab, 29 Agt
  return '$inFormatted – $outFormatted · $nights malam';
}
```

---

## 7. Widget Pemilihan Asuransi pada Layar Checkout (`InsuranceSelectionWidget`)

Komponen UI Flutter untuk menampilkan opsi proteksi menginap di layar konfirmasi pemesanan kamar hotel:

```dart
// flutter/lib/widgets/insurance_selection_widget.dart

import 'package:flutter/material.dart';

class InsurancePlanOption {
  final int id;
  final String name;
  final double premiumAmount;
  final double coverageAmount;

  InsurancePlanOption({
    required this.id,
    required this.name,
    required this.premiumAmount,
    required this.coverageAmount,
  });
}

class InsuranceSelectionWidget extends StatefulWidget {
  final InsurancePlanOption defaultPlan;
  final int nights;
  final int adults;
  final ValueChanged<bool> onInsuranceToggled;
  final TextEditingController nameController;
  final TextEditingController identityController;

  const InsuranceSelectionWidget({
    Key? key,
    required this.defaultPlan,
    required this.nights,
    required this.adults,
    required this.onInsuranceToggled,
    required this.nameController,
    required this.identityController,
  }) : super(key: key);

  @override
  State<InsuranceSelectionWidget> createState() => _InsuranceSelectionWidgetState();
}

class _InsuranceSelectionWidgetState extends State<InsuranceSelectionWidget> {
  bool _isSelected = false;

  @override
  Widget build(BuildContext context) {
    final totalFee = widget.defaultPlan.premiumAmount * widget.nights * widget.adults;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.verified_user, color: Colors.blueAccent),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Asuransi Menginap (${widget.defaultPlan.name})',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
                Switch(
                  value: _isSelected,
                  onChanged: (val) {
                    setState(() => _isSelected = val);
                    widget.onInsuranceToggled(val);
                  },
                ),
              ],
            ),
            const Text(
              'Melindungi dari kecelakaan diri, kompensasi keterlambatan check-in, dan kerusakan barang pribadi hingga Rp 25.000.000.',
              style: TextStyle(color: Colors.grey, fontSize: 13),
            ),
            const SizedBox(height: 8),
            Text(
              'Premi: Rp ${totalFee.toStringAsFixed(0)} (${widget.nights} malam, ${widget.adults} tamu)',
              style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.blueAccent),
            ),
            if (_isSelected) ...[
              const Divider(height: 24),
              TextField(
                controller: widget.nameController,
                decoration: const InputDecoration(
                  labelText: 'Nama Lengkap Tertanggung (sesuai KTP)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: widget.identityController,
                decoration: const InputDecoration(
                  labelText: 'No. KTP / NIK / Passport (Opsional)',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
---

## 8. Berkas Implementasi Layar Flutter Selesai (`flutter/lib/screens/property/hotel/`)

Empat layar utama telah selesai diimplementasikan sesuai acuan mockup dan build HTML Trip.com style:

### A. `HotelSearchScreen` (`hotel_search_screen.dart` — Route `/hotel/search`)
- **Fitur:** Hero gradient background, modal pemilihan kota/destinasi populer ber-gradien, picker tanggal check-in/out, modal stepper Kamar & Tamu (Dewasa, Anak), quick filter chips (Sarapan, Bintang 4), icon shortcut (Disimpan, Pemesanan, Promo saya, Dilihat).

### B. `HotelResultsScreen` (`hotel_results_screen.dart` — Route `/hotel/results`)
- **Fitur:** Summary topbar interaktif, horizontal filter chips bar (Urutkan, Filter, Lokasi, Kebutuhan), banner promo diskon dengan sheet **Trust Modal Keuntungan Booking**, daftar card hotel (badge skor, bintang, kutipan review, harga coret & diskon), dan floating bottom bar (Peta & Disimpan).

### C. `HotelDetailScreen` (`hotel_detail_screen.dart` — Route `/hotel/detail`)
- **Fitur:** Hero gallery preview (`1/43`), info umum (nama, bintang, tahun buka, alamat, rating skor & kutipan ulasan), **8 Tab Lengkap**:
  1. *Kamar*: Ringkasan rekomendasi kombo kamar dan daftar detail tipe kamar (`Family Suite`, `Kamar Superior`).
  2. *Ulasan*: Daftar FAQ horizontal, ulasan staff manager, dan tombol ajukan pertanyaan.
  3. *Pertanyaan Umum*: Tanya jawab seputar operasional hotel.
  4. *Lokasi*: Snapshot peta dan jarak titik transit (Stasiun Kereta, Metro, Bandara, Bus).
  5. *Fasilitas*: Kategori ber-ikon (Makanan/Minuman, Kolam Renang, Transportasi, Spa).
  6. *Kebijakan*: Jam check-in/out, resepsionis 24 jam, kebijakan tamu anak, dan tempat tidur tambahan.
  7. *Keterangan*: Deskripsi lengkap properti dan UGC Blog card ide tempat menginap.
  8. *Trip Moments & Akomodasi Terdekat*: Rekomendasi hotel sekitar dan benefit garansi *Kami Samakan Harga*.
- **Bottom Bar:** Harga kamar diskon & tombol *Pilih kamar*.

### D. `HotelBookingScreen` (`hotel_booking_screen.dart` — Route `/hotel/booking`)
- **Fitur:** Ringkasan tanggal & detail kombo kamar yang dipesan, form pengisian data tamu per kamar (Nama Depan & Belakang per kamar 1 & 2), form info kontak (Email validasi & No. Telepon), box info perolehan Trip Coins & deposit tunai, checkbox persetujuan syarat & ketentuan, banner jaminan harga *Kami Samakan Harga*, dan sticky bottom bar *Prabayar Online* + tombol *Pesan*.

### E. `HotelService` (`flutter/lib/services/hotel_service.dart`)
- Terintegrasi penuh dengan `ApiClient` dan `DummyApiClient` dengan mock response fixture di `assets/json/` (`GET_hotels.json`, `GET_hotels_id.json`, `POST_hotel_bookings.json`).

### F. Catatan Kondisi Nyata & Peringatan (hasil audit 16 Agt 2026)

Empat layar di atas **ada dan sudah terdaftar** di `flutter/lib/router.dart` (44 named route, semua route hotel berpasangan dengan handler-nya). Namun ada 4 hal yang **wajib** diketahui sebelum melanjutkan implementasi:

**1. 🔴 Dua endpoint yang dipanggil tidak ada di Laravel.**

| Dipanggil dari | Path | Route di `routes/api_mobile.php` |
|---|---|---|
| `HotelService.getHotelFilters()` | `GET hotel/filters` | ❌ tidak ada → 404 |
| `HotelService.createHotelBooking()` | `POST hotel/bookings` | ❌ tidak ada → 404 |

Keduanya "hidup" di mode dummy karena punya fixture (`POST_hotel_bookings.json` di daftar §E di atas) — jadi bug ini **tidak terlihat** selama `--dart-define=DUMMY_API=true`. Entri sebenarnya untuk pemesanan adalah **`POST bookings`** dengan `booking_type='room'`; **jangan** buat endpoint kedua. Lihat [A-D4 & A-D5](screen/readme_screen.md#113-drift-kontrak-flutter--laravel).

**2. 🟠 `HotelSearchProvider` melewati `HotelService`.** Provider memanggil `PropertyService.searchHotels()` (`GET properties`), sehingga menyimpan `Paginated<Property>` alih-alih `Paginated<Hotel>`. Akibatnya field khusus hotel — skor ulasan, jumlah ulasan, jarak dari pusat kota, tag `#14B8A6` — tidak tersedia di layar hasil meski `Hotel` sudah memodelkannya. Lihat [A-D6](screen/readme_screen.md#113-drift-kontrak-flutter--laravel).

**3. 🟠 Paket `top_modal_sheet` TIDAK terpasang.** `flutter/pubspec.yaml` hanya memuat `http`, `provider`, `shared_preferences`, `intl`, `cached_network_image`, `url_launcher`, `image_picker`, `app_links`. Top modal (pemilih tanggal & tamu, layar #12–#16) harus dibangun manual dengan `showGeneralDialog` + `SlideTransition` dari atas, **atau** paketnya ditambahkan lebih dulu. Jangan tulis `import 'package:top_modal_sheet/...'` dengan asumsi tersedia. Lihat [A-08](screen/readme_screen.md#4-log-anomali-aset--dokumentasi).

**4. 🟠 Deep link tanpa `city_id` masih crash.** `HotelSearchQuery.fromUri()` memakai `int.tryParse(q['city_id']!)` — satu-satunya field yang tidak punya fallback `??`, padahal `check_in`, `check_out`, `rooms_count`, `adults`, `children`, dan `star_rating` semuanya punya. `sewain://search?check_in=...` tanpa `city_id` akan *throw*. Lihat [A-D7](screen/readme_screen.md#113-drift-kontrak-flutter--laravel).

#### Komponen yang belum ada di `hotel_booking_screen.dart`

| Kekurangan | Layar di Master Ref |
|---|---|
| Bottom sheet kode promo | #36 |
| Bottom sheet permintaan khusus | #37 |
| Bottom sheet informasi tambahan | #33 |
| Bottom sheet detail kamar (Family Suite / Kamar Superior) | #34, #35 |
| ~~Ringkasan kamar masih *hardcode* lewat `_roomSummary(...)`~~ | #27 — ✅ beres di Fase 2, lihat [§G](#g-status-fase-2-diperbarui-16-agt-2026--apa-yang-sudah-tidak-berlaku-dari-f) |
| Seksi Trip Coins yang bisa dibuka-tutup | #29, #31, #32 |

#### Cakupan test Flutter yang sudah ada

`flutter/test/` berisi **17 file**, **6 menyentuh Hotel/asuransi** — jangan tulis ulang:

| File | Isi |
|---|---|
| `models/hotel_test.dart` | 6 test — parsing `Hotel`, `HotelRoomItem`, `HotelPolicy`, `HotelGuestInput.toJson()`, `HotelFacilityGroup` |
| `services/hotel_service_test.dart` | 9 test — `searchHotels`, `getHotelDetail`, `getRoomTypes`, `getInsurancePlans`, `createHotelBooking` ×2, `createHotelForProperty` ×2 |
| `providers/hotel_search_provider_test.dart` | 2 test |
| `models/hotel_search_query_test.dart` | 2 test |
| `widgets/hotel_screens_test.dart` | 8 `testWidgets` — **render-level saja** |
| `models/insurance_plan_test.dart` | 4 test — premi fixed & persentase, samakan dengan Laravel |

> 🔴 `services/hotel_service_test.dart:267` dan `:314` memakai `expectedPath: 'hotel/bookings'` — memaku endpoint hantu di poin 1. Karena transport palsu hanya menangkap body bila path cocok, kedua test akan **gagal** saat pemanggilan diarahkan ke `POST bookings`. Perbaiki keduanya bersamaan. Lihat [A-12](screen/readme_screen.md#4-log-anomali-aset--dokumentasi).
>
> 🟡 `getRoomTypes` terbukti **mendelegasikan** ke `getHotelDetail` — itulah sebab endpoint `GET hotels/{hotel}/room-types` yang ada di Laravel tidak pernah terpanggil ([A-D8](screen/readme_screen.md#113-drift-kontrak-flutter--laravel)).

### G. Status Fase 2 (diperbarui 16 Agt 2026) — apa yang sudah tidak berlaku dari §F

**§F adalah snapshot audit Fase 1.** Setelah perbaikan kode Fase 2, statusnya:

| Peringatan §F | Status sekarang |
|---|---|
| **1.** Dua endpoint hantu (`GET hotel/filters`, `POST hotel/bookings`) | ✅ **beres** — `GET hotel/filters` dihapus total (tak ada pemanggil); pemesanan diarahkan ke `POST bookings` dengan `booking_type: 'room'` + `duration_type: 'daily'` eksplisit. Fixture `GET_hotel_filters.json` & `POST_hotel_bookings.json` ikut dibuang, jadi §E di atas **tidak lagi akurat** soal fixture ketiga. |
| **2.** `HotelSearchProvider` melewati `HotelService` | ✅ **beres** — provider memakai `HotelService.searchHotels()` → `GET hotels`, state `Paginated<Hotel>`, dengan `loadMore()` bertoken anti-balapan. Bonus temuan: `PropertyService.searchHotels()` mengirim `sort=score_desc` ke `GET properties` yang hanya menerima `newest\|price_asc\|price_desc\|rating`, jadi **setiap** pencarian lewat provider dijawab 422. Metode itu dihapus. |
| **3.** `top_modal_sheet` tidak terpasang | ⏳ **masih berlaku** — belum ada paketnya, belum ada `AppTopModalShell` manual. Satu-satunya peringatan §F yang utuh. |
| **4.** Deep link tanpa `city_id` crash | ✅ **beres** — `int.tryParse(q['city_id'] ?? '')`. Sekalian diperbaiki asimetri `toQueryParams()` (memancarkan `star_rating[0]`) ↔ `fromUri` (dulu hanya membaca CSV). |

**Rantai argumen antar-layar hotel (baru, wajib dipakai).** Sebelumnya tiap layar hotel menebak sendiri tanggal & kamar, dan `HotelResultsScreen` bahkan membuka `Routes.propertyDetail` — layar sewa **unit** — sehingga `HotelDetailScreen` tak terjangkau dari alur pengguna mana pun ([A-15](screen/readme_screen.md#4-log-anomali-aset--dokumentasi)). Sekarang:

```
HotelSearchScreen
  └─ Routes.hotelResults ← HotelSearchQuery
       └─ Routes.hotelDetail ← HotelDetailArgs { hotel?, hotelId?, query? }
            └─ Routes.hotelBooking ← HotelBookingArgs { hotel, query, selections? }
                                       selections: List<HotelRoomSelection { roomType, count }>
```

- Ketiga case di `router.dart` tetap menerima bentuk lama (`Hotel` polos, `int` id) demi deep link & call site yang sudah ada; yang datang tanpa stay jatuh ke **`HotelSearchQuery.defaultStay()`** — satu-satunya fallback tanggal di seluruh modul. Jangan tambahkan fallback kedua.
- Kelas `*Args` didefinisikan di **kepala file layar yang mengonsumsinya** (konvensi repo), bukan di `models/`.
- Pemilihan kamar **selalu** lewat `Hotel.cheapestBookableRoom` (memfilter `remaining > 0`). Kartu rekomendasi, bar bawah layar detail, dan fallback layar booking memakai getter yang sama, supaya tak ada layar yang menawarkan kamar yang akan ditolak **422 allotment** oleh `BookingController`.
- Uang di layar hotel **wajib** lewat `Formatters.rupiah(...)`; `toStringAsFixed(0)` mentah masih tersisa di kartu hasil pencarian dan menjadi bagian dari [F-13](screen/readme_screen.md#152-flutter).

**🔴 Peringatan baru — harga hotel tidak dikirim server ([A-D11](screen/readme_screen.md#113-drift-kontrak-flutter--laravel)).** `GET hotels` dan `GET hotels/{hotel}` **tidak memuat** `price_per_night`, `price_original`, maupun `total_price`; harga hanya ada di `active_room_types[].base_price`. Jadi `Hotel.pricePerNight`/`totalPrice` = `0.0` di API nyata, dan kartu hasil pencarian menampilkan `Rp 0`. Terlihat benar di mode dummy semata-mata karena fixture memuat ketiga kunci itu. Layar detail sudah kebal lewat `_nightlyFrom()`; kartu hasil pencarian belum. **Perbaikan yang benar ada di Laravel** (`HotelApiController::index()` memancarkan `price_from` + `total_price`) — jangan hitung ulang di klien, karena filter harga & sort sudah dihitung server.

**🔴 Setiap kolom `decimal:*` menyeberang sebagai String.** `RoomType::$casts` memberi `base_price` & `price_original` cast `decimal:2`, dan `$rt->toArray()` mengirimkannya sebagai `"446637.00"`. Cast Dart `as num?` pada `String` menghasilkan `null` **tanpa exception** → harga jatuh ke 0 diam-diam ([A-16](screen/readme_screen.md#4-log-anomali-aset--dokumentasi)). Pakai helper toleran-tipe seperti `HotelRoomItem._toDouble()`, jangan `as num?`, untuk **semua** field uang yang datang dari kolom desimal.

**Tanggal: jangan pakai `DateFormat(..., 'id_ID')` di layar hotel.** Dua alasan terbukti: locale non-default **throw** kecuali `initializeDateFormatting()` sudah jalan — dan itu hanya dipanggil di `main.dart:13`, yang tidak pernah dieksekusi widget test; lalu intl menyingkat Agustus `Agu` sedangkan seluruh mockup hotel menulis `Agt`. Gunakan helper bebas-locale di `Formatters`: `dayMonthShort`, `weekdayDayMonthShort`, varian `iso*`-nya, dan `hourMinute` (memangkas detik dari kolom `TIME`). `NumberFormat`/`Formatters.rupiah` **tidak** butuh inisialisasi, jadi uang tetap lewat intl.

**Cakupan test setelah Fase 2:** suite Flutter **133 test / 17 file** (dari 117). Yang berubah dari tabel §F di atas: `models/hotel_test.dart` 6→**9**, `services/hotel_service_test.dart` 8→**10** (`expectedPath` diperbaiki ke `bookings`), `providers/hotel_search_provider_test.dart` 2→**6**, `models/hotel_search_query_test.dart` 2→**11**, `widgets/hotel_screens_test.dart` 8→**15** (tidak lagi render-level saja), `utils/formatters_test.dart` 10→**16**, `api_envelope_test.dart` +3. Status per ID: [§15.3 Master Reference](screen/readme_screen.md#153-test--wajib-permintaan-eksplisit-pengguna).

> ⚠️ Seluruh angka test di atas hasil **pembacaan kode**, belum dieksekusi — `flutter test` & `flutter analyze` belum bisa dijalankan (shell terkunci). Jalankan keduanya sebelum menandai item apa pun selesai; suite ini pernah merah tanpa disadari ([A-14](screen/readme_screen.md#4-log-anomali-aset--dokumentasi)).

Rujukan lengkap per layar, payload, dan design system: **[screen/readme_screen.md](screen/readme_screen.md)**.

