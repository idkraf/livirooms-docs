// screens_result.mjs — result_pencarian, result_pencarian_top_modal_filter_date_and_tamu (3-tab parent + full-screen tab contents)
import { ic, statusbar, topbar, T, starRow, scoreBadge, gradPhoto } from './helpers.mjs';
import { HOTEL_LIST } from './lib.mjs';

function hotelCard(h, i) {
  return `<div style="display:flex;gap:0;background:#fff;border-bottom:${i > 0 ? '0' : `8px solid ${T.bgSurface}`};margin-bottom:0">
    <!-- Image placeholder -->
    <div style="width:130px;flex:0 0 130px;position:relative">
      ${gradPhoto({ h: 165, grad: `linear-gradient(135deg,${['#667eea','#06b6d4'][i % 2]},${['#764ba2','#2962FF'][i % 2]})`, radius: 0 })}
      <!-- Favorite -->
      <div style="position:absolute;top:8px;right:8px;width:30px;height:30px;border-radius:50%;background:rgba(0,0,0,.3);display:flex;align-items:center;justify-content:center;color:#fff">${ic('heart', { size: 16, w: 2 })}</div>
    </div>
    <!-- Info -->
    <div style="flex:1;padding:12px 12px 12px 14px;min-width:0">
      <!-- Name + stars -->
      <div style="display:flex;align-items:flex-start;gap:6px;margin-bottom:5px;flex-wrap:wrap">
        <span style="font-size:14px;font-weight:700;flex:1;min-width:0">${h.name}</span>
        <div style="display:flex;gap:2px;flex:0 0 auto">${starRow(h.stars)}</div>
      </div>
      <!-- Score -->
      <div style="display:flex;align-items:center;gap:6px;margin-bottom:5px">
        <div style="background:${T.scoreBg};color:#fff;padding:2px 8px;border-radius:4px;font-size:12px;font-weight:700">${h.score}/10</div>
        ${h.scoreLabel ? `<span style="font-size:12px;font-weight:700">${h.scoreLabel}</span>` : ''}
        <span style="font-size:12px;color:${T.textSub}">${h.reviews} ulasan</span>
      </div>
      <!-- Distance -->
      <div style="font-size:12px;color:${T.textSub};margin-bottom:5px">${h.dist}</div>
      <!-- Tags -->
      <div style="display:flex;flex-direction:column;gap:2px;margin-bottom:6px">
        ${h.tags.map(t => `<span style="font-size:12px;font-weight:500;color:${T.teal}">${t}</span>`).join('')}
      </div>
      <!-- Favorites -->
      <div style="font-size:11px;color:${T.textSub};margin-bottom:8px">${h.favCount} orang menambahkan ke favorit</div>
      <!-- Price -->
      <div style="text-align:right">
        ${h.priceOri ? `<span style="font-size:11px;color:${T.textSub};text-decoration:line-through">${h.priceOri} </span>` : ''}
        <span style="font-size:18px;font-weight:800;color:${T.primary}">${h.price}</span>
        <div style="font-size:11px;color:${T.textSub}">Total harga: ${h.totalHarga}</div>
        <div style="font-size:10px;color:${T.textSub}">${h.desc}</div>
        ${h.discount ? `<div style="margin-top:4px;display:inline-block;padding:3px 10px;border-radius:10px;background:${T.discountBg};color:${T.discountText};font-size:11px;font-weight:700">Diskon Spesial</div>` : ''}
      </div>
    </div>
  </div>`;
}

