import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:ora/screens/principal.dart';
import 'package:ora/screens/statistiques_admin.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

class AdminHome extends StatelessWidget {
  static const String screenRoute = 'pageadmin';

  const AdminHome({super.key});

  Future<void> ajouterUtilisateur(BuildContext context) async {
    final formKey = GlobalKey<FormState>();

    final nomController = TextEditingController();
    final prenomController = TextEditingController();
    final emailController = TextEditingController();
    final motDePasseController = TextEditingController();

    String roleSelectionne = 'user';

    await showDialog(
      context: context,
      builder: (contextDialog) {
        return StatefulBuilder(
          builder: (contextDialog, setStateDialog) {
            return AlertDialog(
              backgroundColor: const Color.fromARGB(255, 197, 179, 252),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
              title: Text("admin.add_user".tr()),
              content: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        controller: nomController,
                        decoration: InputDecoration(
                          labelText: "auth.last_name".tr(),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return "auth.last_name_required".tr();
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: prenomController,
                        decoration: InputDecoration(
                          labelText: "auth.first_name".tr(),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return "auth.first_name_required".tr();
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          labelText: "auth.email".tr(),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return "auth.email_required".tr();
                          }

                          final emailRegex = RegExp(
                            r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
                          );

                          if (!emailRegex.hasMatch(value.trim())) {
                            return "auth.invalid_email".tr();
                          }

                          return null;
                        },
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: motDePasseController,
                        obscureText: true,
                        decoration: InputDecoration(
                          labelText: "auth.password".tr(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "auth.password_required".tr();
                          }
                          if (value.length < 6) {
                            return "auth.password_too_short".tr();
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 10),
                      DropdownButtonFormField<String>(
                        value: roleSelectionne,
                        decoration: InputDecoration(
                          labelText: "admin.user_role".tr(),
                        ),
                        items: [
                          DropdownMenuItem(
                            value: 'user',
                            child: Text("admin.role_user".tr()),
                          ),
                          DropdownMenuItem(
                            value: 'admin',
                            child: Text("admin.role_admin".tr()),
                          ),
                        ],
                        onChanged: (value) {
                          if (value != null) {
                            setStateDialog(() {
                              roleSelectionne = value;
                            });
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(contextDialog);
                  },
                  child: Text("app.cancel".tr()),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (!formKey.currentState!.validate()) {
                      return;
                    }

                    FirebaseApp? secondaryApp;

                    try {
                      try {
                        secondaryApp = Firebase.app('SecondaryApp');
                      } catch (e) {
                        secondaryApp = await Firebase.initializeApp(
                          name: 'SecondaryApp',
                          options: Firebase.app().options,
                        );
                      }

                      final secondaryAuth = FirebaseAuth.instanceFor(
                        app: secondaryApp,
                      );

                      final userCredential = await secondaryAuth
                          .createUserWithEmailAndPassword(
                            email: emailController.text.trim(),
                            password: motDePasseController.text.trim(),
                          );

                      final nouvelUtilisateur = userCredential.user;

                      if (nouvelUtilisateur == null) {
                        throw Exception("errors.not_found".tr());
                      }

                      await FirebaseFirestore.instance
                          .collection('users')
                          .doc(nouvelUtilisateur.uid)
                          .set({
                            'nom': nomController.text.trim(),
                            'prenom': prenomController.text.trim(),
                            'email': emailController.text.trim(),
                            'role': roleSelectionne,
                            'dateCreation': Timestamp.now(),
                          });

                      await secondaryAuth.signOut();

                      if (secondaryApp.name != defaultFirebaseAppName) {
                        await secondaryApp.delete();
                      }

                      if (!contextDialog.mounted) return;
                      Navigator.pop(contextDialog);

                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("admin.user_added".tr())),
                      );
                    } on FirebaseAuthException catch (e) {
                      String message = "errors.general".tr();

                      if (e.code == 'email-already-in-use') {
                        message = "auth.email_already_in_use".tr();
                      } else if (e.code == 'invalid-email') {
                        message = "auth.invalid_email".tr();
                      } else if (e.code == 'weak-password') {
                        message = "auth.weak_password".tr();
                      } else if (e.code == 'operation-not-allowed') {
                        message = "errors.permission".tr();
                      } else if (e.code == 'network-request-failed') {
                        message = "errors.network".tr();
                      }

                      if (!contextDialog.mounted) return;
                      ScaffoldMessenger.of(
                        contextDialog,
                      ).showSnackBar(SnackBar(content: Text(message)));
                    } catch (e) {
                      if (!contextDialog.mounted) return;
                      ScaffoldMessenger.of(contextDialog).showSnackBar(
                        SnackBar(content: Text("${"app.error".tr()} : $e")),
                      );
                    }
                  },
                  child: Text("app.save".tr()),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> supprimerUtilisateur(
    BuildContext context,
    String uid,
    String nomComplet,
  ) async {
    final confirmer = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color.fromARGB(255, 197, 179, 252),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
          title: Text("app.confirm".tr()),
          content: Text("${"admin.confirm_delete_user".tr()} $nomComplet ؟"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text("app.cancel".tr()),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text("app.delete".tr()),
            ),
          ],
        );
      },
    );

    if (confirmer == true) {
      await FirebaseFirestore.instance.collection('users').doc(uid).delete();

      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("admin.user_deleted".tr())));
    }
  }

