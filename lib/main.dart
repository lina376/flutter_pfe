import 'package:flutter/material.dart';
import 'package:ora/screens/chat.dart';
import 'package:ora/screens/connecter.dart';
import 'package:ora/screens/creecompte.dart';
import 'package:ora/screens/rencontre.dart';
import 'package:ora/screens/principal.dart';
import 'package:ora/screens/mesnotes.dart';
import 'package:ora/screens/notes2.dart';
import 'package:ora/screens/calendrier.dart';
import 'package:ora/screens/paramettre.dart';
import 'package:ora/screens/profil.dart';
import 'package:ora/screens/favorise.dart';
import 'package:ora/screens/notifications.dart';
import 'package:ora/screens/notifications2.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ora app',
      theme: ThemeData(primaryColor: Colors.blue, fontFamily: 'Jomhuria'),
      initialRoute: Profil.screenRoute,
      routes: {
        rencontre.screenRoute: (ctx) => rencontre(),
        connecter.screenRoute: (ctx) => connecter(),
        creecompte.screenRoute: (ctx) => creecompte(),
        principal.screenRoute: (ctx) => principal(),
        chat.screenRoute: (ctx) => chat(),
        Favorise.screenRoute: (ctx) => Favorise(),
        mesnotes.screenRoute: (ctx) => mesnotes(),
        notes2.screenRoute: (ctx) => notes2(),
        notifications.screenRoute: (ctx) => notifications(),
        Notifications2.screenRoute: (ctx) => Notifications2(),
        Paramettre.screenRoute: (ctx) => Paramettre(),
        Profil.screenRoute: (ctx) => Profil(),
        Calendrier.screenRoute: (ctx) => Calendrier(),
      },
      debugShowCheckedModeBanner: false,
    );
  }
}