function resultHeader() {
  return `<div style="display:flex;align-items:center;gap:10px;padding:10px 12px;background:#fff;border-bottom:1px solid ${T.borderLight}">
    ${ic('arrowL', { size: 22, w: 2.5 })}
    <div style="flex:1;background:${T.bgSurface};border-radius:${T.radius.field}px;padding:8px 12px">
      <div style="display:flex;align-items:center;gap:8px">
        <div>
          <div style="font-size:11px;font-weight:700">15 Agt</div>
          <div style="font-size:11px;font-weight:700">16 Agt</div>
        </div>
        <div style="width:1px;height:28px;background:${T.border}"></div>
        <span style="font-size:13px;font-weight:600">Jakarta Pusat, Indonesia</span>
        <div style="display:flex;align-items:center;gap:3px;margin-left:auto">
          <span style="font-size:10px;font-weight:700">¥/$</span>
          <span style="font-size:10px;font-weight:700">IDR</span>
        </div>
      </div>
    </div>
  </div>
  <!-- Filter chips -->
  <div style="display:flex;gap:8px;padding:10px 12px;background:#fff;border-bottom:1px solid ${T.borderLight};overflow:hidden">
    ${[['sort', 'Urutkan'], ['filter', 'Filter'], ['pin', 'Lokasi'], ['user', 'Kebutuhan']].map(([icon, lbl]) =>
      `<div style="display:flex;align-items:center;gap:5px;padding:7px 12px;border-radius:${T.radius.chip}px;border:1.5px solid ${T.border};font-size:13px;font-weight:600;white-space:nowrap">
        ${ic(icon, { size: 15, w: 2 })} ${lbl}
      </div>`
    ).join('')}
  </div>`;
}

function resultVariant(panelContent) {
  return `<div class="screen">
    ${statusbar()}
    ${resultHeader()}
    <div class="body">
      <div class="scroll" style="padding:0;background:${T.bgSurface}">
        <!-- Promo Banner -->
        <div style="margin:10px 12px;background:#fff;border-radius:${T.radius.card}px;padding:12px 14px;display:flex;align-items:center;gap:10px;box-shadow:${T.shadow}">
          <div style="width:30px;height:30px;border-radius:6px;background:${T.discountBg};display:flex;align-items:center;justify-content:center">${ic('percent', { size: 16, w: 2, fill: T.discountText })}</div>
          <div style="flex:1">
            <div style="font-size:14px;font-weight:700">Diskon hingga Rp393.750</div>
            <div style="font-size:12px;color:${T.textSub}">Promo Homestay Unggulan</div>
          </div>
          ${ic('chevR', { size: 18, w: 2 })}
        </div>
        <!-- Count -->
        <div style="padding:8px 16px;font-size:14px;font-weight:700">975 akomodasi ditemukan</div>
        <!-- Hotel Cards -->
        ${HOTEL_LIST.map((h, i) => `
          <div style="background:#fff;margin-bottom:10px;overflow:hidden">
            ${hotelCard(h, i)}
          </div>`).join('')}
      </div>
    </div>
    ${panelContent}
    <!-- Floating Bottom Bar -->
    <div style="position:absolute;bottom:20px;left:50%;transform:translateX(-50%);background:rgba(26,26,46,.88);border-radius:30px;padding:12px 24px;display:flex;gap:20px;align-items:center;color:#fff;font-weight:700;font-size:14px;z-index:20;backdrop-filter:blur(10px)">
      <div style="display:flex;align-items:center;gap:8px">${ic('pin', { size: 18, w: 2, fill: '#fff' })} Peta</div>
      <div style="width:1px;height:18px;background:rgba(255,255,255,.3)"></div>
      <div style="display:flex;align-items:center;gap:8px">${ic('heart', { size: 18, w: 2 })} Disimpan</div>
    </div>
  </div>`;
}

