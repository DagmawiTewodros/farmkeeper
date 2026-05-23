import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/routing/app_router.dart';
import 'core/theme/themes.dart';

void main() {
  runApp(const ProviderScope(child: FarmKeeperApp()));
}

class FarmKeeperApp extends StatelessWidget {
  const FarmKeeperApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'FarmKeeper',
      debugShowCheckedModeBanner: false,

      theme: AppTheme.lightTheme,
      routerConfig: appRouter,
    );
  }
}