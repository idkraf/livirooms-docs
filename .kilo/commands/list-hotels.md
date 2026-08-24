---
description: "Ambil respons daftar hotel dengan filter dan simpan sebagai JSON."
agent: code
---

Ikuti instruksi otomatis ini secara sekuensial:
1. Baca file workflow di `@docs/workflows/run_api_sequence.xml`.
2. Gunakan terminal (`bash`) untuk menjalankan `php artisan serve` di latar belakang.
3. Lakukan request `curl` untuk login sesuai kredensial yang ada di file XML tersebut, lalu simpan token-nya ke memori sesi Anda.
4. Tawarkan filter yang tersedia kepada pengguna: `city_id`, `city_name`, `check_in`, `check_out`, `rooms_count`, `adults`, `children`, `star_rating`, `breakfast_included`, `min_price`, `max_price`, `facilities`, `sort`, `lat`, `lng`, `q`, `flex_days`.
5. Minta pengguna memasukkan nilai untuk filter yang diinginkan, atau gunakan nilai default kosong jika tidak ada filter yang dimasukkan.
6. Bangun query string dari filter yang diberikan dan request GET ke endpoint `/api/v1/hotels` dengan filter tersebut.
7. Simpan seluruh respons JSON mentah ke file `@docs/response/list-hotels.json`.
8. Pastikan file terformat dengan indentasi 2 spasi dan ter-enkode UTF-8.
