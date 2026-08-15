// lib.mjs — icon set & shared demo content for hotel screens
// Feather-style inline SVG icons + constants

const P = {
  home:    '<path d="M3 11l9-8 9 8"/><path d="M5 10v10h5v-6h4v6h5V10"/>',
  arrowL:  '<path d="M15 6l-6 6 6 6"/>',
  arrowR:  '<path d="M9 6l6 6-6 6"/>',
  chevD:   '<path d="M6 9l6 6 6-6"/>',
  chevU:   '<path d="M18 15l-6-6-6 6"/>',
  chevR:   '<path d="M9 6l6 6-6 6"/>',
  search:  '<circle cx="11" cy="11" r="7"/><path d="M20 20l-4-4"/>',
  filter:  '<path d="M3 5h18l-7 8v6l-4-2v-4z"/>',
  sort:    '<path d="M4 6h16M7 12h10M10 18h4"/>',
  pin:     '<path d="M12 21s7-6 7-11a7 7 0 0 0-14 0c0 5 7 11 7 11z"/><circle cx="12" cy="10" r="2.5"/>',
  location:'<path d="M12 2a7 7 0 0 0-7 7c0 5 7 13 7 13s7-8 7-13a7 7 0 0 0-7-7z"/><circle cx="12" cy="9" r="2.5"/>',
  heart:   '<path d="M12 20s-7-4.5-7-10a4 4 0 0 1 7-2.5A4 4 0 0 1 19 10c0 5.5-7 10-7 10z"/>',
  share:   '<circle cx="18" cy="5" r="3"/><circle cx="6" cy="12" r="3"/><circle cx="18" cy="19" r="3"/><path d="M8.59 13.51l6.83 3.98M15.41 6.51l-6.82 3.98"/>',
  star:    '<path d="M12 3l2.7 5.5 6 .9-4.3 4.2 1 6-5.4-2.8-5.4 2.8 1-6L3.3 9.4l6-.9z"/>',
  map:     '<polygon points="1,6 1,22 8,18 16,22 23,18 23,2 16,6 8,2"/><line x1="8" y1="2" x2="8" y2="18"/><line x1="16" y1="6" x2="16" y2="22"/>',
  camera:  '<path d="M4 8a2 2 0 0 1 2-2h1l1.5-2h7L18 6h0a2 2 0 0 1 2 2v9a2 2 0 0 1-2 2H6a2 2 0 0 1-2-2z"/><circle cx="12" cy="12.5" r="3.5"/>',
  wifi:    '<path d="M5 12.55a11 11 0 0 1 14.08 0"/><path d="M1.42 9a16 16 0 0 1 21.16 0"/><path d="M8.53 16.11a6 16 0 0 1 6.95 0"/><circle cx="12" cy="20" r="1" fill="currentColor"/>',
  nosmoke: '<circle cx="12" cy="12" r="9"/><path d="M2 2l20 20"/><path d="M9 8h5a2 2 0 0 1 2 2v2"/><path d="M7 16h10v-2"/>',
  window:  '<rect x="3" y="3" width="18" height="18" rx="2"/><path d="M3 9h18M9 3v18"/>',
  bed:     '<path d="M2 4v16M2 8h20v4H2M22 20V8M6 8V4M18 8V4"/><path d="M6 12h4v4H6zM14 12h4v4h-4z"/>',
  bed2:    '<path d="M3 7v13M21 7v13M3 14h18M3 7a4 4 0 0 1 4-4h10a4 4 0 0 1 4 4"/>',
  resize:  '<path d="M15 3h6v6M9 21H3v-6M21 3l-7 7M3 21l7-7"/>',
  pool:    '<path d="M2 12c.5-1 1.5-2 3-2s2.5 1 3 2 1.5 2 3 2 2.5-1 3-2 1.5-2 3-2 2.5 1 3 2"/><path d="M2 17c.5-1 1.5-2 3-2s2.5 1 3 2 1.5 2 3 2 2.5-1 3-2 1.5-2 3-2 2.5 1 3 2"/>',
  car:     '<rect x="1" y="3" width="15" height="13" rx="2"/><path d="M16 8h4l3 5v4h-7V8zM5.5 20a1.5 1.5 0 1 0 0-3 1.5 1.5 0 0 0 0 3zM18.5 20a1.5 1.5 0 1 0 0-3 1.5 1.5 0 0 0 0 3z"/>',
  food:    '<path d="M18 8h1a4 4 0 0 1 0 8h-1"/><path d="M2 8h16v9a4 4 0 0 1-4 4H6a4 4 0 0 1-4-4V8z"/><line x1="6" y1="1" x2="6" y2="4"/><line x1="10" y1="1" x2="10" y2="4"/><line x1="14" y1="1" x2="14" y2="4"/>',
  gym:     '<path d="M18 8h1a2 2 0 0 1 0 4h-1M5 8H4a2 2 0 0 0 0 4h1M8 4v16M16 4v16"/><rect x="8" y="8" width="8" height="8" rx="1"/>',
  clock:   '<circle cx="12" cy="12" r="9"/><path d="M12 7v5l3 2"/>',
  child:   '<circle cx="12" cy="8" r="3"/><path d="M12 13c-4 0-7 2-7 4v1h14v-1c0-2-3-4-7-4z"/>',
  user:    '<circle cx="12" cy="8" r="4"/><path d="M4 21c0-4 4-6 8-6s8 2 8 6"/>',
  check:   '<path d="M4 12l5 5L20 6"/>',
  info:    '<circle cx="12" cy="12" r="9"/><path d="M12 11v5M12 8h.01"/>',
  close:   '<path d="M18 6 6 18M6 6l12 12"/>',
  coin:    '<circle cx="12" cy="12" r="9"/><path d="M9.5 8.5A3.5 3.5 0 0 1 15.5 12a3.5 3.5 0 0 1-6 2.5M12 6v1m0 10v1"/>',
  train:   '<rect x="4" y="3" width="16" height="14" rx="2"/><path d="M4 11h16M8 3v8m8-8v8M7 19l-1 2m12-2 1 2"/><circle cx="9" cy="14" r="1"/><circle cx="15" cy="14" r="1"/>',
  metro:   '<rect x="3" y="3" width="18" height="14" rx="2"/><path d="M3 10h18M8 3v7m8-7v7"/><circle cx="8" cy="14" r="1"/><circle cx="16" cy="14" r="1"/><path d="M8 17l-2 4m10-4 2 4"/>',
  bus:     '<path d="M8 6v2M16 6v2M4 6h16a2 2 0 0 1 2 2v10H2V8a2 2 0 0 1 2-2z"/><path d="M2 16h20"/><circle cx="7" cy="18" r="2"/><circle cx="17" cy="18" r="2"/>',
  plane:   '<path d="M21 16v-2l-8-5V3.5a1.5 1.5 0 0 0-3 0V9l-8 5v2l8-2.5V19l-2 1.5V22l3.5-1 3.5 1v-1.5L13 19v-5.5l8 2.5z"/>',
  shield:  '<path d="M12 3l7 3v6c0 4.5-3 7.5-7 9-4-1.5-7-4.5-7-9V6z"/><path d="M9 12l2 2 4-4"/>',
  minus:   '<path d="M5 12h14"/>',
  plus:    '<path d="M12 5v14M5 12h14"/>',
  edit:    '<path d="M4 20h4L18 10l-4-4L4 16z"/><path d="M13 5l4 4"/>',
  copy:    '<rect x="9" y="9" width="13" height="13" rx="2"/><path d="M5 15H4a2 2 0 0 1-2-2V4a2 2 0 0 1 2-2h9a2 2 0 0 1 2 2v1"/>',
  chat:    '<path d="M4 5a2 2 0 0 1 2-2h12a2 2 0 0 1 2 2v9a2 2 0 0 1-2 2H9l-4 4v-4H6a2 2 0 0 1-2-2z"/>',
  percent: '<path d="M19 5 5 19"/><circle cx="6.5" cy="6.5" r="2.5"/><circle cx="17.5" cy="17.5" r="2.5"/>',
  spa:     '<path d="M12 2C6 2 2 6 2 12s4 10 10 10 10-4 10-10S18 2 12 2z"/><path d="M12 12c-2-4 0-8 4-8-2 4 0 8-4 8zm0 0c2-4 0-8-4-8 2 4 0 8 4 8z"/>',
  billiard:'<circle cx="12" cy="12" r="9"/><circle cx="9" cy="10" r="2"/><circle cx="15" cy="10" r="2"/><circle cx="12" cy="16" r="2"/>',
  massage: '<path d="M12 2a4 4 0 0 1 4 4v2a4 4 0 0 1-8 0V6a4 4 0 0 1 4-4z"/><path d="M8 14s0 6 4 6 4-6 4-6"/><path d="M4 20c0-4 2-6 4-7"/>',
  calendar:'<rect x="3" y="4" width="18" height="18" rx="2"/><path d="M3 9h18M8 2v4M16 2v4M3 10h18"/>',
  cal:'<rect x="3" y="4" width="18" height="18" rx="2"/><path d="M3 9h18M8 2v4M16 2v4M3 10h18"/>',
  grid:'<rect x="3" y="3" width="7" height="7"/><rect x="14" y="3" width="7" height="7"/><rect x="3" y="14" width="7" height="7"/><rect x="14" y="14" width="7" height="7"/>',
  phone:'<path d="M22 16.92v3a2 2 0 0 1-2.18 2 19.79 19.79 0 0 1-8.63-3.07 19.5 19.5 0 0 1-6-6 19.79 19.79 0 0 1-3.07-8.67A2 2 0 0 1 4.11 2h3a2 2 0 0 1 2 1.72c.127.96.361 1.903.7 2.81a2 2 0 0 1-.45 2.11L8.09 9.91a16 16 0 0 0 6 6l1.27-1.27a2 2 0 0 1 2.11-.45c.907.339 1.85.573 2.81.7A2 2 0 0 1 22 16.92z"/>',
  mail:'<path d="M4 4h16c1.1 0 2 .9 2 2v12c0 1.1-.9 2-2 2H4c-1.1 0-2-.9-2-2V6c0-1.1.9-2 2-2z"/><polyline points="22,6 12,13 2,6"/>',
  luggage: '<rect x="6" y="7" width="12" height="14" rx="2"/><path d="M9 7V5a3 3 0 0 1 6 0v2M6 14h12"/>',
  bookmark:'<path d="M19 21l-7-5-7 5V5a2 2 0 0 1 2-2h10a2 2 0 0 1 2 2z"/>',
};

