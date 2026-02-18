import 'package:flutter/material.dart';

class creecompte extends StatefulWidget {
  const creecompte({super.key});

  @override
  State<creecompte> createState() => _creecompteState();
}

class _creecompteState extends State<creecompte> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("images/b3.png"),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              Positioned(
                top: 85,
                right: 10,
                child: Text(
                  "Créer",
                  style: TextStyle(
                    fontSize: 46,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Positioned(
                top: 188,
                right: 10,
                child: Text(
                  "un compte",
                  style: TextStyle(
                    fontSize: 46,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Positioned(
                top: 310,
                left: 12,
                child: Text(
                  "Nom",
                  style: TextStyle(color: Colors.white, fontSize: 14),
                ),
              ),
              Positioned(
                top: 340,
                left: 10,
                right: 10,
                child: TextField(
                  decoration: InputDecoration(
                    hintText: "********",
                    filled: true,
                    fillColor: Colors.white, //pour arriere blanc
                    border: OutlineInputBorder(
                      gapPadding: 3.0,
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(width: 0.5),
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 400,
                left: 12,
                child: Text(
                  "Prénom",
                  style: TextStyle(color: Colors.white, fontSize: 14),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
