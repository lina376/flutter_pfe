import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:ora/screens/principal.dart';

class Profil extends StatefulWidget {
  static const String screenRoute = 'pageprofil';
  const Profil({super.key});

  @override
  State<Profil> createState() => _ProfilState();
}

class _ProfilState extends State<Profil> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nomCtrl = TextEditingController();
  final TextEditingController _prenomCtrl = TextEditingController();
  final TextEditingController _emailCtrl = TextEditingController();
  final TextEditingController _birthCtrl = TextEditingController();

  DateTime? _birthDate;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void dispose() {
    _nomCtrl.dispose();
    _prenomCtrl.dispose();
    _emailCtrl.dispose();
    _birthCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;

        _nomCtrl.text = (data['nom'] ?? '').toString();
        _prenomCtrl.text = (data['prenom'] ?? '').toString();
        _emailCtrl.text = (data['email'] ?? user.email ?? '').toString();

        if (data['dateNaissance'] != null &&
            data['dateNaissance'].toString().isNotEmpty) {
          final parsed = DateTime.tryParse(data['dateNaissance']);
          if (parsed != null) {
            _birthDate = parsed;
            _birthCtrl.text =
                "${parsed.day.toString().padLeft(2, '0')}/${parsed.month.toString().padLeft(2, '0')}/${parsed.year}";
          }
        }
      } else {
        _emailCtrl.text = user.email ?? '';
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Erreur chargement profil : $e")));
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _selectBirthDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _birthDate ?? DateTime(2005, 1, 1),
      firstDate: DateTime(1950, 1, 1),
      lastDate: DateTime.now(),
    );

    if (picked == null) return;

    setState(() {
      _birthDate = picked;
      _birthCtrl.text =
          "${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}";
    });
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'nom': _nomCtrl.text.trim(),
        'prenom': _prenomCtrl.text.trim(),
        'email': _emailCtrl.text.trim(),
        'dateNaissance': _birthDate?.toIso8601String() ?? '',
        'updatedAt': FieldValue.serverTimestamp(),
        'createdAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Profil mis à jour avec succès")),
      );

      Navigator.pushReplacementNamed(context, principal.screenRoute);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Erreur sauvegarde : $e")));
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  InputDecoration _inputDecoration(String hint, {Widget? suffixIcon}) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Colors.white,
      suffixIcon: suffixIcon,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
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
            Navigator.pushReplacementNamed(context, principal.screenRoute);
          },
          tooltip: 'chevron',
          iconSize: 40,
          constraints: const BoxConstraints(minHeight: 50, minWidth: 50),
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
          child: _isLoading
              ? const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 20,
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        const SizedBox(height: 10),
                        const Text(
                          "Profil",
                          style: TextStyle(
                            fontSize: 42,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        const ProfileAvatar(),
                        const SizedBox(height: 24),

                        const Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "Nom",
                            style: TextStyle(color: Colors.white, fontSize: 15),
                          ),
                        ),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: _nomCtrl,
                          decoration: _inputDecoration("Nom"),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return "Nom obligatoire";
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        const Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "Prénom",
                            style: TextStyle(color: Colors.white, fontSize: 15),
                          ),
                        ),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: _prenomCtrl,
                          decoration: _inputDecoration("Prénom"),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return "Prénom obligatoire";
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        const Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "Email",
                            style: TextStyle(color: Colors.white, fontSize: 15),
                          ),
                        ),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: _emailCtrl,
                          readOnly: true,
                          decoration: _inputDecoration("Email"),
                        ),
                        const SizedBox(height: 16),

                        const Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "Date de naissance",
                            style: TextStyle(color: Colors.white, fontSize: 15),
                          ),
                        ),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: _birthCtrl,
                          readOnly: true,
                          onTap: _selectBirthDate,
                          decoration: _inputDecoration(
                            "JJ/MM/AAAA",
                            suffixIcon: const Icon(
                              Icons.calendar_today,
                              color: Colors.black54,
                            ),
                          ),
                        ),
                        const SizedBox(height: 30),

                        SizedBox(
                          width: 180,
                          height: 48,
                          child: ElevatedButton(
                            onPressed: _saveProfile,
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
                            child: const Text(
                              "Sauvegarder",
                              style: TextStyle(
                                color: Color.fromARGB(136, 10, 11, 22),
                                fontWeight: FontWeight.bold,
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
    );
  }
}

class ProfileAvatar extends StatefulWidget {
  const ProfileAvatar({super.key});

  @override
  State<ProfileAvatar> createState() => _ProfileAvatarState();
}

class _ProfileAvatarState extends State<ProfileAvatar> {
  File? _imageFile;

  Future<void> _pick() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.image);
    if (result == null) return;

    setState(() {
      _imageFile = File(result.files.single.path!);
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _pick,
      child: CircleAvatar(
        radius: 45,
        backgroundColor: Colors.white,
        backgroundImage: _imageFile != null ? FileImage(_imageFile!) : null,
        child: _imageFile == null
            ? const Icon(Icons.person, size: 40, color: Colors.black54)
            : null,
      ),
    );
  }
}