function topModalVariant(modalContent) {
  return `<div class="screen">
    ${statusbar()}
    ${resultHeader()}
    <div class="body">
      <div class="scroll" style="padding:0;background:${T.bgSurface}">
        <!-- Promo Banner -->
        <div style="margin:10px 12px;background:#fff;border-radius:${T.radius.card}px;padding:12px 14px;display:flex;align-items:center;gap:10px;box-shadow:${T.shadow}">
          <div style="width:30px;height:30px;border-radius:6px;background:${T.discountBg};display:flex;align-items:center;justify-content:center">${ic('percent', { size: 16, w: 2, fill: T.discountText })}</div>
          <div style="flex:1">
            <div style="font-size:14px;font-weight:700">Diskon hingga Rp393.750</div>
            <div style="font-size:12px;color:${T.textSub}">Promo Homestay Unggulan</div>
          </div>
          ${ic('chevR', { size: 18, w: 2 })}
        </div>
        <!-- Count -->
        <div style="padding:8px 16px;font-size:14px;font-weight:700">975 akomodasi ditemukan</div>
        <!-- Hotel Cards -->
        ${HOTEL_LIST.map((h, i) => `
          <div style="background:#fff;margin-bottom:10px;overflow:hidden">
            ${hotelCard(h, i)}
          </div>`).join('')}
      </div>
    </div>
    <!-- Dark overlay -->
    <div style="position:absolute;inset:0;background:rgba(0,0,0,.3);z-index:29"></div>
    <!-- Top Modal -->
    <div style="position:absolute;top:0;left:0;right:0;background:#fff;border-radius:0 0 20px 20px;max-height:85%;display:flex;flex-direction:column;overflow:hidden;z-index:30">
      ${modalContent}
    </div>
    <!-- Floating Bottom Bar -->
    <div style="position:absolute;bottom:20px;left:50%;transform:translateX(-50%);background:rgba(26,26,46,.88);border-radius:30px;padding:12px 24px;display:flex;gap:20px;align-items:center;color:#fff;font-weight:700;font-size:14px;z-index:20;backdrop-filter:blur(10px)">
      <div style="display:flex;align-items:center;gap:8px">${ic('pin', { size: 18, w: 2, fill: '#fff' })} Peta</div>
      <div style="width:1px;height:18px;background:rgba(255,255,255,.3)"></div>
      <div style="display:flex;align-items:center;gap:8px">${ic('heart', { size: 18, w: 2 })} Disimpan</div>
    </div>
  </div>`;
}

function bottomSheet(title, rightContent, content, footerContent = '') {
  return `<div style="position:absolute;inset:0;background:rgba(0,0,0,.3);z-index:29"></div>
    <div style="position:absolute;bottom:0;left:0;right:0;background:#fff;border-radius:20px 20px 0 0;max-height:70%;display:flex;flex-direction:column;z-index:30">
      <div style="width:36px;height:4px;background:#E0E0E0;border-radius:2px;margin:10px auto;flex:0 0 auto"></div>
      <div style="display:flex;align-items:center;justify-content:space-between;padding:12px 20px;border-bottom:1px solid ${T.borderLight};flex:0 0 auto">
        <span style="font-size:17px;font-weight:700">${title}</span>
        ${rightContent}
      </div>
      <div style="padding:20px;overflow:auto;flex:1">
        ${content}
      </div>
      ${footerContent ? `<div style="padding:12px 20px 20px;border-top:1px solid ${T.borderLight};flex:0 0 auto">${footerContent}</div>` : ''}
    </div>`;
}

function sortPanel() {
  const options = [
    { label: 'Rekomendasi', active: true },
    { label: 'Harga terendah', active: false },
    { label: 'Rating tertinggi', active: false },
    { label: 'Jarak terdekat', active: false },
  ];
  const content = options.map(opt => `
    <div style="display:flex;align-items:center;gap:12px;padding:14px 0;border-bottom:1px solid ${T.borderLight}">
      <div style="width:20px;height:20px;border-radius:50%;border:2px solid ${opt.active ? T.primary : T.border};display:flex;align-items:center;justify-content:center;background:${opt.active ? T.primary : 'transparent'};flex:0 0 auto">
        ${opt.active ? ic('check', { size: 12, w: 2.5, fill: '#fff' }) : ''}
      </div>
      <span style="font-size:15px;font-weight:${opt.active ? 700 : 400};color:${opt.active ? T.primary : T.text}">${opt.label}</span>
    </div>
  `).join('');
  return bottomSheet('Urutkan', ic('close', { size: 22, w: 2 }), content);
}

