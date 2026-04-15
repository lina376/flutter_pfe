import 'package:flutter/material.dart';
import 'package:ora/controlleurs/controleur_alarme.dart';

class AjouterAlarmePage extends StatefulWidget {
  const AjouterAlarmePage({super.key});
  static const String screenRoute = 'pageajouteralarme';
  @override
  State<AjouterAlarmePage> createState() => _AjouterAlarmePageState();
}

class _AjouterAlarmePageState extends State<AjouterAlarmePage> {
  final ControleurAlarme _controleur = ControleurAlarme();

  final TextEditingController _titre = TextEditingController();
  final TextEditingController _note = TextEditingController();

  TimeOfDay _heure = TimeOfDay.now();

  List<String> jours = [];

  final joursList = ["lun", "mar", "mer", "jeu", "ven", "sam", "dim"];

  void _toggleJour(String j) {
    setState(() {
      jours.contains(j) ? jours.remove(j) : jours.add(j);
    });
  }

  Future<void> _choisirHeure() async {
    final h = await showTimePicker(context: context, initialTime: _heure);
    if (h != null) setState(() => _heure = h);
  }

  Future<void> _save() async {
    if (_titre.text.isEmpty) return;

    await _controleur.ajouterAlarme(
      titre: _titre.text,
      note: _note.text,
      heure: _heure.hour,
      minute: _heure.minute,
      jours: jours.isEmpty ? "quotidien" : jours.join(","),
    );

    if (!mounted) return;
    Navigator.pop(context, true);
  }

  Widget chip(String j) {
    final selected = jours.contains(j);

    return GestureDetector(
      onTap: () => _toggleJour(j),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? Colors.purple : Colors.white24,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(j, style: const TextStyle(color: Colors.white)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,

      appBar: AppBar(
        title: const Text("Ajouter alarme"),
        backgroundColor: Colors.transparent,
        elevation: 0,
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
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                TextField(
                  controller: _titre,
                  decoration: const InputDecoration(hintText: "Titre"),
                ),
                TextField(
                  controller: _note,
                  decoration: const InputDecoration(hintText: "Note"),
                ),
                const SizedBox(height: 20),

                ElevatedButton(
                  onPressed: _choisirHeure,
                  child: Text(_heure.format(context)),
                ),

                const SizedBox(height: 20),

                Wrap(spacing: 8, children: joursList.map(chip).toList()),

                const Spacer(),

                ElevatedButton(
                  onPressed: _save,
                  child: const Text("Enregistrer"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
