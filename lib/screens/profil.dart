import 'package:flutter/material.dart';

class Profil extends StatefulWidget {
  const Profil({super.key});

  @override
  State<Profil> createState() => _ProfilState();
}

class _ProfilState extends State<Profil> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
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
            onPressed: () {},
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
          onPressed: () {},
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
            image: AssetImage("images/b5.png"),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
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
            ],
          ),
        ),
      ),
    );
  }
}
