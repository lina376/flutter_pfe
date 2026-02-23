import 'package:flutter/material.dart';

import 'package:google_fonts/google_fonts.dart';
import 'package:ora/screens/chat.dart';
import 'package:ora/screens/connecter.dart';
import 'package:ora/screens/creecompte.dart';
import 'package:ora/screens/rencontre.dart';
import 'package:ora/screens/principal.dart';
import 'package:ora/screens/mesnotes.dart';
import 'package:ora/screens/notes2.dart';
import 'package:ora/screens/Calendrier.dart';
import 'package:ora/screens/paramettre.dart';
import 'package:ora/screens/Profil.dart';
import 'package:ora/screens/favorise.dart';
import 'package:ora/screens/notifications.dart';
import 'package:ora/screens/notifications2.dart';
import 'package:ora/screens/chatv.dart';

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
      home: const Calendrier(),
      debugShowCheckedModeBanner: false,
    );
  }
}
