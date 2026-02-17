import 'package:flutter/material.dart';

class connecter extends StatefulWidget {
  const connecter({super.key});

  @override
  State<connecter> createState() => _connecterState();
}

class _connecterState extends State<connecter> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("images/b2.png"),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              Positioned(
                top: 150,
                left: 10,
                child: Text(
                  'Bienvenue',
                  style: TextStyle(
                    fontSize: 46,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Align(
                alignment: Alignment(0, -0.35),
                child: Text(
                  "Se connecter",
                  style: TextStyle(
                    color: const Color.fromARGB(255, 114, 118, 120),
                    fontSize: 14,
                  ),
                ),
              ),
              Positioned(
                top: 300,
                left: 10,
                child: Text(
                  "Email",
                  style: TextStyle(color: Colors.white, fontSize: 14),
                ),
              ),
              Stack(
                children: [
                  Positioned(
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
                    top: 400,
                    left: 10,
                    child: Text(
                      "Email",
                      style: TextStyle(color: Colors.white, fontSize: 14),
                    ),
                  ),
                  TextField(
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
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
