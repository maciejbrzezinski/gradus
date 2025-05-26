import 'package:flutter/material.dart';

/// Główna aplikacja Gradus
/// US-001: Konfiguracja projektu Flutter z Clean Architecture
class GradusApp extends StatelessWidget {
  const GradusApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gradus',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2563EB), // Blue podobny do daily tasks
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        fontFamily: 'Inter', // TODO: Dodać font w pubspec.yaml
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2563EB),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
        fontFamily: 'Inter',
      ),
      themeMode: ThemeMode.system,
      home: const GradusHomePage(),
    );
  }
}

/// Tymczasowa strona główna - zostanie zastąpiona Timeline/Project view
class GradusHomePage extends StatelessWidget {
  const GradusHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gradus'),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.assignment_outlined,
              size: 64,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              'Gradus',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Your notes and tasks app',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            SizedBox(height: 32),
            Text(
              'Clean Architecture setup complete ✓',
              style: TextStyle(
                color: Colors.green,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