export function ic(name, { size = 22, w = 2, fill = 'none' } = {}) {
  return `<svg viewBox="0 0 24 24" width="${size}" height="${size}" fill="${fill}" stroke="currentColor" stroke-width="${w}" stroke-linecap="round" stroke-linejoin="round" style="display:block;flex-shrink:0">${P[name] || ''}</svg>`;
}

// ---------------------------------------------------------------------------
// Hotel demo data
// ---------------------------------------------------------------------------
export const HOTEL = {
  name: 'Grand Cemara Hotel',
  stars: 3,
  openYear: 1994,
  address: 'Jl. Cemara No.1 5, RT.5/RW.3, Gondangdia, Kec. Menteng, Jakarta Pusat, 10350',
  score: '8,1',
  scoreLabel: 'Luar Biasa',
  reviewCount: '371',
  reviews: ['"Berlokasi di pusat kota"', '"Harga sesuai kualitas"'],
  pricePerNight: 'Rp446.637',
  priceOriginal: 'Rp541.790',
  priceFull: 'Rp1.089.796',
  checkin: '15 Agt',
  checkout: '16 Agt',
  nights: '1 malam',
  rooms: 2,
  adults: 5,
  children: 2,
};

export const TABS = ['Kamar', 'Ulasan', 'Pertanyaan Umum', 'Lokasi', 'Fasilitas', 'Kebijakan', 'Keterangan', 'Trip Moments', 'Akomodasi Terdekat'];

