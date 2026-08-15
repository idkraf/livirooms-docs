// screens.mjs — aggregate all screen builders and provide page renderer
import { W, H, fontLink, baseCSS } from './helpers.mjs';
import { filterScreens } from './screens_filter.mjs';
import { resultScreens } from './screens_result.mjs';
import { detailScreens } from './screens_detail.mjs';
import { formScreens } from './screens_form.mjs';
import { bookingScreens } from './screens_booking.mjs';

export const SCREENS = {
  ...filterScreens,
  ...resultScreens,
  ...detailScreens,
  ...formScreens,
  ...bookingScreens,
};

export const OUT_NAME_MAP = {
  filter_location: 'filter_by_location_screen.png',
  filter_kamar_tamu: 'filter_by_kamar_dan_tamu.png',
  filter_kamar_tamu_bottom_modal_select_anak: 'filter_by_kamar_dan_tamu_bottom_modal_select_anak.png',
  result_pencarian: 'result_pencarian_hotel_screen.png',
  filter_kalendar: 'filter_by_tab_kalendar_screen.png',
  filter_kalendar_tanggal_flexibel: 'filter_by_tab_tanggal_flexibel_screen.png',
  result_pencarian_bottom_modal_filter: 'result_pencarian_hotel_screen_bottom_modal_filter.png',
  result_pencarian_bottom_modal_filter_urutkan: 'result_pencarian_hotel_screen_bottom_modal_filter_urutkan.png',
  result_pencarian_bottom_modal_filter_lokasi: 'result_pencarian_hotel_screen_bottom_modal_filter_lokasi.png',
  result_pencarian_bottom_modal_filter_kebutuhan: 'result_pencarian_hotel_screen_bottom_modal_filter_kebutuhan.png',
  result_pencarian_top_modal_filter_date_and_tamu: 'result_pencarian_hotel_screen_top_modal_filter_date_and_tamu.png',
  result_pencarian_top_modal_filter_date_and_tamu_kalendar: 'result_pencarian_hotel_screen_top_modal_filter_date_and_tamu_klik_1st_to_new_screen_with_tab_kalendar_screen.png',
  result_pencarian_top_modal_filter_date_and_tamu_tanggal_flexibel: 'result_pencarian_hotel_screen_top_modal_filter_date_and_tamu_klik_1st_to_new_screen_with_tab_tanggal_flexibel_screen.png',
  result_pencarian_top_modal_filter_date_and_tamu_2nd: 'result_pencarian_hotel_screen_top_modal_filter_date_and_tamu_klik_2nd.png',
  result_pencarian_top_modal_filter_date_and_tamu_2nd_bottom_modal_select_anak: 'result_pencarian_hotel_screen_top_modal_filter_date_and_tamu_klik_2nd_bottom_modal_select_anak.png',
  pesan_kamar_section: 'detail_hotel_screen_saat_mau_pilih_button_pesan_kamar.png',
  form_pesan_kamar: 'form_pesan_kamar.png',
  form_pengisian_kamar: 'form_pesan_kamar_form_pengisian_kamar.png',
  form_pengisian_kamar_scroll: 'form_pesan_kamar_form_pengisian_kamar_scroll.png',
  form_pesan_kamar_step1: 'form_pesan_kamar_1.png',
  form_pesan_kamar_step2: 'form_pesan_kamar_2.png',
  form_pesan_kamar_step3: 'form_pesan_kamar_3.png',
  bottom_sheet_informasi_tambahan: 'bottom_sheet_informasi_tambahan.png',
  room_detail_family_suite: 'room_detail_family_suite.png',
  room_detail_kamar_superior: 'room_detail_kamar_superior.png',
  bottom_sheet_kode_promo: 'bottom_sheet_kode_promo.png',
  bottom_sheet_permintaan: 'bottom_sheet_permintaan.png',
  booking_list_screen: 'booking_list_screen.png',
  booking_pembayaran_screen: 'booking_pembayaran_screen.png',
  booking_hotel_detail_screen: 'booking_hotel_detail_screen.png',
};

// Screen registry — order matches readme_screen.md Screen Registry table
export const SCREEN_LIST = [
  // Filter screens
  'filter_location',
  'filter_screen',
  'filter_kamar_tamu',
  'filter_kamar_tamu_bottom_modal_select_anak',
  'filter_kalendar',
  'filter_kalendar_tanggal_flexibel',
  // Result screens
  'result_pencarian',
  'result_pencarian_bottom_modal_filter',
  'result_pencarian_bottom_modal_filter_urutkan',
  'result_pencarian_bottom_modal_filter_lokasi',
  'result_pencarian_bottom_modal_filter_kebutuhan',
  'result_pencarian_top_modal_filter_date_and_tamu',
  'result_pencarian_top_modal_filter_date_and_tamu_kalendar',
  'result_pencarian_top_modal_filter_date_and_tamu_tanggal_flexibel',
  'result_pencarian_top_modal_filter_date_and_tamu_2nd',
  'result_pencarian_top_modal_filter_date_and_tamu_2nd_bottom_modal_select_anak',
  // Detail hotel screens
  'detail_hotel',
  'detail_tab_kamar',
  'detail_tab_ulasan',
  'detail_tab_lokasi',
  'detail_tab_fasilitas',
  'detail_tab_kebijakan',
  'detail_tab_keterangan',
  'detail_tab_trip_moments',
  'detail_tab_akomodasi_terdekat',
  // Booking flow
  'pesan_kamar_section',
  // Form screens (moved from screens_booking.mjs to screens_form.mjs)
  'sheet_pesan_kamar',
  'form_pengisian_kamar',
  'form_pengisian_kamar_scroll',
  'form_pesan_kamar_step1',
  'form_pesan_kamar_step2',
  'form_pesan_kamar_step3',
  'bottom_sheet_informasi_tambahan',
  'room_detail_family_suite',
  'room_detail_kamar_superior',
  'bottom_sheet_kode_promo',
  'bottom_sheet_permintaan',
  // Post-booking screens (Laravel API → Flutter)
  'booking_list_screen',
  'booking_pembayaran_screen',
  'booking_hotel_detail_screen',
];

export function renderPage(screenName) {
  const fn = SCREENS[screenName];
  if (!fn) throw new Error('No screen builder: ' + screenName);
  const inner = fn();
  return `<!doctype html><html lang="id"><head><meta charset="utf-8">
<meta name="viewport" content="width=${W},height=${H}">
${fontLink()}
<style>${baseCSS()}</style></head>
<body>${inner}</body></html>`;
}

export { W, H };
