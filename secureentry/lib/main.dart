import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '/router.dart';
import './color_scheme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://nloncltldpyykrxyjhtm.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im5sb25jbHRsZHB5eWtyeHlqaHRtIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MTkxNTg4NTgsImV4cCI6MjAzNDczNDg1OH0.TCA3l5uF_bXbKUFyaqjSpxm-BDVeXIwo1jDFFBZexIE',
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
      title: 'Visitor Management',
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
