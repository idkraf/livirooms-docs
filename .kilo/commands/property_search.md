---
description: "Ambil respons endpoint pencarian properti dan filter metadata, lalu simpan sebagai JSON."
agent: code
---

Ikuti instruksi otomatis ini secara sekuensial:
1. Baca file workflow di `@docs/workflows/run_api_sequence.xml`.
2. Gunakan terminal (`bash`) untuk menjalankan `php artisan serve` di latar belakang.
3. Lakukan request `curl` untuk login sesuai kredensial yang ada di file XML tersebut, lalu simpan token-nya ke memori sesi Anda.
4. Gunakan token tersebut untuk request GET ke endpoint `/api/v1/properties?booking_mode=unit&per_page=2`.
5. Simpan seluruh respons JSON mentah ke file `@docs/response/properties_search.json`.
6. Gunakan token yang sama untuk request GET ke endpoint `/api/v1/properties/filter-metadata`.
7. Simpan seluruh respons JSON mentah ke file `@docs/response/property_filter_metadata.json`.
8. Pastikan kedua file terformat dengan indentasi 2 spasi dan ter-enkode UTF-8.
