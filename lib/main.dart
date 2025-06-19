import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/di/injection.dart';
import 'presentation/pages/timeline/timeline_page.dart';
import 'presentation/cubits/timeline/timeline_cubit.dart';

void main() {
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
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.light,
        ),
        appBarTheme: const AppBarTheme(
          centerTitle: false,
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.dark,
        ),
        appBarTheme: const AppBarTheme(
          centerTitle: false,
        ),
      ),
      home: MultiBlocProvider(
        providers: [
          BlocProvider<TimelineCubit>(
            create: (context) => getIt<TimelineCubit>(),
          ),
        ],
        child: const TimelinePage(),
      ),
    );
  }
}
