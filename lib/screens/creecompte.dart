import 'package:flutter/material.dart';

class creecompte extends StatefulWidget {
  static const String screenRoute = 'pagecreecompte';
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
                top: MediaQuery.of(context).size.height * 0.05,
                right: MediaQuery.of(context).size.height * 0.01,
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
                top: MediaQuery.of(context).size.height * 0.1,
                right: MediaQuery.of(context).size.height * 0.01,
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
                top: MediaQuery.of(context).size.height * 0.2,
                left: MediaQuery.of(context).size.height * 0.01,
                child: Text(
                  "Nom",
                  style: TextStyle(color: Colors.white, fontSize: 15),
                ),
              ),
              Positioned(
                top: MediaQuery.of(context).size.height * 0.24,
                left: MediaQuery.of(context).size.height * 0.01,
                right: MediaQuery.of(context).size.height * 0.01,
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
                top: MediaQuery.of(context).size.height * 0.32,
                left: MediaQuery.of(context).size.height * 0.01,
                child: Text(
                  "Prénom",
                  style: TextStyle(color: Colors.white, fontSize: 14),
                ),
              ),
              Positioned(
                top: MediaQuery.of(context).size.height * 0.35,
                left: MediaQuery.of(context).size.height * 0.01,
                right: MediaQuery.of(context).size.height * 0.01,
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
                top: MediaQuery.of(context).size.height * 0.43,
                left: MediaQuery.of(context).size.height * 0.01,
                child: Text(
                  "Email",
                  style: TextStyle(color: Colors.white, fontSize: 14),
                ),
              ),
              Positioned(
                top: MediaQuery.of(context).size.height * 0.46,
                left: MediaQuery.of(context).size.height * 0.01,
                right: MediaQuery.of(context).size.height * 0.01,
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
                top: MediaQuery.of(context).size.height * 0.545,
                left: MediaQuery.of(context).size.height * 0.01,
                child: Text(
                  "Mot de passe",
                  style: TextStyle(color: Colors.white, fontSize: 14),
                ),
              ),
              Positioned(
                top: MediaQuery.of(context).size.height * 0.57,
                left: MediaQuery.of(context).size.height * 0.01,
                right: MediaQuery.of(context).size.height * 0.01,
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
                top: MediaQuery.of(context).size.height * 0.655,
                left: MediaQuery.of(context).size.height * 0.01,
                child: Text(
                  "Confirmer mot de passe",
                  style: TextStyle(color: Colors.white, fontSize: 14),
                ),
              ),
              Positioned(
                top: MediaQuery.of(context).size.height * 0.68,
                left: MediaQuery.of(context).size.height * 0.01,
                right: MediaQuery.of(context).size.height * 0.01,
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
                top: MediaQuery.of(context).size.height * 0.78,
                right: MediaQuery.of(context).size.height * 0.17,
                left: MediaQuery.of(context).size.height * 0.17,
                child: ElevatedButton(
                  onPressed: () {},
                  child: Text(
                    "S'inscrire",
                    style: TextStyle(
                      color: const Color.fromARGB(136, 10, 11, 22),
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    shape: StadiumBorder(),
                    backgroundColor: const Color.fromARGB(172, 153, 129, 180),
                    elevation: 1,
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
