import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:ora/controlleurs/controleur_profil.dart';
import 'package:ora/models/modele_utilisateur.dart';
import 'package:ora/screens/principal.dart';

class Profil extends StatefulWidget {
  static const String screenRoute = 'pageprofil';

  const Profil({super.key});

  @override
  State<Profil> createState() => _ProfilState();
}

class _ProfilState extends State<Profil> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final ControleurProfil _controleur = ControleurProfil();

  final TextEditingController _nomCtrl = TextEditingController();
  final TextEditingController _prenomCtrl = TextEditingController();
  final TextEditingController _emailCtrl = TextEditingController();
  final TextEditingController _birthCtrl = TextEditingController();
  final TextEditingController _currentPasswordCtrl = TextEditingController();
  final TextEditingController _newPasswordCtrl = TextEditingController();
  final TextEditingController _confirmPasswordCtrl = TextEditingController();

  DateTime? _birthDate;
  bool _isLoading = false;
  bool _obscureCurrentPassword = true;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;

  String _emailInitial = '';
  String _photoUrl = '';
  File? _imageFile;

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
    _currentPasswordCtrl.dispose();
    _newPasswordCtrl.dispose();
    _confirmPasswordCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final user = await _controleur.chargerProfil();

      if (user != null) {
        _nomCtrl.text = user.nom;
        _prenomCtrl.text = user.prenom;
        _emailCtrl.text = user.email;
        _emailInitial = user.email;
        _photoUrl = user.photoUrl;

        if (user.dateNaissance.isNotEmpty) {
          final parsed = DateTime.tryParse(user.dateNaissance);
          if (parsed != null) {
            _birthDate = parsed;
            _birthCtrl.text =
                "${parsed.day.toString().padLeft(2, '0')}/${parsed.month.toString().padLeft(2, '0')}/${parsed.year}";
          } else {
            _birthCtrl.text = '';
          }
        } else {
          _birthCtrl.text = '';
        }
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Erreur chargement profil : $e")));
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
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

  Future<void> _pickImage() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.image);
    if (result == null || result.files.single.path == null) return;

    setState(() {
      _imageFile = File(result.files.single.path!);
    });
  }

  Future<void> _removePhoto() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await _controleur.supprimerPhotoProfil();

      setState(() {
        _imageFile = null;
        _photoUrl = '';
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Photo supprimée avec succès")),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Erreur suppression photo : $e")));
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    final emailChanged = _emailCtrl.text.trim() != _emailInitial.trim();
    final wantsPasswordChange = _newPasswordCtrl.text.trim().isNotEmpty;

    if ((emailChanged || wantsPasswordChange) &&
        _currentPasswordCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Entre le mot de passe actuel pour valider les changements sensibles",
          ),
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      String photoFinale = _photoUrl;

      if (_imageFile != null) {
        photoFinale = await _controleur.televerserPhotoProfil(_imageFile!);
      }

      final utilisateurModel = UserModel(
        nom: _nomCtrl.text.trim(),
        prenom: _prenomCtrl.text.trim(),
        email: _emailCtrl.text.trim(),
        dateNaissance: _birthDate?.toIso8601String() ?? '',
        photoUrl: photoFinale,
      );

      await _controleur.mettreAJourProfil(utilisateurModel: utilisateurModel);

      if (emailChanged) {
        await _controleur.mettreAJourEmail(
          nouvelEmail: _emailCtrl.text.trim(),
          motDePasseActuel: _currentPasswordCtrl.text.trim(),
        );
      }

      if (wantsPasswordChange) {
        await _controleur.mettreAJourMotDePasse(
          motDePasseActuel: _currentPasswordCtrl.text.trim(),
          nouveauMotDePasse: _newPasswordCtrl.text.trim(),
        );
      }

      _emailInitial = _emailCtrl.text.trim();
      _photoUrl = photoFinale;
      _imageFile = null;

      _currentPasswordCtrl.clear();
      _newPasswordCtrl.clear();
      _confirmPasswordCtrl.clear();

      if (!mounted) return;

      String message = "Profil mis à jour avec succès";
      if (emailChanged) {
        message =
            "Profil mis à jour. Vérifie aussi ta boîte mail pour confirmer le nouvel email.";
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));

      Navigator.pushReplacementNamed(context, principal.screenRoute);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Erreur sauvegarde : $e")));
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
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

  Widget _buildAvatar() {
    ImageProvider? imageProvider;

    if (_imageFile != null) {
      imageProvider = FileImage(_imageFile!);
    } else if (_photoUrl.isNotEmpty) {
      imageProvider = NetworkImage(_photoUrl);
    }

    return Column(
      children: [
        GestureDetector(
          onTap: _pickImage,
          child: CircleAvatar(
            radius: 45,
            backgroundColor: Colors.white,
            backgroundImage: imageProvider,
            child: imageProvider == null
                ? const Icon(Icons.person, size: 40, color: Colors.black54)
                : null,
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 10,
          children: [
            OutlinedButton(
              onPressed: _isLoading ? null : _pickImage,
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white,
                side: const BorderSide(color: Colors.white),
              ),
              child: const Text("Changer photo"),
            ),
            if (_photoUrl.isNotEmpty || _imageFile != null)
              OutlinedButton(
                onPressed: _isLoading ? null : _removePhoto,
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: const BorderSide(color: Colors.white),
                ),
                child: const Text("Supprimer photo"),
              ),
          ],
        ),
      ],
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
                        _buildAvatar(),
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
                            if (value.trim().length < 2) {
                              return "Nom trop court";
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
                            if (value.trim().length < 2) {
                              return "Prénom trop court";
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
                          keyboardType: TextInputType.emailAddress,
                          decoration: _inputDecoration("Email"),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return "Email obligatoire";
                            }
                            if (!_controleur.emailValide(value)) {
                              return "Format email invalide";
                            }
                            return null;
                          },
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
                        const SizedBox(height: 24),

                        const Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "Mot de passe actuel",
                            style: TextStyle(color: Colors.white, fontSize: 15),
                          ),
                        ),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: _currentPasswordCtrl,
                          obscureText: _obscureCurrentPassword,
                          decoration: _inputDecoration(
                            "Mot de passe actuel",
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscureCurrentPassword
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscureCurrentPassword =
                                      !_obscureCurrentPassword;
                                });
                              },
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        const Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "Nouveau mot de passe",
                            style: TextStyle(color: Colors.white, fontSize: 15),
                          ),
                        ),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: _newPasswordCtrl,
                          obscureText: _obscureNewPassword,
                          decoration: _inputDecoration(
                            "Nouveau mot de passe",
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscureNewPassword
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscureNewPassword = !_obscureNewPassword;
                                });
                              },
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) return null;
                            if (!_controleur.motDePasseValide(value)) {
                              return "Le mot de passe doit contenir au moins 6 caractères";
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        const Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "Confirmer le mot de passe",
                            style: TextStyle(color: Colors.white, fontSize: 15),
                          ),
                        ),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: _confirmPasswordCtrl,
                          obscureText: _obscureConfirmPassword,
                          decoration: _inputDecoration(
                            "Confirmer le mot de passe",
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscureConfirmPassword
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscureConfirmPassword =
                                      !_obscureConfirmPassword;
                                });
                              },
                            ),
                          ),
                          validator: (value) {
                            if (_newPasswordCtrl.text.trim().isEmpty &&
                                (value == null || value.isEmpty)) {
                              return null;
                            }
                            if (value != _newPasswordCtrl.text) {
                              return "Les mots de passe ne correspondent pas";
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 30),

                        SizedBox(
                          width: 180,
                          height: 48,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _saveProfile,
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
