// screens_detail.mjs — detail_hotel + all 8 tabs
import { ic, statusbar, topbar, tabBar, bottomBarPesan, T, scoreBadge, starRow, gradPhoto } from './helpers.mjs';
import { HOTEL, TABS, FACILITIES, TRANSPORT, NEARBY_HOTELS, ROOM_TYPES } from './lib.mjs';

// Shared action buttons overlay for hero
const heroActions = `
  <div style="position:absolute;top:0;left:0;right:0;display:flex;justify-content:space-between;align-items:center;padding:10px 14px">
    <div style="width:38px;height:38px;border-radius:50%;background:rgba(0,0,0,.5);display:flex;align-items:center;justify-content:center;color:#fff">${ic('arrowL', { size: 22, w: 2.5 })}</div>
    <div style="display:flex;gap:10px">
      <div style="width:38px;height:38px;border-radius:50%;background:rgba(0,0,0,.5);display:flex;align-items:center;justify-content:center;color:#fff">${ic('heart', { size: 20, w: 2 })}</div>
      <div style="width:38px;height:38px;border-radius:50%;background:rgba(0,0,0,.5);display:flex;align-items:center;justify-content:center;color:#fff">${ic('share', { size: 20, w: 2 })}</div>
    </div>
  </div>
  <div style="position:absolute;bottom:10px;right:12px;background:rgba(0,0,0,.6);color:#fff;padding:4px 10px;border-radius:8px;font-size:12px;font-weight:600;display:flex;align-items:center;gap:5px">
    ${ic('camera', { size: 13, w: 2 })} 1/43
  </div>`;

// Reusable detail topbar (with tabs)
function detailTopbar(activeTab = 0) {
  return `
    ${topbar({
      title: HOTEL.name,
      back: true,
      subtitle: activeTab === 0 ? `${HOTEL.checkin}–${HOTEL.checkout} ∨` : '',
      right: `<div style="display:flex;gap:10px;color:${T.textSub}">
        ${ic('heart', { size: 22, w: 2 })}
        ${ic('share', { size: 22, w: 2 })}
      </div>`,
    })}
    ${tabBar(TABS, activeTab)}`;
}

