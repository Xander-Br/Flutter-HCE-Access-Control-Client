import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sicpa/src/features/access_card/presentation/screens/card_list_screen.dart';
import 'package:sicpa/src/features/home/presentation/screens/home_screen.dart';
import 'package:sicpa/src/features/settings/presentation/screens/settings_screen.dart';
import 'package:sicpa/src/shared/widgets/common_scaffold.dart'; // For consistent layout
import 'app_routes.dart';

final goRouterProvider = Provider<GoRouter>((ref) {
 
  final rootNavigatorKey = GlobalKey<NavigatorState>();
  final shellNavigatorKey = GlobalKey<NavigatorState>();


  return GoRouter(
    navigatorKey: rootNavigatorKey, 
    initialLocation: AppRoutes.home,
    debugLogDiagnostics: true, 
    routes: [
      ShellRoute(
        navigatorKey: shellNavigatorKey,
        builder: (context, state, child) {
          return CommonScaffold(child: child);
        },
        routes: [
          GoRoute(
            path: AppRoutes.home,
            name: AppRoutes.home, 
            builder: (context, state) => const HomeScreen(),
            routes: [
              
            ],
          ),
          GoRoute(
            path: AppRoutes.card,
            name: AppRoutes.card,
            builder: (context, state) => const CardListScreen(),
          ),
          GoRoute(
            path: AppRoutes.settings,
            name: AppRoutes.settings,
            builder: (context, state) => const SettingsScreen(),
          ),
        ],
      ),
      
    ],
    errorBuilder: (context, state) => Scaffold( // Basic error screen
      appBar: AppBar(title: const Text('Page Not Found')),
      body: Center(
        child: Text('Oops! Route not found: ${state.error?.message}'),
      ),
    ),
    
  );
});