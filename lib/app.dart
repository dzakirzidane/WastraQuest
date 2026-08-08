import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'screens/splash_screen.dart';
import 'screens/profile_setup_screen.dart';
import 'screens/main_navigation.dart';
import 'screens/quiz_screen.dart';
import 'screens/result_screen.dart';
import 'screens/model_info_screen.dart';
import 'providers/user_provider.dart';

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      title: 'WastraQuest',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFFD4AF37),
          secondary: Color(0xFFB8941E),
          surface: Color(0xFF0B1320),
        ),
        scaffoldBackgroundColor: const Color(0xFF0B1320),
        fontFamily: 'Roboto',
      ),
      routerConfig: _router(ref),
    );
  }

  static GoRouter _router(WidgetRef ref) {
    return GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const SplashScreen(),
        ),
        GoRoute(
          path: '/profile-setup',
          redirect: (context, state) {
            final hasProfile = ref.read(userProvider.notifier).hasProfile;
            if (hasProfile) {
              return '/home';
            }
            return null;
          },
          builder: (context, state) => const ProfileSetupScreen(),
        ),
        GoRoute(
          path: '/home',
          redirect: (context, state) {
            final hasProfile = ref.read(userProvider.notifier).hasProfile;
            if (!hasProfile) {
              return '/profile-setup';
            }
            return null;
          },
          builder: (context, state) => const MainNavigation(),
        ),
        GoRoute(
          path: '/quiz',
          builder: (context, state) {
            final level = state.uri.queryParameters['level'] ?? 'easy';
            return QuizScreen(difficulty: level);
          },
        ),
        GoRoute(
          path: '/result',
          builder: (context, state) => const ResultScreen(),
        ),
        GoRoute(
          path: '/model-info',
          builder: (context, state) => const ModelInfoScreen(),
        ),
      ],
    );
  }
}