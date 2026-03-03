import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:prm_project/core/router/app_router.dart';
import 'package:prm_project/core/theme/app_theme.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // <--- Quan trọng

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // This is a workaround for the MissingPluginException when using path_provider
  // on platforms that don't support it (like web)
  if (!kIsWeb) {
    try {
      await getTemporaryDirectory();
    } catch (e) {
      debugPrint('Error initializing path_provider: $e');
    }
  }

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'HoSe - Home Services',
      theme: AppTheme.lightTheme,
      routerConfig: AppRouter.router,
      debugShowCheckedModeBanner: false,
    );
  }
}
