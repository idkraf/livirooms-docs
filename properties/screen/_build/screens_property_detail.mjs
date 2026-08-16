import { W, H, renderPage, screenImage } from './helpers.mjs';

export const propertyDetailScreens = {
  property_detail_screen_1() {
    const img = screenImage('property_detail_screen/property_detail_screen_1.jpg');
    return renderPage('property_detail_screen_1', img, 'Property Detail Screen 1');
  },
  property_detail_screen_1_with_reviews() {
    const img = screenImage('property_detail_screen/property_detail_screen_1_with_reviews.jpeg');
    return renderPage('property_detail_screen_1_with_reviews', img, 'Property Detail Screen With Reviews');
  },
  property_detail_screen_1_bottom_sheet_diskusi() {
    const img = screenImage('property_detail_screen/property_detail_screen_1_bottom_sheet_diskusi.jpeg');
    return renderPage('property_detail_screen_1_bottom_sheet_diskusi', img, 'Bottom Sheet Diskusi');
  },
  property_detail_screen_1_bottom_sheet_ulasan() {
    const img = screenImage('property_detail_screen/property_detail_screen_1_bottom_sheet_ulasan.jpeg');
    return renderPage('property_detail_screen_1_bottom_sheet_ulasan', img, 'Bottom Sheet Ulasan');
  },
  property_detail_screen_2_tab_facilities() {
    const img = screenImage('property_detail_screen/property_detail_screen_2_tab_facilities.jpg');
    return renderPage('property_detail_screen_2_tab_facilities', img, 'Tab Facilities');
  },
  property_detail_screen_2_tab_facilities_show_bottom_sheet_fasilitas_gedung() {
    const img = screenImage('property_detail_screen/property_detail_screen_2_tab_facilities_show_bottom_sheet_fasilitas_gedung.jpeg');
    return renderPage('property_detail_screen_2_tab_facilities_show_bottom_sheet_fasilitas_gedung', img, 'Bottom Sheet Fasilitas Gedung');
  },
  property_detail_screen_2_tab_facilities_show_bottom_sheet_furniture_ruangan() {
    const img = screenImage('property_detail_screen/property_detail_screen_2_tab_facilities_show_bottom_sheet_fruniture_ruangan.jpeg');
    return renderPage('property_detail_screen_2_tab_facilities_show_bottom_sheet_furniture_ruangan', img, 'Bottom Sheet Furniture Ruangan');
  },
  property_detail_screen_3_tab_info_tab_check_in_info() {
    const img = screenImage('property_detail_screen/property_detail_screen_3_tab_info_tab_check_in_info.jpg');
    return renderPage('property_detail_screen_3_tab_info_tab_check_in_info', img, 'Tab Info Check In');
  },
  property_detail_screen_3_tab_info_tab_deposit() {
    const img = screenImage('property_detail_screen/property_detail_screen_3_tab_info_tab_deposit.jpeg');
    return renderPage('property_detail_screen_3_tab_info_tab_deposit', img, 'Tab Info Deposit');
  },
  property_detail_screen_3_tab_info_tab_unit_detail() {
    const img = screenImage('property_detail_screen/property_detail_screen_3_tab_info_tab_unit_detail.jpeg');
    return renderPage('property_detail_screen_3_tab_info_tab_unit_detail', img, 'Tab Info Unit Detail');
  },
  property_detail_screen_4_tab_details() {
    const img = screenImage('property_detail_screen/property_detail_screen_4_tab_details.jpg');
    return renderPage('property_detail_screen_4_tab_details', img, 'Tab Details');
  },
  property_detail_screen_5_tab_location() {
    const img = screenImage('property_detail_screen/property_detail_screen_5_tab_location.jpg');
    return renderPage('property_detail_screen_5_tab_location', img, 'Tab Location');
  },
  property_detail_screen_6() {
    const img = screenImage('property_detail_screen/property_detail_screen_6.jpg');
    return renderPage('property_detail_screen_6', img, 'Description Screen');
  },
  property_detail_screen_6_show_bottom_sheet_description() {
    const img = screenImage('property_detail_screen/property_detail_screen_6_show_bottom_sheet_descripton.jpeg');
    return renderPage('property_detail_screen_6_show_bottom_sheet_description', img, 'Bottom Sheet Description');
  },
  property_detail_screen_7() {
    const img = screenImage('property_detail_screen/property_detail_screen_7.jpg');
    return renderPage('property_detail_screen_7', img, 'Additional Detail Screen');
  },
};
