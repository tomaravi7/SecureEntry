import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '/router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Supabase.initialize(
    url: 'https://nloncltldpyykrxyjhtm.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im5sb25jbHRsZHB5eWtyeHlqaHRtIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MTkxNTg4NTgsImV4cCI6MjAzNDczNDg1OH0.TCA3l5uF_bXbKUFyaqjSpxm-BDVeXIwo1jDFFBZexIE',
  );
  
  runApp(
    ProviderScope(
      child: MyApp(),
    ),  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Visitor Management',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      routerConfig: router,
    );
  }
}
