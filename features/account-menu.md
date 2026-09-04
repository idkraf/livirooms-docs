# Dokumentasi Fitur: Account Menu Screen (Screen 14)

**File Path:** `flutter/lib/screens/account/account_menu_screen.dart`  
**Route:** `Routes.account` (`/account`) & Embedded Tab di `MainShell` (Tab Index 4)  
**Tipe:** Consumer Account & Profile Navigation Hub  

---

## 1. Ringkasan Desain & Layout

Account Menu Screen telah diperbarui dengan desain modern bernuansa *Trip.com style* yang bersih, elegan, dan fungsional. Layar ini berfungsi sebagai pusat navigasi profil pengguna, loyalty/rewards, status pemesanan, pengaturan, serta portal pendaftaran dan peralihan ke Mode Mitra (Host).

---

## 2. Struktur Komponen UI

### A. Header Profil & Quick Actions
- **Avatar:** Lingkaran kuning lembut (`#FEF3D6`) dengan ikon siluet pengguna amber (`#F5A623`).
- **Judul:** Teks `"Halo Anggota Trip.com"` (atau nama pengguna aktif).
- **Sub-aksi:** Tombol interaktif `"Kelola Akun Saya >"` yang menavigasi ke `Routes.editProfile` (`EditProfileScreen`).
- **Aksi Cepat Kanan:**
  - **Ikon Pindai (Scan QR):** Menampilkan modal informasi kesiapan pemindaian QR tiket dan check-in mandiri.
  - **Ikon Bantuan (Headset):** Menavigasi ke pusat bantuan `Routes.help` (`HelpSupportScreen`).
  - **Ikon Pengaturan (Gear):** Membuka bottom sheet pengaturan lengkap (Edit Profil, Program Referral, Pengaturan Keamanan, Notifikasi, Bahasa, dan Keluar dari Akun).

### B. Carousel Kartu Keuntungan Anggota (Member Benefits)
Carousel horizontal dengan kartu bergaya minimalis:
1. **Promo Member Hotel:** Ikon hotel dengan badge diskon `%`, menavigasi ke daftar promo/diskon (`Routes.myDiscount`).
2. **Jaminan Pembatalan:** Ikon bagasi perjalanan dengan badge verifikasi jaminan fleksibilitas pembatalan.
3. **Selengkapnya:** Tombol panah melingkar untuk melihat semua keuntungan loyalty anggota.

### C. Kartu Trip Coins & Kode Promo
Kartu kontainer dengan pemisah vertikal:
- **Sisi Kiri (Trip Coins):** Ikon koin emas `'T'`, nominal saldo `≈Rp0 (0 Trip Coins)`, dan panduan penghematan.
- **Sisi Kanan (Kode Promo):** Badge merah muda dengan ikon `%`, jumlah voucher aktif, dan tautan langsung ke `Routes.promo` (`PromoCodeScreen`).

### D. Grup Menu Utama (Travel & Akun)
1. **Semua Pemesanan:** Ikon dokumen/kalender biru pada kontainer biru muda (`#EEF4FF`), mengarah ke `Routes.bookingList`.
2. **Perjalanan Mendatang:** Ikon koper biru muda, mengarah ke filter pesanan aktif di `Routes.bookingList`.
3. **Terakhir Dilihat:** Ikon riwayat produk/properti, mengarah ke `Routes.viewedProducts` (`ViewedProductsScreen`).
4. **Kartu Saya:** Ikon kartu kredit outline, mengarah ke penambahan/pengelolaan kartu pembayaran di `Routes.addCard`.
5. **Traveler & Kontak:** Ikon profil outline, mengarah ke data traveler di `Routes.editProfile`.
6. **Disimpan:** Ikon hati (favorit), mengarah ke wishlist di `Routes.wishlist` (`WishlistScreen`).

