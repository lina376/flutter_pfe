import 'package:flutter/material.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:ora/screens/principal.dart';

class Profil extends StatefulWidget {
  static const String screenRoute = 'pageprofil';
  const Profil({super.key});

  @override
  State<Profil> createState() => _ProfilState();
}

class _ProfilState extends State<Profil> {
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

  final _formkey = GlobalKey<FormState>();

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
            Navigator.pushNamed(context, principal.screenRoute);
          },
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
          child: SingleChildScrollView(
            child: SizedBox(
              height: MediaQuery.of(context).size.height,
              child: Form(
                key: _formkey,
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
                      child: ProfileAvatar(),
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
                          decoration: InputDecoration(
                            hintText: "Mot de passe",
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
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
                      top: MediaQuery.of(context).size.height * 0.8,

                      left: MediaQuery.of(context).size.height * 0.16,
                      child: ElevatedButton(
                        onPressed: () {
                          if (_formkey.currentState!.validate()) {
                            Navigator.pushNamed(context, principal.screenRoute);
                          }
                        },
                        child: Text(
                          "Sauvegarder",
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
        backgroundImage: _imageFile != null ? FileImage(_imageFile!) : null,
        child: _imageFile == null ? const Icon(Icons.person, size: 40) : null,
      ),
    );
  }
}
