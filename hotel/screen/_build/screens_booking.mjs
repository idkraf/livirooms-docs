// screens_booking.mjs — pesan_kamar_section, sheet_pesan_kamar, form_pengisian_kamar, form_pengisian_kamar_scroll
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

export const bookingScreens = {

  // 16. Pilih Kamar Section (scroll ke bawah di detail)
  pesan_kamar_section() {
    return `<div class="screen">
      ${statusbar()}
      ${topbar({ title: HOTEL.name, back: true, right: `<div style="display:flex;gap:10px;color:${T.textSub}">${ic('heart',{size:22,w:2})}${ic('share',{size:22,w:2})}</div>` })}
      <div class="body">
        <div class="scroll" style="padding:0">
          <!-- Misc facilities -->
          <div style="padding:14px 16px;background:#fff;border-bottom:1px solid ${T.borderLight}">
            ${[['spa','Spa'],['billiard','Ruang biliar'],['massage','Ruang pijat'],['luggage','Penyimpanan bagasi']].map(([icon,lbl])=>`
              <div style="display:flex;align-items:center;gap:12px;padding:8px 0">
                ${ic(icon,{size:22,w:2})} <span style="font-size:15px">${lbl}</span>
              </div>`).join('')}
          </div>
          <!-- Pilih Kamar section -->
          <div style="padding:16px;background:#fff;border-bottom:8px solid ${T.bgSurface}">
            <div style="font-size:20px;font-weight:800;margin-bottom:4px">Pilih Kamar Anda</div>
            <div style="display:flex;align-items:center;gap:6px;margin-bottom:12px">
              <span style="font-size:20px">💜</span>
              <span style="font-size:13px;font-weight:600;color:${T.teal}">Kami Samakan Harga</span>
            </div>
            <!-- Date/guest selector card -->
            <div style="border:1.5px solid ${T.border};border-radius:${T.radius.card}px;overflow:hidden;margin-bottom:16px">
              <div style="padding:12px 14px;background:#fff">
                <div style="display:flex">
                  <div style="flex:1">
                    <div style="font-size:11px;color:${T.textSub}">Check-in &amp; Check-out</div>
                    <div style="font-size:16px;font-weight:700">${HOTEL.checkin}–${HOTEL.checkout}</div>
                    <div style="font-size:12px;color:${T.textSub}">${HOTEL.nights}</div>
                  </div>
                  <div style="width:1px;background:${T.border};margin:4px 12px"></div>
                  <div>
                    <div style="font-size:11px;color:${T.textSub}">Kamar &amp; Tamu</div>
                    <div style="display:flex;align-items:center;gap:6px;font-size:16px;font-weight:700">
                      ${ic('bed2',{size:16,w:2})} <span>${HOTEL.rooms}</span>
                      ${ic('user',{size:16,w:2})} <span>${HOTEL.adults}</span>
                      <span style="font-size:14px">🌿</span><span>${HOTEL.children}</span>
                    </div>
                  </div>
                </div>
              </div>
              <div style="border-top:1px dashed ${T.border};padding:10px 14px;display:flex;gap:8px;overflow:hidden">
                ${['Termasuk Sarapan','Kamar Keluarga','2 Bed'].map(c=>`
                  <div class="chip">${c}</div>`).join('')}
                ${ic('chevD',{size:18,w:2})}
              </div>
            </div>
            <!-- Kombo recommendation -->
            <div style="font-size:16px;font-weight:700;margin-bottom:10px">Disarankan memesan kombo 2 kamar</div>
            <div style="border:1.5px solid ${T.border};border-radius:${T.radius.card}px;padding:14px">
              <div style="font-size:14px;font-weight:700;margin-bottom:2px">1 × Family Suite</div>
              <div style="font-size:14px;font-weight:700;margin-bottom:8px">1 × Kamar Superior</div>
              <div style="color:${T.primary};font-size:13px;font-weight:700;text-decoration:underline;margin-bottom:14px">Lihat Detail</div>
              <div style="text-align:right;margin-bottom:4px">
                <span style="font-size:12px;color:${T.textSub}">ⓘ </span>
                <span style="font-size:13px;color:${T.textSub};text-decoration:line-through">Rp541.790 </span>
                <span style="font-size:22px;font-weight:800;color:${T.primary}">Rp446.637</span>
              </div>
              <div style="text-align:right;font-size:12px;font-weight:700;margin-bottom:2px">Total harga: Rp1.089.796</div>
              <div style="text-align:right;font-size:11px;color:${T.textSub};margin-bottom:6px">2 kamar × 1 malam termasuk pajak &amp; biaya lainnya</div>
              <div style="text-align:right;margin-bottom:12px">
                <span style="padding:3px 10px;background:${T.discountBg};color:${T.discountText};font-size:11px;font-weight:700;border-radius:10px">Diskon Spesial</span>
              </div>
              <div class="btn btn-primary" style="margin-bottom:12px">Pesan 2 Kamar</div>
              <!-- Room photos -->
              <div style="display:flex;gap:4px;height:80px;border-radius:${T.radius.sm}px;overflow:hidden">
                ${gradPhoto({h:80,grad:'linear-gradient(135deg,#c8a96e,#a67c52)',radius:0})}
                ${gradPhoto({h:80,grad:'linear-gradient(135deg,#8d6e63,#6d4c41)',radius:0})}
              </div>
            </div>
          </div>
        </div>
      </div>
      <div style="display:flex;align-items:center;gap:12px;padding:10px 16px;background:#fff;border-top:1px solid ${T.borderLight}">
        <div style="flex:1">
          <div style="font-size:20px;font-weight:800;color:${T.primary}">${HOTEL.pricePerNight}</div>
          <div style="font-size:12px;color:${T.priceOri};text-decoration:line-through">${HOTEL.priceOriginal}</div>
        </div>
        <div style="width:170px">
          <div class="btn btn-primary">Pilih kamar</div>
        </div>
      </div>
    </div>`;
  },

  // 17-19. Form screens moved to screens_form.mjs: form_pesan_kamar, form_pengisian_kamar, form_pengisian_kamar_scroll

  // 29. Booking List Screen — Daftar Pemesanan Saya
  booking_list_screen() {
    const bookingCard = () => `
      <div style="background:#fff;border-radius:${T.radius.card}px;padding:14px 16px;margin-bottom:12px;border:1px solid ${T.borderLight}">
        <div style="display:flex;align-items:center;gap:8px;margin-bottom:10px">
          <div style="width:32px;height:32px;border-radius:8px;background:${T.bgSurface};display:flex;align-items:center;justify-content:center;color:${T.text}">${ic('bed2',{size:18,w:2})}</div>
          <span style="font-size:14px;font-weight:600">Hotel</span>
          <span style="margin-left:auto;padding:4px 10px;background:#fff3e0;color:#e65100;font-size:11px;font-weight:700;border-radius:10px">Menunggu Pembayaran</span>
        </div>
        <div style="font-size:16px;font-weight:800;margin-bottom:6px">Grand Cemara Hotel</div>
        <div style="font-size:13px;color:${T.textSub};margin-bottom:4px">Family Suite</div>
        <div style="font-size:13px;color:${T.textSub};margin-bottom:6px">17 Agt - 18 Agt, 2 kamar 1 malam</div>
        <div style="font-size:12px;color:${T.teal};font-weight:600;margin-bottom:8px">Anda akan mendapatkan: 43 Trip Coins (Rp7.665)</div>
        <div style="display:flex;align-items:center;justify-content:space-between">
          <div>
            <div style="font-size:11px;color:${T.textSub}">Prabayar online</div>
            <div style="font-size:16px;font-weight:800;color:${T.primary}">Rp1.498.990</div>
          </div>
          <div style="width:120px">
            <div class="btn btn-primary" style="height:40px;font-size:14px">Bayar</div>
          </div>
        </div>
      </div>
    `;

    return `<div class="screen">
      ${statusbar()}
      ${topbar({ title: 'Semua Pemesanan', right: `<div style="display:flex;align-items:center;justify-content:center;width:36px;height:36px;border-radius:50%;background:${T.bgSurface};color:${T.text}">${ic('search',{size:20,w:2})}</div>` })}
      <!-- Tabs -->
      <div style="display:flex;border-bottom:1px solid ${T.borderLight};background:#fff;flex:0 0 auto">
        ${['Semua Pemesanan','Mendatang','Selesai','Refund'].map((t,i)=>
          `<div style="flex:1;text-align:center;padding:12px 0;font-size:13px;font-weight:${i===0?700:500};color:${i===0?T.primary:T.textSub};position:relative;border-bottom:${i===0?'2.5px solid '+T.primary:'none'}">${t}</div>`
        ).join('')}
      </div>
      <!-- Filter chips -->
      <div style="display:flex;gap:8px;padding:10px 16px;background:#fff;border-bottom:1px solid ${T.borderLight};overflow:hidden;flex:0 0 auto">
        ${['Filter','Pesawat','Hotel','Kereta'].map((c,i)=>
          `<div style="padding:7px 14px;border-radius:${T.radius.chip}px;border:1.5px solid ${i===0?T.primary:T.border};font-size:12px;font-weight:600;color:${i===0?T.primary:T.text};white-space:nowrap;background:#fff">${c}</div>`
        ).join('')}
      </div>
      <div class="body">
        <div class="scroll" style="padding:12px 16px">
          ${bookingCard()}
          <div style="text-align:center;padding:24px 0 12px;color:${T.textSub};font-size:13px">Tidak Ada Pemesanan Lainnya</div>
          <div style="text-align:center;font-size:13px;color:${T.primary};font-weight:600;text-decoration:underline;margin-bottom:24px">Cari berdasarkan email atau PIN</div>
        </div>
      </div>
    </div>`;
  },

  // 30. Booking Pembayaran Screen — Pembayaran
  booking_pembayaran_screen() {
    const paymentMethods = [
      { id: 'va', label: 'Virtual Account', active: true, icons: ['bc','bri','bni','mandiri','cimb','permata','danamon'] },
      { id: 'card', label: 'Tambah Kartu Kredit/Debit', active: false, icons: ['mc','visa','jcb','amex'] },
      { id: 'ovo', label: 'OVO', active: false, hint: 'Tautkan akun Anda ke Trip.com agar lebih praktis' },
      { id: 'gpay', label: 'Google Pay', active: false },
    ];

    const bankIcons = {
      bc: '<circle cx="12" cy="12" r="10" fill="#1a5fbb"/><text x="12" y="16" text-anchor="middle" fill="#fff" font-size="10" font-weight="700">BCA</text>',
      bri: '<circle cx="12" cy="12" r="10" fill="#003399"/><text x="12" y="16" text-anchor="middle" fill="#fff" font-size="10" font-weight="700">BRI</text>',
      bni: '<circle cx="12" cy="12" r="10" fill="#fff" stroke="#003399" stroke-width="1.5"/><text x="12" y="16" text-anchor="middle" fill="#003399" font-size="9" font-weight="700">BNI</text>',
      mandiri: '<circle cx="12" cy="12" r="10" fill="#f7b731"/><text x="12" y="16" text-anchor="middle" fill="#fff" font-size="8" font-weight="700">MDR</text>',
      cimb: '<circle cx="12" cy="12" r="10" fill="#d32f2f"/><text x="12" y="16" text-anchor="middle" fill="#fff" font-size="9" font-weight="700">CIMB</text>',
      permata: '<circle cx="12" cy="12" r="10" fill="#1e88e5"/><text x="12" y="16" text-anchor="middle" fill="#fff" font-size="9" font-weight="700">PMT</text>',
      danamon: '<circle cx="12" cy="12" r="10" fill="#fff" stroke="#ed1c24" stroke-width="1.5"/><text x="12" y="16" text-anchor="middle" fill="#ed1c24" font-size="8" font-weight="700">DAN</text>',
      mc: '<circle cx="12" cy="12" r="10" fill="#eb001b"/><circle cx="16" cy="12" r="5" fill="#f79e1b" opacity="0.8"/>',
      visa: '<circle cx="12" cy="12" r="10" fill="#1a1f71"/><text x="12" y="16" text-anchor="middle" fill="#fff" font-size="9" font-weight="700">VISA</text>',
      jcb: '<circle cx="12" cy="12" r="10" fill="#0e4c96"/><text x="12" y="16" text-anchor="middle" fill="#fff" font-size="8" font-weight="700">JCB</text>',
      amex: '<circle cx="12" cy="12" r="10" fill="#2e77bc"/><text x="12" y="16" text-anchor="middle" fill="#fff" font-size="7" font-weight="700">AMEX</text>',
    };

    const cardBankIcons = ['mc','visa','jcb','amex'];

    return `<div class="screen">
      ${statusbar()}
      <!-- Topbar -->
      <div style="display:flex;align-items:center;padding:10px 16px;border-bottom:1px solid ${T.borderLight};background:#fff;flex:0 0 auto">
        <div style="width:36px;height:36px;border-radius:50%;background:${T.bgSurface};display:flex;align-items:center;justify-content:center;flex:0 0 auto">${ic('arrowL',{size:20,w:2.5})}</div>
      </div>
      <div style="padding:14px 16px;background:#fff;border-bottom:1px solid ${T.borderLight};text-align:center;flex:0 0 auto">
        <div style="display:flex;align-items:center;justify-content:center;gap:8px;margin-bottom:6px">
          <div style="width:20px;height:20px;border-radius:50%;background:#e8f5e9;display:flex;align-items:center;justify-content:center;color:#4caf50">${ic('check',{size:12,w:2.5,fill:'#4caf50'})}</div>
          <span style="font-size:13px;color:${T.teal};font-weight:600">Anda telah menghemat Rp277.224 pada pemesanan ini</span>
        </div>
        <div style="font-size:14px;font-weight:700;color:${T.teal};margin-bottom:4px">Transaksi Aman</div>
        <div style="font-size:13px;color:${T.textSub}">Selesaikan pembayaran dalam <span style="font-weight:700;color:${T.text}">00:29:43</span></div>
      </div>
      <div class="body">
        <div class="scroll" style="padding:16px">
          <!-- Total -->
          <div style="text-align:center;padding:8px 0 20px;border-bottom:1px solid ${T.borderLight}">
            <div style="font-size:32px;font-weight:800;color:${T.text}">Rp1.498.990</div>
          </div>
          <!-- Booking info -->
          <div style="padding:14px 0;border-bottom:1px solid ${T.borderLight}">
            <div style="font-size:14px;font-weight:700;margin-bottom:6px">Sen, 17 Agt–Sel, 18 Agt | 1 malam <span style="font-size:12px;color:${T.textSub};font-weight:400;text-decoration:underline;margin-left:8px">Detail</span></div>
            <div style="font-size:13px;color:${T.textSub};margin-bottom:2px">Grand Cemara Hotel</div>
            <div style="font-size:13px;color:${T.textSub}">Info Tamu: Tea Wan</div>
          </div>
          <!-- Payment methods -->
          ${paymentMethods.map((pm, idx) => `
            <div style="display:flex;align-items:center;gap:12px;padding:14px 0;border-bottom:1px solid ${T.borderLight}">
              <div style="width:28px;height:28px;border-radius:8px;background:${T.bgSurface};display:flex;align-items:center;justify-content:center;flex:0 0 auto">
                ${pm.id === 'va' ? '<svg width="24" height="24" viewBox="0 0 24 24">' + bankIcons[pm.icons[0]] + '</svg>' : ''}
                ${pm.id === 'card' ? '<svg width="24" height="24" viewBox="0 0 24 24">' + bankIcons[pm.icons[0]] + '</svg>' : ''}
                ${pm.id === 'ovo' ? '<svg width="24" height="24" viewBox="0 0 24 24"><rect x="3" y="6" width="18" height="12" rx="3" fill="#4c4cce"/><text x="12" y="14" text-anchor="middle" fill="#fff" font-size="8" font-weight="700">OVO</text></svg>' : ''}
                ${pm.id === 'gpay' ? '<svg width="24" height="24" viewBox="0 0 24 24"><rect x="3" y="6" width="18" height="12" rx="3" fill="#fff" stroke="#4285f4" stroke-width="1.5"/><text x="12" y="14" text-anchor="middle" fill="#4285f4" font-size="7" font-weight="700">G Pay</text></svg>' : ''}
              </div>
              <div style="flex:1">
                <div style="font-size:14px;font-weight:700;margin-bottom:${pm.id==='va'?'4px':'0'}">${pm.label}</div>
                ${pm.hint ? `<div style="font-size:12px;color:${T.textSub}">${pm.hint}</div>` : ''}
                ${pm.id === 'va' ? `<div style="display:flex;gap:4px;margin-top:4px">${pm.icons.map(b=>`<svg width="22" height="22" viewBox="0 0 24 24">${bankIcons[b]}</svg>`).join('')}</div>` : ''}
                ${pm.id === 'card' ? `<div style="display:flex;gap:4px;margin-top:4px">${cardBankIcons.map(b=>`<svg width="22" height="22" viewBox="0 0 24 24">${bankIcons[b]}</svg>`).join('')}</div>` : ''}
              </div>
              <div style="width:22px;height:22px;border-radius:50%;border:2px solid ${pm.active?T.primary:T.border};display:flex;align-items:center;justify-content:center;flex:0 0 auto">
                ${pm.active?`<div style="width:12px;height:12px;border-radius:50%;background:${T.primary}"></div>`:''}
              </div>
            </div>
          `).join('')}
        </div>
      </div>
      <div style="padding:0 16px 20px;background:#fff;border-top:1px solid ${T.borderLight}">
        <div class="btn btn-primary" style="font-size:16px">Bayar Sekarang</div>
        <div style="display:flex;justify-content:center;gap:16px;margin-top:12px">
          <span style="font-size:11px;color:${T.textSub};display:flex;align-items:center;gap:4px">${ic('check',{size:12,w:2.5,fill:T.teal})} Berbagai metode pembayaran</span>
          <span style="font-size:11px;color:${T.textSub};display:flex;align-items:center;gap:4px">${ic('check',{size:12,w:2.5,fill:T.teal})} Cakupan global</span>
        </div>
      </div>
    </div>`;
  },

  // 31. Booking Hotel Detail Screen — 1 Kesatuan Scroll (5 bagian)
  booking_hotel_detail_screen() {
    return `<div class="screen">
      ${statusbar()}
      <div class="body">
        <div class="scroll" style="padding:0;background:#fff">
          <!-- PART 1: Menunggu Pembayaran -->
          <div style="padding:16px;border-bottom:8px solid ${T.bgSurface}">
            <!-- Booking header -->
            <div style="text-align:center;padding:8px 0 12px">
              <div style="font-size:11px;color:${T.textSub};margin-bottom:2px">No. Pemesanan</div>
              <div style="font-size:14px;font-weight:700;margin-bottom:2px">1367843010567330</div>
              <div style="font-size:11px;color:${T.textSub}">PIN <span style="font-weight:700;color:${T.text}">*****</span> ${ic('chevD',{size:14,w:2})}</div>
            </div>
            <div style="display:flex;justify-content:space-between;padding:0 4px 12px">
              <div style="width:36px;height:36px;border-radius:50%;background:${T.bgSurface};display:flex;align-items:center;justify-content:center">${ic('arrowL',{size:20,w:2.5})}</div>
              <div style="display:flex;gap:6px">
                <div style="width:36px;height:36px;border-radius:50%;background:${T.bgSurface};display:flex;align-items:center;justify-content:center;color:${T.teal}">${ic('headphone',{size:18,w:2})}</div>
                <div style="width:36px;height:36px;border-radius:50%;background:${T.bgSurface};display:flex;align-items:center;justify-content:center;color:${T.text}">${ic('share',{size:18,w:2})}</div>
              </div>
            </div>
            <!-- Menunggu Pembayaran -->
            <div style="background:#fff3e0;border-radius:${T.radius.card}px;padding:16px;margin-bottom:12px;border:1px solid #ffe0b2">
              <div style="font-size:20px;font-weight:800;color:#e65100;margin-bottom:8px">Menunggu Pembayaran</div>
              <div style="display:flex;align-items:center;gap:4px;margin-bottom:8px">
                <span style="font-size:28px;font-weight:800;color:#e65100">28</span>
                <span style="font-size:20px;font-weight:700;color:#e65100">:</span>
                <span style="font-size:28px;font-weight:800;color:#e65100">00</span>
              </div>
              <div style="font-size:12px;color:${T.textSub};line-height:1.5">Bayar sebelum batas waktu pembayaran berakhir untuk mengunci pemesanan kamar Anda</div>
            </div>
            <!-- Badge -->
            <div style="display:flex;gap:8px;margin-bottom:12px">
              <span style="display:flex;align-items:center;gap:4px;font-size:12px;color:${T.teal};font-weight:600">${ic('heart',{size:14,w:2,fill:T.teal})} Kami Samakan Harga</span>
              <span style="display:flex;align-items:center;gap:4px;font-size:12px;color:${T.teal};font-weight:600">${ic('shield',{size:14,w:2,fill:T.teal})} Jaminan Menginap di Hotel</span>
            </div>
            <!-- No refund notice -->
            <div style="font-size:16px;font-weight:800;margin-bottom:6px">Menunggu Pembayaran</div>
            <div style="font-size:22px;font-weight:800;color:${T.primary};margin-bottom:8px">Rp1.498.990</div>
            <div style="font-size:13px;font-weight:700;color:${T.text};margin-bottom:6px">Pemesanan ini tidak memiliki opsi refund untuk sekarang</div>
            <div style="font-size:13px;color:${T.textSub};line-height:1.5;margin-bottom:4px">Pemesanan ini tidak dapat diubah, dan tidak ada refund jika Anda membatalkannya.</div>
            <div style="font-size:13px;color:${T.primary};font-weight:700;text-decoration:underline;margin-bottom:16px">Kebijakan pembatalan</div>
            <!-- Hotel name + photo -->
            <div style="display:flex;align-items:flex-start;gap:12px;margin-bottom:12px">
              <div style="flex:1">
                <div style="font-size:18px;font-weight:800;margin-bottom:4px">Grand Cemara Hotel</div>
                <div style="font-size:13px;color:${T.primary};font-weight:600;text-decoration:underline">Detail akomodasi</div>
              </div>
              <div style="width:80px;height:60px;border-radius:${T.radius.sm}px;overflow:hidden;flex:0 0 auto">${gradPhoto({h:60,grad:'linear-gradient(135deg,#90a4ae,#607d8b)',radius:T.radius.sm})}</div>
            </div>
            <!-- Action buttons -->
            <div style="display:flex;gap:10px;margin-bottom:16px">
              <div style="flex:1;padding:12px;border-radius:${T.radius.btn}px;border:1.5px solid ${T.border};text-align:center;font-size:14px;font-weight:600;background:#fff">Kirim Pesan</div>
              <div style="flex:1;padding:12px;border-radius:${T.radius.btn}px;border:1.5px solid ${T.border};text-align:center;font-size:14px;font-weight:600;background:#fff">Hubungi Akomodasi</div>
            </div>
            <!-- Date/check info -->
            <div style="padding:14px 0;border-top:1px solid ${T.borderLight}">
              <div style="display:flex;align-items:center;gap:8px;margin-bottom:4px">
                ${ic('cal',{size:18,w:2})}
                <span style="font-size:14px;font-weight:700">Sen, 17 Agt - Sel, 18 Agt 2026 <span style="font-weight:400;color:${T.textSub}">| 1 Malam</span></span>
              </div>
              <div style="font-size:12px;color:${T.textSub};margin-left:26px;margin-bottom:2px">Check-in: Setelah 14.00</div>
              <div style="font-size:12px;color:${T.textSub};margin-left:26px">Check-out: Sebelum 12.00</div>
            </div>
          </div>

          <!-- PART 2: Lokasi, Fasilitas, Kebijakan -->
          <div style="padding:16px;border-bottom:8px solid ${T.bgSurface}">
            <!-- Lokasi -->
            <div style="display:flex;align-items:center;gap:8px;margin-bottom:10px">
              ${ic('location',{size:20,w:2})}
              <span style="font-size:16px;font-weight:700">Lokasi</span>
            </div>
            <div style="font-size:13px;line-height:1.6;color:${T.text};margin-bottom:6px">Jl. Cemara No.1 5, RT.5/RW.3, Gondangdia, Kec. Menteng, Kota Kecamatan Menteng, Jakarta Pusat, Daerah Khusus Ibukota Jakarta, 10350</div>
            <div style="display:flex;gap:12px;margin-bottom:16px">
              <span style="font-size:13px;color:${T.primary};font-weight:700;text-decoration:underline">Alamat berbahasa lokal</span>
              <span style="font-size:13px;color:${T.primary};font-weight:700;text-decoration:underline">Lihat peta</span>
            </div>
            <!-- Transport -->
            <div style="display:flex;align-items:center;gap:8px;margin-bottom:8px">
              ${ic('car',{size:18,w:2})}
              <span style="font-size:14px;font-weight:700">Tidak tersedia layanan antar jemput</span>
            </div>
            <div style="font-size:13px;color:${T.primary};font-weight:700;text-decoration:underline;margin-bottom:16px">Pesan di Trip.com</div>
            <!-- Fasilitas -->
            <div style="display:flex;align-items:center;gap:8px;margin-bottom:10px">
              ${ic('grid',{size:18,w:2})}
              <span style="font-size:16px;font-weight:700">Fasilitas</span>
            </div>
            <div style="font-size:13px;color:${T.textSub};margin-bottom:4px">Resepsionis 24 jam · Penyimpanan bagasi</div>
            <div style="font-size:13px;color:${T.primary};font-weight:700;text-decoration:underline;margin-bottom:16px">Selengkapnya</div>
            <!-- Kebijakan -->
            <div style="font-size:18px;font-weight:800;margin-bottom:12px">Kebijakan</div>
            <div style="font-size:16px;font-weight:700;margin-bottom:6px">Kebijakan Deposit</div>
            <div style="font-size:13px;color:${T.textSub};line-height:1.6;margin-bottom:4px">Deposit tunai sebesar Total Rp100.000 diperlukan saat check-in</div>
            <div style="font-size:13px;color:${T.primary};font-weight:700;text-decoration:underline">Baca selengkapnya</div>
          </div>

          <!-- PART 3: Detail Kamar & Tamu -->
          <div style="padding:16px;border-bottom:8px solid ${T.bgSurface}">
            <div style="font-size:18px;font-weight:800;margin-bottom:10px">Family Suite</div>
            <div style="font-size:14px;color:${T.textSub};margin-bottom:12px">2 Kamar 1 Malam</div>
            <div style="font-size:13px;color:${T.primary};font-weight:700;text-decoration:underline;margin-bottom:16px">Detail kamar</div>
            <!-- Guest info -->
            <div style="display:flex;align-items:center;gap:8px;margin-bottom:8px">
              ${ic('user',{size:18,w:2})}
              <span style="font-size:15px;font-weight:700">5 dewasa, 2 anak (3 tahun, 4 tahun)</span>
            </div>
            <div style="display:flex;align-items:center;gap:8px;margin-bottom:8px">
              ${ic('bed2',{size:18,w:2})}
              <span style="font-size:15px;font-weight:700">2 queen bed</span>
            </div>
            <div style="display:flex;align-items:flex-start;gap:8px;margin-bottom:16px">
              ${ic('food',{size:18,w:2})}
              <div>
                <span style="font-size:15px;font-weight:700">Sarapan untuk 2 tamu per kamar per malam</span>
                <div style="font-size:13px;color:${T.primary};font-weight:700;text-decoration:underline">Detail makanan</div>
              </div>
            </div>
            <!-- Info Tamu -->
            <div style="font-size:18px;font-weight:800;margin-bottom:12px">Info Tamu</div>
            <div style="display:flex;align-items:center;gap:8px;margin-bottom:8px">
              ${ic('user',{size:18,w:2})}
              <span style="font-size:14px;font-weight:700">Tea Wan</span>
            </div>
            <div style="display:flex;align-items:center;gap:8px;margin-bottom:16px">
              ${ic('phone',{size:18,w:2})}
              <span style="font-size:14px;color:${T.text}">62-0858****3846</span>
            </div>
            <div style="display:flex;align-items:center;gap:8px;margin-bottom:16px">
              ${ic('mail',{size:18,w:2})}
              <span style="font-size:14px;color:${T.text}">mohba******gorie@gmail.com</span>
            </div>
            <!-- Reward -->
            <div style="font-size:18px;font-weight:800;margin-bottom:12px">Reward &amp; Benefit</div>
            <div style="display:flex;align-items:center;gap:8px">
              ${ic('coin',{size:20,w:2,fill:T.primary})}
              <span style="font-size:14px;font-weight:700">Trip Coins</span>
            </div>
          </div>

          <!-- PART 4: Reward & Benefit + Customer Service -->
          <div style="padding:16px;border-bottom:8px solid ${T.bgSurface}">
            <div style="display:flex;align-items:center;gap:8px;margin-bottom:10px">
              ${ic('coin',{size:20,w:2,fill:T.primary})}
              <span style="font-size:16px;font-weight:700">Trip Coins</span>
            </div>
            <div style="font-size:14px;color:${T.primary};font-weight:700;margin-bottom:4px">Dapatkan 43 Trip Coins (≈Rp7.665)</div>
            <div style="font-size:12px;color:${T.textSub};margin-bottom:16px">Reward pemesanan hotel</div>
            <!-- Customer Service -->
            <div style="font-size:18px;font-weight:800;margin-bottom:12px">Layanan Pelanggan</div>
            <div style="display:flex;align-items:center;gap:8px;margin-bottom:16px">
              <div style="width:28px;height:28px;border-radius:50%;background:${T.teal};display:flex;align-items:center;justify-content:center;color:#fff">${ic('shield',{size:16,w:2,fill:'#fff'})}</div>
              <span style="font-size:14px;font-weight:700;color:${T.teal}">Bantuan global 30 detik</span>
            </div>
            <!-- FAQ items -->
            ${[
              'Di mana saya bisa melihat informasi pemesanan?',
              'Bagaimana cara melihat fasilitas kamar yang disediakan?',
              'Bisakah saya mengisi data untuk orang lain ketika saya melakukan reservasi?'
            ].map((q,i)=>`
              <div style="display:flex;align-items:center;justify-content:space-between;padding:14px 0;border-bottom:1px solid ${T.borderLight}">
                <span style="font-size:14px;color:${T.text};flex:1">${q}</span>
                ${ic('chevR',{size:16,w:2})}
              </div>
            `).join('')}
            <!-- Rating -->
            <div style="font-size:16px;font-weight:700;margin-top:20px;margin-bottom:10px">Seberapa mungkin Anda merekomendasikan Trip.com ke teman atau rekan?</div>
            <div style="display:flex;justify-content:space-between;margin-bottom:4px">
              <span style="font-size:13px;color:${T.textSub}">Sangat tidak mungkin</span>
              <span style="font-size:13px;color:${T.textSub}">Sangat mungkin</span>
            </div>
            <div style="display:flex;gap:4px;margin-bottom:20px">
              ${Array.from({length:11},(_,i)=>`<div style="width:32px;height:36px;border-radius:4px;border:1.5px solid ${T.border};display:flex;align-items:center;justify-content:center;font-size:14px;font-weight:700;background:#fff">${i}</div>`).join('')}
            </div>
          </div>

          <!-- PART 5: Konfirmasi Pemesanan -->
          <div style="padding:16px">
            <div style="text-align:center;padding:8px 0 16px">
              <div style="font-size:13px;font-weight:700;color:${T.text};margin-bottom:2px">No. Pemesanan 1367843010567330</div>
              <div style="font-size:13px;color:${T.textSub}">PIN <span style="font-weight:700">*****</span> ${ic('chevD',{size:14,w:2})}</div>
            </div>
            <div style="display:flex;align-items:center;gap:8px;padding:12px 0;border-top:1px solid ${T.borderLight}">
              ${ic('info',{size:16,w:2})}
              <span style="font-size:14px;color:${T.text}">Bisakah saya mengisi data untuk orang lain ketika saya melakukan reservasi?</span>
            </div>
            <div style="display:flex;gap:8px;margin-top:16px;padding-top:16px;border-top:1px solid ${T.borderLight}">
              <span style="display:flex;align-items:center;gap:4px;font-size:12px;color:${T.teal};font-weight:600">${ic('heart',{size:14,w:2,fill:T.teal})} Kami Samakan Harga</span>
              <span style="display:flex;align-items:center;gap:4px;font-size:12px;color:${T.teal};font-weight:600">${ic('shield',{size:14,w:2,fill:T.teal})} Jaminan Menginap di Hotel</span>
            </div>
          </div>
        </div>
      </div>
      <!-- Bottom buttons -->
      <div style="display:flex;gap:10px;padding:12px 16px 20px;background:#fff;border-top:1px solid ${T.borderLight};flex:0 0 auto">
        <div style="flex:1;padding:14px;border-radius:${T.radius.btn}px;background:#d84315;color:#fff;text-align:center;font-size:16px;font-weight:700">Bayar</div>
        <div style="flex:1;padding:14px;border-radius:${T.radius.btn}px;background:${T.primary};color:#fff;text-align:center;font-size:16px;font-weight:700">Batalkan Pemesanan</div>
      </div>
    </div>`;
  },
};
