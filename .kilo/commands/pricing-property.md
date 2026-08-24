---
description: "Ambil respons harga properti dan simpan sebagai JSON."
agent: code
---

Ikuti instruksi otomatis ini secara sekuensial:
1. Baca file workflow di `@docs/workflows/run_api_sequence.xml`.
2. Gunakan terminal (`bash`) untuk menjalankan `php artisan serve` di latar belakang.
3. Lakukan request `curl` untuk login sesuai kredensial yang ada di file XML tersebut, lalu simpan token-nya ke memori sesi Anda.
4. Minta ID properti dari pengguna dengan pertanyaan: "Masukkan ID properti untuk melihat harga?".
5. Gunakan token tersebut untuk request GET ke endpoint `/api/v1/properties/{property}/pricing` dengan mengganti `{property}` dengan ID properti yang dimasukkan.
6. Simpan seluruh respons JSON mentah ke file `@docs/response/pricing-property.json`.
7. Pastikan file terformat dengan indentasi 2 spasi dan ter-enkode UTF-8.