function lokasiPanel() {
  const content = `
    <div style="background:${T.bgSurface};border-radius:${T.radius.field}px;padding:12px 16px;display:flex;align-items:center;gap:8px;margin-bottom:16px">
      ${ic('search', { size: 18, w: 2 })}
      <span style="font-size:14px;color:${T.textSub}">Cari lokasi</span>
    </div>
    <div style="font-size:15px;font-weight:700;margin-bottom:12px">Populer</div>
    ${['Jakarta Pusat', 'Jakarta Selatan', 'Bali', 'Kuala Lumpur', 'Yogyakarta'].map(loc => `
      <div style="display:flex;align-items:center;gap:10px;padding:10px 0;border-bottom:1px solid ${T.borderLight}">
        ${ic('pin', { size: 18, w: 2 })}
        <span style="font-size:14px;font-weight:500">${loc}</span>
      </div>
    `).join('')}
  `;
  return bottomSheet('Filter Lokasi', ic('close', { size: 22, w: 2 }), content);
}

function filterPanel() {
  const content = `
    <div style="font-size:15px;font-weight:700;margin-bottom:12px">Harga (untuk 1 malam)</div>
    <div style="background:${T.bgSurface};border-radius:${T.radius.field}px;padding:14px 16px;margin-bottom:16px">
      <div style="display:flex;justify-content:space-between;align-items:center">
        <span style="font-size:13px;color:${T.textSub}">Harga per kamar per malam</span>
        ${ic('chevD', { size: 18, w: 2 })}
      </div>
    </div>
    <div style="height:4px;background:${T.border};border-radius:2px;margin-bottom:16px;position:relative">
      <div style="position:absolute;left:0;right:60%;height:100%;background:${T.primary};border-radius:2px"></div>
    </div>
    <div style="font-size:15px;font-weight:700;margin-bottom:12px">Bintang</div>
    ${[5, 4, 3, 2].map(s => `
      <div style="display:flex;align-items:center;gap:12px;padding:10px 0;border-bottom:1px solid ${T.borderLight}">
        <div style="width:20px;height:20px;border-radius:4px;border:1.5px solid ${T.border};display:flex;align-items:center;justify-content:center">${ic('check', { size: 14, w: 2.5, fill: 'none' })}</div>
        <div style="display:flex;gap:3px;align-items:center">
          ${Array.from({ length: s }, () => ic('star', { size: 18, w: 0, fill: T.star })).join('')}
        </div>
      </div>
    `).join('')}
  `;
  const footer = `<div class="btn btn-primary">Lihat Hasil (900+)</div>`;
  return bottomSheet('Filter',
    `<div style="display:flex;gap:12px;align-items:center">
      <span style="font-size:14px;color:${T.textSub};font-weight:600">Reset</span>
      ${ic('close', { size: 22, w: 2 })}
    </div>`,
    content,
    footer
  );
}

function kebutuhanPanel() {
  const needs = ['Termasuk sarapan', 'Kolam renang', 'Parkir gratis', 'Wi-Fi gratis', 'Spa', 'Pusat kebugaran', 'Restoran', 'Bar lobi'];
  const content = `
    <div style="display:grid;grid-template-columns:1fr 1fr;gap:10px">
      ${needs.map((need, i) => `
        <div style="display:flex;align-items:center;gap:10px;padding:10px;border-radius:${T.radius.field}px;border:1.5px solid ${i < 2 ? T.primary : T.border};background:${i < 2 ? T.bgSurface2 : '#fff'}">
          <div style="width:20px;height:20px;border-radius:4px;border:1.5px solid ${i < 2 ? T.primary : T.border};display:flex;align-items:center;justify-content:center;background:${i < 2 ? T.primary : 'transparent'};flex:0 0 auto">
            ${i < 2 ? ic('check', { size: 14, w: 2.5, fill: '#fff' }) : ''}
          </div>
          <span style="font-size:13px;font-weight:${i < 2 ? 600 : 400};color:${i < 2 ? T.primary : T.text}">${need}</span>
        </div>
      `).join('')}
    </div>
  `;
  return bottomSheet('Kebutuhan', ic('close', { size: 22, w: 2 }), content);
}

