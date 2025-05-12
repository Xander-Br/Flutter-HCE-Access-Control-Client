import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sicpa/src/core/router/app_router.dart';
import 'package:sicpa/src/core/app_theme.dart';
import 'package:sicpa/src/features/settings/presentation/providers/settings_providers.dart';

void main() {
  runApp(
    const ProviderScope( // Wrap with ProviderScope for Riverpod
      child: MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Listen to the theme mode provider
    final themeMode = ref.watch(themeModeProvider);
    // Get the router configuration
    final router = ref.watch(goRouterProvider);

    return MaterialApp.router(
      title: 'Flutter Boilerplate',
      debugShowCheckedModeBanner: false, // Set to true if you need debug banner
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      routerConfig: router, // Use routerConfig for GoRouter
    );
  }
}