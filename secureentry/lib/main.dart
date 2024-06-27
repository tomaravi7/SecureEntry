import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '/router.dart';
import './color_scheme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://zhltoyxqutoaekjwuzkw.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InpobHRveXhxdXRvYWVrand1emt3Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3MTk0NzI0NjUsImV4cCI6MjAzNTA0ODQ2NX0.lICRpoEXaf7plZJ0TH5AByTNH8j5cPMXY5QXnUVv7KI',
  );
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

final SupabaseClient supabase = Supabase.instance.client;

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Secure Entry',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
          useMaterial3: true,
          colorScheme: darkColorScheme,
          textTheme: const TextTheme(
              displayLarge: TextStyle(
            fontSize: 72,
            fontWeight: FontWeight.bold,
          ))),
      routerConfig: router,
    );
  }
}
