import { W, H, renderPage, screenImage } from './helpers.mjs';

export const rincianUnitScreens = {
  tab_harian_1() {
    const img = screenImage('rincian_unit_screen/tab_harian_1.jpg');
    return renderPage('tab_harian_1', img, 'Rincian Unit Tab Harian 1');
  },
  tab_harian_2() {
    const img = screenImage('rincian_unit_screen/tab_harian_2.jpg');
    return renderPage('tab_harian_2', img, 'Rincian Unit Tab Harian 2');
  },
  tab_bulanan_1() {
    const img = screenImage('rincian_unit_screen/tab_bulanan_1.jpg');
    return renderPage('tab_bulanan_1', img, 'Rincian Unit Tab Bulanan 1');
  },
  tab_bulanan_2() {
    const img = screenImage('rincian_unit_screen/tab_bulanan_2.jpg');
    return renderPage('tab_bulanan_2', img, 'Rincian Unit Tab Bulanan 2');
  },
  tab_tahunan_default() {
    const img = screenImage('rincian_unit_screen/tab_tahunan_default.jpg');
    return renderPage('tab_tahunan_default', img, 'Rincian Unit Tab Tahunan Default');
  },
  tab_tahunan_filter() {
    const img = screenImage('rincian_unit_screen/tab_tahunan_filter.jpg');
    return renderPage('tab_tahunan_filter', img, 'Rincian Unit Tab Tahunan Filter');
  },
  tab_tahunan_filter_1() {
    const img = screenImage('rincian_unit_screen/tab_tahunan_filter_1.jpg');
    return renderPage('tab_tahunan_filter_1', img, 'Rincian Unit Tab Tahunan Filter 1');
  },
  tab_tahunan_filter_2() {
    const img = screenImage('rincian_unit_screen/tab_tahunan_filter_2.jpg');
    return renderPage('tab_tahunan_filter_2', img, 'Rincian Unit Tab Tahunan Filter 2');
  },
  tab_tahunan_filter_show_select_screen_cicilan() {
    const img = screenImage('rincian_unit_screen/tab_tahunan_filter_show_select_screen_cicilan.jpg');
    return renderPage('tab_tahunan_filter_show_select_screen_cicilan', img, 'Show Select Screen Cicilan');
  },
};
