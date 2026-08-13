#!/usr/bin/env python3
"""
Generate a simplified, easy-to-understand PDF documentation for the
LiviRooms rental apartment payment system.
"""

from fpdf import FPDF
from pathlib import Path

OUTPUT_PATH = Path(r"D:\Project\Fastwork\rental.apartemen\docs\payments\Panduan_Pembayaran_LiviRooms.pdf")


class PDF(FPDF):
    def header(self):
        if self.page_no() == 1:
            return
        self.set_font("DejaVu", "", 8)
        self.set_text_color(120, 120, 120)
        self.cell(0, 10, "LiviRooms - Panduan Sistem Pembayaran", align="C", new_x="LMARGIN", new_y="NEXT")
        self.line(10, self.get_y(), 200, self.get_y())
        self.ln(2)

    def footer(self):
        self.set_y(-15)
        self.set_font("DejaVu", "", 8)
        self.set_text_color(128, 128, 128)
        self.cell(0, 10, f"Halaman {self.page_no()}", align="C")

    def chapter_title(self, title, level=1):
        if level == 1:
            self.set_font("DejaVu", "B", 16)
            self.set_text_color(15, 40, 80)
            self.set_fill_color(230, 240, 255)
            self.cell(0, 12, title, new_x="LMARGIN", new_y="NEXT", fill=True)
            self.ln(4)
        else:
            self.set_font("DejaVu", "B", 12)
            self.set_text_color(15, 40, 80)
            self.cell(0, 10, title, new_x="LMARGIN", new_y="NEXT")
            self.ln(2)

    def body_text(self, text):
        self.set_font("DejaVu", "", 10)
        self.set_text_color(40, 40, 40)
        self.multi_cell(0, 6, text)
        self.ln(1)

    def bullet_text(self, text):
        self.set_font("DejaVu", "", 10)
        self.set_text_color(40, 40, 40)
        self.cell(5, 6, "•", align="C")
        self.multi_cell(0, 6, text)
        self.ln(1)

    def note_box(self, text):
        self.set_fill_color(255, 250, 220)
        self.set_draw_color(200, 170, 100)
        self.set_font("DejaVu", "B", 10)
        self.set_text_color(120, 90, 20)
        self.cell(0, 8, " Catatan ", new_x="LMARGIN", new_y="NEXT", fill=True)
        self.set_font("DejaVu", "", 10)
        self.set_text_color(80, 60, 10)
        self.multi_cell(0, 6, text)
        self.ln(3)

    def status_box(self, status, description, color):
        self.set_fill_color(*color)
        self.set_text_color(255, 255, 255)
        self.set_font("DejaVu", "B", 10)
        self.cell(50, 8, f" {status} ", fill=True)
        self.set_text_color(40, 40, 40)
        self.set_font("DejaVu", "", 10)
        self.cell(0, 8, f"  {description}", new_x="LMARGIN", new_y="NEXT")
        self.ln(1)


