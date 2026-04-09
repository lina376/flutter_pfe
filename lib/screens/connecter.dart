import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:ora/controlleurs/controleur_authentification.dart';
import 'package:ora/screens/creecompte.dart';
import 'package:ora/screens/principal.dart';

class connecter extends StatefulWidget {
  static const String screenRoute = 'pageconnecter';
  const connecter({super.key});

  @override
  State<connecter> createState() => _connecterState();
}

class _connecterState extends State<connecter> {
  final _formkey = GlobalKey<FormState>();
  final ControleurAuthentification _controleurAuthentification =
      ControleurAuthentification();

  bool isLoading = false;
  String email = '';
  String motdepasse = '';
  Future<void> _motDePasseOublie() async {
    final emailControleur = TextEditingController(text: email);

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Mot de passe oublié"),
          content: TextField(
            controller: emailControleur,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(hintText: "Entrez votre email"),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("Annuler"),
            ),
            ElevatedButton(
              onPressed: () async {
                final emailSaisi = emailControleur.text.trim();

                if (emailSaisi.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Email obligatoire")),
                  );
                  return;
                }

                final emailRegex = RegExp(
                  r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
                );

                if (!emailRegex.hasMatch(emailSaisi)) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Format email incorrect")),
                  );
                  return;
                }

                try {
                  await _controleurAuthentification.reinitialiserMotDePasse(
                    email: emailSaisi,
                  );

                  if (!mounted) return;
                  Navigator.pop(context);

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        "Un email de réinitialisation a été envoyé",
                      ),
                    ),
                  );
                } on FirebaseAuthException catch (e) {
                  String message = "Une erreur s'est produite";

                  if (e.code == 'user-not-found') {
                    message = "Aucun compte trouvé avec cet email";
                  } else if (e.code == 'wrong-password') {
                    message = "Mot de passe incorrect";
                  } else if (e.code == 'invalid-email') {
                    message = "Email invalide";
                  } else if (e.code == 'network-request-failed') {
                    message = "Problème de connexion Internet";
                  } else {
                    message = "Erreur Firebase : ${e.code}";
                  }

                  if (!mounted) return;
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text(message)));
                } catch (e) {
                  if (!mounted) return;
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text("Erreur : $e")));
                }
              },
              child: const Text("Envoyer"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final hauteur = MediaQuery.of(context).size.height;

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
              height: hauteur,
              child: Stack(
                children: [
                  Positioned(
                    top: hauteur * 0.2,
                    left: hauteur * 0.11,
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
                          top: hauteur * 0.35,
                          left: hauteur * 0.01,
                          child: const Text(
                            "Email",
                            style: TextStyle(color: Colors.white, fontSize: 14),
                          ),
                        ),
                        Positioned(
                          top: hauteur * 0.38,
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
                          top: hauteur * 0.47,
                          left: hauteur * 0.01,
                          child: const Text(
                            "Mot de passe",
                            style: TextStyle(color: Colors.white, fontSize: 14),
                          ),
                        ),
                        Positioned(
                          top: hauteur * 0.5,
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
                              return null;
                            },
                          ),
                        ),
                        Positioned(
                          top: hauteur * 0.6,
                          right: hauteur * 0.165,
                          left: hauteur * 0.165,
                          child: ElevatedButton(
                            onPressed: () async {
                              if (isLoading) return;

                              if (_formkey.currentState!.validate()) {
                                setState(() {
                                  isLoading = true;
                                });

                                try {
                                  final userCredential =
                                      await _controleurAuthentification
                                          .seConnecter(
                                            email: email.trim(),
                                            motDePasse: motdepasse.trim(),
                                          );

                                  if (!mounted) return;

                                  final user = userCredential.user;

                                  if (user != null) {
                                    await user.reload();
                                    final userMisAJour =
                                        FirebaseAuth.instance.currentUser;

                                    if (userMisAJour != null &&
                                        !userMisAJour.emailVerified) {
                                      await FirebaseAuth.instance.signOut();
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            "Vérifiez votre email avant de vous connecter",
                                          ),
                                        ),
                                      );
                                      return;
                                    }

                                    Navigator.pushReplacementNamed(
                                      context,
                                      principal.screenRoute,
                                    );
                                  }
                                } on FirebaseAuthException catch (e) {
                                  String message;

                                  if (e.code == 'email-already-in-use') {
                                    message = "Cet email est déjà utilisé";
                                  } else if (e.code == 'invalid-email') {
                                    message = "Email invalide";
                                  } else if (e.code == 'weak-password') {
                                    message = "Mot de passe trop faible";
                                  } else if (e.code ==
                                      'operation-not-allowed') {
                                    message =
                                        "L'inscription par email/mot de passe n'est pas activée sur Firebase";
                                  } else if (e.code ==
                                      'network-request-failed') {
                                    message = "Problème de connexion Internet";
                                  } else if (e.code == 'too-many-requests') {
                                    message =
                                        "Trop de tentatives. Réessaie plus tard";
                                  } else {
                                    message = "Erreur Firebase : ${e.code}";
                                  }

                                  print(
                                    "FirebaseAuthException code: ${e.code}",
                                  );
                                  print(
                                    "FirebaseAuthException message: ${e.message}",
                                  );

                                  if (!mounted) return;
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text(message)),
                                  );
                                } catch (e) {
                                  if (!mounted) return;
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
                            child: Center(
                              child: Text(
                                isLoading ? "Connexion..." : "connecter",
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: Color.fromARGB(136, 10, 11, 22),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          top: hauteur * 0.8,
                          left: hauteur * 0.188,
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
                        Positioned(
                          top: hauteur * 0.777,
                          right: hauteur * 0.156,
                          child: GestureDetector(
                            onTap: _motDePasseOublie,
                            child: const Text(
                              "Mot de passe oublié ",
                              style: TextStyle(
                                color: Color.fromARGB(255, 26, 1, 1),
                                decoration: TextDecoration.underline,
                                fontSize: 13,
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
