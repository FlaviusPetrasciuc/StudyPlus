import 'package:flutter/material.dart';
import 'package:study_plus/auth/auth_gate.dart';
import 'package:study_plus/config/supabase_config.dart';
import 'package:study_plus/services/connectivity_service.dart';
import 'package:study_plus/widgets/offline_wrapper.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize connectivity listener
  await ConnectivityService().initialize();

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
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      builder: (context, child) => OfflineWrapper(child: child!),
      home: const AuthGate(),
    );
  }
}
