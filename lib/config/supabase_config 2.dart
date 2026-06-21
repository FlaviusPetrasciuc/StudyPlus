import 'package:flutter/foundation.dart';

class SupabaseConfig {
  static const String _fallbackUrl =
      'https://lrffrclpulbvqgqprlau.supabase.co';
  static const String _fallbackAnonKey =
      'sb_publishable_ydO2tdQuJBmgkxbtngorEA_kNfcZNR2';

  static const String _supabaseUrl =
      String.fromEnvironment('SUPABASE_URL');
  static const String _nextPublicSupabaseUrl =
      String.fromEnvironment('NEXT_PUBLIC_SUPABASE_URL');
  static const String _supabaseAnonKey =
      String.fromEnvironment('SUPABASE_ANON_KEY');
  static const String _nextPublicSupabaseAnonKey =
      String.fromEnvironment('NEXT_PUBLIC_SUPABASE_ANON_KEY');

  static String get url {
    if (_supabaseUrl.isNotEmpty) return _supabaseUrl;
    if (_nextPublicSupabaseUrl.isNotEmpty) return _nextPublicSupabaseUrl;
    return _fallbackUrl;
  }

  static String get anonKey {
    if (_supabaseAnonKey.isNotEmpty) return _supabaseAnonKey;
    if (_nextPublicSupabaseAnonKey.isNotEmpty) {
      return _nextPublicSupabaseAnonKey;
    }
    return _fallbackAnonKey;
  }

  static void logStartup() {
    if (!kDebugMode) return;

    debugPrint(
      'Supabase config: urlHost=${Uri.tryParse(url)?.host ?? '<invalid>'}, '
      'anonKey=${_maskPublicKey(anonKey)}, '
      'urlSource=${_supabaseUrl.isNotEmpty ? 'SUPABASE_URL' : _nextPublicSupabaseUrl.isNotEmpty ? 'NEXT_PUBLIC_SUPABASE_URL' : 'fallback'}, '
      'anonKeySource=${_supabaseAnonKey.isNotEmpty ? 'SUPABASE_ANON_KEY' : _nextPublicSupabaseAnonKey.isNotEmpty ? 'NEXT_PUBLIC_SUPABASE_ANON_KEY' : 'fallback'}',
    );
  }

  static String _maskPublicKey(String value) {
    if (value.isEmpty) return '<missing>';
    if (value.length <= 12) return '<set:${value.length} chars>';

    return '${value.substring(0, 6)}...${value.substring(value.length - 4)} '
        '(${value.length} chars)';
  }
}
