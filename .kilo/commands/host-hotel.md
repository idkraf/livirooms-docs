---
description: "Ambil respons endpoint host hotels dan simpan sebagai JSON."
agent: code
---

Ikuti instruksi otomatis ini secara sekuensial:
1. Baca file workflow di `@docs/workflows/run_api_sequence.xml`.
2. Gunakan terminal (`bash`) untuk menjalankan `php artisan serve` di latar belakang.
3. Lakukan request `curl` untuk login sesuai kredensial yang ada di file XML tersebut, lalu simpan token-nya ke memori sesi Anda.
4. Gunakan token tersebut untuk request GET ke endpoint `/api/v1/host/hotels`.
5. Simpan seluruh respons JSON mentah ke file `@docs/response/hotels.json`.
6. Pastikan file `hotels.json` terformat dengan indentasi 2 spasi dan ter-enkode UTF-8.
