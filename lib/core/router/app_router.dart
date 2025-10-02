import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/auth_service.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/register_screen.dart';
import '../../features/location/screens/location_selection_screen.dart';
import '../../features/repositor/screens/repositor_home_screen.dart';
import '../../features/supervisor/screens/supervisor_home_screen.dart';
import '../../features/admin/screens/admin_home_screen.dart';
import '../../features/common/screens/splash_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);
  
  return GoRouter(
    initialLocation: '/splash',
    redirect: (context, state) {
      return authState.when(
        data: (user) {
          final isLoggedIn = user != null;
          final isOnAuthPage = state.matchedLocation.startsWith('/auth');
          final isOnSplash = state.matchedLocation == '/splash';

          if (!isLoggedIn && !isOnAuthPage && !isOnSplash) {
            return '/auth/login';
          }
          
          if (isLoggedIn && (isOnAuthPage || isOnSplash)) {
            return '/location-selection';
          }
          
          return null;
        },
        loading: () => '/splash',
        error: (_, __) => '/auth/login',
      );
    },
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/auth/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/auth/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/location-selection',
        builder: (context, state) => const LocationSelectionScreen(),
      ),
      GoRoute(
        path: '/repositor',
        builder: (context, state) => const RepositorHomeScreen(),
      ),
      GoRoute(
        path: '/supervisor',
        builder: (context, state) => const SupervisorHomeScreen(),
      ),
      GoRoute(
        path: '/admin',
        builder: (context, state) => const AdminHomeScreen(),
      ),
    ],
  );
});
