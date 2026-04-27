import 'package:easy_localization/easy_localization.dart';
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
    if (h != null) {
      setState(() => _heure = h);
    }
  }

  Future<void> _save() async {
    if (_titre.text.trim().isEmpty) return;

    try {
      await _controleur.ajouterAlarme(
        titre: _titre.text.trim(),
        note: _note.text.trim(),
        heure: _heure.hour,
        minute: _heure.minute,
        jours: jours.isEmpty ? "quotidien" : jours.join(","),
      );

      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Erreur alarme : $e")));
    }
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
        child: Text(
          "alarms.days.$j".tr(),
          style: const TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text("alarms.add_alarm".tr()),
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
                  decoration: InputDecoration(
                    hintText: "alarms.alarm_label".tr(),
                  ),
                ),
                TextField(
                  controller: _note,
                  decoration: InputDecoration(
                    hintText: "notes.note_content".tr(),
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _choisirHeure,
                  child: Text(_heure.format(context)),
                ),
                const SizedBox(height: 20),
                Wrap(spacing: 8, children: joursList.map(chip).toList()),
                const Spacer(),
                ElevatedButton(onPressed: _save, child: Text("app.save".tr())),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
