import { propertyDetailScreens } from './screens_property_detail.mjs';
import { rincianUnitScreens } from './screens_rincian_unit.mjs';
import { W, H } from './helpers.mjs';

export const SCREENS = {
  ...propertyDetailScreens,
  ...rincianUnitScreens,
};

export const OUT_NAME_MAP = {
  property_detail_screen_1: 'property_detail_screen_1.jpg',
  property_detail_screen_1_with_reviews: 'property_detail_screen_1_with_reviews.jpeg',
  property_detail_screen_1_bottom_sheet_diskusi: 'property_detail_screen_1_bottom_sheet_diskusi.jpeg',
  property_detail_screen_1_bottom_sheet_ulasan: 'property_detail_screen_1_bottom_sheet_ulasan.jpeg',
  property_detail_screen_2_tab_facilities: 'property_detail_screen_2_tab_facilities.jpg',
  property_detail_screen_2_tab_facilities_show_bottom_sheet_fasilitas_gedung: 'property_detail_screen_2_tab_facilities_show_bottom_sheet_fasilitas_gedung.jpeg',
  property_detail_screen_2_tab_facilities_show_bottom_sheet_furniture_ruangan: 'property_detail_screen_2_tab_facilities_show_bottom_sheet_fruniture_ruangan.jpeg',
  property_detail_screen_3_tab_info_tab_check_in_info: 'property_detail_screen_3_tab_info_tab_check_in_info.jpg',
  property_detail_screen_3_tab_info_tab_deposit: 'property_detail_screen_3_tab_info_tab_deposit.jpeg',
  property_detail_screen_3_tab_info_tab_unit_detail: 'property_detail_screen_3_tab_info_tab_unit_detail.jpeg',
  property_detail_screen_4_tab_details: 'property_detail_screen_4_tab_details.jpg',
  property_detail_screen_5_tab_location: 'property_detail_screen_5_tab_location.jpg',
  property_detail_screen_6: 'property_detail_screen_6.jpg',
  property_detail_screen_6_show_bottom_sheet_description: 'property_detail_screen_6_show_bottom_sheet_descripton.jpeg',
  property_detail_screen_7: 'property_detail_screen_7.jpg',
  tab_harian_1: 'tab_harian_1.jpg',
  tab_harian_2: 'tab_harian_2.jpg',
  tab_bulanan_1: 'tab_bulanan_1.jpg',
  tab_bulanan_2: 'tab_bulanan_2.jpg',
  tab_tahunan_default: 'tab_tahunan_default.jpg',
  tab_tahunan_filter: 'tab_tahunan_filter.jpg',
  tab_tahunan_filter_1: 'tab_tahunan_filter_1.jpg',
  tab_tahunan_filter_2: 'tab_tahunan_filter_2.jpg',
  tab_tahunan_filter_show_select_screen_cicilan: 'tab_tahunan_filter_show_select_screen_cicilan.jpg',
};

export const SCREEN_LIST = [
  'property_detail_screen_1',
  'property_detail_screen_1_with_reviews',
  'property_detail_screen_1_bottom_sheet_diskusi',
  'property_detail_screen_1_bottom_sheet_ulasan',
  'property_detail_screen_2_tab_facilities',
  'property_detail_screen_2_tab_facilities_show_bottom_sheet_fasilitas_gedung',
  'property_detail_screen_2_tab_facilities_show_bottom_sheet_furniture_ruangan',
  'property_detail_screen_3_tab_info_tab_check_in_info',
  'property_detail_screen_3_tab_info_tab_deposit',
  'property_detail_screen_3_tab_info_tab_unit_detail',
  'property_detail_screen_4_tab_details',
  'property_detail_screen_5_tab_location',
  'property_detail_screen_6',
  'property_detail_screen_6_show_bottom_sheet_description',
  'property_detail_screen_7',
  'tab_harian_1',
  'tab_harian_2',
  'tab_bulanan_1',
  'tab_bulanan_2',
  'tab_tahunan_default',
  'tab_tahunan_filter',
  'tab_tahunan_filter_1',
  'tab_tahunan_filter_2',
  'tab_tahunan_filter_show_select_screen_cicilan',
];

export { W, H };

export function renderPage(screenName) {
  const fn = SCREENS[screenName];
  if (!fn) throw new Error('No screen builder: ' + screenName);
  return fn();
}