// 11. Top Modal Filter Date & Tamu — summary widget (tap fields opens full-screen sub-pages)
function topDateTamuPanel() {
  return topModalVariant(`
    <div style="padding:16px;background:#fff">
      <!-- Duration summary -->
      <div style="font-size:20px;font-weight:800;margin-bottom:16px">1 malam antara Agt dan Okt</div>
      <!-- Guest summary -->
      <div style="display:flex;align-items:center;gap:8px;padding:14px 0;border-bottom:1px solid ${T.borderLight};margin-bottom:16px">
        <span style="font-size:18px;font-weight:800">2 kamar</span>
        <span style="font-size:18px;font-weight:800">5 dewasa</span>
        <span style="font-size:18px;font-weight:800">2 anak</span>
      </div>
      <!-- Cari button — triggers Laravel API filter -->
      <div class="btn btn-primary" style="font-size:16px">Cari</div>
    </div>
  `, 0);
}

// 11a. Full-screen Kalender (2-Tab) — matches filter_by_tab_kalendar_screen.png
function topDateTamuPanelKalender() {
  const days = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];
  const dates = Array.from({length: 31}, (_, i) => i + 1);
  const selectedDates = new Set([15, 16]);
  return `<div class="screen">
    ${statusbar()}
    ${topbar({ title: 'Pilih Tanggal', back: true })}
    <div style="display:flex;align-items:center;justify-content:space-around;padding:10px 0;background:#fff;border-bottom:1px solid ${T.borderLight};flex:0 0 auto">
      <span style="font-size:16px;font-weight:700;color:${T.primary};position:relative">
        Kalender
        <div style="position:absolute;bottom:-10px,left:0,right:0,height:2.5px,background:${T.primary},border-radius:2px"></div>
      </span>
      <span style="font-size:16px;font-weight:700;color:${T.textSub}">Tanggal Fleksibel</span>
    </div>
    <div class="body">
      <div class="scroll" style="padding:16px;background:#fff">
        <div style="display:flex;align-items:center;justify-content:space-between;margin-bottom:16px">
          <div style="width:36px;height:36px;border-radius:50%;background:${T.bgSurface};display:flex;align-items:center;justify-content:center">${ic('arrowL', { size: 20, w: 2.5 })}</div>
          <div style="font-size:17px;font-weight:700">Agustus 2026</div>
          <div style="width:36px;height:36px;border-radius:50%;background:${T.bgSurface};display:flex;align-items:center;justify-content:center">${ic('arrowR', { size: 20, w: 2.5 })}</div>
        </div>
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
      </div>
    </div>
    <div style="padding:12px 16px 20px;background:#fff;border-top:1px solid ${T.borderLight}">
      <div class="btn btn-primary">Selesai</div>
    </div>
  </div>`;
}

