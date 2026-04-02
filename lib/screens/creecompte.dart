import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:ora/controllers/controleur_authentification.dart';
import 'package:ora/screens/connecter.dart';
import 'package:ora/screens/principal.dart';

class creecompte extends StatefulWidget {
  static const String screenRoute = 'pagecreecompte';
  const creecompte({super.key});

  @override
  State<creecompte> createState() => _creecompteState();
}

class _creecompteState extends State<creecompte> {
  final _formkey = GlobalKey<FormState>();
  final ControleurAuthentification _controleurAuthentification =
      ControleurAuthentification();

  bool isLoading = false;

  String nom = '';
  String prenom = '';
  String email = '';
  String motdepasse = '';
  String confirmerMotdepasse = '';

  @override
  Widget build(BuildContext context) {
    final hauteur = MediaQuery.of(context).size.height;

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
        decoration: const BoxDecoration(
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
                height: hauteur,
                child: Stack(
                  children: [
                    Positioned(
                      top: hauteur * 0.05,
                      right: hauteur * 0.01,
                      child: const Text(
                        "Créer",
                        style: TextStyle(
                          fontSize: 46,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Positioned(
                      top: hauteur * 0.1,
                      right: hauteur * 0.01,
                      child: const Text(
                        "un compte",
                        style: TextStyle(
                          fontSize: 46,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Positioned(
                      top: hauteur * 0.2,
                      left: hauteur * 0.01,
                      child: const Text(
                        "Nom",
                        style: TextStyle(color: Colors.white, fontSize: 15),
                      ),
                    ),
                    Positioned(
                      top: hauteur * 0.24,
                      left: hauteur * 0.01,
                      right: hauteur * 0.01,
                      child: TextFormField(
                        decoration: InputDecoration(
                          hintText: "Nom",
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            gapPadding: 3.0,
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(width: 0.5),
                          ),
                        ),
                        onChanged: (value) {
                          nom = value;
                        },
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return "Nom obligatoire";
                          }
                          final nomRegex = RegExp(r'^[a-zA-ZÀ-ÿ\s-]+$');
                          if (!nomRegex.hasMatch(value.trim())) {
                            return "Nom invalide";
                          }
                          return null;
                        },
                      ),
                    ),
                    Positioned(
                      top: hauteur * 0.32,
                      left: hauteur * 0.01,
                      child: const Text(
                        "Prénom",
                        style: TextStyle(color: Colors.white, fontSize: 14),
                      ),
                    ),
                    Positioned(
                      top: hauteur * 0.35,
                      left: hauteur * 0.01,
                      right: hauteur * 0.01,
                      child: TextFormField(
                        decoration: InputDecoration(
                          hintText: "Prénom",
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            gapPadding: 3.0,
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(width: 0.5),
                          ),
                        ),
                        onChanged: (value) {
                          prenom = value;
                        },
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return "Prénom obligatoire";
                          }
                          final nomRegex = RegExp(r'^[a-zA-ZÀ-ÿ\s-]+$');
                          if (!nomRegex.hasMatch(value.trim())) {
                            return "Prenom invalide";
                          }
                          return null;
                        },
                      ),
                    ),
                    Positioned(
                      top: hauteur * 0.43,
                      left: hauteur * 0.01,
                      child: const Text(
                        "Email",
                        style: TextStyle(color: Colors.white, fontSize: 14),
                      ),
                    ),
                    Positioned(
                      top: hauteur * 0.46,
                      left: hauteur * 0.01,
                      right: hauteur * 0.01,
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
                      top: hauteur * 0.545,
                      left: hauteur * 0.01,
                      child: const Text(
                        "Mot de passe",
                        style: TextStyle(color: Colors.white, fontSize: 14),
                      ),
                    ),
                    Positioned(
                      top: hauteur * 0.57,
                      left: hauteur * 0.01,
                      right: hauteur * 0.01,
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
                      top: hauteur * 0.655,
                      left: hauteur * 0.01,
                      child: const Text(
                        "Confirmer mot de passe",
                        style: TextStyle(color: Colors.white, fontSize: 14),
                      ),
                    ),
                    Positioned(
                      top: hauteur * 0.68,
                      left: hauteur * 0.01,
                      right: hauteur * 0.01,
                      child: TextFormField(
                        obscureText: true,
                        decoration: InputDecoration(
                          hintText: "Confirmer mot de passe",
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
                          if (value != motdepasse) {
                            return "Les mots de passe ne sont pas identiques";
                          }

                          return null;
                        },
                      ),
                    ),
                    Positioned(
                      top: hauteur * 0.78,
                      right: hauteur * 0.17,
                      left: hauteur * 0.17,
                      child: ElevatedButton(
                        onPressed: () async {
                          if (isLoading) return;

                          if (_formkey.currentState!.validate()) {
                            setState(() {
                              isLoading = true;
                            });

                            try {
                              final newUser = await _controleurAuthentification
                                  .creerCompte(
                                    nom: nom.trim(),
                                    prenom: prenom.trim(),
                                    email: email.trim(),
                                    motDePasse: motdepasse.trim(),
                                  );

                              if (!mounted) return;

                              if (newUser.user != null) {
                                Navigator.pushReplacementNamed(
                                  context,
                                  principal.screenRoute,
                                );
                              }
                            } on FirebaseAuthException catch (e) {
                              String message = "Une erreur s'est produite";

                              if (e.code == 'email-already-in-use') {
                                message = "Cet email est déjà utilisé";
                              } else if (e.code == 'invalid-email') {
                                message = "Email invalide";
                              } else if (e.code == 'weak-password') {
                                message = "Mot de passe trop faible";
                              }

                              ScaffoldMessenger.of(
                                context,
                              ).showSnackBar(SnackBar(content: Text(message)));
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text("Erreur : $e")),
                              );
                            } finally {
                              if (mounted) {
                                setState(() {
                                  isLoading = false;
                                });
                              }
                            }
                          }
                        },
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
                        child: Text(
                          isLoading ? "Création..." : "S'inscrire",
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Color.fromARGB(136, 10, 11, 22),
                          ),
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
