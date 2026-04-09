import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'package:ora/screens/alarmes.dart';
import 'package:ora/screens/calendrier.dart';
import 'package:ora/screens/chat.dart';
import 'package:ora/screens/connecter.dart';
import 'package:ora/screens/creecompte.dart';

import 'package:ora/screens/favorise.dart';
import 'package:ora/screens/langue.dart';
import 'package:ora/screens/maps.dart';
import 'package:ora/screens/mesnotes.dart';
import 'package:ora/screens/meteo.dart';
import 'package:ora/screens/notifications.dart';
import 'package:ora/screens/principal.dart';
import 'package:ora/screens/profil.dart';
import 'package:ora/screens/rencontre.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  await Firebase.initializeApp();

  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('fr'), Locale('en'), Locale('ar')],
      path: 'assets/translations',
      fallbackLocale: const Locale('fr'),
      startLocale: const Locale('fr'),
      saveLocale: true,
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ORA',
      locale: context.locale,
      supportedLocales: context.supportedLocales,
      localizationsDelegates: [
        ...context.localizationDelegates,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      initialRoute: principal.screenRoute,
      routes: {
        rencontre.screenRoute: (context) => const rencontre(),
        connecter.screenRoute: (context) => const connecter(),
        creecompte.screenRoute: (context) => const creecompte(),
        principal.screenRoute: (context) => const principal(),
        chat.screenRoute: (context) => const chat(),
        Favorise.screenRoute: (context) => const Favorise(),
        mesnotes.screenRoute: (context) => const mesnotes(),
        notifications.screenRoute: (context) => const notifications(),
        Profil.screenRoute: (context) => const Profil(),
        Calendrier.screenRoute: (context) => const Calendrier(),
        MeteoPage.screenRoute: (context) => const MeteoPage(),
        AlarmesPage.screenRoute: (context) => const AlarmesPage(),
        MapsPage.screenRoute: (context) => const MapsPage(),
        LanguePage.screenRoute: (context) => const LanguePage(),
      },
      theme: ThemeData(primaryColor: Colors.blue, fontFamily: 'Jomhuria'),
    );
  }
}
