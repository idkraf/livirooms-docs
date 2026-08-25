# Arsitektur Standar Dokumentasi — Livirooms Multi-Accommodation

Dokumentasi ini memetakan struktur file di dalam folder `docs/` agar selaras dengan implementasi nyata pada Laravel 12 backend dan Flutter mobile.

## Struktur Direktori `docs/`

```
docs/
├── INDEX.md                             # Indeks navigasi global
├── README.md                            # Gambaran umum sistem & stack
├── ai/                                  # Context pack untuk AI
│   ├── 00-orientation.md               # Titik masuk & aturan navigasi
│   ├── 01-backend-map.md               # Arsitektur backend, 21 model, payment, Livewire
│   ├── 02-frontend-map.md              # Arsitektur mobile, 45 layar, router, model
│   ├── 03-api-contract.md              # Kontrak endpoint API & Dart service mapping
│   └── 04-drift-register.md            # Register perbaikan drift & audit data model
├── configuration/                       # Konfigurasi admin & UI patterns
│   ├── admin-panel.md                  # Panduan Livewire wizard & Yajra DataTables
│   ├── missing-files.md                # Log audit inventaris file
│   └── ui-patterns.md                  # Template Blade & Livewire UI
├── domain/                              # Master domain contracts
│   └── hotel-vs-property.md            # Kontrak arsitektur 21 tabel (3NF), booking_mode
├── features/                            # Dokumentasi spesifik fitur
│   ├── payments.md                     # Integrasi payment gateway & Midtrans
│   └── referral.md                     # Sistem kode referral & reward
├── payments/                            # Detail transaksi pembayaran
│   └── system.md                       # Spesifikasi 6 endpoint payment & webhook
├── response/                            # Master fixture JSON API
│   ├── detail-property.json            # Sample output PropertyShape
│   ├── home.json                       # Sample output Home Feed
│   └── hotels.json                     # Sample output HotelShape
└── workflows/                           # Alur pengujian & eksekusi API
    └── run_api_sequence.xml            # Urutan request API end-to-end
```