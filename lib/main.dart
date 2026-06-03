import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'screens/login_screen.dart';
import 'screens/invite_team_members_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://lrffrclpulbvqgqprlau.supabase.co',
    anonKey: 'sb_publishable_ydO2tdQuJBmgkxbtngorEA_kNfcZNR2',
  );

  runApp(const StudyPlusApp());
}

class StudyPlusApp extends StatelessWidget {
  const StudyPlusApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      // App starts on LoginScreen
      home: const LoginScreen(),

      routes: {
        '/invite-team-members': (context) =>
        const InviteTeamMembersScreen(),
      },
    );
  }
}