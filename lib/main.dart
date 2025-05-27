import 'package:flutter/material.dart';

import 'app/app.dart';
import 'core/di/service_locator.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Dependency Injection
  await initializeDependencies();
  
  runApp(const GradusApp());
}
