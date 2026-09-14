# USER MANUAL MOBILE APP
## Manual Sistem & Arsitektur Teknis Aplikasi Mobile Livirooms (Flutter)
**Document Version:** 2.4.0  
**Target Platform:** Flutter (Android & iOS)  
**Architecture:** Single App, Dual Shell (`MainShell` untuk Konsumen, `MitraShell` untuk Mitra/Host)  
**State Management:** Provider (`provider ^6.1.2`)  
**Network Client:** HTTP Transport (`package:http ^1.2.1`) dengan `ApiClient` Abstraction  
**Payment Gateway:** Midtrans Snap SDK (`webview_flutter ^4.13.0` & `app_links ^6.3.2`)  
**Backend Master:** Laravel 12 REST API (`/api/v1`) dengan PostgreSQL 16 3NF  

---

## DAFTAR ISI

1. [Arsitektur Global & Desain Sistem Mobile](#1-arsitektur-global--desain-sistem-mobile)
   - 1.1 Pola Dua Peran (Dual-Shell Architecture)
   - 1.2 Manajemen State & Lapisan Transport API
   - 1.3 Siklus Hidup Navigasi & Auto-Refresh (`RouteAware`)
2. [Modul 1: Authentication, Onboarding & Recovery](#2-modul-1-authentication-onboarding--recovery)
   - 2.1 Purpose & User Flow
   - 2.2 Screen Components & UI States
   - 2.3 State Management & API Integration
3. [Modul 2: Home, Explore & Search Discovery](#3-modul-2-home-explore--search-discovery)
   - 3.1 Purpose & User Flow
   - 3.2 Screen Components & UI States
   - 3.3 State Management & API Integration
4. [Modul 3: Property & Hotel Detail Experience](#4-modul-3-property--hotel-detail-experience)
   - 4.1 Purpose & User Flow (Property vs Hotel)
   - 4.2 Screen Components & UI States
   - 4.3 State Management & API Integration
5. [Modul 4: Booking, Unit Configuration & Reservation Flow](#5-modul-4-booking-unit-configuration--reservation-flow)
   - 5.1 Purpose & User Flow (Rincian Unit vs Hotel Booking)
   - 5.2 Screen Components & Dynamic Price Calculation
   - 5.3 State Management & API Integration
6. [Modul 5: Payment Gateway, Checkout & Midtrans Snap Integration](#6-modul-5-payment-gateway-checkout--midtrans-snap-integration)
   - 6.1 Purpose & User Flow
   - 6.2 Screen Components & WebView Lifecycle
   - 6.3 Deep Link Handler & Webhook Settlement Verification
7. [Modul 6: Riwayat Pesanan & Booking Management (Tiket & Voucher Digital)](#7-modul-6-riwayat-pesanan--booking-management-tiket--voucher-digital)
   - 7.1 Purpose & User Flow
   - 7.2 Screen Components & 9-State Lifecycle Badges
   - 7.3 State Management & Auto-Reload On Resume
8. [Modul 7: User Profile, Wishlist & Settings](#8-modul-7-user-profile-wishlist--settings)
   - 8.1 Purpose & User Flow
   - 8.2 Screen Components & UI States
   - 8.3 State Management & API Integration
9. [Lampiran: Matriks Rute, Layar, Service Dart, dan Payload API Contract](#9-lampiran-matriks-rute-layar-service-dart-dan-payload-api-contract)

---

# 1. ARSITEKTUR GLOBAL & DESAIN SISTEM MOBILE

### 1.1 Pola Dua Peran (Dual-Shell Architecture)
Aplikasi seluler **Livirooms** dirancang dengan pendekatan arsitektur satu basis kode (*Single Codebase*) yang melayani dua persona pengguna yang berbeda melalui pemisahan Shell antarmuka di level navigasi root:
1. **Konsumen Shell (`MainShell`):** Antarmuka utama pencari sewa properti dan kamar hotel. Memiliki 5 navigasi bawah (*Bottom Navigation Bar*):
   - **Tab 0:** `HomeScreen` (Eksplorasi beranda, banner promosi, kurasi kota, dan akomodasi terpopuler).
   - **Tab 1:** `BookingListScreen` (Daftar pemesanan aktif, riwayat menginap, dan e-voucher).
   - **Tab 2:** `WishlistScreen` (Koleksi properti favorit yang disimpan).
   - **Tab 3:** `PesanScreen` / `ChatListScreen` (Pusat pesan percakapan dengan Host dan Customer Support).
   - **Tab 4:** `AccountMenuScreen` (Profil pengguna, verifikasi akun, kode referral, dan pengaturan).
2. **Mitra / Host Shell (`MitraShell`):** Antarmuka pemilik properti untuk memantau performa bisnis, kalender okupansi, pengelolaan listing, pemrosesan pesanan masuk, dan dompet pencairan dana (*Mitra Wallet*).

```
+-----------------------------------------------------------------------+
| ENTRY POINT: main.dart -> AppRouter.onGenerateRoute                   |
+-----------------------------------------------------------------------+
| AuthProvider.isLoggedIn == true ?                                     |
|    ├── User.isHost == true  ──► Routes.mitraHome (MitraShell)         |
|    └── User.isHost == false ──► Routes.home (MainShell)               |
| AuthProvider.isLoggedIn == false                                      |
|    └── First install?       ──► Routes.onboarding / Routes.welcome    |
|                             ──► Routes.home (Tamu Jelajah Tanpa Login)|
+-----------------------------------------------------------------------+
```

### 1.2 Manajemen State & Lapisan Transport API
- **State Management:** Menggunakan pustaka resmi `provider ^6.1.2`. `AuthProvider` diregistrasikan di tingkat tertinggi `MultiProvider` pada `main.dart` untuk memantau status token JWT Sanctum, profil pengguna, dan sinkronisasi sesi.
- **Lapisan Transport API (`ApiClient`):** Berdiri di atas kontrak `ApiTransport`:
  - `_RealApiClient`: Berkomunikasi langsung dengan backend Laravel melalui `package:http ^1.2.1`. Menginjeksi token otentikasi `Bearer <sanctum_token>` dari penyimpanan lokal aman `SharedPreferences` via `AuthStorage`, dengan batas *network timeout* 20 detik.
  - `DummyApiClient`: Engine simulasi offline yang memuat fixture berkas JSON lokal dari `assets/json/` ketika aplikasi dijalankan dengan flag `--dart-define=DUMMY_API=true`.
- **Standar Amplop API (`ApiResponse`):** Seluruh respons di-deserialize ke kelas model `ApiResponse<T>`:
  ```json
  {
    "status": true,
    "code": 200,
    "message": "Operasi berhasil",
    "data": { ... },
    "meta": null,
    "errors": null
  }
  ```

### 1.3 Siklus Hidup Navigasi & Auto-Refresh (`RouteAware`)
Pemesanan properti memerlukan sinkronisasi data seketika saat tamu berpindah layar atau kembali dari browser pembayaran Midtrans. Aplikasi mengimplementasikan:
- `RouteObserver<PageRoute>` terdaftar secara global di `router.dart`.
- `BookingListScreen` mengimplementasikan `RouteAware` (`didPopNext()`) dan `WidgetsBindingObserver` (`didChangeAppLifecycleState: resumed`) untuk memicu pemanggilan ulang `_load()` tanpa memerlukan intervensi manual dari pengguna.

---

# 2. MODUL 1: AUTHENTICATION, ONBOARDING & RECOVERY

### 2.1 Purpose & User Flow
Modul Autentikasi mengamankan akses akun tamu dan mitra ke platform Livirooms, mendukung pendaftaran akun baru, validasi kredensial, proteksi sesi menggunakan token Bearer Sanctum, serta pemulihan kata sandi yang terlupa.

```
[Splash Screen] 
       │ (Cek Token di SharedPreferences)
       ├── Token Valid & Host?     ──► [MitraShell (Host Home)]
       ├── Token Valid & Consumer? ──► [MainShell (Home Tab)]
       └── Belum Login / Expired   ──► [Welcome / Login Screen]
                                              │
               ┌──────────────────────────────┴──────────────────────────────┐
               ▼                                                             ▼
        [Login Screen]                                                [Register Screen]
     (Email/Phone + Password)                                       (Nama, Email, Telepon)
               │                                                             │
        [Forgot Password]                                            [Register Profile]
     (Request OTP / Reset Link)                                    (Tipe Akun, Domisili)
```

### 2.2 Screen Components & UI States
1. **Splash Screen (`SplashScreen` — `/splash`):**
   - Menampilkan logo visual Livirooms animasi transisi fade-in.
   - Menginisialisasi service lokal, memuat konfigurasi `RemoteConfigService`, serta memeriksa token `AuthStorage`.
2. **Onboarding & Welcome (`OnboardingScreen` & `WelcomeScreen`):**
   - Carousel ilustrasi keuntungan memesan apartemen dan hotel di Livirooms (fleksibilitas durasi sewa, jaminan unit terverifikasi, pembayaran aman).
   - Tombol aksi utama: **Masuk (Login)**, **Daftar Akun Baru**, dan **Jelajahi Sekarang (Guest Mode)**.
3. **Login Screen (`LoginScreen` — `/auth/login`):**
   - Input identifier ganda (dapat menerima alamat email atau nomor WhatsApp/ponsel).
   - Input kata sandi dengan toggle intip (*eye visibility icon*).
   - Tombol *Lupa Kata Sandi?* yang mengarahkan ke `ForgotPasswordScreen`.
   - Tombol **Masuk** dengan indikator *loading spinner* internal (`_isLoading`).
4. **Register Screen (`RegisterScreen` & `RegisterProfileScreen`):**
   - Input nama lengkap, nomor telepon aktif, email, dan kata sandi baru (minimal 8 karakter).
   - Pemilihan minat tipe hunian (Apartemen Harian/Bulanan vs Hotel Staycation).
5. **State Handling:**
   - **Loading State:** Tombol `BrandButton` beralih menampilkan CircularProgressIndicator warna putih, mencegah klik ganda (*double submission guard*).
   - **Error State:** Menampilkan banner merah `TopSnackBar` atau dialog pop-up informatif saat kredensial salah atau nomor telepon telah terdaftar.

### 2.3 State Management & API Integration
- **State Provider:** `AuthProvider` (`auth_provider.dart`) mengelola objek `User? user` dan status boolean `isLoggedIn`.
- **Service Pemanggil:** `AuthService` (`auth_service.dart`).
- **Endpoint Terkait:**
  - `POST /api/v1/auth/register` (Registrasi akun baru)
  - `POST /api/v1/auth/login` (Otentikasi kredensial & pengambilan Bearer token)
  - `GET /api/v1/auth/me` (Sinkronisasi profil aktif)
  - `POST /api/v1/auth/logout` (Revokasi token Sanctum di server)

---

# 3. MODUL 2: HOME, EXPLORE & SEARCH DISCOVERY

### 3.1 Purpose & User Flow
Layar Beranda (*Home Screen*) berfungsi sebagai etalase digital utama penemuan akomodasi. Memfasilitasi pencarian multi-kategori (Sewa Apartemen Harian, Sewa Bulanan, Hotel Bintang, Kost Eksklusif), pencarian lokasi berdasarkan kota, serta kurasi rekomendasi promo dan diskon flash-sale.

```
+---------------------------------------------------------------------+
| LIVIROOMS - TEMUKAN HUNIAN IMPIAN ANDA                              |
+---------------------------------------------------------------------+
| [ Lokasi: Jakarta Selatan v ]               [ [L] Notifikasi (3) ]  |
| [Cari apartemen, gedung, stasiun, hotel...]                         |
+---------------------------------------------------------------------+
| SHORTCUT KATEGORI:                                                  |
| [ Apt Harian ]   [ Apt Bulanan ]   [ Hotel Murah ]   [ Villa Mewah ]|
+---------------------------------------------------------------------+
| PROMO & BANNER SPESIAL (Carousel):                                  |
| [=================== BANNER FLASH SALE BULANAN ===================] |
+---------------------------------------------------------------------+
| REKOMENDASI TERBAIK DI KOTA ANDA:                                   |
| +-------------------------+ +-------------------------+             |
| | [FOTO] Bassura City Apt | | [FOTO] Beverly Tower    |             |
| | Jkt Timur | Star 4.8    | | Jkt Selatan | Star 4.9  |             |
| | Rp 3.500.000 / bln      | | Rp 6.200.000 / bln      |             |
| +-------------------------+ +-------------------------+             |
+---------------------------------------------------------------------+
```

### 3.2 Screen Components & UI States
1. **Header Lokasi & Search Bar:**
   - Dropdown pemilih kota cepat (`CitySelectorSheet`) yang memfilter listing rekomendasi secara reaktif.
   - Bilah pencarian interaktif yang ketika ditekan membuka `PropertySearchScreen` atau `HotelSearchScreen`.
2. **Category Shortcut Grid:**
   - Ikon jalan pintas tematik: **Apartemen Harian**, **Apartemen Bulanan**, **Hotel Staycation**, **Vila Liburan**.
3. **Banner Carousel Slider:**
   - Slider promo visual responsif dengan penanda titik (*dot indicators*). Menautkan banner ke halaman promo voucher atau kurasi properti khusus.
4. **Listing Card Component (`PropertyCard` & `HotelCard`):**
   - Menampilkan cover foto rasio 16:9 (`CachedNetworkImage` dengan shimmer placeholder).
   - Label kategori hunian, rating ulasan (skala 1-10) dengan bintang emas.
   - Ikon spesifikasi singkat (Kapasitas Tamu, Jumlah Kamar Tidur, Luas $m^2$).
   - Badge ketersediaan instan (*Instant Booking*) dan harga terendah (`price_from`).
   - Tombol hati (*Wishlist Toggle*) di sudut kanan atas foto kartu.
5. **Filter Screen (`FilterScreen` — `/filter`):**
   - Slider rentang harga min-max (*RangeSlider*).
   - Pilihan tipe properti (Apartemen, Kost, Vila, Hotel).
   - Filter fasilitas wajib (Kolam Renang, WiFi Kencang, Dapur, Parkir Mobil, Mesin Cuci).
   - Filter kebijakan (Boleh Merokok, Hewan Peliharaan Diizinkan, Check-in 24 Jam).

### 3.3 State Management & API Integration
- **Service Pemanggil:** `HomeService`, `CityService`, `PropertyService`, `SearchLogService`.
- **Endpoint Terkait:**
  - `GET /api/v1/home?city_id={id}` (Memuat banner promosi dan rekomendasi terkurasi kota aktif)
  - `GET /api/v1/cities` (Daftar seluruh wilayah kota operasional Livirooms)
  - `GET /api/v1/properties` (Pencarian daftar sewa properti unit)
  - `GET /api/v1/hotels` (Pencarian daftar hotel OTA)
  - `POST /api/v1/search-logs` (Mencatat analitik keyword pencarian tamu secara asinkron tanpa memblokir UI)

---

# 4. MODUL 3: PROPERTY & HOTEL DETAIL EXPERIENCE

### 4.1 Purpose & User Flow (Property vs Hotel)
Layar Detail menyajikan informasi menyeluruh mengenai unit sewa atau hotel sebelum tamu mengambil keputusan memesan. Sistem membagi alur penyajian menjadi dua varian berdasarkan arsitektur backend `booking_mode`:
- **Property Detail (`booking_mode = 'unit'`):** Menampilkan rincian hunian tunggal, spesifikasi perabot ruangan (*furniture groups*), rincian bed kasur, dan kalkulator durasi sewa harian/bulanan.
- **Hotel Detail (`booking_mode = 'room'`):** Menampilkan profil hotel berbintang, blok pilihan tipe kamar (*Room Types Grid* seperti Deluxe, Suite), kuota kamar tersisa, dan fasilitas sarapan.

```
[Explore / Search] ──► Klik Kartu Properti / Hotel
                              │
               ┌──────────────┴──────────────┐
               ▼                             ▼
   [PropertyDetailScreen]          [HotelDetailScreen]
   - Galeri Foto Unit              - Galeri Foto Hotel
   - Luas m2, Kamar, Kamar Mandi   - Peringkat Bintang Hotel
   - Perabot per Ruangan           - Daftar Kamar (Unit Types)
   - Kebijakan Pembatalan          - Allotment Stok Sisa
   - Tombol: "Pilih Opsi Sewa"     - Tombol: "Pilih Kamar Ini"
               │                             │
               ▼                             ▼
       [RincianUnitScreen]          [HotelBookingScreen]
```

### 4.2 Screen Components & UI States
1. **Interactive Photo Carousel (`FullImageScreen` Support):**
   - Header carousel foto layar penuh dengan penghitung halaman foto ($1/12$).
   - Tombol aksi mengambang: Kembali (*Back*), Bagikan (*Share*), dan Simpan Favorit (*Wishlist Heart*).
   - Ketukan pada foto membuka galeri layar penuh dengan dukungan pinch-to-zoom.
2. **Blok Informasi Utama & Rating:**
   - Judul akomodasi, tipe hunian, bintang hotel, dan badge skor ulasan tamu (skor 1.0 - 10.0 dengan label seperti "Luar Biasa", "Sangat Nyaman").
3. **Spesifikasi & Fasilitas (`FacilityItemGrid`):**
   - Baris ikon spesifikasi (Kapasitas Maksimal Tamu, Jumlah Kasur, Luas Ruangan $m^2$, Kamar Mandi).
   - Kategori fasilitas terkelompok: Fasilitas Kamar, Fasilitas Gedung, Layanan Parkir, dan Keamanan 24 Jam.
4. **Peta Lokasi & Poin Penting Sekitar (`NearbyPlacesSection`):**
   - Pratinjau peta lokasi statis dan daftar fasilitas transportasi terdekat (stasiun MRT/KRL, halte bus, bandara, rumah sakit, pusat perbelanjaan) lengkap dengan estimasi jarak dan waktu tempuh.
5. **Kebijakan & FAQ Properti:**
   - Jadwal jam check-in (mulai 14:00) dan check-out (maksimal 12:00).
   - Ketentuan deposit jaminan unit dan klausul kebijakan pengembalian dana pembatalan (*cancellation policy*).
6. **Sticky Bottom Action Bar:**
   - Menampilkan harga terendah mulai dari `price_from` per malam atau per bulan.
   - Tombol utama **Sewa Sekarang** (pada Properti) atau **Pilih Kamar** (pada Hotel).

### 4.3 State Management & API Integration
- **Models Terlibat:** `Property`, `Hotel`, `HotelRoomItem`, `FacilityGroup`, `AccommodationPolicy`, `NearbyPlace`, `Review`.
- **Service Pemanggil:** `PropertyService`, `HotelService`.
- **Endpoint Terkait:**
  - `GET /api/v1/properties/{id}` (Menghasilkan payload terstandar `propertyShape`)
  - `GET /api/v1/hotels/{id}` (Menghasilkan payload terstandar `hotelShape`)
  - `GET /api/v1/accommodations/{id}` (Unified endpoint yang auto-branching sesuai discriminator database)
  - `POST /api/v1/wishlists/{id}` (Menyimpan atau menghapus akomodasi dari daftar favorit)

---

# 5. MODUL 4: BOOKING, UNIT CONFIGURATION & RESERVATION FLOW

### 5.1 Purpose & User Flow (Rincian Unit vs Hotel Booking)
Modul ini menangani proses konfigurasi pesanan sebelum diteruskan ke gerbang pembayaran. Menghitung kalkulasi harga secara transparan, menerapkan kupon diskon promo, mencatat data tamu yang menginap, serta menampung permintaan khusus (*special requests*).

```
+---------------------------------------------------------------------+
| RINGKASAN PEMESANAN (RincianUnitScreen)                             |
+---------------------------------------------------------------------+
| AKOMODASI: Bassura City Apartment - Unit 12B, Tower Cattleya        |
| JADWAL SEWA : 01 Okt 2026 s/d 01 Nov 2026 (1 Bulan / 31 Hari)      |
| JUMLAH TAMU : 2 Dewasa, 0 Anak-anak                                 |
+---------------------------------------------------------------------+
| RINCIAN BIAYA SEWA TRANSAKSI:                                       |
| - Biaya Sewa Pokok (1 Bulan)                : Rp 4.200.000          |
| - Biaya Kebersihan (Cleaning Fee)           : Rp   150.000          |
| - Biaya Layanan Aplikasi Livirooms          : Rp    25.000          |
| - Deposit Jaminan Kerusakan (Refundable)    : Rp 1.000.000          |
| - Diskon Promo Voucher [LIVISEPTEMBER]      : -Rp  200.000          |
+---------------------------------------------------------------------+
| TOTAL PEMBAYARAN DI MUKA                    : Rp 5.175.000          |
+---------------------------------------------------------------------+
| [ X ] Saya menyetujui Aturan Hunian dan Kebijakan Pembatalan       |
| [ LANJUT KE PEMBAYARAN MIDTRANS (Rp 5.175.000) ]                   |
+---------------------------------------------------------------------+
```

### 5.2 Screen Components & Dynamic Price Calculation
1. **Pemilihan Durasi & Rentang Tanggal:**
   - **Sewa Harian:** Menampilkan `showDateRangePicker` kalender untuk memilih tanggal check-in dan check-out dengan validasi anti-bentrok.
   - **Sewa Bulanan / Tahunan:** Menampilkan `showDatePicker` untuk menentukan tanggal mulai sewa, dan durasi bulan (1, 3, 6, 12 bulan) dengan kalkulasi tanggal akhir sewa otomatis.
2. **Form Data Kontak & Identitas Tamu:**
   - Nama lengkap pemesan, alamat email aktif (untuk pengiriman tanda terima e-voucher), dan nomor WhatsApp.
   - Checkbox "Saya memesan untuk orang lain" yang membuka field nama tamu menginap tambahan.
3. **Form Permintaan Khusus (*Special Requests*):**
   - Pilihan checkbox cepat: Bebas Asap Rokok (*Non-smoking room*), Lantai Tinggi (*High floor*), Waktu Check-in Lebih Awal (*Early check-in*), Kasur Tambahan (*Extra bed*).
4. **Voucher Promo Sheet (`PromoCodeScreen`):**
   - Input manual kode voucher atau memilih kupon promo yang tersedia dari daftar.
   - Validasi langsung ke backend: jika kupon valid, nominal diskon langsung memotong rincian subtotal secara visual.
5. **Kalkulator Rincian Biaya (Price Breakdown):**
   - Rincian harga pokok sewa.
   - Biaya kebersihan (*cleaning fee*).
   - Biaya layanan platform Livirooms.
   - Biaya deposit jaminan kerusakan (bersifat dapat dikembalikan / *refundable* pasca-inspeksi check-out).
   - Potongan kupon promosi.
   - Total tagihan bersih (*Total Payable Amount*).

### 5.3 State Management & API Integration
- **Guard Anti-Double Submit:** Tombol pembayaran diproteksi oleh flag boolean `_isSubmitting` di tingkat State widget untuk mencegah tamu menekan tombol berulang kali saat jaringan lambat.
- **Service Pemanggil:** `BookingService`, `VoucherService`.
- **Endpoint Terkait:**
  - `POST /api/v1/booking-property` (Membuat order sewa unit properti: menerima `accommodation_id`, `check_in`, `check_out`, `duration_type`, `adults`, `promo_code`)
  - `POST /api/v1/booking-hotels` (Membuat order sewa kamar hotel: menerima array kamar `guests[]`, `rooms_count`, `check_in`, `check_out`)
  - `GET /api/v1/vouchers` (Daftar promo voucher aktif)

---

# 6. MODUL 5: PAYMENT GATEWAY, CHECKOUT & MIDTRANS SNAP INTEGRATION

### 6.1 Purpose & User Flow
Modul Pembayaran memfasilitasi transaksi moneter yang aman, fleksibel, dan terverifikasi secara instan. Mengintegrasikan **Midtrans Snap** untuk menyediakan beragam saluran pembayaran lokal Indonesia (Virtual Account Bank, QRIS, GoPay, ShopeePay, Kartu Kredit/Debit 3D Secure, serta gerai retail Alfamart/Indomaret).

```
[Rincian Unit / Booking]
           │ (POST /api/v1/booking-* -> Order Terbit)
           ▼
[PaymentMethodScreen] ──► Pilih: BCA VA, QRIS, GoPay, dll.
           │
           │ (POST /api/v1/orders/{id}/pay)
           ▼
[PaymentWebviewScreen] (Midtrans Snap WebView)
           │
           ├── Skenario A: Bayar Sukses via QRIS / E-Wallet / VA
           │        │
           │        ├──► Midtrans S2S Webhook ──► [Backend Laravel Update 'confirmed']
           │        │
           │        └──► Redirect URL Browser:
           │             livirooms://payment-result?order_id=X&status=success
           │                    │
           │                    ▼ (Ditangkap DeepLinkHandler)
           │             [PaymentResultScreen (SUCCESS)]
           │                    │
           │                    ▼
           │             [BookingSuccessScreen / Pesanan Saya]
           │
           └── Skenario B: Pembatalan / Waktu Habis (Pending / Expired)
                    │
                    ▼
           [PaymentResultScreen (PENDING / FAILED)]
                    │
                    ▼
           Tombol: "Coba Lagi" atau "Lihat Daftar Tagihan"
```

### 6.2 Screen Components & WebView Lifecycle
1. **Layar Pilihan Metode Pembayaran (`PaymentMethodScreen`):**
   - Menampilkan saldo Livirooms Wallet (jika memiliki kredit referral).
   - Pilihan kategori: Transfer Bank Virtual Account (BCA, Mandiri, BNI, BRI, Permata), Uang Elektronik Instant (GoPay, QRIS, ShopeePay), dan Kartu Kredit/Debit Visa/Mastercard.
2. **Midtrans Snap WebView (`PaymentWebviewScreen`):**
   - Diimplementasikan menggunakan `webview_flutter ^4.13.0`.
   - Mengontrol URL redirect: menyaring setiap skema URL yang diawali dengan `livirooms://payment-result` atau format deep link aplikasi e-wallet (seperti `gojek://`, `shopeeid://`).
   - Dilengkapi bilah kemajuan loading (*LinearProgressIndicator*) di bagian atas layar.
3. **Layar Konfirmasi Status Pembayaran (`PaymentResultScreen`):**
   - **Status Sukses (Hijau):** Menampilkan animasi centang sukses, nomor transaksi, metode pembayaran yang digunakan, dan tombol **Lihat E-Voucher Tiket**.
   - **Status Menunggu Pembayaran (Kuning/Pending):** Menampilkan nomor Virtual Account, batas waktu pembayaran (*Countdown Timer 24 Jam*), dan tombol salin nomor rekening VA.
   - **Status Gagal / Kedaluwarsa (Merah):** Menampilkan alasan kegagalan transaksi dan tombol **Ulangi Pembayaran**.

### 6.3 Deep Link Handler & Webhook Settlement Verification
- **Protokol Deep Link:** `livirooms://payment-result` didaftarkan pada manifes sistem operasi (Android `AndroidManifest.xml` via `intent-filter` dan iOS `Info.plist` via `CFBundleURLSchemes`).
- **Penanganan di Flutter:** `DeepLinkHandler` diinisialisasi pada `main.dart` menggunakan pustaka `app_links ^6.3.2`. Saat aplikasi dibuka kembali oleh redirect browser, listener deep link menangkap parameter query (`order_id`, `status`), lalu melakukan routing cerdas ke `PaymentResultScreen`.
- **Integritas Settlement:** Sesuai prinsip *Single Source of Truth*, aplikasi mobile **tidak pernah memutasi status pembayaran secara mandiri**. Aplikasi hanya meminta data status terbaru ke backend (`GET /api/v1/payments/check/{order}`), sementara backend Laravel hanya mengubah status menjadi `paid` setelah menerima sinyal resmi dari **Midtrans Server-to-Server (S2S) Webhook**.

---

# 7. MODUL 6: RIWAYAT PESANAN & BOOKING MANAGEMENT (TIKET & VOUCHER DIGITAL)

### 7.1 Purpose & User Flow
Layar Pesanan (`BookingListScreen`) adalah pusat kendali bagi tamu untuk mengelola seluruh reservasi yang dimiliki. Menyajikan pemisahan tab antara pesanan yang sedang berjalan (*Active Bookings*) dan riwayat inap masa lalu (*Past Stays*), membuka e-voucher tiket dengan QR code untuk check-in di front desk, serta memproses permohonan pembatalan sewa.

```
+---------------------------------------------------------------------+
| PESANAN SAYA (BookingListScreen)                                    |
+---------------------------------------------------------------------+
| [ TAB AKTIF: BERJALAN (2) ]          [ TAB RIWAYAT: SELESAI (8) ]   |
+---------------------------------------------------------------------+
| KARTU PESANAN AKTIF 1:                                              |
| [FOTO] Bassura City Apartment - Unit 12B                            |
| Kode: BK-LIV-202609-0012 | 01 Okt 2026 - 01 Nov 2026 (1 Bulan)     |
| Total: Rp 5.175.000 | Status: [ CONFIRMED / MENUNGGU CHECK-IN ]     |
| [ LIHAT VOUCHER & QR ]     [ CHAT HOST ]      [ HUBUNGI BANTUAN ]   |
+---------------------------------------------------------------------+
| KARTU PESANAN AKTIF 2:                                              |
| [FOTO] Hotel Aston Pasteur Bandung - Deluxe Room                    |
| Kode: BK-LIV-202609-0094 | 20 Sep 2026 - 22 Sep 2026 (2 Malam)     |
| Total: Rp 1.450.000 | Status: [ WAITING PAYMENT - Sisa 18:42 ]      |
| [ BAYAR SEKARANG ]         [ BATALKAN PESANAN ]                     |
+---------------------------------------------------------------------+
```

### 7.2 Screen Components & 9-State Lifecycle Badges
1. **Daftar Segmentasi Status:**
   Komponen `booking_widgets_segment_status.dart` dan `booking_widgets_bottom_bar.dart` menegakkan aturan tampilan visual yang ketat berdasarkan 9 status database:
   - `waiting_payment` (Kuning): Menampilkan countdown sisa waktu bayar dan tombol aktif **Bayar Sekarang**.
   - `waiting_confirmation` (Biru Muda): Menampilkan teks informatif bahwa host sedang memverifikasi unit.
   - `confirmed` / `paid` (Biru Tua): Unit telah terkunci aman, menampilkan tombol **Unduh E-Voucher Tiket**.
   - `waiting_checkin` (Oranye): Mengingatkan instruksi serah kunci unit di hari-H.
   - `staying` (Ungu): Tamu sedang menempati unit hunian.
   - `completed` (Hijau Sukses): Masa inap selesai. Menampilkan tombol **Beri Ulasan & Rating** bintang 1-10. Tombol bayar dan batalkan disembunyikan permanen.
   - `cancelled` / `expired` (Merah Bahaya): Transaksi dibatalkan atau waktu pembayaran terlampaui. Tombol aksi finansial dinonaktifkan sepenuhnya.
2. **Digital Voucher & QR Code Screen (`BookingDetailScreen`):**
   - Menampilkan kode batang dan QR Code reservasi resolusi tajam yang dapat dipindai oleh staf resepsionis atau host saat serah terima kunci.
   - Alamat akomodasi lengkap dan tautan navigasi langsung ke Google Maps.
   - Kontak darurat pengelola gedung dan tombol panggilan cepat.

### 7.3 State Management & Auto-Reload On Resume
- **Mekanisme Auto-Refresh:** Layar mengimplementasikan `RouteAware` dengan mendaftarkan listener ke `routeObserver`. Saat navigasi kembali dari halaman detail booking atau dari luar aplikasi (misalnya aplikasi e-wallet pembayaran), metode `didPopNext()` dan `AppLifecycleState.resumed` secara otomatis memicu pemanggilan ulang `_load()`.

---

# 8. MODUL 7: USER PROFILE, WISHLIST & SETTINGS

### 8.1 Purpose & User Flow
Modul Akun dan Pengaturan memberikan kendali penuh kepada pengguna atas informasi pribadi, preferensi aplikasi, daftar simpanan favorit (*Wishlist*), program afiliasi referral, formulir pendaftaran mitra host (KYC), serta pengaturan keamanan akun.

```
[Akun & Profil Pengguna]
       │
       ├──► [Edit Profil]            ──► Ubah Nama, No. HP, Gender, Tanggal Lahir, Foto Avatar
       ├──► [Wishlist Favorit]       ──► Daftar Hunian Favorit Tersimpan (Bisa Hapus / Pesan)
       ├──► [Daftar Menjadi Host]    ──► Formulir Validasi KYC (Upload Foto KTP & Selfie KTP)
       ├──► [Referral & Hadiah]      ──► Kode Referral Unik Pengguna & Saldo Dompet Bonus
       ├──► [Pengaturan Notifikasi]  ──► Sakelar Push FCM (Info Promo, Status Booking, Chat)
       ├──► [Pusat Bantuan & CS]     ──► FAQ Interaktif & Tombol Chat WhatsApp Dukungan
       └──► [Keluar / Logout]        ──► Pembersihan Sesi Lokal & Revokasi Token Sanctum
```

### 8.2 Screen Components & UI States
1. **Layar Profil Utama (`AccountMenuScreen` — Tab 4 MainShell):**
   - Kartu header profil: Foto avatar lingkaran (`CachedNetworkImage` dengan tombol edit kamera), Nama Lengkap Pengguna, Email Terdaftar, dan badge verifikasi akun.
   - Kartu saldo referral dan poin rewards.
   - Banner ajakan: *"Punya apartemen atau kamar kosong? Daftarkan properti Anda dan raih jutaan rupiah setiap bulan"* yang mengarahkan ke formulir kemitraan host.
2. **Edit Profile Screen (`EditProfileScreen` — `/edit-profile`):**
   - Input nama lengkap, nomor telepon (WhatsApp), jenis kelamin, tanggal lahir, dan alamat domisili.
   - Fitur unggah foto avatar menggunakan `image_picker` (memilih dari Galeri Foto atau Kamera gawai).
3. **Wishlist Screen (`WishlistScreen` — Tab 2 MainShell / `/wishlist`):**
   - Menampilkan kisi kartu akomodasi yang telah disimpan oleh pengguna.
   - **Empty State:** Menggunakan ilustrasi hati kosong dengan teks ramah: *"Belum ada properti favorit. Jelajahi apartemen impian Anda dan simpan di sini!"* dilengkapi tombol **Mulai Eksplorasi**.
4. **KYC Host Verification Screen (`ValidationScreen` — `/validation`):**
   - Formulir pengajuan upgrade akun menjadi mitra pemilik properti.
   - Komponen kamera pengunggah foto identitas resmi:
     - Foto Kartu Tanda Penduduk (KTP) asli yang terbaca jelas.
     - Foto potret diri (*Selfie*) sambil memegang KTP di samping wajah.
   - Input Nomor Induk Kependudukan (NIK) 16 digit dan nama lengkap sesuai KTP.
   - Tombol **Kirim Dokumen Verifikasi**. Pengajuan akan masuk ke Meja Verifikasi KYC di dashboard admin Laravel.
5. **Notification Settings Screen (`NotificationSettingsScreen`):**
   - Toggle switch independen: Notifikasi Transaksi & Booking, Notifikasi Chat Host, dan Notifikasi Penawaran Promo / Diskon.

### 8.3 State Management & API Integration
- **Service Pemanggil:** `ProfileService`, `WishlistService`, `ContentService`.
- **Endpoint Terkait:**
  - `GET /api/v1/profile` (Memuat data lengkap profil pengguna)
  - `PUT /api/v1/profile` (Memperbarui data teks profil)
  - `POST /api/v1/profile/avatar` (Mengunggah berkas foto profil multipart/form-data)
  - `POST /api/v1/user/validation` (Mengirimkan berkas KTP & selfie KTP untuk KYC host)
  - `GET /api/v1/wishlists` (Memuat daftar properti favorit pengguna)
  - `POST /api/v1/auth/logout` (Menghapus sesi otentikasi)

---

# 9. LAMPIRAN: MATRIKS RUTE, LAYAR, SERVICE DART, DAN PAYLOAD API CONTRACT

Tabel referensi komprehensif berikut memetakan seluruh alur teknis aplikasi seluler Flutter ke endpoint backend Laravel 12:

| Modul | Nama Layar Flutter | Rute (`Routes.*`) | Service Dart | Endpoint Backend Laravel | Payload / Keterangan |
|---|---|---|---|---|---|
| **Auth** | `SplashScreen` | `/splash` | `AuthService` | `GET /api/v1/auth/me` | Cek token lokal & redirect otomatis |
| **Auth** | `LoginScreen` | `/auth/login` | `AuthService` | `POST /api/v1/auth/login` | `{ email/phone, password }` |
| **Auth** | `RegisterScreen` | `/auth/register` | `AuthService` | `POST /api/v1/auth/register` | `{ name, email, phone, password }` |
| **Explore** | `HomeScreen` | `/` (`MainShell`) | `HomeService` | `GET /api/v1/home` | Menerima query parameter `?city_id={id}` |
| **Explore** | `FilterScreen` | `/filter` | `PropertyService` | `GET /api/v1/properties` | `{ city_id, price_min, price_max, type }` |
| **Explore** | `SearchResultsScreen` | `/search-results` | `PropertyService` | `GET /api/v1/properties` | Menampilkan hasil filter & sortir |
| **Explore** | `HotelSearchScreen` | `/hotel-search` | `HotelService` | `GET /api/v1/hotels` | Pencarian hotel berdasarkan bintang & lokasi |
| **Detail** | `PropertyDetailScreen`| `/property/detail` | `PropertyService` | `GET /api/v1/properties/{id}` | Payload lengkap `propertyShape` |
| **Detail** | `HotelDetailScreen` | `/hotel/detail` | `HotelService` | `GET /api/v1/hotels/{id}` | Payload lengkap `hotelShape` |
| **Booking** | `RincianUnitScreen` | `/rincian-unit` | `BookingService` | `POST /api/v1/booking-property` | `{ accommodation_id, check_in, check_out, duration_type, adults }` |
| **Booking** | `HotelBookingScreen` | `/hotel-booking` | `HotelService` | `POST /api/v1/booking-hotels` | `{ guests[], rooms_count, check_in, check_out }` |
| **Payment** | `PaymentMethodScreen` | `/payment-method` | `PaymentService` | `GET /api/v1/payments/methods` | Mengambil katalog channel pembayaran aktif |
| **Payment** | `PaymentWebviewScreen`| `/payment-webview`| `PaymentService` | `POST /api/v1/orders/{id}/pay` | Menerima `snap_token` & `redirect_url` |
| **Payment** | `PaymentResultScreen` | `/payment-result` | `PaymentService` | `GET /api/v1/payments/check/{id}`| Polling status settlement transaksi |
| **Trips** | `BookingListScreen` | `/bookings` | `BookingService` | `GET /api/v1/bookings` | Mengembalikan daftar pesanan dengan relasi nested |
| **Trips** | `BookingDetailScreen` | `/booking/detail` | `BookingService` | `GET /api/v1/bookings/{id}` | Detail e-voucher, invoice, & QR code |
| **Account** | `AccountMenuScreen` | `/account` | `ProfileService` | `GET /api/v1/profile` | Profil akun pengguna & ringkasan saldo |
| **Account** | `EditProfileScreen` | `/edit-profile` | `ProfileService` | `PUT /api/v1/profile` | `{ name, phone, gender, birth_date }` |
| **Account** | `ValidationScreen` | `/validation` | `ProfileService` | `POST /api/v1/user/validation` | Multipart berkas `upload_ktp` & `upload_selfie` |
| **Account** | `WishlistScreen` | `/wishlist` | `WishlistService` | `GET /api/v1/wishlists` | Daftar properti favorit yang disimpan |
| **Help** | `HelpSupportScreen` | `/help-support` | `ContentService` | `GET /api/v1/faqs` | Pertanyaan yang sering diajukan & kontak |

---

### Standar Kualitas & Pencegahan Bug Flutter
1. **Pencegahan Render Overflow:** Seluruh formulir input dan daftar kartu wajib dibungkus di dalam `SingleChildScrollView` atau `ListView` dengan `BouncingScrollPhysics` untuk menjamin kompatibilitas pada layar ponsel berukuran kecil saat keyboard virtual muncul.
2. **Caching Aset Jaringan:** Seluruh gambar eksternal wajib dimuat melalui `CachedNetworkImage` dengan durasi cache yang wajar serta menyertakan `placeholder` shimmer abu-abu dan `errorWidget` fallback gambar default Livirooms.
3. **Idempotensi Form Submission:** Setiap tombol transaksi pembayaran wajib menerapkan penjaga variabel `_isSubmitting` di level state untuk mengeliminasi risiko duplikasi pemotongan saldo atau pembuatan order ganda akibat ketukan berulang (*multi-tap*).

---
*Dokumen ini merupakan panduan teknis dan manual pengguna resmi aplikasi mobile Flutter Livirooms. Setiap penambahan layar, perubahan rute, atau refactoring service wajib didokumentasikan dan disinkronkan secara konsisten dengan dokumen ini.*