export const HOTEL_LIST = [
  { name: 'Grand Cemara Hotel', stars: 3, score: '8,1', scoreLabel: 'Luar Biasa', reviews: 371, dist: '800m dari pusat kota', tags: ['Kamar Keluarga', 'Aktivitas untuk anak'], favCount: '1.549', price: 'Rp446.637', priceOri: 'Rp541.790', totalHarga: 'Rp1.089.796', desc: '2 kamar × 1 malam termasuk pajak & biaya lainnya', discount: true },
  { name: 'Amaris Hotel Pasar Baru', stars: 2, score: '7,4', scoreLabel: null, reviews: 26, dist: '2,4km dari pusat kota', tags: ['Termasuk sarapan', 'Disukai keluarga', 'Lokasi strategis'], favCount: '188', price: 'Rp337.795', priceOri: null, totalHarga: 'Rp1.648.436', desc: '4 kamar × 1 malam termasuk pajak', discount: false },
];

export const NEARBY_HOTELS = [
  { name: 'Hotel Alia Cikini', stars: 2, score: '8,4', reviews: 41, dist: '930m', price: 'Rp795.164' },
  { name: 'Keraton at The Plaza, The Unbound Collection', stars: 5, score: '9,6', reviews: 52, dist: '1km', price: 'Rp4.405.000' },
];

