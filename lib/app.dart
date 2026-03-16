import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'core/constants/app_theme.dart';
import 'core/models/care_profile.dart';
import 'core/models/garment.dart';
import 'features/garment_detail/add_garment_screen.dart';
import 'features/garment_detail/garment_detail_screen.dart';
import 'features/scan/scan_result_screen.dart';
import 'features/scan/scan_screen.dart';
import 'features/wardrobe/wardrobe_screen.dart';

// ── Router ────────────────────────────────────────────────────────────────────

final _router = GoRouter(
  initialLocation: '/',
  debugLogDiagnostics: false,
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const WardrobeScreen(),
    ),
    GoRoute(
      path: '/scan',
      builder: (context, state) => const ScanScreen(),
      routes: [
        GoRoute(
          path: 'result',
          builder: (context, state) {
            final extra = state.extra as Map<String, dynamic>?;
            final careProfile = extra?['careProfile'] as CareProfile? ??
                CareProfile.empty();
            final imagePath = extra?['imagePath'] as String?;
            final rawText = extra?['rawText'] as String? ?? '';
            return ScanResultScreen(
              careProfile: careProfile,
              imagePath: imagePath,
              rawText: rawText,
            );
          },
        ),
      ],
    ),
    GoRoute(
      path: '/garment/add',
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>?;
        final careProfile = extra?['careProfile'] as CareProfile?;
        final tagPhotoPath = extra?['tagPhotoPath'] as String?;
        final existingGarment = extra?['existingGarment'] as Garment?;
        return AddGarmentScreen(
          careProfile: careProfile,
          tagPhotoPath: tagPhotoPath,
          existingGarment: existingGarment,
        );
      },
    ),
    GoRoute(
      path: '/garment/:id',
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        return GarmentDetailScreen(garmentId: id);
      },
    ),
  ],
  errorBuilder: (context, state) => Scaffold(
    appBar: AppBar(title: const Text('Page Not Found')),
    body: Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, size: 56, color: Colors.grey),
          const SizedBox(height: 16),
          Text(
            'Page not found: ${state.uri}',
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => context.go('/'),
            child: const Text('Go Home'),
          ),
        ],
      ),
    ),
  ),
);

// ── App Widget ────────────────────────────────────────────────────────────────

class WashWiseApp extends ConsumerWidget {
  const WashWiseApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      title: 'WashWise',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      routerConfig: _router,
    );
  }
}
