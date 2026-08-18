import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/dashboard/dashboard_screen.dart';
import '../screens/vehicles/vehicle_list_screen.dart';
import '../screens/vehicles/vehicle_detail_screen.dart';
import '../screens/vehicles/vehicle_form_screen.dart';
import '../screens/drivers/driver_list_screen.dart';
import '../screens/drivers/driver_form_screen.dart';
import '../screens/maintenance/maintenance_list_screen.dart';
import '../screens/maintenance/maintenance_form_screen.dart';
import '../screens/service_centers/service_center_list_screen.dart';
import '../screens/service_centers/service_center_form_screen.dart';
import '../screens/reports/reports_screen.dart';
import '../screens/settings/settings_screen.dart';
import '../widgets/app_scaffold.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();

final goRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/',
  redirect: (context, state) {
    final user = FirebaseAuth.instance.currentUser;
    final isLoggedIn = user != null;
    final isAuthRoute =
        state.matchedLocation == '/' || state.matchedLocation == '/register';

    if (!isLoggedIn && !isAuthRoute) {
      return '/';
    }
    if (isLoggedIn && isAuthRoute) {
      return '/dashboard';
    }
    return null;
  },
  routes: [
    GoRoute(
      path: '/',
      name: 'login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/register',
      name: 'register',
      builder: (context, state) => const RegisterScreen(),
    ),
    ShellRoute(
      navigatorKey: _rootNavigatorKey,
      builder: (context, state, child) => AppScaffold(child: child),
      routes: [
        GoRoute(
          path: '/dashboard',
          name: 'dashboard',
          builder: (context, state) => const DashboardScreen(),
        ),
        GoRoute(
          path: '/vehicles',
          name: 'vehicles',
          builder: (context, state) => const VehicleListScreen(),
        ),
        GoRoute(
          path: '/vehicles/new',
          name: 'addVehicle',
          builder: (context, state) => const VehicleFormScreen(),
        ),
        GoRoute(
          path: '/vehicles/:id',
          name: 'vehicleDetail',
          builder: (context, state) =>
              VehicleDetailScreen(vehicleId: state.pathParameters['id']!),
        ),
        GoRoute(
          path: '/vehicles/:id/edit',
          name: 'editVehicle',
          builder: (context, state) => VehicleFormScreen(
            vehicleId: state.pathParameters['id'],
          ),
        ),
        GoRoute(
          path: '/drivers',
          name: 'drivers',
          builder: (context, state) => const DriverListScreen(),
        ),
        GoRoute(
          path: '/drivers/new',
          name: 'addDriver',
          builder: (context, state) => const DriverFormScreen(),
        ),
        GoRoute(
          path: '/drivers/:id/edit',
          name: 'editDriver',
          builder: (context, state) => DriverFormScreen(
            driverId: state.pathParameters['id'],
          ),
        ),
        GoRoute(
          path: '/maintenance',
          name: 'maintenance',
          builder: (context, state) => const MaintenanceListScreen(),
        ),
        GoRoute(
          path: '/maintenance/new',
          name: 'addMaintenance',
          builder: (context, state) => const MaintenanceFormScreen(),
        ),
        GoRoute(
          path: '/maintenance/:id/edit',
          name: 'editMaintenance',
          builder: (context, state) => MaintenanceFormScreen(
            recordId: state.pathParameters['id'],
          ),
        ),
        GoRoute(
          path: '/service-centers',
          name: 'serviceCenters',
          builder: (context, state) => const ServiceCenterListScreen(),
        ),
        GoRoute(
          path: '/service-centers/new',
          name: 'addServiceCenter',
          builder: (context, state) => const ServiceCenterFormScreen(),
        ),
        GoRoute(
          path: '/service-centers/:id/edit',
          name: 'editServiceCenter',
          builder: (context, state) => ServiceCenterFormScreen(
            centerId: state.pathParameters['id'],
          ),
        ),
        GoRoute(
          path: '/reports',
          name: 'reports',
          builder: (context, state) => const ReportsScreen(),
        ),
        GoRoute(
          path: '/settings',
          name: 'settings',
          builder: (context, state) => const SettingsScreen(),
        ),
      ],
    ),
  ],
);
