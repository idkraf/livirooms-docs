---
description: "Jalankan server Laravel, curl login, dan test API secara sekuensial."
agent: code
---

Ikuti instruksi otomatis ini secara sekuensial:
1. Baca file workflow di `@docs/workflows/run_api_sequence.xml`.
2. Gunakan terminal (`bash`) untuk menjalankan `php artisan serve` di latar belakang.
3. Lakukan request `curl` untuk login sesuai kredensial yang ada di file XML tersebut, lalu simpan token-nya ke memori sesi Anda.
4. Gunakan token tersebut untuk menembak endpoint target dan mengaudit responsnya.
5. Jika ada parameter yang salah atau tidak sesuai, langsung berikan perbaikan kodenya.