// 11b. Full-screen Tanggal Fleksibel (2-Tab) — matches filter_by_tab_tanggal_flexibel_screen.png
function topDateTamuPanelTanggalFleksibel() {
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
    <div style="display:flex;align-items:center;justify-content:space-around;padding:10px 0;background:#fff;border-bottom:1px solid ${T.borderLight};flex:0 0 auto">
      <span style="font-size:16px;font-weight:700;color:${T.textSub}">Kalender</span>
      <span style="font-size:16px;font-weight:700;color:${T.primary};position:relative">
        Tanggal Fleksibel
        <div style="position:absolute;bottom:-10px,left:0,right:0,height:2.5px,background:${T.primary},border-radius:2px"></div>
      </span>
    </div>
    <div class="body">
      <div class="scroll" style="padding:16px;background:#fff">
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
      </div>
    </div>
    <div style="padding:0 16px 16px;background:#fff">
      <div style="padding:14px 0;font-size:15px;font-weight:700;border-top:1px solid ${T.borderLight}">1 malam antara Agt dan Okt</div>
      <div class="btn btn-primary" style="font-size:16px">Konfirmasi (1 malam)</div>
    </div>
  </div>`;
}

// 11c. Full-screen Kamar & Tamu — matches filter_by_kamar_dan_tamu.png
function topDateTamuPanel2nd() {
  return `<div class="screen">
    ${statusbar()}
    ${topbar({ title: 'Kamar dan Tamu', back: true })}
    <div class="body">
      <div style="padding:0 16px;background:#fff">
        <div style="display:flex;align-items:center;justify-content:space-between;padding:14px 0;border-bottom:1px solid ${T.borderLight}">
          <span style="font-size:14px;font-weight:500">Dewasa</span>
          <div style="display:flex;align-items:center;gap:16px">
            <div style="width:32px;height:32px;border-radius:50%;border:1.5px solid ${T.primary};display:flex;align-items:center;justify-content:center;color:${T.primary}">${ic('minus', { size: 16, w: 2.5 })}</div>
            <span style="font-size:18px;font-weight:700;min-width:20px;text-align:center">2</span>
            <div style="width:32px;height:32px;border-radius:50%;background:${T.primary};display:flex;align-items:center;justify-content:center;color:#fff">${ic('plus', { size: 16, w: 2.5 })}</div>
          </div>
        </div>
        <div style="display:flex;align-items:center;justify-content:space-between;padding:14px 0;border-bottom:1px solid ${T.borderLight}">
          <span style="font-size:14px;font-weight:500">Anak</span>
          <div style="display:flex;align-items:center;gap:16px">
            <div style="width:32px;height:32px;border-radius:50%;border:1.5px solid ${T.border};display:flex;align-items:center;justify-content:center;color:${T.textSub}">${ic('minus', { size: 16, w: 2.5 })}</div>
            <span style="font-size:18px;font-weight:700;min-width:20px;text-align:center">2</span>
            <div style="width:32px;height:32px;border-radius:50%;background:${T.primary};display:flex;align-items:center;justify-content:center;color:#fff">${ic('plus', { size: 16, w: 2.5 })}</div>
          </div>
        </div>
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
      <div style="background:${T.bgSurface};padding:16px;flex:1">
        <div style="font-size:13px;color:${T.textSub};line-height:1.6">
          <div style="display:flex;gap:8px;margin-bottom:8px"><span>·</span><span>Harap konfirmasi jumlah anak dan usianya. Ini akan membantu kami menemukan tipe kamar dan diskon yang paling sesuai dengan kebutuhan Anda.</span></div>
          <div style="display:flex;gap:8px"><span>·</span><span>Jika ada lebih banyak tamu, pertimbangkan untuk menambah kamar</span></div>
        </div>
      </div>
    </div>
    <div style="padding:12px 16px 20px;background:#fff;border-top:1px solid ${T.borderLight}">
      <div class="btn btn-primary" style="font-size:16px">Selesai</div>
    </div>
  </div>`;
}

// 11d. Bottom Modal Select Anak — matches filter_by_kamar_dan_tamu_bottom_modal_select_anak.png
function topDateTamuPanel2ndBottomModalSelectAnak() {
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
}

export const resultScreens = {

  // 5. Hasil Pencarian Hotel
  result_pencarian() {
    return `<div class="screen">
      ${statusbar()}
      <!-- Search Topbar -->
      <div style="display:flex;align-items:center;gap:10px;padding:10px 12px;background:#fff;border-bottom:1px solid ${T.borderLight}">
        ${ic('arrowL', { size: 22, w: 2.5 })}
        <div style="flex:1;background:${T.bgSurface};border-radius:${T.radius.field}px;padding:8px 12px">
          <div style="display:flex;align-items:center;gap:8px">
            <div>
              <div style="font-size:11px;font-weight:700">15 Agt</div>
              <div style="font-size:11px;font-weight:700">16 Agt</div>
            </div>
            <div style="width:1px;height:28px;background:${T.border}"></div>
            <span style="font-size:13px;font-weight:600">Jakarta Pusat, Indonesia</span>
            <div style="display:flex;align-items:center;gap:3px;margin-left:auto">
              <span style="font-size:10px;font-weight:700">¥/$</span>
              <span style="font-size:10px;font-weight:700">IDR</span>
            </div>
          </div>
        </div>
      </div>
      <!-- Filter chips -->
      <div style="display:flex;gap:8px;padding:10px 12px;background:#fff;border-bottom:1px solid ${T.borderLight};overflow:hidden">
        ${[['sort', 'Urutkan'], ['filter', 'Filter'], ['pin', 'Lokasi'], ['user', 'Kebutuhan']].map(([icon, lbl]) =>
          `<div style="display:flex;align-items:center;gap:5px;padding:7px 12px;border-radius:${T.radius.chip}px;border:1.5px solid ${T.border};font-size:13px;font-weight:600;white-space:nowrap">
            ${ic(icon, { size: 15, w: 2 })} ${lbl}
          </div>`
        ).join('')}
      </div>
      <div class="body">
        <div class="scroll" style="padding:0;background:${T.bgSurface}">
          <!-- Promo Banner -->
          <div style="margin:10px 12px;background:#fff;border-radius:${T.radius.card}px;padding:12px 14px;display:flex;align-items:center;gap:10px;box-shadow:${T.shadow}">
            <div style="width:30px;height:30px;border-radius:6px;background:${T.discountBg};display:flex;align-items:center;justify-content:center">${ic('percent', { size: 16, w: 2, fill: T.discountText })}</div>
            <div style="flex:1">
              <div style="font-size:14px;font-weight:700">Diskon hingga Rp393.750</div>
              <div style="font-size:12px;color:${T.textSub}">Promo Homestay Unggulan</div>
            </div>
            ${ic('chevR', { size: 18, w: 2 })}
          </div>
          <!-- Count -->
          <div style="padding:8px 16px;font-size:14px;font-weight:700">975 akomodasi ditemukan</div>
          <!-- Hotel Cards -->
          ${HOTEL_LIST.map((h, i) => `
            <div style="background:#fff;margin-bottom:10px;overflow:hidden">
              ${hotelCard(h, i)}
            </div>`).join('')}
        </div>
      </div>
      <!-- Floating Bottom Bar -->
      <div style="position:absolute;bottom:20px;left:50%;transform:translateX(-50%);background:rgba(26,26,46,.88);border-radius:30px;padding:12px 24px;display:flex;gap:20px;align-items:center;color:#fff;font-weight:700;font-size:14px;z-index:20;backdrop-filter:blur(10px)">
        <div style="display:flex;align-items:center;gap:8px">${ic('pin', { size: 18, w: 2, fill: '#fff' })} Peta</div>
        <div style="width:1px;height:18px;background:rgba(255,255,255,.3)"></div>
        <div style="display:flex;align-items:center;gap:8px">${ic('heart', { size: 18, w: 2 })} Disimpan</div>
      </div>
    </div>`;
  },

  // 11. Hasil Pencarian — Top Modal Filter Date & Tamu (summary widget + Cari → Laravel API)
  result_pencarian_top_modal_filter_date_and_tamu() {
    return topDateTamuPanel();
  },

  // 12. Tab 1 → Full Screen Kalender (2-Tab sub-header)
  result_pencarian_top_modal_filter_date_and_tamu_kalendar() {
    return topDateTamuPanelKalender();
  },

  // 13. Tab 3 → Full Screen Tanggal Fleksibel (2-Tab sub-header)
  result_pencarian_top_modal_filter_date_and_tamu_tanggal_flexibel() {
    return topDateTamuPanelTanggalFleksibel();
  },

  // 14. Tab 2 → Full Screen Kamar & Tamu (stepper)
  result_pencarian_top_modal_filter_date_and_tamu_2nd() {
    return topDateTamuPanel2nd();
  },

  // 15. Tab 2 → Bottom Modal Select Anak
  result_pencarian_top_modal_filter_date_and_tamu_2nd_bottom_modal_select_anak() {
    return resultVariant(topDateTamuPanel2ndBottomModalSelectAnak());
  },

  // 7. Hasil Pencarian — Bottom Modal Filter
  result_pencarian_bottom_modal_filter() {
    return resultVariant(filterPanel());
  },

  // 8. Hasil Pencarian — Bottom Modal Filter Urutkan
  result_pencarian_bottom_modal_filter_urutkan() {
    return resultVariant(sortPanel());
  },

  // 9. Hasil Pencarian — Bottom Modal Filter Lokasi
  result_pencarian_bottom_modal_filter_lokasi() {
    return resultVariant(lokasiPanel());
  },

  // 10. Hasil Pencarian — Bottom Modal Filter Kebutuhan
  result_pencarian_bottom_modal_filter_kebutuhan() {
    return resultVariant(kebutuhanPanel());
  },
};