export const FACILITIES = [
  { icon: 'food',    title: 'Makanan & minuman', items: [['Minimarket/kios', true], ['Restoran', false], ['Bar lobi', true]] },
  { icon: 'pool',    title: 'Kolam Renang',       items: [['Kolam Renang Indoor', true], ['Kolam Renang Outdoor', true]] },
  { icon: 'car',     title: 'Transportasi',       items: [['Rental mobil', true], ['Area Parkir', true, 'Gratis'], ['Layanan mobil concierge', true]] },
  { icon: 'gym',     title: 'Kesehatan & kebugaran', items: [['Spa', true, 'Biaya tambahan']] },
];

export const TRANSPORT = [
  { icon: 'train', name: 'Gondangdia', type: 'Stasiun Kereta', dist: '480m' },
  { icon: 'train', name: 'Stasiun Gambir', type: 'Stasiun Kereta', dist: '1,5km' },
  { icon: 'metro', name: 'Bundaran HI Bank Jakarta', type: 'Stasiun Metro', dist: '1,3km' },
  { icon: 'metro', name: 'Dukuh Atas BNI', type: 'Stasiun Metro', dist: '3,3km' },
  { icon: 'bus',   name: 'Monas', type: 'Stasiun bus jarak jauh', dist: '1,5km' },
  { icon: 'plane', name: 'Bandar Udara Internasional Halim Perdanakusuma', type: 'Bandara', dist: '14,7km' },
];

export const POPULAR_DESTINATIONS = [
  { name: 'Bali', grad: 'linear-gradient(135deg,#0ea5e9,#06b6d4)' },
  { name: 'Jakarta Pusat', grad: 'linear-gradient(135deg,#6366f1,#8b5cf6)' },
  { name: 'Jakarta Selatan', grad: 'linear-gradient(135deg,#f59e0b,#ef4444)' },
  { name: 'Kuala Lumpur', grad: 'linear-gradient(135deg,#10b981,#3b82f6)' },
  { name: 'Yogyakarta', grad: 'linear-gradient(135deg,#ec4899,#f97316)' },
  { name: 'Kecamatan Depok', grad: 'linear-gradient(135deg,#14b8a6,#22d3ee)' },
];

export const ROOM_TYPES = [
  { name: 'Family Suite', beds: '2 queen bed', size: '30 m²', window: true, noSmoke: true, wifi: true, priceOri: null, price: null },
  { name: 'Kamar Superior', beds: '1 queen bed atau 2 single bed', size: '21 m²', window: true, noSmoke: true, wifi: true, priceOri: 'Rp415.089', price: 'Rp350.495' },
];
