import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';

import 'core/di/injection.dart';
import 'core/theme/app_theme.dart';
import 'core/routes/app_routes.dart';
import 'presentation/cubits/auth/auth_cubit.dart';
import 'presentation/cubits/focus/focus_cubit.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  configureDependencies();

  runApp(const GradusApp());
}

class GradusApp extends StatefulWidget {
  const GradusApp({super.key});

  @override
  State<GradusApp> createState() => _GradusAppState();
}

class _GradusAppState extends State<GradusApp> {
  AuthCubit? authCubit;

  @override
  void initState() {
    super.initState();
    authCubit = getIt<AuthCubit>()..checkAuthStatus();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthCubit>.value(value: authCubit!),
        BlocProvider<FocusCubit>(create: (context) => getIt<FocusCubit>()),
      ],
      child: MaterialApp(
        title: 'Gradus',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        initialRoute: authCubit!.state.isAuthenticated ? AppRoutes.timeline : AppRoutes.login,
        onGenerateRoute: AppRoutes.onGenerateRoute,
      ),
    );
  }
}
