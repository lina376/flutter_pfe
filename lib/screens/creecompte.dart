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
                top: 40,
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
                top: 80,
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
                top: 170,
                left: 12,
                child: Text(
                  "Nom",
                  style: TextStyle(color: Colors.white, fontSize: 15),
                ),
              ),
              Positioned(
                top: 200,
                left: 10,
                right: 10,
                child: TextField(
                  decoration: InputDecoration(
                    hintText: "Nom",
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
                top: 265,
                left: 12,
                child: Text(
                  "Prénom",
                  style: TextStyle(color: Colors.white, fontSize: 14),
                ),
              ),
              Positioned(
                top: 295,
                left: 10,
                right: 10,
                child: TextField(
                  decoration: InputDecoration(
                    hintText: "Prénom",
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
                top: 360,
                left: 12,
                child: Text(
                  "Email",
                  style: TextStyle(color: Colors.white, fontSize: 14),
                ),
              ),
              Positioned(
                top: 390,
                left: 10,
                right: 10,
                child: TextField(
                  decoration: InputDecoration(
                    hintText: "email@gmail.com",
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
                top: 455,
                left: 12,
                child: Text(
                  "Mot de passe",
                  style: TextStyle(color: Colors.white, fontSize: 14),
                ),
              ),
              Positioned(
                top: 485,
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
                top: 550,
                left: 12,
                child: Text(
                  "Confirmer mot de passe",
                  style: TextStyle(color: Colors.white, fontSize: 14),
                ),
              ),
              Positioned(
                top: 580,
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
            ],
          ),
        ),
      ),
    );
  }
}
