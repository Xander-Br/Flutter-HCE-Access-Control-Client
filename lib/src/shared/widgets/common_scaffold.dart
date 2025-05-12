import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sicpa/src/core/router/app_routes.dart';

class CommonScaffold extends StatefulWidget {
  final Widget child;
  const CommonScaffold({super.key, required this.child});

  @override
  State<CommonScaffold> createState() => _CommonScaffoldState();
}

class _CommonScaffoldState extends State<CommonScaffold> {
  int _calculateSelectedIndex(BuildContext context) {
    final String location = GoRouterState.of(context).uri.toString();
    if (location == AppRoutes.home) {
      return 0;
    }
    if (location == AppRoutes.card) {
      return 1;
    }
    if (location == AppRoutes.settings) {
      return 2;
    }
    return 0; // Default to home
  }

  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        GoRouter.of(context).go(AppRoutes.home);
        break;
      case 1:
        GoRouter.of(context).go(AppRoutes.card);
        break;
      case 2:
        GoRouter.of(context).go(AppRoutes.settings);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: widget.child,
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.credit_card_outlined),
            activeIcon: Icon(Icons.credit_card),
            label: 'Card',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings_outlined),
            activeIcon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
        currentIndex: _calculateSelectedIndex(context),
        onTap: (index) => _onItemTapped(index, context),
        
      ),
      
    );
  }
}