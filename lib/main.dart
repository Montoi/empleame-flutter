import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'providers/locale_provider.dart';
import 'providers/providers.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();

  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
    ),
  );

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('en'), Locale('es')],
      path: 'assets/translations',
      fallbackLocale: const Locale('en'),
      child: const ProviderScope(child: MyApp()),
    ),
  );
}

/// Root widget.
///
/// On first build, syncs [localeProvider] from the locale that
/// [EasyLocalization] restored from SharedPreferences, then passes it
/// to [MaterialApp.router]. This makes [localeProvider] the single
/// driver of the active locale — screens just `ref.watch(localeProvider)`
/// to rebuild, and [LanguageScreen] updates both easy_localization and
/// the provider together.
class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Sync localeProvider with whatever locale easy_localization restored
    // from SharedPreferences (runs before first frame, safe to call here).
    final savedLocale = context.locale;
    final providerLocale = ref.read(localeProvider);
    if (savedLocale != providerLocale) {
      // Use addPostFrameCallback to avoid modifying provider during build.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(localeProvider.notifier).state = savedLocale;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Watch localeProvider — rebuilds MyApp (and all screens) on locale change.
    final locale = ref.watch(localeProvider);

    // ref.read — stable cached instance, never recreated on rebuilds.
    final router = ref.read(routerProvider);

    return MaterialApp.router(
      title: 'EmpleaMe',
      debugShowCheckedModeBanner: false,
      // localeProvider drives the active locale; easy_localization provides
      // the delegates and the translated strings from the JSON assets.
      locale: locale,
      supportedLocales: context.supportedLocales,
      localizationsDelegates: context.localizationDelegates,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF7210FF),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Color(0xFF1F222A),
          elevation: 0,
          surfaceTintColor: Colors.white,
          systemOverlayStyle: SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: Brightness.dark,
            statusBarBrightness: Brightness.light,
          ),
        ),
        navigationBarTheme: NavigationBarThemeData(
          backgroundColor: Colors.white,
          indicatorColor: const Color(0xFF7210FF).withValues(alpha: 0.15),
          elevation: 0,
          surfaceTintColor: Colors.white,
        ),
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF7210FF),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFF181A20),
      ),
      themeMode: ThemeMode.light,
      routerConfig: router,
    );
  }
}
