import 'package:flutter/material.dart';
import 'package:ora/controlleurs/controleur_alarme.dart';
import 'package:ora/models/modele_alarme.dart';
import 'package:ora/screens/principal.dart';
import 'package:ora/screens/ajouter_alarme.dart';

class AlarmesPage extends StatefulWidget {
  static const String screenRoute = 'pagealarmes';

  const AlarmesPage({super.key});

  @override
  State<AlarmesPage> createState() => _AlarmesPageState();
}

class _AlarmesPageState extends State<AlarmesPage> {
  final ControleurAlarme _controleur = ControleurAlarme();

  Future<void> _ouvrirAjoutAlarme() async {
    final resultat = await Navigator.pushNamed(
      context,
      AjouterAlarmePage.screenRoute,
    );

    if (resultat == true && mounted) {
      setState(() {});
    }
  }

  Future<void> _supprimerAlarme(int id) async {
    await _controleur.supprimerAlarme(id);

    if (!mounted) return;
    setState(() {});

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Alarme supprimée.")));
  }

  Future<void> _basculerActivation(ModeleAlarme alarme, bool valeur) async {
    if (alarme.id == null) return;

    await _controleur.basculerActivation(alarme.id!, valeur);

    if (!mounted) return;
    setState(() {});
  }

  String _formaterHeure(int heure, int minute) {
    final String heureTexte = heure.toString().padLeft(2, '0');
    final String minuteTexte = minute.toString().padLeft(2, '0');
    return "$heureTexte:$minuteTexte";
  }

  String _formaterJours(String jours) {
    if (jours.trim().isEmpty) {
      return "Tous les jours";
    }

    if (jours.toLowerCase() == "quotidien") {
      return "Tous les jours";
    }

    return jours
        .split(',')
        .map((jour) {
          switch (jour.trim().toLowerCase()) {
            case 'lun':
              return 'Lun';
            case 'mar':
              return 'Mar';
            case 'mer':
              return 'Mer';
            case 'jeu':
              return 'Jeu';
            case 'ven':
              return 'Ven';
            case 'sam':
              return 'Sam';
            case 'dim':
              return 'Dim';
            default:
              return jour;
          }
        })
        .join('   ');
  }

  Widget _joursMini(String jours, bool estActive) {
    return Text(
      _formaterJours(jours),
      style: TextStyle(
        color: estActive ? Colors.white70 : Colors.white54,
        fontSize: 11,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  Widget _carteAlarme(ModeleAlarme alarme) {
    final bool estActive = alarme.active;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        gradient: estActive
            ? const LinearGradient(
                colors: [
                  Color.fromARGB(255, 66, 19, 131),
                  Color.fromARGB(255, 64, 41, 113),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : null,
        color: estActive ? null : Colors.white.withOpacity(0.12),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white.withOpacity(0.12)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  alarme.titre,
                  style: TextStyle(
                    color: estActive ? Colors.white70 : Colors.white54,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  _formaterHeure(alarme.heure, alarme.minute),
                  style: TextStyle(
                    color: estActive ? Colors.white : Colors.white70,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                _joursMini(alarme.jours, estActive),
                if (alarme.note != null && alarme.note!.trim().isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Text(
                    alarme.note!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: estActive ? Colors.white : Colors.white70,
                      fontSize: 11,
                    ),
                  ),
                ],
              ],
            ),
          ),
          Column(
            children: [
              Switch(
                value: alarme.active,
                activeColor: Colors.white,
                activeTrackColor: const Color.fromARGB(255, 101, 124, 255),
                inactiveThumbColor: Colors.white,
                inactiveTrackColor: Colors.white30,
                onChanged: (valeur) => _basculerActivation(alarme, valeur),
              ),
              IconButton(
                onPressed: () {
                  if (alarme.id != null) {
                    _supprimerAlarme(alarme.id!);
                  }
                },
                icon: const Icon(
                  Icons.delete_outline,
                  color: Colors.white70,
                  size: 20,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _boutonAjouter() {
    return InkWell(
      onTap: _ouvrirAjoutAlarme,
      borderRadius: BorderRadius.circular(22),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 22),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.10),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: Colors.white.withOpacity(0.12)),
        ),
        child: Column(
          children: const [
            CircleAvatar(
              radius: 20,
              backgroundColor: Color.fromARGB(191, 58, 12, 87),
              child: Icon(Icons.add, color: Colors.white),
            ),
            SizedBox(height: 10),
            Text(
              "Ajouter une alarme",
              style: TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _contenu() {
    return FutureBuilder<List<ModeleAlarme>>(
      future: _controleur.recupererToutesLesAlarmes(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: Colors.white),
          );
        }

        if (snapshot.hasError) {
          return Center(
            child: Text(
              "Erreur : ${snapshot.error}",
              style: const TextStyle(color: Colors.white),
              textAlign: TextAlign.center,
            ),
          );
        }

        final alarmes = snapshot.data ?? [];

        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          children: [
            if (alarmes.isEmpty)
              Container(
                padding: const EdgeInsets.all(20),
                margin: const EdgeInsets.only(bottom: 14),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: Colors.white.withOpacity(0.12)),
                ),
                child: const Text(
                  "Aucune alarme disponible",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white, fontSize: 15),
                ),
              ),

            ...alarmes.map(_carteAlarme),

            _boutonAjouter(),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _controleur.dispose();
    super.dispose();
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
        ),
        title: const Text(
          "Alarmes",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        centerTitle: true,
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
        child: SafeArea(child: _contenu()),
      ),
    );
  }
}
