import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:ora/controlleurs/controleur_profil.dart';
import 'package:ora/models/modele_utilisateur.dart';
import 'package:ora/screens/principal.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
    _loadImage();
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("profile.load_error".tr(args: ["$e"]))),
      );
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
    final prefs = await SharedPreferences.getInstance();

final uid = FirebaseAuth.instance.currentUser!.uid;

await prefs.setString(
  '${uid}_photo_profil',
  result.files.single.path!,
);
  }
  Future<void> _loadImage() async {
  final prefs = await SharedPreferences.getInstance();

final uid = FirebaseAuth.instance.currentUser!.uid;

final path = prefs.getString(
  '${uid}_photo_profil',
);

  if (path != null) {
    setState(() {
      _imageFile = File(path);
    });
  }
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
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("profile.photo_deleted".tr())));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("profile.delete_error".tr(args: ["$e"]))),
      );
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
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("profile.need_password".tr())));
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

      String message = "profile.updated".tr();
      if (emailChanged) {
        message = "profile.updated_email".tr();
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));

      Navigator.pushReplacementNamed(context, principal.screenRoute);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("profile.save_error".tr(args: ["$e"]))),
      );
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
              child: Text("profile.change_photo".tr()),
            ),
            if (_photoUrl.isNotEmpty || _imageFile != null)
              OutlinedButton(
                onPressed: _isLoading ? null : _removePhoto,
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: const BorderSide(color: Colors.white),
                ),
                child: Text("profile.delete_photo".tr()),
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
                        Text(
                          "profile.title".tr(),
                          style: const TextStyle(
                            fontSize: 42,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _buildAvatar(),
                        const SizedBox(height: 24),

                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "profile.nom".tr(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: _nomCtrl,
                          decoration: _inputDecoration("profile.nom".tr()),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return "profile.nom_required".tr();
                            }
                            if (value.trim().length < 2) {
                              return "profile.nom_short".tr();
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "profile.prenom".tr(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: _prenomCtrl,
                          decoration: _inputDecoration("profile.prenom".tr()),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return "profile.prenom_required".tr();
                            }
                            if (value.trim().length < 2) {
                              return "profile.prenom_short".tr();
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "profile.email".tr(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: _emailCtrl,
                          keyboardType: TextInputType.emailAddress,
                          decoration: _inputDecoration("profile.email".tr()),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return "profile.email_required".tr();
                            }
                            if (!_controleur.emailValide(value)) {
                              return "profile.email_invalid".tr();
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "profile.birth".tr(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: _birthCtrl,
                          readOnly: true,
                          onTap: _selectBirthDate,
                          decoration: _inputDecoration(
                            "profile.birth_hint".tr(),
                            suffixIcon: const Icon(
                              Icons.calendar_today,
                              color: Colors.black54,
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),

                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "profile.current_password".tr(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: _currentPasswordCtrl,
                          obscureText: _obscureCurrentPassword,
                          decoration: _inputDecoration(
                            "profile.current_password".tr(),
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

                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "profile.new_password".tr(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: _newPasswordCtrl,
                          obscureText: _obscureNewPassword,
                          decoration: _inputDecoration(
                            "profile.new_password".tr(),
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
                              return "profile.password_invalid".tr();
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "profile.confirm_password".tr(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: _confirmPasswordCtrl,
                          obscureText: _obscureConfirmPassword,
                          decoration: _inputDecoration(
                            "profile.confirm_password".tr(),
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
                              return "profile.password_not_match".tr();
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
                            child: Text(
                              "profile.save".tr(),
                              style: const TextStyle(
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