  Future<void> changerRole(
    BuildContext context,
    String uid,
    String roleActuel,
  ) async {
    final nouveauRole = roleActuel == 'admin' ? 'user' : 'admin';

    await FirebaseFirestore.instance.collection('users').doc(uid).update({
      'role': nouveauRole,
    });

    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          "${"admin.user_role".tr()} : ${nouveauRole == 'admin' ? "admin.role_admin".tr() : "admin.role_user".tr()}",
        ),
      ),
    );
  }

  Widget carteUtilisateur({
    required BuildContext context,
    required String uid,
    required String nom,
    required String prenom,
    required String email,
    required String role,
  }) {
    final nomComplet = "$nom $prenom".trim();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.14),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withOpacity(0.20)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: const Color.fromARGB(180, 88, 70, 142),
                child: const Icon(Icons.person, color: Colors.white),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      nomComplet.isEmpty ? "app.unknown".tr() : nomComplet,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 19,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      email,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert, color: Colors.white),
                onSelected: (value) async {
                  if (value == 'changer_role') {
                    await changerRole(context, uid, role);
                  } else if (value == 'supprimer') {
                    await supprimerUtilisateur(context, uid, nomComplet);
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'changer_role',
                    child: Text(
                      role == 'admin'
                          ? "admin.role_user".tr()
                          : "admin.role_admin".tr(),
                    ),
                  ),
                  PopupMenuItem(
                    value: 'supprimer',
                    child: Text("app.delete".tr()),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.badge_outlined, color: Colors.white70, size: 18),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  "UID: $uid",
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(
                Icons.admin_panel_settings_outlined,
                color: Colors.white70,
                size: 18,
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: role == 'admin'
                      ? const Color.fromARGB(180, 103, 169, 255)
                      : const Color.fromARGB(180, 88, 70, 142),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  role == 'admin'
                      ? "admin.role_admin".tr()
                      : "admin.role_user".tr(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget titrePage() {
    return Column(
      children: [
        const SizedBox(height: 10),
        Text(
          "admin.title".tr(),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 34,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          "admin.users".tr(),
          style: const TextStyle(color: Colors.white70, fontSize: 17),
        ),
      ],
    );
  }

  Widget statistiques(int total, int admins, int users) {
    Widget box(String titre, String valeur) {
      return Expanded(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 6),
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.14),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.20)),
          ),
          child: Column(
            children: [
              Text(
                valeur,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                titre,
                style: const TextStyle(color: Colors.white70, fontSize: 13),
              ),
            ],
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: Row(
        children: [
          box("app.total".tr(), total.toString()),
          box("admin.role_admin".tr(), admins.toString()),
          box("admin.role_user".tr(), users.toString()),
        ],
      ),
    );
  }

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
            icon: const Icon(Icons.bar_chart_rounded, color: Colors.white),
            onPressed: () {
              Navigator.pushNamed(context, StatistiquesAdminPage.screenRoute);
            },
          ),
          const SizedBox(width: 8),
          IconButton(
            style: const ButtonStyle(
              backgroundColor: WidgetStatePropertyAll<Color>(
                Color.fromARGB(194, 88, 70, 142),
              ),
            ),
            icon: const Icon(Icons.person_add, color: Colors.white),
            onPressed: () {
              ajouterUtilisateur(context);
            },
          ),
          const SizedBox(width: 8),
        ],
        leading: IconButton(
          style: const ButtonStyle(
            backgroundColor: WidgetStatePropertyAll<Color>(
              Color.fromARGB(194, 88, 70, 142),
            ),
          ),
          icon: const Icon(Icons.chevron_left, color: Colors.white),
          onPressed: () {
            Navigator.pushReplacementNamed(context, principal.screenRoute);
          },
        ),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("images/b5.png"),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: FirebaseFirestore.instance
                .collection('users')
                .orderBy('nom')
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                );
              }

              if (snapshot.hasError) {
                return Center(
                  child: Text(
                    "${"app.error".tr()} : ${snapshot.error}",
                    style: const TextStyle(color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                );
              }

              final docs = snapshot.data?.docs ?? [];

              final total = docs.length;
              final admins = docs
                  .where((doc) => (doc.data()['role'] ?? 'user') == 'admin')
                  .length;
              final users = total - admins;

              return Column(
                children: [
                  titrePage(),
                  const SizedBox(height: 20),
                  statistiques(total, admins, users),
                  const SizedBox(height: 18),
                  Expanded(
                    child: docs.isEmpty
                        ? Center(
                            child: Text(
                              "app.empty".tr(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                              ),
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.only(bottom: 20),
                            itemCount: docs.length,
                            itemBuilder: (context, index) {
                              final doc = docs[index];
                              final data = doc.data();

                              final nom = data['nom'] ?? '';
                              final prenom = data['prenom'] ?? '';
                              final email = data['email'] ?? '';
                              final role = data['role'] ?? 'user';

                              return carteUtilisateur(
                                context: context,
                                uid: doc.id,
                                nom: nom,
                                prenom: prenom,
                                email: email,
                                role: role,
                              );
                            },
                          ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
