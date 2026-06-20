import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void logSupabaseError(String operation, Object error, [StackTrace? stackTrace]) {
  if (!kDebugMode) return;

  if (error is AuthException) {
    debugPrint(
      'Supabase Auth error [$operation]: '
      'message="${error.message}", '
      'statusCode=${error.statusCode ?? '<none>'}, '
      'code=${error.code ?? '<none>'}',
    );
  } else if (error is PostgrestException) {
    debugPrint(
      'Supabase PostgREST error [$operation]: '
      'message="${error.message}", '
      'details=${error.details ?? '<none>'}, '
      'hint=${error.hint ?? '<none>'}, '
      'code=${error.code ?? '<none>'}',
    );
  } else {
    debugPrint('Supabase error [$operation]: $error');
  }

  if (stackTrace != null) {
    debugPrintStack(stackTrace: stackTrace);
  }
}
