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
import 'package:ora/screens/chatv.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ora app',
      theme: ThemeData(primaryColor: Colors.blue),
      home: const Chatv(),
      debugShowCheckedModeBanner: false,
    );
  }
}
