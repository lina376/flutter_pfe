import 'package:flutter/material.dart';
import 'package:ora/screens/connecter.dart';
import 'package:ora/screens/principal.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class creecompte extends StatefulWidget {
  static const String screenRoute = 'pagecreecompte';
  const creecompte({super.key});

  @override
  State<creecompte> createState() => _creecompteState();
}

class _creecompteState extends State<creecompte> {
  final _formkey = GlobalKey<FormState>();
  final _auth = FirebaseAuth.instance;
  late String nom;
  late String prenom;
  late String email;
  late String motdepasse;
  late String confirmerMotdepasse; //late matist7a9ch valeur
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          style: const ButtonStyle(
            backgroundColor: WidgetStatePropertyAll<Color>(
              Color.fromARGB(194, 88, 70, 142),
            ),
          ),
          icon: const Icon(Icons.chevron_left, color: Colors.white),
          onPressed: () {
            Navigator.pushNamed(context, connecter.screenRoute);
          },
          tooltip: 'chevron',
          iconSize: 40,
          constraints: const BoxConstraints(minHeight: 50, minWidth: 50),
        ),
      ),
      resizeToAvoidBottomInset: true,
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
          child: Form(
            key: _formkey,
            child: SingleChildScrollView(
              child: SizedBox(
                height: MediaQuery.of(context).size.height,
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
                        onChanged: (value) {
                          nom = value;
                        },
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
                        onChanged: (value) {
                          prenom = value;
                        },
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
                        validator: (value) {
                          //validator tkhdem ken ma3 TextFormField
                          if (value == null || value.isEmpty) {
                            return "Email obligatoire";
                          }

                          final emailRegex = RegExp(
                            r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
                          );

                          if (!emailRegex.hasMatch(value)) {
                            return "Format email incorrect";
                          }

                          return null;
                        },
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

                          final passwordRegex = RegExp(
                            r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)[A-Za-z\d]{8,}$',
                          );

                          if (!passwordRegex.hasMatch(value)) {
                            return "Min 8 caractères, 1 majuscule, 1 chiffre";
                          }

                          return null;
                        },
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
                          confirmerMotdepasse = value;
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Mot de passe obligatoire";
                          }

                          final passwordRegex = RegExp(
                            r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)[A-Za-z\d]{8,}$',
                          );

                          if (!passwordRegex.hasMatch(value)) {
                            return "Min 8 caractères, 1 majuscule, 1 chiffre";
                          }

                          return null;
                        },
                      ),
                    ),

                    Positioned(
                      top: MediaQuery.of(context).size.height * 0.78,
                      right: MediaQuery.of(context).size.height * 0.17,
                      left: MediaQuery.of(context).size.height * 0.17,
                      child: ElevatedButton(
                        onPressed: () async {
                          if (_formkey.currentState!.validate()) {
                            try {
                              final newUser = await _auth
                                  .createUserWithEmailAndPassword(
                                    email: email.trim(),
                                    password: motdepasse.trim(),
                                  );

                              if (newUser.user != null) {
                                await FirebaseFirestore.instance
                                    .collection('users')
                                    .doc(newUser.user!.uid)
                                    .set({
                                      'nom': nom,
                                      'prenom': prenom,
                                      'email': email,
                                    });
                                Navigator.pushReplacementNamed(
                                  context,
                                  principal.screenRoute,
                                );
                              }
                            } catch (e) {
                              print(e);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    "Erreur lors de la création du compte",
                                  ),
                                ),
                              );
                            }
                          }
                        },
                        child: Text(
                          "S'inscrire",
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
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