def main():
    pdf = PDF()
    # Register Unicode fonts (DejaVu supports Indonesian characters)
    # Use system Arial fonts which support Indonesian characters
    pdf.add_font("DejaVu", "", "C:\\Windows\\Fonts\\arial.ttf")
    pdf.add_font("DejaVu", "B", "C:\\Windows\\Fonts\\arialbd.ttf")

    pdf.set_auto_page_break(auto=True, margin=15)
    pdf.add_page()

    # ── Cover ──────────────────────────────────────────────────────────
    pdf.set_font("DejaVu", "B", 24)
    pdf.set_text_color(15, 40, 80)
    pdf.ln(40)
    pdf.cell(0, 15, "Panduan Sistem Pembayaran", align="C", new_x="LMARGIN", new_y="NEXT")
    pdf.cell(0, 15, "LiviRooms", align="C", new_x="LMARGIN", new_y="NEXT")
    pdf.set_font("DejaVu", "", 12)
    pdf.set_text_color(80, 80, 80)
    pdf.ln(10)
    pdf.cell(0, 10, "Dokumentasi lengkap alur booking, pembayaran, dan manajemen order", align="C", new_x="LMARGIN", new_y="NEXT")
    pdf.cell(0, 10, "untuk aplikasi LiviRooms - Rental Apartemen", align="C", new_x="LMARGIN", new_y="NEXT")
    pdf.set_font("DejaVu", "", 10)
    pdf.ln(20)
    pdf.cell(0, 8, "Versi 1.0 - Agustus 2026", align="C", new_x="LMARGIN", new_y="NEXT")

    # ── Table of Contents (manual) ────────────────────────────────────
    pdf.add_page()
    pdf.chapter_title("Daftar Isi", level=1)
    toc_items = [
        "1. Pendahuluan",
        "2. Peran Pengguna",
        "3. Alur Status Booking",
        "4. Langkah demi Langkah (User)",
        "5. Langkah demi Langkah (Host/Mitra)",
        "6. API Endpoints",
        "7. Aturan Penting",
        "8. Troubleshooting",
        "9. Referensi File",
    ]
    for item in toc_items:
        pdf.set_font("DejaVu", "", 11)
        pdf.set_text_color(40, 40, 40)
        pdf.cell(0, 8, item, new_x="LMARGIN", new_y="NEXT")

    # ── 1. Pendahuluan ────────────────────────────────────────────────
    pdf.add_page()
    pdf.chapter_title("1. Pendahuluan", level=1)
    pdf.body_text(
        "LiviRooms adalah aplikasi untuk menyewa apartemen secara online. "
        "Dokumen ini menjelaskan bagaimana sistem pembayaran bekerja, "
        "mulai dari saat user membuat booking, host mengonfirmasi, "
        "user melakukan pembayaran, hingga tamu check-in."
    )
    pdf.body_text(
        "Sistem ini menggunakan Midtrans sebagai payment gateway. "
        "Pembayaran dilakukan melalui browser eksternal (Midtrans Snap), "
        "dan status pembayaran dikembalikan ke aplikasi melalui webhook."
    )

    pdf.chapter_title("Komponen Utama", level=2)
    pdf.bullet_text("Flutter (Frontend) - Aplikasi mobile untuk user dan host")
    pdf.bullet_text("Laravel (Backend) - API server yang menangani booking dan pembayaran")
    pdf.bullet_text("Midtrans (Payment Gateway) - Memproses pembayaran online")
    pdf.ln(3)

    # ── 2. Peran Pengguna ─────────────────────────────────────────────
    pdf.add_page()
    pdf.chapter_title("2. Peran Pengguna", level=1)
    pdf.body_text("Ada 3 peran utama dalam sistem LiviRooms:")

    pdf.chapter_title("Guest (Pengguna)", level=2)
    pdf.bullet_text("Membuat booking apartemen")
    pdf.bullet_text("Melihat status booking dan pembayaran")
    pdf.bullet_text("Melakukan pembayaran")
    pdf.bullet_text("Membatalkan booking (jika masih dalam masa yang diperbolehkan)")

    pdf.chapter_title("Host / Mitra (Pemilik Apartemen)", level=2)
    pdf.bullet_text("Menerima atau menolak permintaan booking")
    pdf.bullet_text("Mengonfirmasi kehadiran tamu (check-in)")
    pdf.bullet_text("Melihat daftar order dan status pembayaran")
    pdf.bullet_text("Mengelola properti dan ketersediaan")

    pdf.chapter_title("Admin", level=2)
    pdf.bullet_text("Mengelola metode pembayaran")
    pdf.bullet_text("Melihat dan mengekspor data pembayaran")
    pdf.bullet_text("Mengatur konfigurasi Midtrans")

    # ── 3. Alur Status Booking ────────────────────────────────────────
    pdf.add_page()
    pdf.chapter_title("3. Alur Status Booking", level=1)
    pdf.body_text(
        "Setiap booking memiliki status yang berubah seiring proses. "
        "Berikut adalah alur status dari awal hingga akhir:"
    )
    pdf.ln(3)

    # Visual flow
    statuses = [
        ("waiting_confirmation", "Booking dibuat, menunggu host mengonfirmasi", (255, 200, 150)),
        ("confirmed", "Host mengonfirmasi, user bisa bayar", (200, 230, 255)),
        ("paid", "Pembayaran berhasil, menunggu check-in", (220, 255, 220)),
        ("waiting_checkin", "Tamu tiba, menunggu konfirmasi check-in", (255, 255, 200)),
        ("staying", "Tamu sedang menginap", (200, 255, 200)),
        ("completed", "Booking selesai", (200, 230, 200)),
        ("cancelled", "Dibatalkan", (255, 220, 220)),
        ("expired", "Kedaluwarsa", (240, 240, 240)),
    ]
    for status, desc, color in statuses:
        pdf.status_box(status, desc, color)

    pdf.ln(5)
    pdf.chapter_title("Alur Visual", level=2)
    pdf.body_text(
        "waiting_confirmation  →  confirmed  →  paid  →  waiting_checkin  →  staying  →  completed"
    )
    pdf.body_text(
        "      ↓                   ↓            ↓              ↓               ↓"
    )
    pdf.body_text(
        "   cancelled          cancelled    cancelled        cancelled        cancelled"
    )
    pdf.body_text(
        "   (host tolak)     (user/host)  (payment gagal)  (check-in gagal)  (selesai)"
    )
    pdf.body_text(
        "      ↓"
    )
    pdf.body_text(
        "   expired  (payment timeout / check-in terlewat)"
    )

    pdf.note_box(
        "Setiap booking selalu dimulai dari 'waiting_confirmation'. "
        "Host harus mengonfirmasi terlebih dahulu sebelum user dapat melakukan pembayaran."
    )

    # ── 4. Langkah demi Langkah (User) ────────────────────────────────
    pdf.add_page()
    pdf.chapter_title("4. Langkah demi Langkah (User)", level=1)

    pdf.chapter_title("4.1 Membuat Booking", level=2)
    pdf.body_text("1. Buka aplikasi LiviRooms dan pilih apartemen yang ingin disewa.")
    pdf.body_text("2. Pilih tanggal check-in dan check-out.")
    pdf.body_text("3. Isi data tamu (nama, telepon, dll).")
    pdf.body_text("4. Klik 'Pesan Sekarang'.")
    pdf.body_text("5. Sistem membuat booking dengan status 'waiting_confirmation'.")
    pdf.body_text("6. User melihat pesan: 'Menunggu konfirmasi dari pemilik properti...'")
    pdf.note_box("Booking belum dapat dibayar sebelum host mengonfirmasi.")

    pdf.chapter_title("4.2 Menunggu Konfirmasi Host", level=2)
    pdf.body_text("Setelah booking dibuat, user dapat:")
    pdf.bullet_text("Melihat status booking di halaman 'Daftar Booking'")
    pdf.bullet_text("Menunggu notifikasi bahwa host telah mengonfirmasi")
    pdf.bullet_text("Membatalkan booking jika masih dalam status 'waiting_confirmation'")

    pdf.chapter_title("4.3 Melakukan Pembayaran", level=2)
    pdf.body_text("Setelah host mengonfirmasi, status berubah menjadi 'confirmed' dan tombol 'Lanjutkan Bayar' muncul.")
    pdf.body_text("1. Klik tombol 'Lanjutkan Bayar'.")
    pdf.body_text("2. Pilih metode pembayaran (QRIS, Virtual Account, E-Wallet, Kartu Kredit).")
    pdf.body_text("3. Sistem membuat transaksi Midtrans dan membuka halaman pembayaran.")
    pdf.body_text("4. User selesaikan pembayaran di Midtrans.")
    pdf.body_text("5. Setelah pembayaran berhasil, webhook Midtrans mengupdate status menjadi 'paid'.")

    pdf.chapter_title("4.4 Setelah Pembayaran", level=2)
    pdf.body_text("Status booking menjadi 'paid'. User dapat:")
    pdf.bullet_text("Melihat detail pembayaran (metode, waktu, nominal)")
    pdf.bullet_text("Menunggu tanggal check-in")
    pdf.bullet_text("Membatalkan booking (kebijakan cancellation berlaku)")
    pdf.note_box("Pembayaran hanya dianggap berhasil setelah webhook Midtrans mengonfirmasi. Jangan percayai halaman 'finish' dari Midtrans.")

    pdf.add_page()
    pdf.chapter_title("4.5 Check-in dan Menginap", level=2)
    pdf.body_text("Pada hari check-in:")
    pdf.bullet_text("Host akan menandai tamu tiba (status: 'waiting_checkin')")
    pdf.bullet_text("Host mengonfirmasi check-in (status: 'staying')")
    pdf.body_text("Selama menginap, status tetap 'staying'.")
    pdf.body_text("Setelah check-out, status berubah menjadi 'completed'.")

    pdf.chapter_title("4.6 Membatalkan Booking", level=2)
    pdf.body_text("User dapat membatalkan booking jika status masih:")
    pdf.bullet_text("'waiting_confirmation' (belum dikonfirmasi host)")
    pdf.bullet_text("'confirmed' (sudah dikonfirmasi, belum bayar)")
    pdf.body_text("Setelah dibatalkan, tanggal properti kembali tersedia untuk booking lain.")

    # ── 5. Langkah demi Langkah (Host) ────────────────────────────────
    pdf.add_page()
    pdf.chapter_title("5. Langkah demi Langkah (Host / Mitra)", level=1)

    pdf.chapter_title("5.1 Menerima Booking Baru", level=2)
    pdf.body_text("1. Login sebagai host di aplikasi LiviRooms.")
    pdf.body_text("2. Buka menu 'Manajemen Order'.")
    pdf.body_text("3. Lihat tab 'Baru' untuk booking yang menunggu konfirmasi.")
    pdf.body_text("4. Klik detail booking untuk melihat informasi lengkap.")
    pdf.body_text("5. Klik 'Terima' untuk menerima booking.")
    pdf.body_text("6. Status booking berubah menjadi 'confirmed', user dapat membayar.")

    pdf.chapter_title("5.2 Menolak Booking", level=2)
    pdf.body_text("1. Di halaman detail booking, klik 'Tolak'.")
    pdf.body_text("2. Booking dibatalkan dan tanggal properti kembali tersedia.")
    pdf.body_text("3. User receives notifikasi bahwa booking ditolak.")

    pdf.chapter_title("5.3 Menandai Tamu Tiba", level=2)
    pdf.body_text("1. Pada hari check-in, buka 'Manajemen Order' → tab 'Dikonfirmasi'.")
    pdf.body_text("2. Lihat booking dengan status 'paid'.")
    pdf.body_text("3. Klik 'Tamu Tiba' untuk menandai kedatangan.")
    pdf.body_text("4. Status berubah menjadi 'waiting_checkin'.")

    pdf.chapter_title("5.4 Mengonfirmasi Check-in", level=2)
    pdf.body_text("1. Setelah menandai tamu tiba, klik 'Konfirmasi Check-in'.")
    pdf.body_text("2. Status berubah menjadi 'staying'.")
    pdf.body_text("3. Tamu resmi menginap dan dapat mengakses properti.")

    pdf.chapter_title("5.5 Check-out dan Selesai", level=2)
    pdf.body_text("1. Setelah tamu check-out, sistem otomatis mengubah status menjadi 'completed'.")
    pdf.body_text("2. Dana pembayaran akan ditransfer ke dompet host sesuai jadwal.")
    pdf.body_text("3. Host dapat melihat riwayat completed booking di tab 'Selesai'.")

    # ── 6. API Endpoints ──────────────────────────────────────────────
    pdf.add_page()
    pdf.chapter_title("6. API Endpoints", level=1)
    pdf.body_text("Berikut adalah endpoint API yang digunakan oleh aplikasi Flutter:")

    pdf.chapter_title("6.1 Booking", level=2)
    endpoints = [
        ("GET", "/api/v1/bookings", "Mendapatkan daftar booking milik user"),
        ("POST", "/api/v1/bookings", "Membuat booking baru"),
        ("GET", "/api/v1/bookings/{id}", "Detail booking"),
        ("POST", "/api/v1/bookings/{id}/cancel", "Membatalkan booking"),
        ("POST", "/api/v1/bookings/{id}/confirm", "Host mengonfirmasi booking"),
        ("POST", "/api/v1/bookings/{id}/reject", "Host menolak booking"),
        ("POST", "/api/v1/bookings/{id}/checkin", "Host menandai tamu tiba"),
        ("POST", "/api/v1/bookings/{id}/confirm-checkin", "Host mengonfirmasi check-in"),
    ]
    for method, path, desc in endpoints:
        pdf.set_font("DejaVu", "B", 10)
        pdf.set_text_color(15, 40, 80)
        pdf.cell(20, 7, method, border=1)
        pdf.set_font("DejaVu", "", 10)
        pdf.set_text_color(40, 40, 40)
        pdf.cell(70, 7, path, border=1)
        pdf.cell(0, 7, desc, border=1, new_x="LMARGIN", new_y="NEXT")
    pdf.ln(3)

    pdf.chapter_title("6.2 Payment", level=2)
    payment_endpoints = [
        ("GET", "/api/v1/payments/methods", "Daftar metode pembayaran aktif"),
        ("POST", "/api/v1/orders/{id}/pay", "Buat transaksi pembayaran"),
        ("POST", "/api/v1/orders/{id}/pay/retry", "Ulangi pembayaran (retry/continue)"),
        ("GET", "/api/v1/payments/{id}", "Detail pembayaran"),
        ("GET", "/api/v1/payments/{id}/reconcile", "Sinkron status dengan Midtrans"),
        ("POST", "/api/v1/payments/webhook", "Webhook dari Midtrans (publik)"),
    ]
    for method, path, desc in payment_endpoints:
        pdf.set_font("DejaVu", "B", 10)
        pdf.set_text_color(15, 40, 80)
        pdf.cell(20, 7, method, border=1)
        pdf.set_font("DejaVu", "", 10)
        pdf.set_text_color(40, 40, 40)
        pdf.cell(70, 7, path, border=1)
        pdf.cell(0, 7, desc, border=1, new_x="LMARGIN", new_y="NEXT")
    pdf.ln(3)

    pdf.chapter_title("6.3 Host Orders", level=2)
    order_endpoints = [
        ("GET", "/api/v1/host/orders", "Daftar order untuk host (berdasarkan properti)"),
        ("GET", "/api/v1/host/orders/{id}", "Detail order untuk host"),
    ]
    for method, path, desc in order_endpoints:
        pdf.set_font("DejaVu", "B", 10)
        pdf.set_text_color(15, 40, 80)
        pdf.cell(20, 7, method, border=1)
        pdf.set_font("DejaVu", "", 10)
        pdf.set_text_color(40, 40, 40)
        pdf.cell(70, 7, path, border=1)
        pdf.cell(0, 7, desc, border=1, new_x="LMARGIN", new_y="NEXT")

    # ── 7. Aturan Penting ─────────────────────────────────────────────
    pdf.add_page()
    pdf.chapter_title("7. Aturan Penting", level=1)

    pdf.chapter_title("7.1 Booking dan Availability", level=2)
    pdf.bullet_text("Saat user membuat booking, sistem mengecek ketersediaan tanggal.")
    pdf.bullet_text("Jika ada booking aktif lain di tanggal yang sama, booking ditolak.")
    pdf.bullet_text("Booking aktif meliputi status: waiting_confirmation, confirmed, paid, waiting_checkin, staying.")
    pdf.bullet_text("Setiap booking memiliki availability lock selama proses pembayaran.")

    pdf.chapter_title("7.2 Host Confirmation", level=2)
    pdf.bullet_text("Booking baru tidak dapat dibayar sebelum host mengonfirmasi.")
    pdf.bullet_text("Host memiliki waktu untuk menerima atau menolak booking.")
    pdf.bullet_text("Jika host menolak, booking dibatalkan dan tanggal tersedia kembali.")

    pdf.chapter_title("7.3 Pembayaran", level=2)
    pdf.bullet_text("Pembayaran hanya diproses oleh webhook Midtrans yang terverifikasi.")
    pdf.bullet_text("Halaman 'finish' dari Midtrans hanya untuk navigasi, tidak mengubah status.")
    pdf.bullet_text("Jika pembayaran gagal/expired, booking dibatalkan dan tanggal tersedia kembali.")
    pdf.bullet_text("User dapat retry pembayaran jika masih dalam masa yang diperbolehkan.")

    pdf.chapter_title("7.4 Expired dan Cancelled", level=2)
    pdf.bullet_text("Booking otomatis dibatalkan jika check-in terlewat dan masih dalam proses.")
    pdf.bullet_text("Command 'payments:cancel-expired' berjalan secara berkala untuk membersihkan booking lama.")
    pdf.bullet_text("Booking yang dibatalkan mengembalikan ketersediaan tanggal.")

    pdf.chapter_title("7.5 Check-in", level=2)
    pdf.bullet_text("Host harus menandai tamu tiba sebelum dapat mengonfirmasi check-in.")
    pdf.bullet_text("Check-in hanya dapat dilakukan jika status booking adalah 'paid'.")
    pdf.bullet_text("Setelah check-in dikonfirmasi, status menjadi 'staying'.")

    # ── 8. Troubleshooting ────────────────────────────────────────────
    pdf.add_page()
    pdf.chapter_title("8. Troubleshooting", level=1)

    issues = [
        ("Booking tidak muncul di daftar host", "Pastikan booking memiliki status 'waiting_confirmation' dan properti dimiliki host."),
        ("Tombol 'Lanjutkan Bayar' tidak muncul", "Pastikan host sudah mengonfirmasi booking (status: 'confirmed')."),
        ("Pembayaran berhasil tapi status tidak berubah", "Cek apakah webhook Midtrans bekerja. Jalankan 'php artisan payments:cancel-expired' untuk reconcile."),
        ("Booking expired tapi masih menunggu pembayaran", "Jalankan 'php artisan payments:cancel-expired' untuk membersihkan booking expired."),
        ("Double booking terjadi", "Sistem overlap check seharusnya mencegah ini. Cek log booking dengan tanggal yang sama."),
        ("Tamu check-in tapi status tidak berubah", "Host harus menekan 'Tamu Tiba' terlebih dahulu, lalu 'Konfirmasi Check-in'."),
        ("Pembayaran ditolak Midtrans", "Cek saldo/limit kartu, atau coba metode pembayaran lain."),
    ]
    for issue, solution in issues:
        pdf.chapter_title(issue, level=2)
        pdf.body_text(solution)

    # ── 9. Referensi File ─────────────────────────────────────────────
    pdf.add_page()
    pdf.chapter_title("9. Referensi File", level=1)
    pdf.body_text("Berikut adalah file-file utama yang terlibat dalam sistem pembayaran:")

    refs = [
        ("Backend - Booking", [
            "app/Http/Controllers/Api/BookingController.php",
            "app/Models/Booking.php",
            "database/migrations/2026_08_12_000001_update_booking_status_enum.php",
            "app/Console/Commands/CancelExpiredPayments.php",
        ]),
        ("Backend - Payment", [
            "app/Http/Controllers/Api/PaymentController.php",
            "app/Http/Controllers/Api/OrderController.php",
            "app/Models/Order.php",
            "app/Models/Payment.php",
        ]),
        ("Backend - Routes", [
            "routes/api_mobile.php",
            "routes/web.php (payment callbacks)",
        ]),
        ("Flutter - Screens", [
            "lib/screens/booking/booking_detail_screen.dart",
            "lib/screens/booking/booking_list_screen.dart",
            "lib/screens/mitra/order_management_screen.dart",
            "lib/screens/mitra/order_detail_screen.dart",
        ]),
        ("Flutter - Models & Services", [
            "lib/models/booking.dart",
            "lib/models/order.dart",
            "lib/models/payment.dart",
            "lib/services/booking_service.dart",
            "lib/services/host_service.dart",
        ]),
        ("Documentation", [
            "docs/payments/flow.md",
            "docs/payments/integration.md",
            "docs/payments/setup.md",
            "docs/payments/remediation.md",
            "docs/payments/trial_fix_payment.md",
            "docs/payments/MOBILE_API_INSTALL.md",
        ]),
    ]

    for category, files in refs:
        pdf.chapter_title(category, level=2)
        for f in files:
            pdf.set_font("DejaVu", "", 10)
            pdf.set_text_color(60, 60, 60)
            pdf.cell(5, 6, "•", align="C")
            pdf.cell(0, 6, f, new_x="LMARGIN", new_y="NEXT")
        pdf.ln(2)

    # ── Save ──────────────────────────────────────────────────────────
    OUTPUT_PATH.parent.mkdir(parents=True, exist_ok=True)
    pdf.output(str(OUTPUT_PATH))
    print(f"PDF generated: {OUTPUT_PATH}")


if __name__ == "__main__":
    main()
