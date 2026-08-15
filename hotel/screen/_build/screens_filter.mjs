// screens_filter.mjs — filter_location, filter_screen, filter_kamar_tamu, filter_kalendar_screen
import { ic, statusbar, topbar, T, gradPhoto } from './helpers.mjs';
import { POPULAR_DESTINATIONS } from './lib.mjs';

function filter_kalendar_screen(activeTab = 0) {
  const days = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];
  const dates = Array.from({length: 31}, (_, i) => i + 1);
  const selectedDates = new Set([15, 16]);
  const durations = ['1 malam', '2 malam', '3 malam', '4 malam', '5 malam', '6 malam', '7 malam'];
  const months = [
    { name: 'Agt', year: 2026, selected: true },
    { name: 'Sep', year: 2026, selected: true },
    { name: 'Okt', year: 2026, selected: true },
    { name: 'Nov', year: 2026, selected: false },
  ];

  return `<div class="screen">
    ${statusbar()}
    ${topbar({ title: 'Pilih Tanggal', back: true })}
    <!-- 2-Tab Header -->
    <div style="display:flex;align-items:center;justify-content:space-around;padding:10px 0;background:#fff;border-bottom:1px solid ${T.borderLight};flex:0 0 auto">
      <span style="font-size:16px;font-weight:700;color:${activeTab === 0 ? T.primary : T.textSub};position:relative">
        Kalender
        ${activeTab === 0 ? `<div style="position:absolute;bottom:-10px;left:0;right:0;height:2.5px;background:${T.primary};border-radius:2px"></div>` : ''}
      </span>
      <span style="font-size:16px;font-weight:700;color:${activeTab === 1 ? T.primary : T.textSub};position:relative">
        Tanggal Fleksibel
        ${activeTab === 1 ? `<div style="position:absolute;bottom:-10px;left:0;right:0;height:2.5px;background:${T.primary};border-radius:2px"></div>` : ''}
      </span>
    </div>
    <div class="body">
      <div class="scroll" style="padding:16px;background:#fff">
        ${activeTab === 0 ? `
          <!-- Calendar Header -->
          <div style="display:flex;align-items:center;justify-content:space-between;margin-bottom:16px">
            <div style="width:36px;height:36px;border-radius:50%;background:${T.bgSurface};display:flex;align-items:center;justify-content:center">${ic('arrowL', { size: 20, w: 2.5 })}</div>
            <div style="font-size:17px;font-weight:700">Agustus 2026</div>
            <div style="width:36px;height:36px;border-radius:50%;background:${T.bgSurface};display:flex;align-items:center;justify-content:center">${ic('arrowR', { size: 20, w: 2.5 })}</div>
          </div>
          <!-- Calendar Grid -->
          <div style="display:grid;grid-template-columns:repeat(7,1fr);gap:4px;margin-bottom:8px">
            ${days.map(d => `<div style="text-align:center;font-size:13px;font-weight:600;color:${T.textSub}">${d}</div>`).join('')}
          </div>
          <div style="display:grid;grid-template-columns:repeat(7,1fr);gap:4px">
            ${Array.from({length: 5}, () => `<div></div>`).join('')}
            ${dates.map(d => {
              const isSelected = selectedDates.has(d);
              return `<div style="aspect-ratio:1;display:flex;align-items:center;justify-content:center;border-radius:50%;font-size:14px;font-weight:${isSelected ? 700 : 400};background:${isSelected ? T.primary : 'transparent'};color:${isSelected ? '#fff' : T.text}">${d}</div>`;
            }).join('')}
          </div>
        ` : `
          <!-- Tanggal Fleksibel Content -->
          <div style="font-size:18px;font-weight:700;margin-bottom:14px">Durasi menginap</div>
          <div style="display:grid;grid-template-columns:repeat(4,1fr);gap:10px;margin-bottom:20px">
            ${durations.map((d, i) => {
              const active = i === 0;
              return `<div style="padding:10px 0;border-radius:${T.radius.field}px;border:1.5px solid ${active ? T.primary : T.border};text-align:center;font-size:14px;font-weight:${active ? 700 : 400};color:${active ? T.primary : T.text};background:${active ? '#fff' : T.bgSurface}">${d}</div>`;
            }).join('')}
          </div>
          <div style="display:flex;align-items:center;gap:12px;margin-bottom:20px">
            <div style="width:20px;height:20px;border-radius:4px;border:1.5px solid ${T.border};flex:0 0 auto"></div>
            <span style="font-size:14px;font-weight:500">Termasuk hari Jumat</span>
          </div>
          <div style="display:flex;align-items:center;gap:12px;margin-bottom:24px">
            <div style="width:20px;height:20px;border-radius:4px;border:1.5px solid ${T.border};flex:0 0 auto"></div>
            <span style="font-size:14px;font-weight:500">Termasuk hari Sabtu</span>
          </div>
          <div style="font-size:18px;font-weight:700;margin-bottom:14px">Bulan</div>
          <div style="display:grid;grid-template-columns:repeat(4,1fr);gap:10px">
            ${months.map(m => {
              const active = m.selected;
              return `<div style="padding:14px 0;border-radius:${T.radius.field}px;border:1.5px solid ${active ? T.primary : T.border};text-align:center;background:${active ? '#fff' : T.bgSurface};position:relative">
                <div style="display:flex;justify-content:center;margin-bottom:8px;color:${active ? T.primary : T.text}">
                  ${active ? ic('check', { size: 24, w: 2.5, fill: T.primary }) : ic('calendar', { size: 24, w: 2 })}
                </div>
                <div style="font-size:15px;font-weight:700;color:${active ? T.primary : T.text}">${m.name}</div>
                <div style="font-size:13px;color:${T.textSub}">${m.year}</div>
                ${active ? `<div style="width:16px;height:16px;border-radius:50%;background:${T.primary};position:absolute;bottom:-4px;right:-4px"></div>` : ''}
              </div>`;
            }).join('')}
          </div>
        `}
      </div>
    </div>
    <div style="padding:0 16px 16px;background:#fff">
      <div style="padding:14px 0;font-size:15px;font-weight:700;border-top:1px solid ${T.borderLight}">1 malam antara Agt dan Okt</div>
      <div class="btn btn-primary" style="font-size:16px">${activeTab === 0 ? 'Selesai' : 'Konfirmasi (1 malam)'}</div>
    </div>
  </div>`;
}

