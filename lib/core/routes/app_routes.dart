import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../presentation/cubits/auth/auth_cubit.dart';
import '../../presentation/pages/auth/login_page.dart';
import '../../presentation/pages/auth/register_page.dart';
import '../../presentation/pages/timeline/timeline_page.dart';
import '../theme/app_theme.dart';

class AppRoutes {
  static const String login = '/login';
  static const String register = '/register';
  static const String timeline = '/timeline';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case login:
        return _createRoute(const LoginPage());
      case register:
        return _createRoute(const RegisterPage());
      case timeline:
        return _createRoute(const TimelinePage());
      default:
        return _createRoute(const LoadingPage());
    }
  }

  static PageRoute _createRoute(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        // Fade animation
        final fadeAnimation = Tween<double>(
          begin: 0.0,
          end: 1.0,
        ).animate(CurvedAnimation(parent: animation, curve: AppTheme.slowCurve));

        // Slide animation
        final slideAnimation = Tween<Offset>(
          begin: const Offset(0, -0.01),
          end: Offset.zero,
        ).animate(CurvedAnimation(parent: animation, curve: AppTheme.slowCurve));

        return FadeTransition(
          opacity: fadeAnimation,
          child: SlideTransition(position: slideAnimation, child: child),
        );
      },
      transitionDuration: AppTheme.slowAnimation,
    );
  }
}

class LoadingPage extends StatelessWidget {
  const LoadingPage({super.key});

  @override
  Widget build(BuildContext context) {
    context.read<AuthCubit>().checkAuthStatus();
    return const Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      body: Center(child: CircularProgressIndicator(color: AppTheme.primaryColor)),
    );
  }
}
