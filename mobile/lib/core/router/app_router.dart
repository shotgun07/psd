import 'package:flutter/material.dart';

// Auth Screens
import 'package:oblns/features/auth/presentation/enhanced_login_screen.dart';
import 'package:oblns/features/auth/presentation/otp_verification_screen.dart';
import 'package:oblns/features/auth/presentation/screens/register_screen.dart';

// Home Screens
import 'package:oblns/features/home/presentation/screens/home_screen.dart';
import 'package:oblns/features/drivers/presentation/screens/driver_home_screen.dart';

// Order Screens
import 'package:oblns/features/orders/presentation/screens/search_destination_screen.dart';
import 'package:oblns/features/orders/presentation/screens/trip_confirm_screen.dart';
import 'package:oblns/features/orders/presentation/screens/trip_tracking_screen.dart';
import 'package:oblns/features/orders/presentation/screens/trip_rating_screen.dart';

// Driver Screens
import 'package:oblns/features/drivers/presentation/screens/driver_trip_request_screen.dart';

// IoT Screens
import 'package:oblns/features/iot/presentation/screens/iot_dashboard_screen.dart';

// Wearable Screens
import 'package:oblns/features/wearable/presentation/screens/wearable_dashboard_screen.dart';

// Other Screens
import 'package:oblns/features/wallet/presentation/screens/wallet_screen.dart';
import 'package:oblns/features/profile/presentation/screens/profile_screen.dart';
import 'package:oblns/features/chatbot/presentation/chat_screen.dart';
import 'package:oblns/features/chatbot/presentation/screens/chatbot_screen.dart';

class AppRouter {
  static const String login = '/login';
  static const String otp = '/otp';
  static const String register = '/register';
  static const String home = '/home';
  static const String driverHome = '/driver-home';
  static const String searchDestination = '/search-destination';
  static const String tripConfirm = '/trip-confirm';
  static const String tripTracking = '/trip-tracking';
  static const String tripRating = '/trip-rating';
  static const String driverTripRequest = '/driver-trip-request';
  static const String wallet = '/wallet';
  static const String profile = '/profile';
  static const String chat = '/chat';
  static const String chatbot = '/chatbot';
  static const String iotDashboard = '/iot-dashboard';
  static const String wearableDashboard = '/wearable-dashboard';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case login:
        return _fadeRoute(const EnhancedLoginScreen());

      case otp:
        final phone = settings.arguments as String;
        return _slideRoute(OtpVerificationScreen(phoneNumber: phone));

      case register:
        return _slideRoute(const RegisterScreen());

      case home:
        return _fadeRoute(const HomeScreen());

      case driverHome:
        return _fadeRoute(const DriverHomeScreen());

      case searchDestination:
        return _slideRoute(const SearchDestinationScreen());

      case tripConfirm:
        final args = settings.arguments as Map<String, dynamic>;
        return _slideRoute(
          TripConfirmScreen(
            pickupAddress: args['pickupAddress'],
            destAddress: args['destAddress'],
            pickupLatLng: args['pickupLatLng'],
            destLatLng: args['destLatLng'],
          ),
        );

      case tripTracking:
        final tripId = settings.arguments as String;
        return _slideRoute(TripTrackingScreen(tripId: tripId));

      case tripRating:
        final args = settings.arguments as Map<String, dynamic>;
        return _slideRoute(
          TripRatingScreen(
            tripId: args['tripId'],
            driverName: args['driverName'],
            amount: args['amount'],
          ),
        );

      case driverTripRequest:
        final args = settings.arguments as Map<String, dynamic>;
        return _fadeRoute(
          DriverTripRequestScreen(
            tripId: args['tripId'],
            pickupAddress: args['pickupAddress'],
            destAddress: args['destAddress'],
            fare: args['fare'],
            distance: args['distance'],
          ),
        );

      case wallet:
        return _slideRoute(const WalletScreen());

      case profile:
        return _slideRoute(const ProfileScreen());

      case chat:
        return _slideRoute(const ChatScreen());

      case chatbot:
        return _slideRoute(const ChatbotScreen());

      case iotDashboard:
        return _slideRoute(const IotDashboardScreen());

      case wearableDashboard:
        return _slideRoute(const WearableDashboardScreen());

      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(child: Text('Route ${settings.name} not found')),
          ),
        );
    }
  }

  static PageRouteBuilder _fadeRoute(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(opacity: animation, child: child);
      },
      transitionDuration: const Duration(milliseconds: 300),
    );
  }

  static PageRouteBuilder _slideRoute(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        const curve = Curves.easeInOut;
        var tween = Tween(
          begin: begin,
          end: end,
        ).chain(CurveTween(curve: curve));
        return SlideTransition(position: animation.drive(tween), child: child);
      },
      transitionDuration: const Duration(milliseconds: 300),
    );
  }
}