export const detailScreens = {

  // 7. Detail Hotel (Scroll Awal / Overview)
  detail_hotel() {
    return `<div class="screen">
      ${statusbar()}
      <!-- Hero image -->
      <div style="position:relative;flex:0 0 210px">
        ${gradPhoto({ h: 210, grad: 'linear-gradient(160deg,#1a2a6c,#b21f1f,#fdbb2d)', radius: 0 })}
        ${heroActions}
      </div>
      <div class="body">
        <div class="scroll" style="padding:0">
          <!-- Hotel name & stars -->
          <div style="padding:16px 16px 12px;border-bottom:1px solid ${T.borderLight}">
            <h1 style="font-size:22px;font-weight:800;margin-bottom:6px">${HOTEL.name}</h1>
            <div style="display:flex;align-items:center;gap:8px;margin-bottom:10px">
              <div style="display:flex;gap:2px">${starRow(HOTEL.stars)}</div>
              <span style="font-size:13px;color:${T.textSub}">Dibuka tahun ${HOTEL.openYear}</span>
            </div>
            <div style="font-size:13px;line-height:1.6;color:${T.textSub};margin-bottom:6px">${HOTEL.address}</div>
            <span style="font-size:13px;font-weight:600;color:${T.primary};text-decoration:underline">Lihat di Peta</span>
          </div>
          <!-- Score -->
          <div style="padding:14px 16px;border-bottom:1px solid ${T.borderLight}">
            ${scoreBadge(HOTEL.score, HOTEL.scoreLabel, HOTEL.reviewCount)}
            <div style="font-size:13px;color:${T.textSub};margin-top:8px">${HOTEL.reviews.join(' ')}</div>
          </div>
          <!-- Fasilitas Keluarga -->
          <div style="padding:14px 16px;border-bottom:1px solid ${T.borderLight}">
            <div style="font-size:16px;font-weight:700;margin-bottom:10px">Fasilitas untuk Keluarga 🧡</div>
            <div style="display:grid;grid-template-columns:1fr 1fr;gap:8px">
              ${[['home', 'Kamar Keluarga'], ['child', 'Aktivitas untuk anak'], ['home', 'Suite'], ['location', 'Lokasi strategis']].map(([icon, lbl]) =>
                `<div style="display:flex;align-items:center;gap:8px;font-size:13px">
                  ${ic(icon, { size: 18, w: 2 })} ${lbl}
                </div>`
              ).join('')}
            </div>
          </div>
          <!-- Lokasi Strategis -->
          <div style="padding:14px 16px">
            <div style="font-size:16px;font-weight:700;margin-bottom:10px">Lokasi Strategis</div>
            ${[
              ['resize', 'Area komersial: Thamrin', '2,2km'],
              ['train', 'Stasiun kereta api: Gondangdia', '480m'],
              ['pin', 'Atraksi wisata: Masjid Cut Meutia', '420m'],
            ].map(([icon, name, dist]) =>
              `<div style="display:flex;align-items:center;gap:10px;padding:7px 0;font-size:13px">
                ${ic(icon, { size: 18, w: 2 })}
                <span style="flex:1">${name}</span>
                <span style="color:${T.textSub}">${dist}</span>
              </div>`
            ).join('')}
          </div>
        </div>
      </div>
      ${bottomBarPesan()}
    </div>`;
  },

  // 8. Tab Kamar
  detail_tab_kamar() {
    return `<div class="screen">
      ${statusbar()}
      ${detailTopbar(0)}
      <div class="body">
        <div class="scroll">
          <!-- Family Suite (expanded) -->
          <div style="padding:14px 0;border-bottom:8px solid ${T.bgSurface}">
            <div style="padding:0 16px">
              <div style="font-size:17px;font-weight:700;margin-bottom:10px">Family Suite</div>
              <div style="display:flex;flex-wrap:wrap;gap:10px;margin-bottom:10px">
                ${[[ic('bed2',{size:16,w:2}),'2 queen bed'],[ic('resize',{size:16,w:2}),'30 m²'],[ic('window',{size:16,w:2}),'Memiliki jendela']].map(([icon,lbl])=>
                  `<div style="display:flex;align-items:center;gap:5px;font-size:12px">${icon} ${lbl}</div>`
                ).join('')}
              </div>
              <div style="display:flex;flex-wrap:wrap;gap:10px">
                ${[[ic('nosmoke',{size:16,w:2}),'Bebas rokok'],[ic('wifi',{size:16,w:2}),'Wi-Fi gratis']].map(([icon,lbl])=>
                  `<div style="display:flex;align-items:center;gap:5px;font-size:12px">${icon} ${lbl}</div>`
                ).join('')}
              </div>
            </div>
            <div style="text-align:center;padding:14px;color:${T.primary};font-weight:700;font-size:14px;border-top:1px solid ${T.borderLight};margin-top:14px">Sembunyikan ∧</div>
          </div>
          <!-- Group recommendation -->
          <div style="padding:16px;border-bottom:8px solid ${T.bgSurface}">
            <div style="font-size:16px;font-weight:700;margin-bottom:6px">Tambahkan kamar untuk mengakomodasi grup Anda</div>
            <div style="font-size:13px;color:${T.textSub};line-height:1.6">Tipe kamar berikut tidak dapat mengakomodasi seluruh grup Anda. Pertimbangkan untuk memesan beberapa kamar sebagai alternatif.</div>
          </div>
          <!-- Kamar Superior card -->
          <div style="padding:16px;background:#fff">
            <!-- Room photos -->
            <div style="display:flex;gap:4px;height:120px;border-radius:${T.radius.card}px;overflow:hidden;margin-bottom:12px">
              ${gradPhoto({ h: 120, grad: 'linear-gradient(135deg,#c8a96e,#b8832a)', radius: 0 })}
              <div style="position:relative;width:80px;flex:0 0 80px">
                ${gradPhoto({ h: 120, grad: 'linear-gradient(135deg,#8d6e63,#6d4c41)', radius: 0 })}
                <div style="position:absolute;bottom:6px;right:6px;background:rgba(0,0,0,.6);color:#fff;padding:2px 7px;border-radius:6px;font-size:11px;display:flex;align-items:center;gap:4px">${ic('camera',{size:11,w:2})} 5</div>
              </div>
            </div>
            <div style="display:flex;align-items:center;gap:5px;font-size:16px;font-weight:700;margin-bottom:8px">Kamar Superior ${ic('chevR',{size:18,w:2.5})}</div>
            <div style="display:flex;flex-wrap:wrap;gap:8px;margin-bottom:6px">
              ${[[ic('bed2',{size:15,w:2}),'1 queen bed atau 2 single bed'],[ic('resize',{size:15,w:2}),'21 m²'],[ic('window',{size:15,w:2}),'Memiliki jendela'],[ic('nosmoke',{size:15,w:2}),'Bebas rokok'],[ic('wifi',{size:15,w:2}),'Wi-Fi gratis']].map(([icon,lbl])=>
                `<div style="display:flex;align-items:center;gap:5px;font-size:12px">${icon} ${lbl}</div>`
              ).join('')}
            </div>
            <div style="text-align:right;margin-top:10px">
              <span style="font-size:12px;color:${T.textSub};text-decoration:line-through">Rp415.089 </span>
              <span style="font-size:22px;font-weight:800;color:${T.primary}">Rp350.495</span>
            </div>
            <div style="text-align:center;color:${T.primary};font-size:13px;font-weight:700;margin-top:10px">Lihat harga lainnya (2) ∨</div>
          </div>
        </div>
      </div>
      ${bottomBarPesan()}
    </div>`;
  },

  // 9. Tab Ulasan / Pertanyaan Umum
  detail_tab_ulasan() {
    return `<div class="screen">
      ${statusbar()}
      ${detailTopbar(1)}
      <div class="body">
        <div class="scroll" style="padding:16px">
          <div style="font-size:17px;font-weight:700;margin-bottom:14px">Mungkin Anda ingin tahu</div>
          <!-- FAQ cards horizontal scroll -->
          <div style="display:flex;gap:12px;overflow:hidden;margin-bottom:16px">
            <div style="flex:0 0 80%;background:#fff;border:1.5px solid ${T.border};border-radius:${T.radius.card}px;padding:14px">
              <div style="font-size:14px;font-weight:700;margin-bottom:8px">Berapa biaya sarapan?</div>
              <div style="font-size:12px;color:${T.textSub};line-height:1.6;margin-bottom:12px">
                Info Kebijakan Sarapan:<br>Sarapan disediakan: Ya<br>Jam buka: Sen-Min 07:00–10:00...
              </div>
              <div style="display:flex;align-items:center;gap:8px">
                <div style="width:28px;height:28px;border-radius:50%;background:linear-gradient(135deg,#6366f1,#8b5cf6);flex:0 0 auto"></div>
                <span style="font-size:12px;color:${T.textSub}">Manager akomodasi</span>
              </div>
            </div>
            <div style="flex:0 0 15%;background:#fff;border:1.5px solid ${T.border};border-radius:${T.radius.card}px;padding:14px;opacity:.5">
              <div style="font-size:14px;font-weight:700">Baga...</div>
              <div style="font-size:12px;color:${T.textSub}">sara...</div>
            </div>
          </div>
          <div style="font-size:14px;font-weight:700;text-decoration:underline;margin-bottom:20px">Lihat Semua Pertanyaan</div>
          <!-- Masih ada pertanyaan -->
          <div style="margin-bottom:16px">
            <div style="font-size:17px;font-weight:700;margin-bottom:6px">Masih ada pertanyaan?</div>
            <div style="font-size:13px;color:${T.textSub};margin-bottom:14px">Dapatkan jawaban cepat untuk semua pertanyaan Anda</div>
            <div style="border:1.5px solid ${T.border};border-radius:${T.radius.field}px;padding:14px;display:flex;align-items:center;justify-content:center;gap:10px;font-size:14px;font-weight:700">
              ${ic('chat', { size: 20, w: 2 })} Ajukan pertanyaan
            </div>
          </div>
          <div style="font-size:17px;font-weight:700">Lokasi</div>
        </div>
      </div>
      ${bottomBarPesan()}
    </div>`;
  },

  // 10. Tab Lokasi
  detail_tab_lokasi() {
    return `<div class="screen">
      ${statusbar()}
      ${detailTopbar(3)}
      <div class="body">
        <div class="scroll" style="padding:16px">
          <div style="font-size:20px;font-weight:800;margin-bottom:10px">Lokasi</div>
          <div style="display:flex;align-items:center;gap:8px;margin-bottom:14px">
            <span style="font-size:22px;font-weight:800;color:${T.primary}">8,9</span>
            <span style="font-size:14px;font-weight:600">/10 Lokasi Strategis</span>
          </div>
          <!-- Map placeholder -->
          <div style="border-radius:${T.radius.card}px;overflow:hidden;margin-bottom:14px;border:1px solid ${T.border}">
            <div style="background:linear-gradient(135deg,#e8f4f8,#d4e8f0);height:180px;position:relative">
              <!-- Grid lines simulating map -->
              <div style="position:absolute;inset:0;opacity:.3">
                ${Array.from({length:8},(_,i)=>`<div style="position:absolute;left:${i*14}%;top:0;bottom:0;width:1px;background:#90caf9"></div>`).join('')}
                ${Array.from({length:6},(_,i)=>`<div style="position:absolute;top:${i*18}%;left:0;right:0;height:1px;background:#90caf9"></div>`).join('')}
              </div>
              <!-- Roads -->
              <div style="position:absolute;top:40%;left:0;right:0;height:6px;background:rgba(255,255,255,.8);border-radius:2px"></div>
              <div style="position:absolute;top:0;bottom:0;left:55%;width:5px;background:rgba(255,255,255,.8);border-radius:2px"></div>
              <!-- Pin -->
              <div style="position:absolute;top:35%;left:52%;transform:translate(-50%,-50%)">
                <div style="width:36px;height:36px;border-radius:50%;background:${T.primary};display:flex;align-items:center;justify-content:center;box-shadow:0 4px 12px rgba(41,98,255,.5)">
                  ${ic('bed2',{size:18,w:2,fill:'#fff'})}
                </div>
              </div>
              <!-- Labels -->
              <div style="position:absolute;bottom:6px;left:8px;font-size:9px;color:${T.textSub}">Google</div>
            </div>
          </div>
          <!-- Address -->
          <div style="font-size:13px;line-height:1.6;margin-bottom:14px;display:flex;align-items:flex-start;gap:8px">
            <span style="flex:1">${HOTEL.address}</span>
            ${ic('copy',{size:18,w:2})}
          </div>
          <!-- Filter chips -->
          <div style="display:flex;gap:8px;margin-bottom:14px">
            ${['Transportasi','Atraksi wisata','Belanja'].map((c,i)=>
              `<div style="padding:8px 14px;border-radius:${T.radius.chip}px;border:1.5px solid ${i===0?T.primary:T.border};color:${i===0?T.primary:T.text};font-size:13px;font-weight:600">${c}</div>`
            ).join('')}
          </div>
          <!-- Transport list -->
          ${TRANSPORT.map(t=>`
            <div style="display:flex;align-items:flex-start;gap:10px;padding:10px 0;border-bottom:1px solid ${T.borderLight}">
              ${ic(t.icon,{size:20,w:2})}
              <div style="flex:1;min-width:0">
                <span style="font-size:14px;font-weight:600">${t.name}</span>
                <span style="font-size:12px;color:${T.textSub};margin-left:6px">${t.type}</span>
              </div>
              <span style="font-size:13px;font-weight:600;flex:0 0 auto">${t.dist}</span>
            </div>`
          ).join('')}
          <div style="font-size:14px;font-weight:700;text-decoration:underline;padding:14px 0">Tampilkan semua area sekitar</div>
        </div>
      </div>
      ${bottomBarPesan()}
    </div>`;
  },

  // 11. Tab Fasilitas
  detail_tab_fasilitas() {
    return `<div class="screen">
      ${statusbar()}
      ${detailTopbar(4)}
      <div class="body">
        <div class="scroll" style="padding:16px">
          <div style="font-size:18px;font-weight:700;margin-bottom:14px">Layanan &amp; fasilitas</div>
          <!-- Facility photos grid -->
          <div style="display:grid;grid-template-columns:1fr 1fr;gap:8px;margin-bottom:20px">
            ${[
              { grad:'linear-gradient(135deg,#29b6f6,#0288d1)', label:'Kolam Renang Out... (2)' },
              { grad:'linear-gradient(135deg,#b0bec5,#78909c)', label:'Ruang pertemuan (11)' },
            ].map(f=>`
              <div style="border-radius:${T.radius.sm}px;overflow:hidden;position:relative">
                ${gradPhoto({h:90,grad:f.grad,radius:T.radius.sm})}
                <div style="position:absolute;bottom:0;left:0;right:0;background:linear-gradient(transparent,rgba(0,0,0,.6));padding:6px 8px;color:#fff;font-size:10px;font-weight:700">${f.label}</div>
              </div>`
            ).join('')}
          </div>
          <!-- Facility categories -->
          ${FACILITIES.map(cat=>`
            <div style="margin-bottom:18px">
              <div style="display:flex;align-items:center;gap:10px;margin-bottom:10px;font-size:16px;font-weight:700">
                ${ic(cat.icon,{size:22,w:2})} ${cat.title}
              </div>
              ${cat.items.map(([name,available,badge])=>`
                <div style="padding:6px 0 6px 32px;display:flex;align-items:center;gap:8px">
                  <span style="font-size:14px;color:${available?T.text:T.textDisabled};text-decoration:${available?'none':'line-through'}">${name}</span>
                  ${badge?`<span style="padding:2px 8px;background:#e0f2f1;color:#00897b;font-size:11px;font-weight:700;border-radius:10px">${badge}</span>`:''}
                </div>`
              ).join('')}
            </div>`
          ).join('')}
          <div style="font-size:14px;font-weight:700;text-decoration:underline;padding:4px 0 16px">Tampilkan semua fasilitas</div>
        </div>
      </div>
      ${bottomBarPesan()}
    </div>`;
  },

  // 12. Tab Kebijakan
  detail_tab_kebijakan() {
    return `<div class="screen">
      ${statusbar()}
      ${detailTopbar(5)}
      <div class="body">
        <div class="scroll" style="padding:16px">
          <div style="font-size:18px;font-weight:700;margin-bottom:18px">Kebijakan akomodasi</div>
          <!-- Check-in/out -->
          <div style="margin-bottom:20px">
            <div style="display:flex;align-items:center;gap:10px;font-size:16px;font-weight:700;margin-bottom:12px">
              ${ic('clock',{size:22,w:2})} Check-in/Check-out
            </div>
            <div style="background:${T.bgSurface};border-radius:${T.radius.field}px;padding:14px;margin-bottom:10px">
              <div style="font-size:14px;margin-bottom:4px">Check-in: Setelah 14:00</div>
              <div style="font-size:14px">Waktu check-out: Sebelum 12:00</div>
            </div>
            <div style="font-size:13px;color:${T.textSub};margin-bottom:6px">Jam kerja resepsionis: 24 jam</div>
            <div style="font-size:13px;line-height:1.6">Tamu utama yang check-in harus berusia minimal 18 tahun.</div>
          </div>
          <!-- Kebijakan anak -->
          <div style="margin-bottom:20px">
            <div style="display:flex;align-items:center;gap:10px;font-size:16px;font-weight:700;margin-bottom:12px">
              ${ic('child',{size:22,w:2})} Kebijakan tamu anak
            </div>
            <div style="font-size:13px;line-height:1.6;margin-bottom:10px">Anak-anak dari segala usia dapat menginap di akomodasi ini.</div>
            <div style="font-size:13px;line-height:1.6;margin-bottom:12px">Kami telah merekomendasikan tipe kamar ramah anak untuk Anda. Biayanya tergantung pada harga kamar. Harap pastikan bahwa jumlah dan usia anak dalam kata kunci pencarian sudah benar.</div>
            <div style="background:${T.bgSurface};border-radius:${T.radius.field}px;padding:14px;display:flex;align-items:center;justify-content:space-between">
              <div>
                <div style="font-size:13px;margin-bottom:3px">Jumlah tamu: 5 dewasa, 2 anak</div>
                <div style="font-size:13px">Anak: 0 tahun &amp; 4 tahun</div>
              </div>
              <span style="font-size:14px;font-weight:700;text-decoration:underline">Ubah</span>
            </div>
          </div>
          <!-- Ranjang -->
          <div>
            <div style="display:flex;align-items:center;gap:10px;font-size:16px;font-weight:700;margin-bottom:12px">
              ${ic('bed2',{size:22,w:2})} Ranjang bayi dan tempat tidur tambahan
            </div>
            <div style="font-size:13px;color:${T.textSub};line-height:1.6">Kebijakan tempat tidur tambahan dan ranjang bayi dapat bervariasi sesuai dengan tipe kamar.</div>
          </div>
        </div>
      </div>
      ${bottomBarPesan()}
    </div>`;
  },

  // 13. Tab Keterangan
  detail_tab_keterangan() {
    return `<div class="screen">
      ${statusbar()}
      ${detailTopbar(6)}
      <div class="body">
        <div class="scroll" style="padding:16px">
          <div style="font-size:18px;font-weight:700;margin-bottom:10px">Deskripsi akomodasi</div>
          <div style="font-size:13px;color:${T.textSub};margin-bottom:8px">Buka: ${HOTEL.openYear}</div>
          <div style="font-size:13px;line-height:1.7;color:${T.text};margin-bottom:8px">
            Dengan menginap di Grand Cemara Hotel, Anda akan berada di pusat kota Jakarta, hanya 5 menit dengan berkendara dari Bundaran HI dan Grand Indonesia. Hotel ini berada 5,3 mi (8,5 km) dari Blok M Square dan 1,5 mi (2,4 km) dari Pusat Perbelanjaan Thamrin City....
          </div>
          <div style="font-size:14px;font-weight:700;text-decoration:underline;margin-bottom:20px;display:flex;align-items:center;gap:5px">Tampilkan deskripsi lengkap ${ic('chevD',{size:16,w:2})}</div>
          <!-- Trip Moments / UGC Card -->
          <div style="font-size:18px;font-weight:700;margin-bottom:14px">Ide Untuk Tempat Menginap Anda</div>
          <div style="border:1.5px solid ${T.border};border-radius:${T.radius.card}px;overflow:hidden">
            <!-- Photo grid -->
            <div style="display:flex;height:160px">
              ${gradPhoto({h:160,grad:'linear-gradient(135deg,#90a4ae,#607d8b)',radius:0})}
              <div style="width:120px;flex:0 0 120px;display:flex;flex-direction:column;gap:4px;margin-left:4px">
                ${gradPhoto({h:77,grad:'linear-gradient(135deg,#ffcc02,#ff9800)',radius:0})}
                ${gradPhoto({h:77,grad:'linear-gradient(135deg,#c8a96e,#a67c52)',radius:0})}
              </div>
            </div>
            <!-- Text content -->
            <div style="padding:12px">
              <div style="font-size:14px;font-weight:700;margin-bottom:6px">Hidden Gem Hotel di Gading Serpong!</div>
              <div style="font-size:12px;color:${T.textSub};line-height:1.5">
                #fotohotellokal  Lagi cari hotel nyaman di Gading Serpong buat staycation singkat ataupun trip baren...
              </div>
              <div style="display:flex;align-items:center;gap:8px;margin-top:10px">
                <div style="width:24px;height:24px;border-radius:50%;background:linear-gradient(135deg,#667eea,#764ba2)"></div>
                <span style="font-size:12px;color:${T.textSub}">itslxyx</span>
              </div>
            </div>
          </div>
        </div>
      </div>
      ${bottomBarPesan()}
    </div>`;
  },

  // 14. Tab Trip Moments
  detail_tab_trip_moments() {
    return `<div class="screen">
      ${statusbar()}
      ${detailTopbar(7)}
      <div class="body">
        <div class="scroll" style="padding:16px">
          <!-- UGC full card -->
          <div style="font-size:18px;font-weight:700;margin-bottom:14px">Ide Untuk Tempat Menginap Anda</div>
          <div style="border:1.5px solid ${T.border};border-radius:${T.radius.card}px;overflow:hidden;margin-bottom:20px">
            <div style="display:flex;height:160px">
              ${gradPhoto({h:160,grad:'linear-gradient(135deg,#90a4ae,#607d8b)',radius:0})}
              <div style="width:120px;flex:0 0 120px;display:flex;flex-direction:column;gap:4px;margin-left:4px">
                ${gradPhoto({h:77,grad:'linear-gradient(135deg,#ffcc02,#ff9800)',radius:0})}
                ${gradPhoto({h:77,grad:'linear-gradient(135deg,#c8a96e,#a67c52)',radius:0})}
              </div>
            </div>
            <div style="padding:12px">
              <div style="font-size:14px;font-weight:700;margin-bottom:6px">Hidden Gem Hotel di Gading Serpong!</div>
              <div style="font-size:12px;color:${T.textSub};line-height:1.5">#fotohotellokal  Lagi cari hotel nyaman di Gading Serpong buat staycation singkat ataupun trip baren...</div>
              <div style="display:flex;align-items:center;justify-content:space-between;margin-top:10px">
                <div style="display:flex;align-items:center;gap:8px">
                  <div style="width:28px;height:28px;border-radius:50%;background:linear-gradient(135deg,#667eea,#764ba2)"></div>
                  <span style="font-size:12px;font-weight:600">itslxyx</span>
                </div>
                <div style="display:flex;align-items:center;gap:5px;color:${T.textSub};font-size:12px">👍 45</div>
              </div>
            </div>
          </div>
          <!-- Nearby hotels horizontal -->
          <div style="font-size:18px;font-weight:700;margin-bottom:14px">Anda mungkin juga menyukai</div>
          <div style="display:flex;gap:12px;overflow:hidden">
            ${NEARBY_HOTELS.map((h,i)=>`
              <div style="flex:0 0 170px;border:1.5px solid ${T.border};border-radius:${T.radius.card}px;overflow:hidden">
                ${gradPhoto({h:100,grad:`linear-gradient(135deg,${['#c8a96e','#6366f1'][i]},${['#8d6e63','#8b5cf6'][i]})`,radius:0})}
                <div style="padding:10px">
                  <div style="font-size:13px;font-weight:700;margin-bottom:4px">${h.name}</div>
                  <div style="display:flex;gap:2px;margin-bottom:4px">${starRow(h.stars)}</div>
                  <div style="background:${T.scoreBg};color:#fff;display:inline-block;padding:2px 7px;border-radius:4px;font-size:11px;font-weight:700;margin-bottom:4px">${h.score}/10</div>
                  <span style="font-size:11px;color:${T.textSub};margin-left:4px">${h.reviews} ulasan</span>
                  <div style="font-size:11px;color:${T.textSub};margin-bottom:6px">${h.dist} dari akomodasi yang dicari</div>
                  <div style="font-size:14px;font-weight:800;color:${T.primary}">${h.price}</div>
                </div>
              </div>`
            ).join('')}
          </div>
        </div>
      </div>
      ${bottomBarPesan()}
    </div>`;
  },

  // 15. Tab Akomodasi Terdekat
  detail_tab_akomodasi_terdekat() {
    return `<div class="screen">
      ${statusbar()}
      ${detailTopbar(8)}
      <div class="body">
        <div class="scroll" style="padding:16px">
          <!-- Nearby hotels -->
          <div style="font-size:18px;font-weight:700;margin-bottom:14px">Anda mungkin juga menyukai</div>
          <div style="display:flex;gap:12px;overflow:hidden;margin-bottom:24px">
            ${NEARBY_HOTELS.map((h,i)=>`
              <div style="flex:0 0 170px;border:1.5px solid ${T.border};border-radius:${T.radius.card}px;overflow:hidden">
                ${gradPhoto({h:100,grad:`linear-gradient(135deg,${['#c8a96e','#6366f1'][i]},${['#8d6e63','#8b5cf6'][i]})`,radius:0})}
                <div style="padding:10px">
                  <div style="font-size:13px;font-weight:700;margin-bottom:4px">${h.name}</div>
                  <div style="display:flex;gap:2px;margin-bottom:4px">${starRow(h.stars)}</div>
                  <div style="background:${T.scoreBg};color:#fff;display:inline-block;padding:2px 7px;border-radius:4px;font-size:11px;font-weight:700;margin-bottom:4px">${h.score}/10</div>
                  <span style="font-size:11px;color:${T.textSub};margin-left:4px">${h.reviews} ulasan</span>
                  <div style="font-size:11px;color:${T.textSub};margin-bottom:6px">${h.dist} dari akomodasi yang dicari (jarak garis l...</div>
                  <div style="font-size:15px;font-weight:800;color:${T.primary}">${h.price}</div>
                </div>
              </div>`
            ).join('')}
          </div>
          <!-- Mengapa Pesan -->
          <div style="font-size:18px;font-weight:700;margin-bottom:16px">Mengapa Pesan di Trip.com?</div>
          ${[
            ['heart', 'Kami Samakan Harga', 'Kami ingin menawarkan harga terbaik untuk Anda. Jika Anda menemukan harga yang lebih murah di tempat lain, kami akan memberikan refund atas selisih harga yang memenuhi syarat berupa Trip Coins.'],
            ['coin', 'Dapatkan reward saat bepergian', 'Dapatkan reward untuk menghemat uang tiap kali Anda memesan, tanpa batasan cara menggunakannya.'],
          ].map(([icon, title, desc])=>`
            <div style="display:flex;align-items:flex-start;gap:12px;margin-bottom:16px">
              <div style="width:36px;height:36px;border-radius:50%;background:${T.bgSurface2};display:flex;align-items:center;justify-content:center;flex:0 0 36px;color:${T.primary}">
                ${ic(icon,{size:20,w:2})}
              </div>
              <div>
                <div style="font-size:15px;font-weight:700;margin-bottom:5px">${title}</div>
                <div style="font-size:13px;color:${T.textSub};line-height:1.6">${desc}</div>
              </div>
            </div>`
          ).join('')}
        </div>
      </div>
      ${bottomBarPesan()}
    </div>`;
  },
};
