import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Supabase configuration loaded from `.env` file.
/// DO NOT hard-code credentials here — always use environment variables.
abstract class SupabaseConfig {
  static String get url =>
      dotenv.env['SUPABASE_URL'] ?? '';

  static String get anonKey =>
      dotenv.env['SUPABASE_ANON_KEY'] ?? '';
}
