import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:ora/screens/eau_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ora/controlleurs/controleur_eau.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ConfigurationHydratationPage extends StatefulWidget {
  static const String screenRoute = 'configuration_hydratation';

  const ConfigurationHydratationPage({super.key});

  @override
  State<ConfigurationHydratationPage> createState() =>
      _ConfigurationHydratationPageState();
}

class _ConfigurationHydratationPageState
    extends State<ConfigurationHydratationPage> {
  final TextEditingController controleurAge = TextEditingController();
  final TextEditingController controleurPoids = TextEditingController();
  @override
  void initState() {
    super.initState();
    chargerProfil();
  }

  String niveauActivite = 'normale';

  String? get utilisateurId => FirebaseAuth.instance.currentUser?.uid;

  String clePreference(String nom) => '${utilisateurId}_$nom';

  int calculerObjectifHydratation({
    required int age,
    required double poids,
    required String niveauActivite,
  }) {
    double litres = poids * 0.035;

    if (age < 12) {
      litres = poids * 0.03;
    }

    if (niveauActivite == 'sportif') {
      litres += 0.5;
    }

    if (niveauActivite == 'faible') {
      litres -= 0.2;
    }

    litres = litres.clamp(1.0, 4.0);

    return (litres / 0.25).round();
  }

  Future<void> chargerProfil() async {
    final prefs = await SharedPreferences.getInstance();

    controleurAge.text = (prefs.getInt(cle('profil_age')) ?? '').toString();

    controleurPoids.text = (prefs.getDouble(cle('profil_poids')) ?? '')
        .toString();

    niveauActivite = prefs.getString(cle('profil_activite')) ?? 'normale';

    if (!mounted) return;

    setState(() {});
  }

  String cle(String nom) {
    final uid = FirebaseAuth.instance.currentUser?.uid ?? 'guest';
    return '${uid}_$nom';
  }

  Future<void> enregistrerProfilHydratation() async {
    final age = int.tryParse(controleurAge.text.trim());
    final poids = double.tryParse(controleurPoids.text.trim());

    if (age == null || poids == null || age <= 0 || poids <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez vérifier l’âge et le poids.')),
      );
      return;
    }

    final objectif = calculerObjectifHydratation(
      age: age,
      poids: poids,
      niveauActivite: niveauActivite,
    );

    final uid = utilisateurId;
    if (uid == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Utilisateur non connecté.')),
      );
      return;
    }

    final prefs = await SharedPreferences.getInstance();

    await prefs.setBool(cle('profil_hydratation_configure'), true);
    await prefs.setInt(cle('profil_age'), age);
    await prefs.setDouble(cle('profil_poids'), poids);
    await prefs.setString(cle('profil_activite'), niveauActivite);
    await prefs.setInt(cle('objectif_hydratation'), objectif);
    final controleurEau = ControleurEau();
    await controleurEau.modifierObjectifAujourdhui(objectif);

    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('profil_hydratation')
        .doc('configuration')
        .set({
          'age': age,
          'poids': poids,
          'activite': niveauActivite,
          'objectifVerres': objectif,
          'updatedAt': DateTime.now().toIso8601String(),
        });

    if (!mounted) return;

    Navigator.pop(context, true);
  }

  @override
  void dispose() {
    controleurAge.dispose();
    controleurPoids.dispose();
    super.dispose();
  }

  Widget champSaisie({
    required String libelle,
    required TextEditingController controleur,
    required String suffixe,
  }) {
    return TextField(
      controller: controleur,
      keyboardType: TextInputType.number,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: libelle,
        suffixText: suffixe,
        labelStyle: const TextStyle(color: Colors.white70),
        suffixStyle: const TextStyle(color: Colors.white70),
        filled: true,
        fillColor: Colors.white.withOpacity(0.12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.18)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.18)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: Color(0xFF4FB3FF)),
        ),
      ),
    );
  }

  Widget carteActivite({
    required String valeur,
    required String titre,
    required IconData icone,
  }) {
    final estSelectionnee = niveauActivite == valeur;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            niveauActivite = valeur;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: estSelectionnee
                ? const Color(0xFF4FB3FF).withOpacity(0.35)
                : Colors.white.withOpacity(0.10),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: estSelectionnee
                  ? const Color(0xFF4FB3FF)
                  : Colors.white.withOpacity(0.16),
            ),
          ),
          child: Column(
            children: [
              Icon(icone, color: Colors.white, size: 24),
              const SizedBox(height: 6),
              Text(
                titre,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  BoxDecoration decorationCarte() {
    return BoxDecoration(
      color: Colors.white.withOpacity(0.12),
      borderRadius: BorderRadius.circular(28),
      border: Border.all(color: Colors.white.withOpacity(0.16)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text(
          'Profil hydratation',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('images/b2.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(22),
            child: Column(
              children: [
                const SizedBox(height: 24),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(22),
                  decoration: decorationCarte(),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.water_drop_rounded,
                        color: Color(0xFF4FB3FF),
                        size: 58,
                      ),
                      const SizedBox(height: 14),
                      const Text(
                        'Personnaliser l’objectif',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 21,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'ORA calcule votre besoin en eau selon l’âge, le poids et le niveau d’activité.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.75),
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                champSaisie(
                  libelle: 'Âge',
                  controleur: controleurAge,
                  suffixe: 'ans',
                ),
                const SizedBox(height: 16),
                champSaisie(
                  libelle: 'Poids',
                  controleur: controleurPoids,
                  suffixe: 'kg',
                ),
                const SizedBox(height: 22),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Niveau d’activité',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 15,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    carteActivite(
                      valeur: 'faible',
                      titre: 'Faible',
                      icone: Icons.self_improvement,
                    ),
                    const SizedBox(width: 10),
                    carteActivite(
                      valeur: 'normale',
                      titre: 'Normal',
                      icone: Icons.directions_walk,
                    ),
                    const SizedBox(width: 10),
                    carteActivite(
                      valeur: 'sportif',
                      titre: 'Sportif',
                      icone: Icons.directions_run,
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: enregistrerProfilHydratation,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4FB3FF),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(22),
                      ),
                    ),
                    child: const Text(
                      'Continuer',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