export const filterScreens = {

  // 1. Filter Lokasi / Cari Destinasi
  filter_location() {
    const destinations = POPULAR_DESTINATIONS;
    return `<div class="screen">
      ${statusbar()}
      <div class="body">
        <!-- Topbar with search bar active -->
        <div style="display:flex;align-items:center;gap:10px;padding:10px 16px;border-bottom:1px solid ${T.borderLight}">
          <div style="width:34px;height:34px;border-radius:50%;background:${T.bgSurface};display:flex;align-items:center;justify-content:center">${ic('close', { size: 20 })}</div>
          <div style="flex:1;height:42px;border:1.5px solid ${T.primary};border-radius:${T.radius.field}px;display:flex;align-items:center;gap:10px;padding:0 14px;background:#fff">
            ${ic('search', { size: 18, w: 2 })}
            <span style="font-size:14px;color:${T.textSub}">Destinasi atau akomodasi</span>
          </div>
        </div>
        <!-- Lokasi saat ini -->
        <div style="padding:14px 16px;display:flex;align-items:center;gap:10px;border-bottom:1px solid ${T.borderLight}">
          ${ic('location', { size: 18, w: 2, fill: T.primary })}
          <span style="font-size:15px;font-weight:600;color:${T.primary}">Lokasi Saat Ini</span>
        </div>
        <!-- Pencarian Terakhir -->
        <div style="padding:16px 16px 8px">
          <div style="display:flex;justify-content:space-between;align-items:center;margin-bottom:10px">
            <span style="font-size:15px;font-weight:700">Pencarian Terakhir</span>
            <span style="font-size:13px;color:${T.primary};font-weight:600">Hapus</span>
          </div>
          <div style="display:flex;align-items:center;gap:12px;padding:12px 0;border-bottom:1px solid ${T.borderLight}">
            ${ic('clock', { size: 18, w: 2 })}
            <div style="flex:1">
              <div style="font-size:15px;font-weight:600">Kelapa Dua</div>
              <div style="font-size:12px;color:${T.textSub};margin-top:2px">15 Agt–16 Agt &nbsp;|&nbsp; 2 dewasa</div>
            </div>
            ${ic('chevR', { size: 18, w: 2 })}
          </div>
        </div>
        <!-- Destinasi Populer -->
        <div style="padding:16px 16px 0">
          <div style="font-size:16px;font-weight:700;margin-bottom:12px">Destinasi Populer</div>
          <div style="display:grid;grid-template-columns:1fr 1fr;gap:10px">
            ${destinations.map(d => `
              <div style="border-radius:${T.radius.card}px;overflow:hidden;position:relative">
                ${gradPhoto({ h: 90, grad: d.grad, radius: T.radius.card })}
                <div style="position:absolute;bottom:8px;left:10px;display:flex;align-items:center;gap:5px;color:#fff;font-size:13px;font-weight:700">
                  ${ic('pin', { size: 13, w: 2.5, fill: '#fff' })} ${d.name}
                </div>
              </div>`).join('')}
          </div>
        </div>
      </div>
    </div>`;
  },

  // 2. Filter Screen (Home Search)
  filter_screen() {
    return `<div class="screen" style="position:relative">
      ${statusbar(true)}
      <!-- Hero background -->
      <div style="position:absolute;inset:0;background:linear-gradient(160deg,#0ea5e9 0%,#2962FF 50%,#6366f1 100%);z-index:0"></div>
      <div style="position:absolute;inset:0;opacity:.18;background:radial-gradient(ellipse at 80% 20%,#fff 0,transparent 50%)"></div>
      <!-- Topbar overlay -->
      <div style="position:relative;z-index:10;display:flex;align-items:center;justify-content:space-between;padding:8px 16px">
        <div style="width:36px;height:36px;border-radius:50%;background:rgba(255,255,255,.22);display:flex;align-items:center;justify-content:center;color:#fff">${ic('arrowL', { size: 22, w: 2.5 })}</div>
        <div style="width:36px;height:36px;border-radius:50%;background:${T.primary};display:flex;align-items:center;justify-content:center;color:#fff;font-weight:800;font-size:14px">T</div>
        <div style="width:36px;height:36px;border-radius:50%;background:rgba(255,255,255,.22);display:flex;align-items:center;justify-content:center;color:#fff">${ic('billiard', { size: 20, w: 2 })}</div>
      </div>
      <!-- Title -->
      <div style="position:relative;z-index:10;padding:4px 20px 16px;color:#fff">
        <div style="font-size:28px;font-weight:800;line-height:1.15">Hotel &amp; Rumah<br>Liburan<span style="color:${T.star}">.</span></div>
      </div>
      <!-- Search Card -->
      <div style="position:relative;z-index:10;margin:0 12px;background:#fff;border-radius:16px;padding:16px;box-shadow:0 8px 30px rgba(0,0,0,.18)">
        <!-- Row 1: Lokasi -->
        <div style="display:flex;align-items:center;gap:10px;padding-bottom:12px;border-bottom:1px solid ${T.borderLight}">
          ${ic('search', { size: 20, w: 2, fill: 'none' })}
          <div style="flex:1">
            <div style="font-size:15px;font-weight:700">Jakarta Pusat</div>
            <div style="font-size:12px;color:${T.textSub}">Indonesia</div>
          </div>
          <div style="width:28px;height:28px;border-radius:50%;background:${T.bgSurface};display:flex;align-items:center;justify-content:center">${ic('close', { size: 14, w: 2.5 })}</div>
        </div>
        <!-- Row 2: Tanggal -->
        <div style="display:flex;align-items:center;gap:10px;padding:12px 0;border-bottom:1px solid ${T.borderLight}">
          ${ic('cal', { size: 20, w: 2 })}
          <div style="flex:1">
            <div style="font-size:14px;font-weight:700">Sab, 15 Agt – Min, 16 Agt</div>
          </div>
          <span style="font-size:12px;color:${T.textSub}">1 malam</span>
        </div>
        <!-- Row 3: Tamu -->
        <div style="display:flex;align-items:center;gap:10px;padding:12px 0;border-bottom:1px solid ${T.borderLight}">
          ${ic('user', { size: 20, w: 2 })}
          <div style="font-size:14px;font-weight:700">2 kamar &nbsp;·&nbsp; 5 dewasa &nbsp;·&nbsp; 2 anak</div>
        </div>
        <!-- Chips -->
        <div style="display:flex;gap:8px;overflow:hidden;padding:10px 0;border-bottom:1px solid ${T.borderLight}">
          ${['⇌ Filter', 'Termasuk Sarapan', '4 Bintang', 'Kolam re...'].map(c =>
            `<div class="chip" style="white-space:nowrap">${c}</div>`
          ).join('')}
        </div>
        <!-- Cari Button -->
        <div style="margin-top:12px">
          <div class="btn btn-primary" style="font-size:16px">Cari</div>
        </div>
      </div>
      <!-- Shortcuts -->
      <div style="position:relative;z-index:10;display:flex;justify-content:space-around;padding:16px 20px;background:#fff;margin-top:12px">
        ${[['heart', 'Disimpan'], ['bookmark', 'Pemesanan'], ['percent', 'Promo saya'], ['clock', 'Dilihat']].map(([icon, lbl]) =>
          `<div style="display:flex;flex-direction:column;align-items:center;gap:6px">
            <div style="width:52px;height:52px;border-radius:50%;background:${T.bgSurface};display:flex;align-items:center;justify-content:center;color:${T.primary}">${ic(icon, { size: 24, w: 2 })}</div>
            <span style="font-size:11px;font-weight:600;color:${T.textSub}">${lbl}</span>
          </div>`
        ).join('')}
      </div>
      <!-- Promo card -->
      <div style="position:relative;z-index:10;margin:0 12px 12px;background:#fff;border-radius:12px;padding:14px;box-shadow:${T.shadow};display:flex;align-items:flex-start;gap:12px">
        <div style="width:64px;height:64px;border-radius:8px;background:linear-gradient(135deg,#667eea,#764ba2);flex:0 0 auto"></div>
        <div style="flex:1">
          <div style="display:flex;justify-content:space-between">
            <div style="font-size:14px;font-weight:700">Pesan Akomodasi Ini</div>
            <div style="color:${T.textSub}">${ic('close', { size: 16, w: 2 })}</div>
          </div>
          <div style="font-size:12px;color:${T.textSub};margin-top:2px">Vega Hotel Gading Serpong</div>
          <div style="font-size:12px;color:${T.textSub}">Superior Double · 15 Agt – 16 Agt · 2 kamar</div>
          <div style="font-size:14px;font-weight:700;color:${T.primary};margin-top:4px">Rp1.083.218</div>
        </div>
      </div>
    </div>`;
  },

  // 3. Filter Kamar & Tamu
  filter_kamar_tamu() {
    const stepperRow = (label, value, minDisabled = false) => `
      <div style="display:flex;align-items:center;padding:16px 0;border-bottom:1px solid ${T.borderLight}">
        <span style="flex:1;font-size:15px;font-weight:500">${label}</span>
        <div style="display:flex;align-items:center;gap:16px">
          <div style="width:32px;height:32px;border-radius:50%;border:1.5px solid ${minDisabled ? T.border : T.primary};display:flex;align-items:center;justify-content:center;color:${minDisabled ? T.textSub : T.primary}">${ic('minus', { size: 16, w: 2.5 })}</div>
          <span style="font-size:18px;font-weight:700;min-width:20px;text-align:center">${value}</span>
          <div style="width:32px;height:32px;border-radius:50%;background:${T.primary};display:flex;align-items:center;justify-content:center;color:#fff">${ic('plus', { size: 16, w: 2.5 })}</div>
        </div>
      </div>`;

    return `<div class="screen">
      ${statusbar()}
      ${topbar({ title: 'Kamar dan Tamu', back: true })}
      <div class="body">
        <div style="padding:0 16px;background:#fff">
          ${stepperRow('Kamar', 1, true)}
          ${stepperRow('Dewasa', 2)}
          ${stepperRow('Anak', 2)}
        </div>
        <div style="background:${T.bgSurface};padding:14px 16px">
          <span style="font-size:13px;color:${T.textSub}">Usia anak pada saat check-in</span>
        </div>
        <div style="background:#fff">
          <div style="display:flex;align-items:center;justify-content:space-between;padding:14px 16px;border-bottom:1px solid ${T.borderLight}">
            <span style="font-size:14px;font-weight:500">Anak 1</span>
            <div style="display:flex;align-items:center;gap:6px;color:${T.primary}">
              <span style="font-size:13px">&lt;1 tahun</span>
              ${ic('chevR', { size: 16, w: 2 })}
            </div>
          </div>
          <div style="display:flex;align-items:center;justify-content:space-between;padding:14px 16px;border-bottom:1px solid ${T.borderLight}">
            <span style="font-size:14px;font-weight:500">Anak 2</span>
            <div style="display:flex;align-items:center;gap:6px;color:${T.primary}">
              <span style="font-size:13px">4 tahun</span>
              ${ic('chevR', { size: 16, w: 2 })}
            </div>
          </div>
        </div>
        <!-- Info box -->
        <div style="background:${T.bgSurface};padding:16px;flex:1">
          <div style="font-size:13px;color:${T.textSub};line-height:1.6">
            <div style="display:flex;gap:8px;margin-bottom:8px"><span>·</span><span>Harap konfirmasi jumlah anak dan usianya. Ini akan membantu kami menemukan tipe kamar dan diskon yang paling sesuai dengan kebutuhan Anda.</span></div>
            <div style="display:flex;gap:8px"><span>·</span><span>Jika ada lebih banyak tamu, pertimbangkan untuk menambah kamar</span></div>
          </div>
        </div>
      </div>
      <!-- Bottom -->
      <div style="padding:12px 16px 20px;background:#fff;border-top:1px solid ${T.borderLight}">
        <div class="btn btn-primary" style="font-size:16px">Selesai</div>
      </div>
    </div>`;
  },

  // 4. Filter Kamar & Tamu — Bottom Modal Pilih Anak
  filter_kamar_tamu_bottom_modal_select_anak() {
    const ageOptions = ['<1 tahun', '1 tahun', '2 tahun', '3 tahun', '4 tahun', '5 tahun', '6 tahun', '7 tahun', '8 tahun', '9 tahun', '10 tahun', '11 tahun', '12 tahun', '13 tahun', '14 tahun', '15 tahun', '16 tahun', '17 tahun'];

    return `<div class="screen">
      ${statusbar()}
      ${topbar({ title: 'Kamar dan Tamu', back: true })}
      <div class="body">
        <div style="padding:0 16px;background:#fff">
          <div style="display:flex;align-items:center;justify-content:space-between;padding:14px 0;border-bottom:1px solid ${T.borderLight}">
            <span style="font-size:14px;font-weight:500">Anak 1</span>
            <div style="display:flex;align-items:center;gap:6px;color:${T.primary}">
              <span style="font-size:13px">&lt;1 tahun</span>
              ${ic('chevR', { size: 16, w: 2 })}
            </div>
          </div>
          <div style="display:flex;align-items:center;justify-content:space-between;padding:14px 0;border-bottom:1px solid ${T.borderLight}">
            <span style="font-size:14px;font-weight:500">Anak 2</span>
            <div style="display:flex;align-items:center;gap:6px;color:${T.primary}">
              <span style="font-size:13px">4 tahun</span>
              ${ic('chevR', { size: 16, w: 2 })}
            </div>
          </div>
        </div>
        <div style="background:${T.bgSurface};padding:14px 16px">
          <span style="font-size:13px;color:${T.textSub}">Usia anak pada saat check-in</span>
        </div>
        <div style="background:#fff;padding:16px">
          <div style="font-size:15px;font-weight:700;margin-bottom:12px">Pilih usia anak</div>
          <div style="display:grid;grid-template-columns:repeat(3,1fr);gap:10px">
            ${ageOptions.map(age => `
              <div style="padding:10px 0;border-radius:${T.radius.field}px;border:1.5px solid ${T.border};text-align:center;font-size:13px;font-weight:500;color:${T.text};background:#fff">${age}</div>
            `).join('')}
          </div>
        </div>
      </div>
      <div style="padding:12px 16px 20px;background:#fff;border-top:1px solid ${T.borderLight}">
        <div class="btn btn-primary" style="font-size:16px">Selesai</div>
      </div>
    </div>`;
  },

  // 5. Filter Kalender (2-Tab: Kalender + Tanggal Fleksibel) — SATU screen dengan 2 tab
  filter_kalendar_screen(activeTab = 0) {
    const days = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];
    const dates = Array.from({length: 31}, (_, i) => i + 1);
    const selectedDates = new Set([15, 16]);
    const durations = ['1 malam', '2 malam', '3 malam', '4 malam', '5 malam', '6 malam', '7 malam'];
    const months = [
      { name: 'Agt', year: 2026, selected: true },
      { name: 'Sep', year: 2026, selected: true },
      { name: 'Okt', year: 2026, selected: true },
      { name: 'Nov', year: 2026, selected: false },
    ];

    return `<div class="screen">
      ${statusbar()}
      ${topbar({ title: 'Pilih Tanggal', back: true })}
      <!-- 2-Tab Header -->
      <div style="display:flex;align-items:center;justify-content:space-around;padding:10px 0;background:#fff;border-bottom:1px solid ${T.borderLight};flex:0 0 auto">
        <span style="font-size:16px;font-weight:700;color:${activeTab === 0 ? T.primary : T.textSub};position:relative">
          Kalender
          ${activeTab === 0 ? `<div style="position:absolute;bottom:-10px;left:0;right:0;height:2.5px;background:${T.primary};border-radius:2px"></div>` : ''}
        </span>
        <span style="font-size:16px;font-weight:700;color:${activeTab === 1 ? T.primary : T.textSub};position:relative">
          Tanggal Fleksibel
          ${activeTab === 1 ? `<div style="position:absolute;bottom:-10px;left:0;right:0;height:2.5px;background:${T.primary};border-radius:2px"></div>` : ''}
        </span>
      </div>
      <div class="body">
        <div class="scroll" style="padding:16px;background:#fff">
          ${activeTab === 0 ? `
            <!-- Calendar Header -->
            <div style="display:flex;align-items:center;justify-content:space-between;margin-bottom:16px">
              <div style="width:36px;height:36px;border-radius:50%;background:${T.bgSurface};display:flex;align-items:center;justify-content:center">${ic('arrowL', { size: 20, w: 2.5 })}</div>
              <div style="font-size:17px;font-weight:700">Agustus 2026</div>
              <div style="width:36px;height:36px;border-radius:50%;background:${T.bgSurface};display:flex;align-items:center;justify-content:center">${ic('arrowR', { size: 20, w: 2.5 })}</div>
            </div>
            <!-- Calendar Grid -->
            <div style="display:grid;grid-template-columns:repeat(7,1fr);gap:4px;margin-bottom:8px">
              ${days.map(d => `<div style="text-align:center;font-size:13px;font-weight:600;color:${T.textSub}">${d}</div>`).join('')}
            </div>
            <div style="display:grid;grid-template-columns:repeat(7,1fr);gap:4px">
              ${Array.from({length: 5}, () => `<div></div>`).join('')}
              ${dates.map(d => {
                const isSelected = selectedDates.has(d);
                return `<div style="aspect-ratio:1;display:flex;align-items:center;justify-content:center;border-radius:50%;font-size:14px;font-weight:${isSelected ? 700 : 400};background:${isSelected ? T.primary : 'transparent'};color:${isSelected ? '#fff' : T.text}">${d}</div>`;
              }).join('')}
            </div>
          ` : `
            <!-- Tanggal Fleksibel Content -->
            <div style="font-size:18px;font-weight:700;margin-bottom:14px">Durasi menginap</div>
            <div style="display:grid;grid-template-columns:repeat(4,1fr);gap:10px;margin-bottom:20px">
              ${durations.map((d, i) => {
                const active = i === 0;
                return `<div style="padding:10px 0;border-radius:${T.radius.field}px;border:1.5px solid ${active ? T.primary : T.border};text-align:center;font-size:14px;font-weight:${active ? 700 : 400};color:${active ? T.primary : T.text};background:${active ? '#fff' : T.bgSurface}">${d}</div>`;
              }).join('')}
            </div>
            <div style="display:flex;align-items:center;gap:12px;margin-bottom:20px">
              <div style="width:20px;height:20px;border-radius:4px;border:1.5px solid ${T.border};flex:0 0 auto"></div>
              <span style="font-size:14px;font-weight:500">Termasuk hari Jumat</span>
            </div>
            <div style="display:flex;align-items:center;gap:12px;margin-bottom:24px">
              <div style="width:20px;height:20px;border-radius:4px;border:1.5px solid ${T.border};flex:0 0 auto"></div>
              <span style="font-size:14px;font-weight:500">Termasuk hari Sabtu</span>
            </div>
            <div style="font-size:18px;font-weight:700;margin-bottom:14px">Bulan</div>
            <div style="display:grid;grid-template-columns:repeat(4,1fr);gap:10px">
              ${months.map(m => {
                const active = m.selected;
                return `<div style="padding:14px 0;border-radius:${T.radius.field}px;border:1.5px solid ${active ? T.primary : T.border};text-align:center;background:${active ? '#fff' : T.bgSurface};position:relative">
                  <div style="display:flex;justify-content:center;margin-bottom:8px;color:${active ? T.primary : T.text}">
                    ${active ? ic('check', { size: 24, w: 2.5, fill: T.primary }) : ic('calendar', { size: 24, w: 2 })}
                  </div>
                  <div style="font-size:15px;font-weight:700;color:${active ? T.primary : T.text}">${m.name}</div>
                  <div style="font-size:13px;color:${T.textSub}">${m.year}</div>
                  ${active ? `<div style="width:16px;height:16px;border-radius:50%;background:${T.primary};position:absolute;bottom:-4px;right:-4px"></div>` : ''}
                </div>`;
              }).join('')}
            </div>
          `}
        </div>
      </div>
      <div style="padding:0 16px 16px;background:#fff">
        <div style="padding:14px 0;font-size:15px;font-weight:700;border-top:1px solid ${T.borderLight}">1 malam antara Agt dan Okt</div>
        <div class="btn btn-primary" style="font-size:16px">${activeTab === 0 ? 'Selesai' : 'Konfirmasi (1 malam)'}</div>
      </div>
    </div>`;
  },

  // Tab aliases untuk filter_kalendar_screen
  filter_kalendar() {
    return filter_kalendar_screen(0);
  },

  filter_kalendar_tanggal_flexibel() {
    return filter_kalendar_screen(1);
  },
};
