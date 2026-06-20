import 'package:flutter/material.dart';
import 'package:study_plus/auth/auth_gate.dart';
import 'package:study_plus/config/supabase_config.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SupabaseConfig.logStartup();

  await Supabase.initialize(
    url: SupabaseConfig.url,
    anonKey: SupabaseConfig.anonKey,
  );

  runApp(const StudyPlusApp());
}

class StudyPlusApp extends StatelessWidget {
  const StudyPlusApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: AuthGate(),
    );
  }
}