### E. Banner & Pusat Kreator (Trip Moments)
- **Banner Trip Moments:** Desain latar biru muda pastel (`#F1F6FE`) dengan teks ajakan membagikan momen perjalanan untuk reward 25 Trip Coins, dilengkapi tombol aksi `"Mulai"`.
- **Menu Pusat Kreator:** Item menu dengan ikon pena/sparkle untuk ulasan dan komunitas kreator.

### F. Bagian Tentang & Ketentuan
- **Tentang Trip.com:** Dialog informasi aplikasi, versi, dan layanan.
- **Beri nilai Aplikasi:** Dialog penilaian bintang interaktif untuk ulasan pengguna.
- **Syarat & Ketentuan:** Dialog ketentuan hukum, privasi, dan standar operasional.

### G. Kartu Kemitraan (Partner / Host Card)
- **Status Non-Host:** Menampilkan ajakan `"Bergabunglah bersama Trip.com sebagai mitra..."` dengan tombol outline `"Mulai Sekarang"`. Menjalankan fungsi `_becomeHost()` untuk validasi dan onboarding mitra.
- **Status Host:** Menampilkan informasi status aktif mitra dan tombol `"Beralih ke Mode Mitra"` yang mengarahkan ke `Routes.mitraHome` (`MitraShell`).
- **Ilustrasi Kanan:** Grafis melingkar berisi ikon jabat tangan (handshake) dan pin lokasi/globe.

### H. Footer Kepercayaan (Trust Badges)
- Teks utama: `"Layanan yang bisa Anda andalkan"`.
- Poin keunggulan:
  - `✔ Bantuan global 30 detik`
  - `✔ Travel Bebas Khawatir`

---

## 3. Integrasi State & Service

| Fitur | Sumber Data / Service | Handler |
|---|---|---|
| Autentikasi Pengguna | `AuthProvider.user` | Menampilkan nama dan avatar |
| Status Host / Mitra | `AuthProvider.isHost` | Kondisional kartu mitra / beralih mode |
| Onboarding Mitra | `ProfileService.becomeHost()` | `_becomeHost()` |
| Validasi Mitra | `ProfileService.validationStatus()` | `Routes.validation` jika belum tervalidasi |
| Keluar Akun | `AuthProvider.logout()` | `_logout()` dengan konfirmasi dialog |

---

## 4. Dokumentasi Fitur: Profil Pengguna (Screen 15 & 23)

**File Path:** `flutter/lib/screens/account/edit_profile_screen.dart`  
**Route:** `Routes.editProfile` (`/account/edit-profile`)  
**Tipe:** Manage User Account & Personal Security Information  

### Struktur Komponen UI:
1. **Avatar Header:** Avatar profil lingkaran kuning (`#FEF3D6`) dengan badge edit biru pensil (`#2563EB`).
2. **Keamanan Akun:**
   - Email dengan masking keamanan (`mohba******gorie@gmail.com`).
   - Nomor telepon dengan tombol aksi `"Hubungkan"` / `"Ubah"`.
   - Ubah Kata Sandi dengan tombol aksi `"Atur"`.
   - Kelola Perangkat & Riwayat Login dengan chevron navigasi.
3. **Pengaturan Pembayaran:**
   - PIN Keamanan status `"Belum diatur >"`.
4. **Profil Member (Rewards):**
   - Kartu dengan badge `REWARDS` dan deskripsi pentingnya ID resmi.
   - Box informasi nama resmi dan tanggal lahir dengan tombol aksi `"Edit"`.
5. **Info Pribadi:**
   - Header dengan tombol `"Edit"`.
   - Data: Nama, Jenis kelamin, Negara atau wilayah, Kota tempat tinggal, dan Kota yang sering dikunjungi.
6. **Kelola Akun (Login Pihak Ketiga):**
   - Header dengan badge hijau teal `"Login Instan"`.
   - Akun Google dengan tombol `"Putuskan"`.
   - Akun Facebook dengan tombol `"Hubungkan"`.
7. **Aksi Akun & Footer:**
   - Tombol putih lebar `"Keluar"` (Logout).
   - Tautan `"Hapus Akun Saya"` dengan konfirmasi dan peringatan permanen.

