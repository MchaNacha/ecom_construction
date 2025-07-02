import 'package:ecom_construction/data/providers/wishlist_provider.dart';
import 'package:ecom_construction/features/seller/seller_dashboard_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'features/dashboard/dashboard_screen.dart';
import 'features/auth/role_selector_screen.dart';
import 'package:provider/provider.dart';
import 'data/providers/cart_provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => WishlistProvider()),
      ],
      child: const ConstructionApp(),
    ),
  );
}

class ConstructionApp extends StatefulWidget {
  const ConstructionApp({super.key});

  @override
  State<ConstructionApp> createState() => _ConstructionAppState();
}

class _ConstructionAppState extends State<ConstructionApp> {
  Locale _locale = const Locale('ar');
  Widget _startScreen = const Scaffold(
    body: Center(child: CircularProgressIndicator()),
  );

  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    setState(() {
      _startScreen =
          token != null
              ? const DashboardScreen()
              : const RoleSelectorScreen();
    });
  }

  void setLocale(Locale newLocale) {
    setState(() {
      _locale = newLocale;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // ← localized app title
      onGenerateTitle: (context) => AppLocalizations.of(context)!.appTitle,

      debugShowCheckedModeBanner: false,

      // ← your runtime‐switchable locale
      locale: _locale,

      // ← the locales you declared in your ARB files
      supportedLocales: AppLocalizations.supportedLocales,

      // ← includes AppLocalizations.delegate + the Flutter built-ins
      localizationsDelegates: AppLocalizations.localizationsDelegates,

      // ← your existing resolution logic
      localeResolutionCallback: (deviceLocale, supportedLocales) {
        if (deviceLocale == null) return supportedLocales.first;
        for (final locale in supportedLocales) {
          if (locale.languageCode == deviceLocale.languageCode) {
            return locale;
          }
        }
        return supportedLocales.first;
      },

      home: _startScreen,

      // routes: {
      //   '/seller/dashboard': (context) => const SellerDashboardScreen(),
      //   '/seller/edit-profile': (context) => const Placeholder(),
      //   '/seller/shop': (context) => const Placeholder(),
      //   '/seller/products': (context) => const Placeholder(),
      //   '/seller/orders': (context) => const Placeholder(),
      // },
    );
  }
}
