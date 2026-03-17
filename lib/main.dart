import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:prm_project/core/l10n/app_localizations.dart';
import 'package:prm_project/core/config/supabase_config.dart';
import 'package:prm_project/core/router/app_router.dart';
import 'package:prm_project/core/theme/app_theme.dart';
import 'package:prm_project/core/providers/settings_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load .env file (must be before any SupabaseConfig access)
  await dotenv.load(fileName: '.env');

  // Initialize Supabase (must be before runApp)
  await Supabase.initialize(
    url: SupabaseConfig.url,
    anonKey: SupabaseConfig.anonKey,
  );

  // Workaround for path_provider on web
  if (!kIsWeb) {
    try {
      await getTemporaryDirectory();
    } catch (e) {
      debugPrint('Error initializing path_provider: $e');
    }
  }

  // Initialize SharedPreferences before runApp
  final prefs = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp.router(
      title: 'HoSe - Home Services',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      routerConfig: AppRouter.router,
      debugShowCheckedModeBanner: false,
    );
  }
}
