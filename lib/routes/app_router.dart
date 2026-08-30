import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../data/models/order.dart';
import '../features/auth/providers/auth_controller.dart';
import '../features/auth/providers/auth_state.dart';
import '../features/auth/screens/home_screen.dart';
import '../features/auth/screens/order_mobile_entry_screen.dart';
import '../features/auth/screens/registration_screen.dart';
import '../features/auth/screens/splash_screen.dart';
import '../features/dashboard/screens/dashboard_screen.dart';
import '../features/menu/screens/meal_selection_screen.dart';
import '../features/menu/screens/order_confirmation_screen.dart';
import '../features/menu/screens/weekly_menu_screen.dart';
import '../features/notifications/screens/notifications_screen.dart';
import '../features/orders/screens/order_details_screen.dart';
import '../features/orders/screens/order_history_screen.dart';
import '../features/orders/screens/upcoming_orders_screen.dart';
import '../features/profile/screens/edit_profile_screen.dart';
import '../features/profile/screens/profile_screen.dart';
import 'app_shell.dart';

class MealSelectionArgs {
  const MealSelectionArgs({required this.date, this.existingOrder});
  final DateTime date;
  final OrderModel? existingOrder;
}

class OrderConfirmArgs {
  const OrderConfirmArgs({
    required this.date,
    required this.selections,
    this.existingOrderId,
  });
  final DateTime date;
  final Map<String, String> selections;
  final int? existingOrderId;
}

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/splash',
    refreshListenable: _AuthListenable(ref),
    redirect: (context, state) {
      final authState = ref.read(authControllerProvider);
      final location = state.matchedLocation;
      final isSplash = location == '/splash';
      final isAuthRoute = ['/home', '/register', '/order/mobile'].any((p) => location.startsWith(p));

      if (authState.status == AuthStatus.unknown) {
        // Still resolving (reading secure storage / re-fetching the profile)
        // — park on splash rather than flashing another screen first.
        return isSplash ? null : '/splash';
      }
      if (authState.status == AuthStatus.unauthenticated) {
        return isAuthRoute ? null : '/home';
      }
      // authenticated
      if (isSplash || isAuthRoute) return '/dashboard';
      return null;
    },
    routes: [
      GoRoute(path: '/splash', builder: (context, state) => const SplashScreen()),
      GoRoute(path: '/home', builder: (context, state) => const HomeScreen()),
      GoRoute(
        path: '/order/mobile',
        builder: (context, state) => const OrderMobileEntryScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => RegistrationScreen(
          mobile: state.uri.queryParameters['mobile'] ?? '',
        ),
      ),
      GoRoute(
        path: '/notifications',
        builder: (context, state) => const NotificationsScreen(),
      ),
      GoRoute(
        path: '/profile/edit',
        builder: (context, state) => const EditProfileScreen(),
      ),
      GoRoute(
        path: '/menu/select',
        builder: (context, state) => MealSelectionScreen(args: state.extra as MealSelectionArgs),
      ),
      GoRoute(
        path: '/order/confirm',
        builder: (context, state) => OrderConfirmationScreen(args: state.extra as OrderConfirmArgs),
      ),
      GoRoute(
        path: '/orders/history',
        builder: (context, state) => const OrderHistoryScreen(),
      ),
      // ShellRoute must be registered before the generic '/orders/:id' route
      // below — go_router matches routes in declaration order, and
      // '/orders/upcoming' would otherwise be captured as id="upcoming".
      ShellRoute(
        builder: (context, state, child) => AppShell(child: child),
        routes: [
          GoRoute(path: '/dashboard', builder: (context, state) => const DashboardScreen()),
          GoRoute(path: '/menu', builder: (context, state) => const WeeklyMenuScreen()),
          GoRoute(path: '/orders/upcoming', builder: (context, state) => const UpcomingOrdersScreen()),
          GoRoute(path: '/profile', builder: (context, state) => const ProfileScreen()),
        ],
      ),
      GoRoute(
        path: '/orders/:id',
        builder: (context, state) => OrderDetailsScreen(orderId: int.parse(state.pathParameters['id']!)),
      ),
    ],
  );
});

/// Bridges Riverpod state changes into something GoRouter's
/// `refreshListenable` (a plain Listenable) can react to.
class _AuthListenable extends ChangeNotifier {
  _AuthListenable(Ref ref) {
    ref.listen(authControllerProvider, (previous, next) {
      if (previous?.status != next.status) notifyListeners();
    });
  }
}
