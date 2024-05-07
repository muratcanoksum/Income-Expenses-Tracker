// ignore_for_file: library_private_types_in_public_api, unused_import

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:unilive/addcategory.dart';
import 'package:unilive/addearnings.dart';
import 'package:unilive/addexpenses.dart';
import 'package:unilive/currency.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:unilive/home.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late Timer _timer;
  Locale _appLocale = const Locale("en");

  @override
  void initState() {
    super.initState();
    _timer =
        Timer.periodic(const Duration(seconds: 1), (Timer t) => _checkLocale());
    _fetchLocale();
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  _fetchLocale() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.getString('savedLocale') != null) {
      setState(() {
        _appLocale = Locale(prefs.getString('savedLocale')!);
      });
    } else {
      setState(() {
        _appLocale = const Locale('en'); // Varsayılan dil İngilizce
      });
    }
  }

  _checkLocale() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? savedLocale = prefs.getString('savedLocale');
    if (savedLocale != null && savedLocale != _appLocale.languageCode) {
      setState(() {
        _appLocale = Locale(savedLocale);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Color(0xff07873A),
      statusBarIconBrightness: Brightness.light,
    ));

    return SafeArea(
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        //
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        // Dil burada ayarlanacak
        locale: _appLocale,

        theme: ThemeData(
          appBarTheme: const AppBarTheme(elevation: 0),
          fontFamily: 'DINPro',
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: const Home(),
      ),
    );
  }
}
