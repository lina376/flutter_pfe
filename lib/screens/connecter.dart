import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ora/screens/creecompte.dart';
import 'package:ora/screens/principal.dart';
import 'package:firebase_auth/firebase_auth.dart';

class connecter extends StatefulWidget {
  static const String screenRoute = 'pageconnecter';
  const connecter({super.key});

  @override
  State<connecter> createState() => _connecterState();
}

class _connecterState extends State<connecter> {
  final _formkey = GlobalKey<FormState>();
  final _auth = FirebaseAuth.instance;
  late String email;
  late String motdepasse; //late matist7a9ch valeur

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
          child: SingleChildScrollView(
            child: SizedBox(
              height: MediaQuery.of(context).size.height,
              child: Stack(
                children: [
                  Positioned(
                    top: MediaQuery.of(context).size.height * 0.2,
                    left: MediaQuery.of(context).size.height * 0.11,
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

                  Form(
                    key: _formkey,
                    child: Stack(
                      children: [
                        Positioned(
                          top: MediaQuery.of(context).size.height * 0.35,
                          left: MediaQuery.of(context).size.height * 0.01,
                          child: Text(
                            "Email",
                            style: TextStyle(color: Colors.white, fontSize: 14),
                          ),
                        ),
                        Positioned(
                          top: MediaQuery.of(context).size.height * 0.38,
                          left: MediaQuery.of(context).size.height * 0.01,
                          right: MediaQuery.of(context).size.height * 0.01,
                          child: TextFormField(
                            keyboardType: TextInputType.emailAddress,
                            decoration: InputDecoration(
                              hintText: "Email",
                              filled: true,
                              fillColor: Colors.white, //pour arriere blanc
                              border: OutlineInputBorder(
                                gapPadding: 3.0,
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(width: 0.5),
                              ),
                            ),
                            onChanged: (value) {
                              email = value;
                            },
                          ),
                        ),
                        Positioned(
                          top: MediaQuery.of(context).size.height * 0.47,
                          left: MediaQuery.of(context).size.height * 0.01,
                          child: Text(
                            "Mot de passe",
                            style: TextStyle(color: Colors.white, fontSize: 14),
                          ),
                        ),
                        Positioned(
                          top: MediaQuery.of(context).size.height * 0.5,
                          left: MediaQuery.of(context).size.height * 0.01,
                          right: MediaQuery.of(context).size.height * 0.01,
                          child: TextFormField(
                            obscureText: true,
                            decoration: InputDecoration(
                              hintText: "Mot de passe",
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            onChanged: (value) {
                              motdepasse = value;
                            },
                          ),
                        ),

                        Positioned(
                          top: MediaQuery.of(context).size.height * 0.6,
                          right: MediaQuery.of(context).size.height * 0.165,
                          left: MediaQuery.of(context).size.height * 0.165,
                          child: ElevatedButton(
                            onPressed: () async {
                              final newUser = await _auth
                                  .signInWithEmailAndPassword(
                                    email: email,
                                    password: motdepasse,
                                  );
                              try {
                                final newUser = await _auth
                                    .signInWithEmailAndPassword(
                                      email: email,
                                      password: motdepasse,
                                    );

                                Navigator.pushNamed(
                                  context,
                                  principal.screenRoute,
                                );
                              } catch (e) {
                                print(e);
                              }
                            },
                            child: Text(
                              "connecter",
                              style: TextStyle(
                                color: const Color.fromARGB(136, 10, 11, 22),
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              shape: StadiumBorder(),
                              backgroundColor: const Color.fromARGB(
                                172,
                                153,
                                129,
                                180,
                              ),
                              elevation: 1,
                            ),
                          ),
                        ),
                        Positioned(
                          top: MediaQuery.of(context).size.height * 0.8,
                          left: MediaQuery.of(context).size.height * 0.188,
                          child: GestureDetector(
                            onTap: () {
                              Navigator.pushNamed(
                                context,
                                creecompte.screenRoute,
                              );
                            },
                            child: Text(
                              "Crée compte",
                              style: TextStyle(
                                color: Colors.black,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ),
                      ],
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
