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
  final _formkey = GlobalKey<FormState>(); //clé du formulaire (validation)
  final _auth = FirebaseAuth.instance;
  bool isLoading = false; //apres connecter
  late String email;
  late String motdepasse;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
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
                    child: const Text(
                      'Bienvenue',
                      style: TextStyle(
                        fontSize: 46,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const Align(
                    alignment: Alignment(0, -0.35),
                    child: Text(
                      "Se connecter",
                      style: TextStyle(
                        color: Color.fromARGB(255, 114, 118, 120),
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
                          child: const Text(
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
                              fillColor: Colors.white,
                              border: OutlineInputBorder(
                                gapPadding: 3.0,
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(width: 0.5),
                              ),
                            ),
                            onChanged: (value) {
                              email = value;
                            },
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return "Email obligatoire";
                              }

                              final emailRegex = RegExp(
                                r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
                              );

                              if (!emailRegex.hasMatch(value.trim())) {
                                return "Format email incorrect";
                              }

                              return null;
                            },
                          ),
                        ),
                        Positioned(
                          top: MediaQuery.of(context).size.height * 0.47,
                          left: MediaQuery.of(context).size.height * 0.01,
                          child: const Text(
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
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "Mot de passe obligatoire";
                              }
                              return null;
                            },
                          ),
                        ),
                        Positioned(
                          top: MediaQuery.of(context).size.height * 0.6,
                          right: MediaQuery.of(context).size.height * 0.165,
                          left: MediaQuery.of(context).size.height * 0.165,
                          child: ElevatedButton(
                            onPressed: () async {
                              if (isLoading) return;

                              if (_formkey.currentState!.validate()) {
                                setState(() {
                                  isLoading = true;
                                });

                                try {
                                  final userCredential = await _auth
                                      .signInWithEmailAndPassword(
                                        email: email.trim(),
                                        password: motdepasse.trim(),
                                      );

                                  if (userCredential.user != null) {
                                    Navigator.pushReplacementNamed(
                                      context,
                                      principal.screenRoute,
                                    );
                                  }
                                  // gestion des erreurs Firebase
                                } on FirebaseAuthException catch (e) {
                                  String message = "Une erreur s'est produite";

                                  if (e.code == 'user-not-found') {
                                    message =
                                        "Aucun compte trouvé avec cet email";
                                  } else if (e.code == 'wrong-password') {
                                    message = "Mot de passe incorrect";
                                  } else if (e.code == 'invalid-email') {
                                    message = "Email invalide";
                                  } else if (e.code == 'invalid-credential') {
                                    message = "Email ou mot de passe incorrect";
                                  }

                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text(message)),
                                  );
                                } catch (e) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text("Erreur : $e")),
                                  );
                                } finally {
                                  setState(() {
                                    isLoading = false;
                                  });
                                }
                              }
                            },
                            child: Center(
                              child: Text(
                                isLoading ? "Connexion..." : "connecter",
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: Color.fromARGB(136, 10, 11, 22),
                                ),
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              shape: const StadiumBorder(),
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
                            child: const Text(
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
