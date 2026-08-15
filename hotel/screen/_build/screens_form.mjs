// screens_form.mjs — form screens: form_pesan_kamar, form steps, modals/room detail
import { ic, statusbar, topbar, T, gradPhoto } from './helpers.mjs';
import { HOTEL } from './lib.mjs';

const tealBanner = `<div style="background:#e0f7fa;padding:10px 16px;display:flex;align-items:center;justify-content:center;gap:8px">
  <span style="font-size:20px">💜</span>
  <span style="font-size:13px;font-weight:600;color:#00796b">Kami Samakan Harga</span>
</div>`;

const bottomPesan = `<div style="display:flex;align-items:center;gap:12px;padding:10px 16px 16px;background:#fff;border-top:1px solid ${T.borderLight}">
  <div style="flex:1">
    <div style="font-size:11px;color:${T.textSub}">Prabayar Online (total harga)</div>
    <div style="font-size:20px;font-weight:800;color:${T.primary}">Rp1.089.796 <span style="font-size:14px;color:${T.textSub}">ⓘ</span></div>
  </div>
  <div style="width:100px">
    <div class="btn btn-primary" style="height:44px;font-size:15px">Pesan</div>
  </div>
</div>`;

export const formScreens = {

  // 18a. Form Pesan Kamar — Step 1 (Multi-room guest info)
  form_pesan_kamar_step1() {
    const formField = (label, value = '', hasCheck = false) => `
      <div style="border:1.5px solid ${value ? T.primary : T.border};border-radius:${T.radius.field}px;padding:14px 16px;margin-bottom:10px;position:relative;display:flex;align-items:center;justify-content:space-between">
        <span style="font-size:15px;color:${value ? T.text : T.textSub}">${value || label}</span>
        ${hasCheck ? `<span style="color:#4caf50;font-weight:700">✓</span>` : ''}
      </div>`;

    const roomSection = (num, type) => `
      <div style="margin-bottom:16px">
        <div style="display:flex;align-items:center;justify-content:space-between;margin-bottom:6px">
          <div style="display:flex;align-items:center;gap:8px;font-size:15px;font-weight:700">
            ${ic('luggage',{size:20,w:2})} Kamar ${num}
          </div>
          <div style="background:${T.bgSurface};padding:7px 12px;border-radius:10px;font-size:12px;display:flex;align-items:center;gap:5px;color:${T.textSub}">
            ${ic('user',{size:14,w:2})} Pilih tamu yang tersimpan
          </div>
        </div>
        <div style="font-size:13px;color:${T.textSub};margin-bottom:10px">${type}</div>
        ${formField('Nama depan*')}
        ${formField('Nama belakang*')}
      </div>`;

    return `<div class="screen">
      ${statusbar()}
      <div style="display:flex;align-items:center;justify-content:center;padding:12px 16px;border-bottom:1px solid ${T.borderLight};position:relative">
        <div style="position:absolute;left:16px">${ic('arrowL',{size:24,w:2.5})}</div>
        <span style="font-size:17px;font-weight:700">${HOTEL.name}</span>
      </div>
      <div class="body">
        <div class="scroll" style="padding:16px">
          ${roomSection(1, 'Family Suite')}
          ${roomSection(2, 'Kamar Superior')}
          <!-- Info Kontak -->
          <div>
            <div style="font-size:16px;font-weight:700;margin-bottom:12px">Info Kontak</div>
            <!-- Email field with value -->
            <div style="border:1.5px solid ${T.primary};border-radius:${T.radius.field}px;padding:10px 16px;margin-bottom:10px;position:relative">
              <div style="font-size:11px;color:${T.primary};font-weight:600;margin-bottom:2px">Email*</div>
              <div style="display:flex;align-items:center;justify-content:space-between">
                <span style="font-size:14px">mohbaswandegorie@gmail.com</span>
                <span style="color:#4caf50;font-weight:700">✓</span>
              </div>
            </div>
            <!-- Phone field -->
            <div style="border:1.5px solid ${T.border};border-radius:${T.radius.field}px;padding:14px 16px;display:flex;align-items:center;gap:10px">
              <span style="font-size:14px;font-weight:600">+62</span>
              <div style="width:1px;height:20px;background:${T.border}"></div>
              ${ic('chevR',{size:16,w:2})}
              <span style="font-size:15px;color:${T.textSub};flex:1">Nomor Telepon*</span>
            </div>
          </div>
        </div>
      </div>
      ${tealBanner}
      ${bottomPesan}
    </div>`;
  },

  // 18b. Form Pesan Kamar — Step 2 (Diskon & benefit)
  form_pesan_kamar_step2() {
    return `<div class="screen">
      ${statusbar()}
      <div style="display:flex;align-items:center;justify-content:center;padding:12px 16px;border-bottom:1px solid ${T.borderLight};position:relative">
        <div style="position:absolute;left:16px">${ic('arrowL',{size:24,w:2.5})}</div>
        <span style="font-size:17px;font-weight:700">${HOTEL.name}</span>
      </div>
      <div class="body">
        <div class="scroll" style="padding:16px">
          <!-- Diskon & benefit -->
          <div style="font-size:20px;font-weight:800;margin-bottom:16px">Diskon & benefit</div>
          <!-- Kode Promo -->
          <div style="margin-bottom:16px">
            <div style="display:flex;align-items:center;gap:8px;margin-bottom:10px">
              ${ic('percent',{size:20,w:2})}
              <span style="font-size:16px;font-weight:700">Kode Promo</span>
            </div>
            <div style="font-size:13px;color:#00796b;font-weight:600;margin-bottom:10px">Kode promo berhasil digunakan</div>
            <!-- Kamar Superior promo -->
            <div style="border:1.5px solid ${T.border};border-radius:${T.radius.field}px;padding:14px;margin-bottom:10px">
              <div style="font-size:14px;font-weight:700;margin-bottom:4px">Kamar Superior</div>
              <div style="font-size:13px;color:${T.textSub};margin-bottom:4px">Kode promo pengguna baru (pemesanan pertama) : - Rp22.351 <span style="color:#00796b;font-weight:700">Digunakan</span> ${ic('chevR',{size:14,w:2})}</div>
            </div>
            <!-- Family Suite promo -->
            <div style="border:1.5px solid ${T.border};border-radius:${T.radius.field}px;padding:14px;margin-bottom:10px">
              <div style="font-size:14px;font-weight:700;margin-bottom:4px">Family Suite</div>
              <div style="font-size:13px;color:${T.textSub}">Silakan masukkan kode promo Anda (4 tidak dapat digunakan) ${ic('chevR',{size:14,w:2})}</div>
            </div>
          </div>
          <!-- Trip Coins -->
          <div style="display:flex;align-items:flex-start;gap:12px;padding:14px 0;border-bottom:1px solid ${T.borderLight};margin-bottom:16px">
            <div style="width:34px;height:34px;border-radius:50%;background:${T.bgSurface2};display:flex;align-items:center;justify-content:center;flex:0 0 34px">
              ${ic('coin',{size:18,w:2,fill:T.primary})}
            </div>
            <div>
              <div style="font-size:14px;font-weight:700;margin-bottom:4px">Trip Coins</div>
              <div style="font-size:13px;color:${T.textSub};line-height:1.5">
                Dapatkan <span style="color:${T.star};font-weight:700">32 Trip Coins (≈Rp5.704)</span> setelah Anda menginap.
                ${ic('chevD',{size:14,w:2})}
              </div>
            </div>
          </div>
          <!-- Permintaan Khusus -->
          <div style="padding-bottom:16px;border-bottom:1px solid ${T.borderLight};margin-bottom:16px">
            <div style="font-size:16px;font-weight:700;margin-bottom:8px">Permintaan Khusus</div>
            <div style="font-size:13px;color:${T.textSub};line-height:1.6;margin-bottom:8px">Pihak akomodasi akan berupaya secara maksimal, tetapi tidak menjamin semua permintaan dapat dipenuhi.</div>
            <span style="font-size:13px;font-weight:700;text-decoration:underline">Pelajari Selengkapnya</span>
          </div>
          <!-- Informasi Tambahan -->
          <div style="padding-bottom:16px;border-bottom:1px solid ${T.borderLight};margin-bottom:16px">
            <div style="font-size:16px;font-weight:700;margin-bottom:8px">Informasi Tambahan (1)</div>
            <div style="font-size:13px;line-height:1.6">
              Deposit tunai sebesar Total Rp100.000 diperlukan saat check-in
              <span style="font-weight:700;text-decoration:underline">Pelajari Selengkapnya</span>
            </div>
          </div>
        </div>
      </div>
      <div style="padding:0 16px 16px;background:#fff;border-top:1px solid ${T.borderLight}">
        <div style="display:flex;align-items:center;gap:8px;margin-bottom:8px">
          <div style="width:20px;height:20px;border-radius:50%;background:#e8f5e9;display:flex;align-items:center;justify-content:center;color:#4caf50">${ic('check',{size:12,w:2.5,fill:'#4caf50'})}</div>
          <span style="font-size:13px;color:${T.teal};font-weight:600">Hati tenangkan berkat opsi pembatalan gratis.</span>
        </div>
      </div>
      ${bottomPesan}
    </div>`;
  },

  // 18c. Form Pesan Kamar — Step 3 (Informasi Tambahan + T&C)
  form_pesan_kamar_step3() {
    return `<div class="screen">
      ${statusbar()}
      <div style="display:flex;align-items:center;justify-content:center;padding:12px 16px;border-bottom:1px solid ${T.borderLight};position:relative">
        <div style="position:absolute;left:16px">${ic('arrowL',{size:24,w:2.5})}</div>
        <span style="font-size:17px;font-weight:700">${HOTEL.name}</span>
      </div>
      <div class="body">
        <div class="scroll" style="padding:16px">
          <!-- Trip Coins -->
          <div style="display:flex;align-items:flex-start;gap:12px;padding:14px 0;border-bottom:1px solid ${T.borderLight};margin-bottom:16px">
            <div style="width:34px;height:34px;border-radius:50%;background:${T.bgSurface2};display:flex;align-items:center;justify-content:center;flex:0 0 34px">
              ${ic('coin',{size:18,w:2,fill:T.primary})}
            </div>
            <div>
              <div style="font-size:14px;font-weight:700;margin-bottom:4px">Trip Coins</div>
              <div style="font-size:13px;color:${T.textSub};line-height:1.5">
                Dapatkan <span style="color:${T.star};font-weight:700">31 Trip Coins (≈Rp5.526)</span> setelah Anda menginap.
                ${ic('chevD',{size:14,w:2})}
              </div>
            </div>
          </div>
          <!-- Permintaan Khusus -->
          <div style="padding-bottom:16px;border-bottom:1px solid ${T.borderLight};margin-bottom:16px">
            <div style="font-size:16px;font-weight:700;margin-bottom:8px">Permintaan Khusus</div>
            <div style="font-size:13px;color:${T.textSub};line-height:1.6;margin-bottom:8px">Pihak akomodasi akan berupaya secara maksimal, tetapi tidak menjamin semua permintaan dapat dipenuhi.</div>
            <span style="font-size:13px;font-weight:700;text-decoration:underline">Pelajari Selengkapnya</span>
          </div>
          <!-- Informasi Tambahan -->
          <div style="padding-bottom:16px;border-bottom:1px solid ${T.borderLight};margin-bottom:16px">
            <div style="font-size:16px;font-weight:700;margin-bottom:8px">Informasi Tambahan (1)</div>
            <div style="font-size:13px;line-height:1.6">
              Deposit tunai sebesar Total Rp100.000 diperlukan saat check-in
              <span style="font-weight:700;text-decoration:underline">Pelajari Selengkapnya</span>
            </div>
          </div>
          <!-- T&C -->
          <div style="padding-bottom:16px;border-bottom:1px solid ${T.borderLight};margin-bottom:14px">
            <div style="font-size:13px;line-height:1.6;color:${T.textSub}">
              Dengan melanjutkan pemesanan ini, saya menyatakan bahwa saya telah membaca dan menyetujui
              <span style="text-decoration:underline;color:${T.text};font-weight:600">Syarat &amp; Ketentuan</span> dan
              <span style="text-decoration:underline;color:${T.text};font-weight:600">Pernyataan Privasi</span> Trip.com.
            </div>
          </div>
          <!-- Checkbox -->
          <div style="display:flex;align-items:flex-start;gap:12px">
            <div style="width:20px;height:20px;border-radius:4px;background:${T.bgSurface2};border:1.5px solid ${T.primary};display:flex;align-items:center;justify-content:center;flex:0 0 20px">
              ${ic('check',{size:13,w:2.5,fill:'none'})}
            </div>
            <span style="font-size:13px;color:${T.textSub};line-height:1.6">Kirimi saya promo spesial Trip.com dan pengingat perjalanan via email, notifikasi push, WhatsApp, dan channel lainnya</span>
          </div>
        </div>
      </div>
      ${tealBanner}
      ${bottomPesan}
    </div>`;
  },

  // 17. Sheet Pesan Kamar — Ringkasan
  sheet_pesan_kamar() {
    const roomDetail = (name, count, guests, bed, extraTag = '') => `
      <div style="padding:14px 0;border-bottom:1px solid ${T.borderLight}">
        <div style="font-size:16px;font-weight:700;margin-bottom:10px">${name} <span style="color:${T.textSub};font-weight:400;font-size:14px">| ${count} Kamar</span></div>
        ${[
          [ic('user',{size:16,w:2}), `Harga untuk ${guests}`],
          [ic('bed2',{size:16,w:2}), bed],
          [ic('nosmoke',{size:16,w:2}), 'Bebas rokok'],
          ...(extraTag ? [[`<span style="font-size:18px">💜</span>`, `<span style="color:${T.teal};font-weight:600">${extraTag}</span>`]] : []),
          [ic('food',{size:16,w:2}), 'Sarapan berbayar Rp108.900 (opsional)'],
          [ic('info',{size:16,w:2}), 'Tidak dapat di-refund'],
        ].map(([icon,lbl])=>`
          <div style="display:flex;align-items:flex-start;gap:10px;padding:5px 0;font-size:13px">
            ${icon} <span>${lbl}</span>
          </div>`).join('')}
      </div>`;

    return `<div class="screen">
      ${statusbar()}
      <div style="display:flex;align-items:center;justify-content:center;padding:12px 16px;border-bottom:1px solid ${T.borderLight};position:relative">
        <div style="position:absolute;left:16px">${ic('arrowL',{size:24,w:2.5})}</div>
        <span style="font-size:17px;font-weight:700">${HOTEL.name}</span>
      </div>
      <div class="body">
        <div class="scroll" style="padding:16px">
          <!-- Booking summary card -->
          <div style="border:1.5px solid ${T.border};border-radius:${T.radius.card}px;padding:16px;margin-bottom:16px">
            <!-- Date row -->
            <div style="display:flex;align-items:flex-start;justify-content:space-between;padding-bottom:14px;border-bottom:1px solid ${T.borderLight}">
              <div>
                <div style="font-size:11px;color:${T.textSub}">Check-in</div>
                <div style="font-size:18px;font-weight:800">Sab, 15 Agt</div>
                <div style="font-size:12px;color:${T.textSub}">Setelah pukul 14:00</div>
              </div>
              <div style="text-align:center;padding-top:12px">
                <div style="font-size:12px;color:${T.textSub}">1 malam</div>
                <div style="border-top:1px solid ${T.border};width:60px;margin:6px 0"></div>
              </div>
              <div style="text-align:right">
                <div style="font-size:11px;color:${T.textSub}">Check-out</div>
                <div style="font-size:18px;font-weight:800">Min, 16 Agt</div>
                <div style="font-size:12px;color:${T.textSub}">Sebelum pukul 12:00</div>
              </div>
            </div>
            <!-- Rooms -->
            ${roomDetail('Family Suite', 1, '4 Dewasa', '2 queen bed')}
            ${roomDetail('Kamar Superior', 1, '2 dewasa + 1 anak', '1 queen bed atau 2 single bed', 'Anak Menginap Gratis')}
          </div>
          <!-- Info tamu -->
          <div style="margin-bottom:16px">
            <div style="font-size:16px;font-weight:700;margin-bottom:12px;display:flex;align-items:center;gap:6px">Info tamu ${ic('info',{size:16,w:2})}</div>
            <div style="display:flex;align-items:center;justify-content:space-between;background:${T.bgSurface};border-radius:${T.radius.field}px;padding:12px 14px">
              <div style="display:flex;align-items:center;gap:8px;font-size:14px;font-weight:600">
                ${ic('luggage',{size:18,w:2})} Kamar 1
              </div>
              <div style="display:flex;align-items:center;gap:5px;font-size:13px;color:${T.textSub}">
                ${ic('user',{size:15,w:2})} Pilih tamu yang tersimpan
              </div>
            </div>
          </div>
        </div>
      </div>
      ${tealBanner}
      ${bottomPesan}
    </div>`;
  },

  // 18. Form Pengisian Kamar
  form_pengisian_kamar() {
    const formField = (label, value = '') => `
      <div style="border:1.5px solid ${value ? T.primary : T.border};border-radius:${T.radius.field}px;padding:14px 16px;margin-bottom:10px;position:relative;display:flex;align-items:center;justify-content:space-between">
        <span style="font-size:15px;color:${value ? T.text : T.textSub}">${value || label}</span>
        ${value ? ic('check',{size:20,w:2.5,fill:'none'}) : ''}
      </div>`;

    const roomSection = (num, type) => `
      <div style="margin-bottom:16px">
        <div style="display:flex;align-items:center;justify-content:space-between;margin-bottom:6px">
          <div style="display:flex;align-items:center;gap:8px;font-size:15px;font-weight:700">
            ${ic('luggage',{size:20,w:2})} Kamar ${num}
          </div>
          <div style="background:${T.bgSurface};padding:7px 12px;border-radius:10px;font-size:12px;display:flex;align-items:center;gap:5px;color:${T.textSub}">
            ${ic('user',{size:14,w:2})} Pilih tamu yang tersimpan
          </div>
        </div>
        <div style="font-size:13px;color:${T.textSub};margin-bottom:10px">${type}</div>
        ${formField('Nama depan*')}
        ${formField('Nama belakang*')}
      </div>`;

    return `<div class="screen">
      ${statusbar()}
      <div style="display:flex;align-items:center;justify-content:center;padding:12px 16px;border-bottom:1px solid ${T.borderLight};position:relative">
        <div style="position:absolute;left:16px">${ic('arrowL',{size:24,w:2.5})}</div>
        <span style="font-size:17px;font-weight:700">${HOTEL.name}</span>
      </div>
      <div class="body">
        <div class="scroll" style="padding:16px">
          ${roomSection(1, 'Family Suite')}
          ${roomSection(2, 'Kamar Superior')}
          <!-- Info Kontak -->
          <div>
            <div style="font-size:16px;font-weight:700;margin-bottom:12px">Info Kontak</div>
            <!-- Email field with value -->
            <div style="border:1.5px solid ${T.primary};border-radius:${T.radius.field}px;padding:10px 16px;margin-bottom:10px;position:relative">
              <div style="font-size:11px;color:${T.primary};font-weight:600;margin-bottom:2px">Email*</div>
              <div style="display:flex;align-items:center;justify-content:space-between">
                <span style="font-size:14px">mohbaswandegorie@gmail.com</span>
                <span style="color:#4caf50;font-weight:700">✓</span>
              </div>
            </div>
            <!-- Phone field -->
            <div style="border:1.5px solid ${T.border};border-radius:${T.radius.field}px;padding:14px 16px;display:flex;align-items:center;gap:10px">
              <span style="font-size:14px;font-weight:600">+62</span>
              <div style="width:1px;height:20px;background:${T.border}"></div>
              ${ic('chevR',{size:16,w:2})}
              <span style="font-size:15px;color:${T.textSub};flex:1">Nomor Telepon*</span>
            </div>
          </div>
        </div>
      </div>
      ${tealBanner}
      ${bottomPesan}
    </div>`;
  },

  // 18d. Form Pengisian Kamar — Scroll Bawah
  form_pengisian_kamar_scroll() {
    return `<div class="screen">
      ${statusbar()}
      <div style="display:flex;align-items:center;justify-content:center;padding:12px 16px;border-bottom:1px solid ${T.borderLight};position:relative">
        <div style="position:absolute;left:16px">${ic('arrowL',{size:24,w:2.5})}</div>
        <span style="font-size:17px;font-weight:700">${HOTEL.name}</span>
      </div>
      <div class="body">
        <div class="scroll" style="padding:16px">
          <!-- Trip Coins -->
          <div style="display:flex;align-items:flex-start;gap:12px;padding:14px 0;border-bottom:1px solid ${T.borderLight};margin-bottom:16px">
            <div style="width:34px;height:34px;border-radius:50%;background:${T.bgSurface2};display:flex;align-items:center;justify-content:center;flex:0 0 34px">
              ${ic('coin',{size:18,w:2,fill:T.primary})}
            </div>
            <div>
              <div style="font-size:14px;font-weight:700;margin-bottom:4px">Trip Coins</div>
              <div style="font-size:13px;color:${T.textSub};line-height:1.5">
                Dapatkan <span style="color:${T.star};font-weight:700">31 Trip Coins (≈Rp5.526)</span> setelah Anda menginap.
                ${ic('chevD',{size:14,w:2})}
              </div>
            </div>
          </div>
          <!-- Permintaan Khusus -->
          <div style="padding-bottom:16px;border-bottom:1px solid ${T.borderLight};margin-bottom:16px">
            <div style="font-size:16px;font-weight:700;margin-bottom:8px">Permintaan Khusus</div>
            <div style="font-size:13px;color:${T.textSub};line-height:1.6;margin-bottom:8px">Pihak akomodasi akan berupaya secara maksimal, tetapi tidak menjamin semua permintaan dapat dipenuhi.</div>
            <span style="font-size:13px;font-weight:700;text-decoration:underline">Pelajari Selengkapnya</span>
          </div>
          <!-- Informasi Tambahan -->
          <div style="padding-bottom:16px;border-bottom:1px solid ${T.borderLight};margin-bottom:16px">
            <div style="font-size:16px;font-weight:700;margin-bottom:8px">Informasi Tambahan (1)</div>
            <div style="font-size:13px;line-height:1.6">
              Deposit tunai sebesar Total Rp100.000 diperlukan saat check-in
              <span style="font-weight:700;text-decoration:underline">Pelajari Selengkapnya</span>
            </div>
          </div>
          <!-- T&C -->
          <div style="padding-bottom:16px;border-bottom:1px solid ${T.borderLight};margin-bottom:14px">
            <div style="font-size:13px;line-height:1.6;color:${T.textSub}">
              Dengan melanjutkan pemesanan ini, saya menyatakan bahwa saya telah membaca dan menyetujui
              <span style="text-decoration:underline;color:${T.text};font-weight:600">Syarat &amp; Ketentuan</span> dan
              <span style="text-decoration:underline;color:${T.text};font-weight:600">Pernyataan Privasi</span> Trip.com.
            </div>
          </div>
          <!-- Checkbox -->
          <div style="display:flex;align-items:flex-start;gap:12px">
            <div style="width:20px;height:20px;border-radius:4px;background:${T.bgSurface2};border:1.5px solid ${T.primary};display:flex;align-items:center;justify-content:center;flex:0 0 20px">
              ${ic('check',{size:13,w:2.5,fill:'none'})}
            </div>
            <span style="font-size:13px;color:${T.textSub};line-height:1.6">Kirimi saya promo spesial Trip.com dan pengingat perjalanan via email, notifikasi push, WhatsApp, dan channel lainnya</span>
          </div>
        </div>
      </div>
      ${tealBanner}
      ${bottomPesan}
    </div>`;
  },

  // 18e. Bottom Sheet — Informasi Tambahan (Kebijakan Deposit)
  bottom_sheet_informasi_tambahan() {
    return `<div class="screen">
      ${statusbar()}
      <div style="display:flex;align-items:center;justify-content:center;padding:12px 16px;border-bottom:1px solid ${T.borderLight};position:relative">
        <div style="position:absolute;left:16px">${ic('close',{size:22,w:2})}</div>
        <span style="font-size:17px;font-weight:700">Informasi Tambahan</span>
      </div>
      <div class="body">
        <div class="scroll" style="padding:16px">
          <div style="font-size:18px;font-weight:800;margin-bottom:10px">Kebijakan Deposit</div>
          <div style="font-size:14px;color:${T.textSub};line-height:1.6">
            Deposit tunai sebesar Total Rp100.000 diperlukan saat check-in
          </div>
        </div>
      </div>
    </div>`;
  },

  // 18f. Bottom Sheet Full — Room Detail Family Suite
  room_detail_family_suite() {
    const tabContent = `
      <div style="padding:16px">
        <!-- Photo -->
        <div style="width:100%;height:180px;border-radius:${T.radius.card}px;overflow:hidden;margin-bottom:14px">
          ${gradPhoto({h:180,grad:'linear-gradient(135deg,#90a4ae,#607d8b)',radius:T.radius.card})}
        </div>
        <!-- Title + tabs -->
        <div style="font-size:20px;font-weight:800;margin-bottom:12px">Family Suite</div>
        <div style="display:flex;gap:8px;margin-bottom:16px">
          <div style="padding:8px 16px;border-radius:${T.radius.chip}px;border:1.5px solid ${T.border};font-size:13px;font-weight:600;background:#fff">Kamar Superior</div>
          <div style="padding:8px 16px;border-radius:${T.radius.chip}px;border:1.5px solid ${T.primary};font-size:13px;font-weight:600;background:${T.bgSurface2};color:${T.primary}">Family Suite</div>
        </div>
        <!-- Room specs -->
        <div style="display:flex;flex-wrap:wrap;gap:10px;margin-bottom:16px">
          ${[[ic('resize',{size:16,w:2}),'30 m²'],[ic('window',{size:16,w:2}),'Memiliki jendela'],[ic('nosmoke',{size:16,w:2}),'Bebas rokok'],[ic('wifi',{size:16,w:2}),'Wi-Fi gratis']].map(([icon,lbl])=>
            `<div style="display:flex;align-items:center;gap:5px;font-size:13px">${icon} ${lbl}</div>`
          ).join('')}
        </div>
        <div style="display:flex;align-items:center;gap:8px;margin-bottom:16px">
          ${ic('bed2',{size:16,w:2})}
          <span style="font-size:14px;font-weight:600">2 queen bed (lebar 1,6 m)</span>
        </div>
        <div style="font-size:13px;color:${T.textSub};line-height:1.6;margin-bottom:20px">
          Anda tidak dapat memesan tempat tidur tambahan dan ranjang bayi di tipe kamar ini
        </div>
        <!-- Pilihan Anda -->
        <div style="font-size:18px;font-weight:800;margin-bottom:12px">Pilihan Anda</div>
        <div style="display:flex;align-items:center;gap:8px;margin-bottom:8px">
          ${ic('user',{size:18,w:2})}
          <span style="font-size:14px;font-weight:700">4 dewasa</span>
        </div>
        <div style="font-size:13px;color:${T.textSub};line-height:1.6;margin-bottom:16px">
          Kamar ini cocok untuk grup Anda karena dapat mengakomodasi hingga 4 tamu
        </div>
        <div style="font-size:13px;color:${T.textSub};margin-bottom:8px">Tidak termasuk makanan</div>
        <div style="font-size:13px;color:${T.textSub};margin-bottom:16px">Berikut adalah biaya untuk sarapan tambahan</div>
        <div style="display:flex;gap:8px;margin-bottom:20px">
          <div style="padding:10px 16px;border:1.5px solid ${T.border};border-radius:${T.radius.field}px;font-size:14px;font-weight:600">Dewasa</div>
          <div style="padding:10px 16px;border:1.5px solid ${T.border};border-radius:${T.radius.field}px;font-size:14px;color:${T.textSub}">Buffet:Rp108.900 per orang</div>
        </div>
        <!-- Konfirmasi Langsung -->
        <div style="display:flex;align-items:center;gap:8px;margin-bottom:12px;color:${T.teal};font-weight:700;font-size:15px">
          ${ic('check',{size:18,w:2.5,fill:T.teal})} Konfirmasi Langsung
        </div>
        <div style="display:flex;align-items:center;gap:8px;margin-bottom:24px;font-size:14px;color:${T.textSub}">
          ${ic('luggage',{size:18,w:2})} Prabayar Online
        </div>
        <!-- Fasilitas Kamar -->
        <div style="font-size:18px;font-weight:800;margin-bottom:12px">Fasilitas Kamar</div>
        <div style="display:grid;grid-template-columns:1fr 1fr;gap:10px;margin-bottom:16px">
          ${[['Kamar mandi pribadi','Shower','AC'],['Pengering rambut','Minibar','Handuk']].map(row=>
            row.map(item=>`<div style="font-size:13px;color:${T.text}">${item}</div>`).join('')
          ).join('')}
        </div>
        <div style="font-size:14px;color:${T.primary};font-weight:700;text-decoration:underline;margin-bottom:24px">Tampilkan semua fasilitas</div>
        <!-- Kebijakan & layanan -->
        <div style="font-size:18px;font-weight:800;margin-bottom:12px">Kebijakan & layanan</div>
        <div style="font-size:16px;font-weight:700;color:${T.teal};margin-bottom:8px">Pembatalan Gratis</div>
        <div style="display:flex;align-items:flex-start;gap:10px;margin-bottom:8px">
          <div style="width:20px;height:20px;border-radius:50%;background:${T.teal};display:flex;align-items:center;justify-content:center;color:#fff;flex:0 0 20px">${ic('clock',{size:12,w:2,fill:'#fff'})}</div>
          <div>
            <div style="font-size:14px;font-weight:700;color:${T.teal}">Pembatalan Gratis</div>
            <div style="font-size:13px;color:${T.textSub}">Sebelum 16 Agt 2026, 23.59</div>
          </div>
        </div>
        <div style="display:flex;align-items:flex-start;gap:10px;margin-bottom:16px">
          <div style="width:20px;height:20px;border-radius:50%;border:1.5px solid ${T.border};display:flex;align-items:center;justify-content:center;flex:0 0 20px"></div>
          <div>
            <div style="font-size:14px;font-weight:700;color:${T.textSub}">Tidak dapat di-refund</div>
            <div style="font-size:13px;color:${T.textSub}">Setelah 16 Agt 2026, 23.59</div>
          </div>
        </div>
        <div style="font-size:13px;color:${T.textSub};line-height:1.6;margin-bottom:16px">
          · Anda akan dikenakan biaya pembatalan jika Anda tidak check-in.<br>
          · Mengacu pada zona waktu di lokasi hotel.
        </div>
        <div style="font-size:14px;color:${T.teal};font-weight:700;margin-bottom:6px">Konfirmasi Langsung</div>
        <div style="font-size:13px;color:${T.textSub};line-height:1.6;margin-bottom:24px">Pemesanan akan langsung dikonfirmasi.</div>
        <!-- Kebijakan Anak -->
        <div style="font-size:18px;font-weight:800;margin-bottom:12px">Kebijakan Anak dan Tempat Tidur Tambahan</div>
        <div style="font-size:16px;font-weight:700;margin-bottom:8px">Kebijakan Tamu Anak</div>
        <div style="font-size:13px;color:${T.textSub};line-height:1.6;margin-bottom:16px">
          · Anak dari segala usia dapat menginap di kamar ini.<br>
          · Harap tambahkan jumlah pasti anak-anak dan usia mereka ke dalam kriteria pencarian, dan kami akan memberi Anda tipe kamar yang sesuai.
        </div>
        <div style="font-size:16px;font-weight:700;margin-bottom:8px">Ranjang Bayi dan Tempat Tidur Tambahan</div>
        <div style="font-size:13px;color:${T.textSub};line-height:1.6;margin-bottom:24px">Anda tidak dapat memesan tempat tidur tambahan dan ranjang bayi di tipe kamar ini</div>
        <!-- Sarapan -->
        <div style="font-size:18px;font-weight:800;margin-bottom:12px">Sarapan</div>
        <div style="font-size:14px;font-weight:700;margin-bottom:4px">Gaya</div>
        <div style="font-size:13px;color:${T.textSub};margin-bottom:4px">Buffet</div>
        <div style="font-size:14px;font-weight:700;margin-bottom:4px">Jam buka</div>
        <div style="font-size:13px;color:${T.textSub};margin-bottom:16px">[Sen - Min] 07:00-10:00 Buka</div>
        <div style="font-size:14px;font-weight:700;margin-bottom:8px">Biaya</div>
        <div style="border:1px solid ${T.borderLight};border-radius:${T.radius.field}px;overflow:hidden;margin-bottom:16px">
          <div style="display:grid;grid-template-columns:1fr 1fr;border-bottom:1px solid ${T.borderLight}">
            <div style="padding:12px 16px;font-size:13px;font-weight:700;border-right:1px solid ${T.borderLight}">Usia</div>
            <div style="padding:12px 16px;font-size:13px;font-weight:700">Biaya</div>
          </div>
          <div style="display:grid;grid-template-columns:1fr 1fr;border-bottom:1px solid ${T.borderLight}">
            <div style="padding:12px 16px;font-size:13px;font-weight:700">Anak usia 5-17 tahun</div>
            <div style="padding:12px 16px;font-size:13px;color:${T.textSub}">Rp65.000 per orang</div>
          </div>
          <div style="display:grid;grid-template-columns:1fr 1fr">
            <div style="padding:12px 16px;font-size:13px;font-weight:700">Dewasa</div>
            <div style="padding:12px 16px;font-size:13px;color:${T.textSub}">Buffet:Rp108.900 per orang</div>
          </div>
        </div>
        <div style="font-size:12px;color:${T.textSub};line-height:1.6;margin-bottom:24px">
          Biaya sarapan tambahan tidak termasuk dalam total biaya dan harus dibayar secara terpisah di akomodasi.
        </div>
      </div>
    </div>`;
  },

  // 18g. Bottom Sheet Full — Room Detail Kamar Superior
  room_detail_kamar_superior() {
    return `<div class="screen">
      ${statusbar()}
      <div style="display:flex;align-items:center;justify-content:center;padding:12px 16px;border-bottom:1px solid ${T.borderLight};position:relative">
        <div style="position:absolute;left:16px">${ic('close',{size:22,w:2})}</div>
        <span style="font-size:17px;font-weight:700">Kamar Superior</span>
      </div>
      <div class="body">
        <div class="scroll" style="padding:16px">
          <!-- Photo -->
          <div style="width:100%;height:180px;border-radius:${T.radius.card}px;overflow:hidden;margin-bottom:14px">
            ${gradPhoto({h:180,grad:'linear-gradient(135deg,#c8a96e,#8d6e63)',radius:T.radius.card})}
          </div>
          <!-- Title + tabs -->
          <div style="font-size:20px;font-weight:800;margin-bottom:12px">Kamar Superior</div>
          <div style="display:flex;gap:8px;margin-bottom:16px">
            <div style="padding:8px 16px;border-radius:${T.radius.chip}px;border:1.5px solid ${T.primary};font-size:13px;font-weight:600;background:${T.bgSurface2};color:${T.primary}">Kamar Superior</div>
            <div style="padding:8px 16px;border-radius:${T.radius.chip}px;border:1.5px solid ${T.border};font-size:13px;font-weight:600;background:#fff">Family Suite</div>
          </div>
          <!-- Room specs -->
          <div style="display:flex;flex-wrap:wrap;gap:10px;margin-bottom:16px">
            ${[[ic('resize',{size:16,w:2}),'21 m²'],[ic('window',{size:16,w:2}),'Memiliki jendela'],[ic('nosmoke',{size:16,w:2}),'Bebas rokok'],[ic('wifi',{size:16,w:2}),'Wi-Fi gratis']].map(([icon,lbl])=>
              `<div style="display:flex;align-items:center;gap:5px;font-size:13px">${icon} ${lbl}</div>`
            ).join('')}
          </div>
          <div style="font-size:14px;font-weight:700;margin-bottom:4px">Jenis kamar disediakan selama persediaan masih ada</div>
          <div style="border:1px solid ${T.borderLight};border-radius:${T.radius.field}px;overflow:hidden;margin-bottom:12px">
            <div style="display:grid;grid-template-columns:1fr 1fr;border-bottom:1px solid ${T.borderLight}">
              <div style="padding:12px 16px;font-size:13px;font-weight:700;border-right:1px solid ${T.borderLight}">Opsi 1</div>
              <div style="padding:12px 16px;font-size:13px;color:${T.textSub}">1 queen bed (lebar 1,6 m)</div>
            </div>
            <div style="display:grid;grid-template-columns:1fr 1fr">
              <div style="padding:12px 16px;font-size:13px;font-weight:700">Opsi 2</div>
              <div style="padding:12px 16px;font-size:13px;color:${T.textSub}">2 single bed (lebar 0,8 m)</div>
            </div>
          </div>
          <div style="font-size:13px;color:${T.textSub};line-height:1.6;margin-bottom:20px">
            Anda tidak dapat memesan tempat tidur tambahan dan ranjang bayi di tipe kamar ini
          </div>
          <!-- Pilihan Anda -->
          <div style="font-size:18px;font-weight:800;margin-bottom:12px">Pilihan Anda</div>
          <div style="display:flex;align-items:center;gap:8px;margin-bottom:8px">
            ${ic('user',{size:18,w:2})}
            <span style="font-size:14px;font-weight:700">2 dewasa, 1 anak (Usia 0-5 tahun)</span>
          </div>
          <div style="font-size:13px;color:${T.textSub};line-height:1.6;margin-bottom:16px">
            Kamar ini cocok untuk grup Anda karena dapat mengakomodasi hingga 3 tamu
          </div>
          <div style="font-size:13px;color:${T.textSub};margin-bottom:8px">Tidak termasuk makanan</div>
          <div style="font-size:13px;color:${T.textSub};margin-bottom:16px">Berikut adalah biaya untuk sarapan tambahan</div>
          <div style="display:flex;gap:8px;margin-bottom:20px">
            <div style="padding:10px 16px;border:1.5px solid ${T.border};border-radius:${T.radius.field}px;font-size:14px;font-weight:600">Dewasa</div>
            <div style="padding:10px 16px;border:1.5px solid ${T.border};border-radius:${T.radius.field}px;font-size:14px;color:${T.textSub}">Buffet:Rp108.900 per orang</div>
          </div>
          <!-- Konfirmasi Langsung -->
          <div style="display:flex;align-items:center;gap:8px;margin-bottom:12px;color:${T.teal};font-weight:700;font-size:15px">
            ${ic('check',{size:18,w:2.5,fill:T.teal})} Konfirmasi Langsung
          </div>
          <div style="display:flex;align-items:center;gap:8px;margin-bottom:24px;font-size:14px;color:${T.textSub}">
            ${ic('luggage',{size:18,w:2})} Prabayar Online
          </div>
          <!-- Fasilitas Kamar -->
          <div style="font-size:18px;font-weight:800;margin-bottom:12px">Fasilitas Kamar</div>
          <div style="display:grid;grid-template-columns:1fr 1fr;gap:10px;margin-bottom:16px">
            ${[['Kamar mandi pribadi','AC','TV LCD'],['Pengering rambut','Minibar','Bathtub atau shower']].map(row=>
              row.map(item=>`<div style="font-size:13px;color:${T.text}">${item}</div>`).join('')
            ).join('')}
          </div>
          <div style="font-size:14px;color:${T.primary};font-weight:700;text-decoration:underline;margin-bottom:24px">Tampilkan semua fasilitas</div>
          <!-- Kebijakan & layanan -->
          <div style="font-size:18px;font-weight:800;margin-bottom:12px">Kebijakan & layanan</div>
          <div style="font-size:16px;font-weight:700;color:${T.teal};margin-bottom:8px">Pembatalan Gratis</div>
          <div style="display:flex;align-items:flex-start;gap:10px;margin-bottom:8px">
            <div style="width:20px;height:20px;border-radius:50%;background:${T.teal};display:flex;align-items:center;justify-content:center;color:#fff;flex:0 0 20px">${ic('clock',{size:12,w:2,fill:'#fff'})}</div>
            <div>
              <div style="font-size:14px;font-weight:700;color:${T.teal}">Pembatalan Gratis</div>
              <div style="font-size:13px;color:${T.textSub}">Sebelum 16 Agt 2026, 23.59</div>
            </div>
          </div>
          <div style="display:flex;align-items:flex-start;gap:10px;margin-bottom:16px">
            <div style="width:20px;height:20px;border-radius:50%;border:1.5px solid ${T.border};display:flex;align-items:center;justify-content:center;flex:0 0 20px"></div>
            <div>
              <div style="font-size:14px;font-weight:700;color:${T.textSub}">Tidak dapat di-refund</div>
              <div style="font-size:13px;color:${T.textSub}">Setelah 16 Agt 2026, 23.59</div>
            </div>
          </div>
          <div style="font-size:13px;color:${T.textSub};line-height:1.6;margin-bottom:16px">
            · Anda akan dikenakan biaya pembatalan jika Anda tidak check-in.<br>
            · Mengacu pada zona waktu di lokasi hotel.
          </div>
          <div style="font-size:14px;color:${T.teal};font-weight:700;margin-bottom:6px">Konfirmasi Langsung</div>
          <div style="font-size:13px;color:${T.textSub};line-height:1.6;margin-bottom:24px">Pemesanan akan langsung dikonfirmasi.</div>
          <!-- Kebijakan Anak -->
          <div style="font-size:18px;font-weight:800;margin-bottom:12px">Kebijakan Anak dan Tempat Tidur Tambahan</div>
          <div style="font-size:16px;font-weight:700;margin-bottom:8px">Kebijakan Tamu Anak</div>
          <div style="font-size:13px;color:${T.textSub};line-height:1.6;margin-bottom:16px">
            · Anak dari segala usia dapat menginap di kamar ini.<br>
            · Harap tambahkan jumlah pasti anak-anak dan usia mereka ke dalam kriteria pencarian, dan kami akan memberi Anda tipe kamar yang sesuai.
          </div>
          <div style="font-size:16px;font-weight:700;margin-bottom:8px">Ranjang Bayi dan Tempat Tidur Tambahan</div>
          <div style="font-size:13px;color:${T.textSub};line-height:1.6;margin-bottom:24px">Anda tidak dapat memesan tempat tidur tambahan dan ranjang bayi di tipe kamar ini</div>
          <!-- Sarapan -->
          <div style="font-size:18px;font-weight:800;margin-bottom:12px">Sarapan</div>
          <div style="font-size:14px;font-weight:700;margin-bottom:4px">Gaya</div>
          <div style="font-size:13px;color:${T.textSub};margin-bottom:4px">Buffet</div>
          <div style="font-size:14px;font-weight:700;margin-bottom:4px">Jam buka</div>
          <div style="font-size:13px;color:${T.textSub};margin-bottom:16px">[Sen - Min] 07:00-10:00 Buka</div>
          <div style="font-size:14px;font-weight:700;margin-bottom:8px">Biaya</div>
          <div style="border:1px solid ${T.borderLight};border-radius:${T.radius.field}px;overflow:hidden;margin-bottom:16px">
            <div style="display:grid;grid-template-columns:1fr 1fr;border-bottom:1px solid ${T.borderLight}">
              <div style="padding:12px 16px;font-size:13px;font-weight:700;border-right:1px solid ${T.borderLight}">Usia</div>
              <div style="padding:12px 16px;font-size:13px;font-weight:700">Biaya</div>
            </div>
            <div style="display:grid;grid-template-columns:1fr 1fr;border-bottom:1px solid ${T.borderLight}">
              <div style="padding:12px 16px;font-size:13px;font-weight:700">Anak usia 5-17 tahun</div>
              <div style="padding:12px 16px;font-size:13px;color:${T.textSub}">Rp65.000 per orang</div>
            </div>
            <div style="display:grid;grid-template-columns:1fr 1fr">
              <div style="padding:12px 16px;font-size:13px;font-weight:700">Dewasa</div>
              <div style="padding:12px 16px;font-size:13px;color:${T.textSub}">Buffet:Rp108.900 per orang</div>
            </div>
          </div>
          <div style="font-size:12px;color:${T.textSub};line-height:1.6;margin-bottom:24px">
            Biaya sarapan tambahan tidak termasuk dalam total biaya dan harus dibayar secara terpisah di akomodasi.
          </div>
        </div>
      </div>
    </div>`;
  },

  // 18h. Bottom Sheet — Kode Promo
  bottom_sheet_kode_promo() {
    const promoList = [
      { title: 'Diskon 5% Maks. Diskon Rp21...', sub: 'Diskon 3 malam', valid: 'Berlaku mulai 14 Agt 2026, 11.57 sampai 21 Agt 2026, 22.59', detail: 'Tidak berlaku untuk jumlah malam yang Anda pilih', disabled: true },
      { title: 'Diskon hingga Rp393.750', sub: 'Promo Homestay Unggulan', valid: 'Berlaku mulai 14 Agt 2026, 11.57 sampai 21 Agt 2026, 22.59', detail: 'Tidak berlaku untuk akomodasi ini', disabled: true },
      { title: 'Diskon 10% Maks. Diskon Rp9...', sub: 'Kode promo pengguna baru (pemesan pertama)', valid: 'Berlaku mulai 13 Agt 2026, 02.12 sampai 27 Agt 2026, 22.59', detail: 'Kode promo ini tidak dapat digunakan pada pemesanan saat ini', disabled: true },
    ];

    return `<div class="screen">
      ${statusbar()}
      <div style="display:flex;align-items:center;justify-content:center;padding:12px 16px;border-bottom:1px solid ${T.borderLight};position:relative">
        <div style="position:absolute;left:16px">${ic('close',{size:22,w:2})}</div>
        <span style="font-size:17px;font-weight:700">Kode Promo</span>
      </div>
      <div class="body">
        <div class="scroll" style="padding:16px">
          <!-- Input -->
          <div style="display:flex;gap:8px;margin-bottom:16px">
            <div style="flex:1;border:1.5px solid ${T.border};border-radius:${T.radius.field}px;padding:12px 16px;font-size:14px;color:${T.textSub}">Tambah Kode Promo</div>
            <div style="padding:12px 20px;border-radius:${T.radius.field}px;background:${T.bgSurface};color:${T.textSub};font-size:14px;font-weight:600">Tambah</div>
          </div>
          <!-- List -->
          <div style="font-size:14px;font-weight:700;margin-bottom:12px">Pilih Kode Promo (0 Tersedia)</div>
          ${promoList.map(p=>`
            <div style="border:1.5px solid ${T.borderLight};border-radius:${T.radius.card}px;padding:14px;margin-bottom:10px;opacity:${p.disabled?0.6:1}">
              <div style="display:flex;justify-content:space-between;align-items:flex-start;margin-bottom:6px">
                <div style="font-size:15px;font-weight:700;flex:1">${p.title}</div>
                <div style="width:20px;height:20px;border-radius:50%;border:1.5px solid ${T.border};flex:0 0 auto;margin-left:8px"></div>
              </div>
              <div style="font-size:13px;color:${T.textSub};margin-bottom:4px">${p.sub}</div>
              <div style="font-size:12px;color:${T.textSub};margin-bottom:4px">${p.valid}</div>
              <div style="font-size:12px;color:#e65100;text-decoration:underline">${p.detail}</div>
            </div>
          `).join('')}
        </div>
      </div>
    </div>`;
  },

  // 18i. Bottom Sheet — Permintaan Khusus
  bottom_sheet_permintaan() {
    const bedPreference = [
      { label: 'Utamakan 2 single bed', selected: false },
      { label: 'Utamakan 1 queen bed', selected: false },
    ];
    const liftPosition = [
      { label: 'Jauh dari lift', selected: false },
      { label: 'Dekat lift', selected: false },
    ];
    const otherRequests = [
      { label: 'Kamar kedap suara', selected: false },
      { label: 'Perlu pembersihan khusus asap rokok', selected: false },
      { label: 'Kamar non-corner', selected: false },
      { label: 'Perlu menitipkan bagasi', selected: false },
    ];

    return `<div class="screen">
      ${statusbar()}
      <div style="display:flex;align-items:center;justify-content:center;padding:12px 16px;border-bottom:1px solid ${T.borderLight};position:relative">
        <div style="position:absolute;left:16px">${ic('close',{size:22,w:2})}</div>
        <span style="font-size:17px;font-weight:700">Permintaan Khusus</span>
      </div>
      <div class="body">
        <div class="scroll" style="padding:16px">
          <!-- Kamar Superior -->
          <div style="font-size:16px;font-weight:700;margin-bottom:12px">Kamar Superior</div>
          <!-- Preferensi tipe tempat tidur -->
          <div style="font-size:15px;font-weight:700;margin-bottom:8px">Preferensi tipe tempat tidur</div>
          ${bedPreference.map(opt=>`
            <div style="display:flex;align-items:center;gap:10px;padding:10px 0;border-bottom:1px solid ${T.borderLight}">
              <div style="width:20px;height:20px;border-radius:50%;border:1.5px solid ${T.border};flex:0 0 auto"></div>
              <span style="font-size:14px">${opt.label}</span>
            </div>
          `).join('')}
          <!-- Posisi dari Lift -->
          <div style="font-size:15px;font-weight:700;margin:16px 0 8px">Posisi dari Lift</div>
          ${liftPosition.map(opt=>`
            <div style="display:flex;align-items:center;gap:10px;padding:10px 0;border-bottom:1px solid ${T.borderLight}">
              <div style="width:20px;height:20px;border-radius:50%;border:1.5px solid ${T.border};flex:0 0 auto"></div>
              <span style="font-size:14px">${opt.label}</span>
            </div>
          `).join('')}
          <!-- Permintaan lainnya -->
          <div style="font-size:15px;font-weight:700;margin:16px 0 8px">Permintaan lainnya</div>
          ${otherRequests.map(opt=>`
            <div style="display:flex;align-items:center;gap:10px;padding:10px 0;border-bottom:1px solid ${T.borderLight}">
              <div style="width:20px;height:20px;border-radius:4px;border:1.5px solid ${T.border};flex:0 0 auto"></div>
              <span style="font-size:14px">${opt.label}</span>
            </div>
          `).join('')}
          <!-- Permintaan tambahan -->
          <div style="font-size:14px;font-weight:700;margin-top:16px;margin-bottom:8px">Permintaan tambahan</div>
          <div style="border:1.5px solid ${T.border};border-radius:${T.radius.field}px;padding:12px 16px;margin-bottom:8px">
            <div style="width:100%;min-height:80px;font-size:14px;color:${T.textSub};outline:none;border:none;background:transparent;resize:none" contenteditable="true"></div>
            <div style="text-align:right;font-size:12px;color:${T.textSub}">0/200</div>
          </div>
          <div style="font-size:12px;color:${T.textSub};line-height:1.6;margin-bottom:24px">
            Pihak akomodasi akan berupaya secara maksimal, tetapi tidak menjamin semua permintaan dapat dipenuhi.
          </div>
        </div>
      </div>
      <div style="padding:12px 16px 20px;background:#fff;border-top:1px solid ${T.borderLight};flex:0 0 auto">
        <div class="btn btn-primary" style="font-size:16px">Selesai</div>
      </div>
    </div>`;
  },
};
