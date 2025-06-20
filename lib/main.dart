import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:gradus/presentation/cubits/auth/auth_state.dart';

import 'core/di/injection.dart';
import 'core/theme/app_theme.dart';
import 'presentation/pages/timeline/timeline_page.dart';
import 'presentation/pages/auth/login_page.dart';
import 'presentation/cubits/timeline/timeline_cubit.dart';
import 'presentation/cubits/auth/auth_cubit.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // Konfiguruj dependency injection
  configureDependencies();
  
  runApp(const GradusApp());
}

class GradusApp extends StatelessWidget {
  const GradusApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gradus',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      home: MultiBlocProvider(
        providers: [
          BlocProvider<AuthCubit>(
            create: (context) => getIt<AuthCubit>()..checkAuthStatus(),
          ),
          BlocProvider<TimelineCubit>(
            create: (context) => getIt<TimelineCubit>(),
          ),
        ],
        child: const AuthWrapper(),
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        return state.when(
          initial: () => const Scaffold(
            body: Center(
              child: CircularProgressIndicator(
                color: AppTheme.primaryColor,
              ),
            ),
          ),
          loading: () => const Scaffold(
            body: Center(
              child: CircularProgressIndicator(
                color: AppTheme.primaryColor,
              ),
            ),
          ),
          authenticated: () => const TimelinePage(),
          unauthenticated: () => const LoginPage(),
          error: (message) => const LoginPage(),
        );
      },
    );
  }
}
