import 'package:flutter/material.dart';

import 'models/property.dart';
import 'screens/property/property_detail_screen.dart';
import 'screens/property/search_results_screen.dart';
import 'screens/home/filter_screen.dart';
import 'screens/home/main_shell.dart';
import 'screens/account/wishlist_screen.dart';
import 'screens/payment/payment_method_screen.dart';
import 'screens/chat/chat_room_screen.dart';
import 'screens/property/hotel/hotel_search_screen.dart';
import 'screens/property/hotel/hotel_results_screen.dart';
import 'screens/property/hotel/hotel_detail_screen.dart';
import 'screens/property/hotel/hotel_booking_screen.dart';
import 'models/hotel.dart';
import 'models/hotel_search_query.dart';
import 'screens/mitra/property_management_screen.dart';
import 'screens/mitra/property_form_screen.dart';
import 'screens/mitra/hotel_form_screen.dart';
import 'screens/mitra/availability_calendar_screen.dart';

class Routes {
  Routes._();

  static const home = '/home';
  static const filter = '/search/filter';
  static const searchResults = '/search/results';
  static const Property = '/property/detail';

  static const hotelSearch = '/hotel/search';
  static const hotelResults = '/hotel/results';
  static const hotelDetail = '/hotel/detail';
  static const hotelBooking = '/hotel/booking';

  static const wishlist = '/wishlist';

  static const paymentMethod = '/payment/method';

  static const chatRoom = '/chat/room';

  static const mitraProperties = '/mitra/properties';
  static const mitraPropertyForm = '/mitra/properties/form';
  static const mitraHotelForm = '/mitra/hotels/form';
  static const mitraCalendar = '/mitra/calendar';
}

class AppRouter {
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    print('[Router] onGenerateRoute: ${settings.name}');
    final args = settings.arguments;
    Widget page;
    switch (settings.name) {
      case Routes.home:
        page = MainShell(initialTab: args is int ? args : 0);
      case Routes.filter:
        page = FilterScreen(initial: args is FilterArgs ? args : null);
      case Routes.searchResults:
        page = SearchResultsScreen(args: args is SearchArgs ? args : const SearchArgs());
      case Routes.Property:
        page = PropertyDetailScreen(
          property: args is Property ? args : null,
          propertyId: args is int ? args : (args is Property ? args.id : null),
        );

      case Routes.hotelSearch:
        page = HotelSearchScreen(
          initialQuery: args is HotelSearchQuery ? args : null,
        );
      case Routes.hotelResults:
        page = HotelResultsScreen(
          query: args is HotelSearchQuery ? args : HotelSearchQuery.defaultStay(),
        );
      case Routes.hotelDetail:
        {
          final detailArgs = args is HotelDetailArgs
              ? args
              : HotelDetailArgs(
                  hotel: args is Hotel ? args : null,
                  hotelId: args is int ? args : (args is Hotel ? args.id : null),
                );
          page = HotelDetailScreen(
            hotel: detailArgs.hotel,
            hotelId: detailArgs.hotelId ?? detailArgs.hotel?.id ?? 101,
            query: detailArgs.query,
          );
        }
      case Routes.hotelBooking:
        page = HotelBookingScreen(
          args: args is HotelBookingArgs
              ? args
              : HotelBookingArgs(
                  hotel: args as Hotel,
                  query: HotelSearchQuery.defaultStay(),
                ),
        );

      case Routes.wishlist:
        page = const WishlistScreen();

      case Routes.paymentMethod:
        page = PaymentMethodScreen(args: args as PaymentArgs);

      case Routes.chatRoom:
        page = ChatRoomScreen(args: args as ChatRoomArgs);

      case Routes.mitraProperties:
        page = const PropertyManagementScreen();
      case Routes.mitraPropertyForm:
        page = PropertyFormScreen(property: args is Property ? args : null);
      case Routes.mitraHotelForm:
        final propId = args is int ? args : (args is Property ? args.id : 1);
        final hotelId = args is Map ? args['hotel_id'] as int? : null;
        page = HotelFormScreen(propertyId: propId, hotelId: hotelId);
      case Routes.mitraCalendar:
        page = AvailabilityCalendarScreen(property: args is Property ? args : null);

      default:
        print('[Router] unknown route: ${settings.name}');
        page = Scaffold(
          body: Center(child: Text('Rute tidak ditemukan: ${settings.name}')),
        );
    }
    print('[Router] building route: $settings.name');
    return MaterialPageRoute(builder: (_) => page, settings: settings);
  }
}



