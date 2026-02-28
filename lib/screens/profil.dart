import 'package:flutter/material.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart';

class Profil extends StatefulWidget {
  const Profil({super.key});

  @override
  State<Profil> createState() => _ProfilState();
}

class _ProfilState extends State<Profil> {
  final _formKey = GlobalKey<FormState>();
  DateTime? _birthDate;
  final TextEditingController _birthCtrl = TextEditingController();

  @override
  void dispose() {
    _birthCtrl.dispose();
    super.dispose();
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
      _birthCtrl.text = "${picked.day}/${picked.month}/${picked.year}";
    });
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
            icon: const Icon(Icons.home, color: Colors.white),
            onPressed: () {},
            tooltip: 'home',
            iconSize: 40,
            constraints: const BoxConstraints(minHeight: 50, minWidth: 50),
          ),
        ],
        leading: IconButton(
          style: const ButtonStyle(
            backgroundColor: WidgetStatePropertyAll<Color>(
              Color.fromARGB(194, 88, 70, 142),
            ),
          ),
          icon: const Icon(Icons.chevron_left, color: Colors.white),
          onPressed: () {},
          tooltip: 'chevron',
          iconSize: 40,
          constraints: const BoxConstraints(minHeight: 50, minWidth: 50),
        ),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("images/b5.png"),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: Form(
            key: _formKey,
            child: Stack(
              children: [
                Positioned(
                  top: MediaQuery.of(context).size.height * 0.0001,
                  left: MediaQuery.of(context).size.height * 0.165,
                  child: Text(
                    "Profil",
                    style: TextStyle(
                      fontSize: 46,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Positioned(
                  top: MediaQuery.of(context).size.height * 0.065,
                  left: MediaQuery.of(context).size.height * 0.18,
                  child: ProfileAvatarFP(),
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
                  top: MediaQuery.of(context).size.height * 0.23,
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
                  ),
                ),
                Positioned(
                  top: MediaQuery.of(context).size.height * 0.3,
                  left: MediaQuery.of(context).size.height * 0.01,
                  child: Text(
                    "Prénom",
                    style: TextStyle(color: Colors.white, fontSize: 14),
                  ),
                ),
                Positioned(
                  top: MediaQuery.of(context).size.height * 0.33,
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
                  ),
                ),
                Positioned(
                  top: MediaQuery.of(context).size.height * 0.4,
                  left: MediaQuery.of(context).size.height * 0.01,
                  child: Text(
                    "Email",
                    style: TextStyle(color: Colors.white, fontSize: 14),
                  ),
                ),

                Positioned(
                  top: MediaQuery.of(context).size.height * 0.43,
                  left: MediaQuery.of(context).size.height * 0.01,
                  right: MediaQuery.of(context).size.height * 0.01,
                  child: TextFormField(
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    decoration: InputDecoration(
                      labelText: "Email",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(width: 0.5),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    keyboardType: TextInputType.emailAddress,

                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Email obligatoire";
                      }

                      if (!value.contains("@")) {
                        return "Email doit contenir @";
                      }

                      return null;
                    },
                  ),
                ),

                Positioned(
                  top: MediaQuery.of(context).size.height * 0.52,
                  left: MediaQuery.of(context).size.height * 0.01,
                  child: Text(
                    "Mot de passe",
                    style: TextStyle(color: Colors.white, fontSize: 14),
                  ),
                ),
                Positioned(
                  top: MediaQuery.of(context).size.height * 0.55,
                  left: MediaQuery.of(context).size.height * 0.01,
                  right: MediaQuery.of(context).size.height * 0.01,
                  child: Form(
                    child: TextFormField(
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: "Mot de passe",
                        border: OutlineInputBorder(
                          borderSide: BorderSide(width: 0.5),
                          borderRadius: BorderRadius.all(Radius.circular(8)),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),

                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Mot de passe obligatoire";
                        }

                        if (value.length < 8) {
                          return "Minimum 8 caractères";
                        }

                        if (!RegExp(r'[A-Z]').hasMatch(value)) {
                          return "Au moins une lettre majuscule";
                        }

                        if (!RegExp(r'[0-9]').hasMatch(value)) {
                          return "Au moins un chiffre";
                        }

                        return null;
                      },

                      autovalidateMode: AutovalidateMode.onUserInteraction,
                    ),
                  ),
                ),
                Positioned(
                  top: MediaQuery.of(context).size.height * 0.635,
                  left: MediaQuery.of(context).size.height * 0.01,
                  child: Text(
                    "Date de naissance",
                    style: TextStyle(color: Colors.white, fontSize: 14),
                  ),
                ),
                Positioned(
                  top: MediaQuery.of(context).size.height * 0.665,
                  left: MediaQuery.of(context).size.height * 0.01,
                  right: MediaQuery.of(context).size.height * 0.01,
                  child: TextFormField(
                    readOnly: true,
                    onTap: _selectBirthDate,
                    decoration: InputDecoration(
                      labelText: "JJ/MM/AAAA",
                      suffixIcon: const Icon(Icons.calendar_today),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    controller: TextEditingController(
                      text: _birthDate == null
                          ? ""
                          : "${_birthDate!.day}/${_birthDate!.month}/${_birthDate!.year}",
                    ),
                  ),
                ),
                Positioned(
                  bottom: MediaQuery.of(context).size.height * 0.05,

                  left: MediaQuery.of(context).size.height * 0.16,
                  child: ElevatedButton(
                    onPressed: () {},
                    child: Text(
                      "Sauvegarder",
                      style: TextStyle(
                        color: const Color.fromARGB(136, 10, 11, 22),
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      shape: StadiumBorder(),
                      backgroundColor: const Color.fromARGB(172, 153, 129, 180),
                      elevation: 1,
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

class ProfileAvatarFP extends StatefulWidget {
  const ProfileAvatarFP({super.key});

  @override
  State<ProfileAvatarFP> createState() => _ProfileAvatarFPState();
}

class _ProfileAvatarFPState extends State<ProfileAvatarFP> {
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
        backgroundImage: _imageFile != null ? FileImage(_imageFile!) : null,
        child: _imageFile == null ? const Icon(Icons.person, size: 40) : null,
      ),
    );
  }
}
