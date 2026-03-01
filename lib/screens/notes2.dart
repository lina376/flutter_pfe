import 'package:flutter/material.dart';
import 'package:ora/screens/mesnotes.dart';
import 'package:ora/screens/principal.dart';

class notes2 extends StatefulWidget {
  static const String screenRoute = 'pagenotes2';
  const notes2({super.key});

  @override
  State<notes2> createState() => _notes2State();
}

class _notes2State extends State<notes2> {
  final TextEditingController ctrl = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text("Nouvelle note"),

        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            style: const ButtonStyle(
              backgroundColor: WidgetStatePropertyAll<Color>(
                Color.fromARGB(194, 88, 70, 142),
              ),
            ),
            icon: const Icon(Icons.home, color: Colors.white),
            onPressed: () {
              Navigator.pushNamed(context, principal.screenRoute);
            },
            tooltip: 'home',
            iconSize: 40,
            constraints: const BoxConstraints(minHeight: 50, minWidth: 50),
          ),
        ],
        leading: IconButton(
          style: const ButtonStyle(
            backgroundColor: WidgetStatePropertyAll<Color>(
              Color.fromARGB(194, 88, 70, 142),
            ),
          ),
          icon: const Icon(Icons.chevron_left, color: Colors.white),
          onPressed: () {
            Navigator.pushNamed(context, mesnotes.screenRoute);
          },
          tooltip: 'chevron',
          iconSize: 40,
          constraints: const BoxConstraints(minHeight: 50, minWidth: 50),
        ),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("images/b6.png"),
            fit: BoxFit.cover,
          ),
        ),

        child: SafeArea(
          child: SingleChildScrollView(
            child: SizedBox(
              height: MediaQuery.of(context).size.height,
              child: Stack(
                children: [
                  Positioned(
                    child: TextField(
                      controller: ctrl,
                      maxLines: 8,
                      decoration: const InputDecoration(
                        hintText: "Écrire votre note...",
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),

                  Positioned(
                    child: ElevatedButton(
                      onPressed: () {
                        final text = ctrl.text.trim();
                        if (text.isEmpty) return;
                        Navigator.pop(context, text); //traj3ek l mesnotes
                      },
                      child: const Text("Enregistrer"),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
