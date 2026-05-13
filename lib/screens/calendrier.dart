import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:ora/controlleurs/controleur_tache.dart';
import 'package:ora/models/modele_tache.dart';
import 'package:ora/screens/principal.dart';
import 'package:table_calendar/table_calendar.dart';

class Calendrier extends StatefulWidget {
  static const String screenRoute = 'pagecalendrier';

  const Calendrier({super.key});

  @override
  State<Calendrier> createState() => _CalendrierState();
}

class _CalendrierState extends State<Calendrier> {
  final ControleurTache _controleurTache = ControleurTache();

 final List<String> _categories = [
  "tasks.study".tr(),
  "tasks.work".tr(),
  "tasks.personal".tr(),
  "tasks.health".tr(),
  "tasks.shopping".tr(),
  "tasks.meeting".tr(),
  "tasks.other".tr(),
];
final List<String> _priorites = [
  "tasks.high".tr(),
  "tasks.medium".tr(),
  "tasks.low".tr(),
];
  @override
  void initState() {
    super.initState();
    _controleurTache.synchroniserTaches();
  }

  DateTime _moisAffiche = DateTime.now();
  DateTime _dateSelectionnee = DateTime.now();

  Future<String?> _choisirHeure() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (picked == null) return null;

    final hh = picked.hour.toString().padLeft(2, '0');
    final mm = picked.minute.toString().padLeft(2, '0');
    return "$hh:$mm";
  }

  void _afficherAjoutTache() {
    final titreCtrl = TextEditingController();
    String? heureChoisie;
    String categorieChoisie = 'Autre';
String prioriteChoisie = 'Basse';
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setLocalState) {
            return AlertDialog(
              backgroundColor: const Color.fromARGB(255, 197, 179, 252),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
              title: Text("tasks.add_task".tr()),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: titreCtrl,
                    decoration: InputDecoration(
                      labelText: "tasks.task_title".tr(),
                      border: const OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: categorieChoisie,
                    decoration: InputDecoration(
                      labelText: "tasks.category".tr(),
                      border: const OutlineInputBorder(),
                    ),
                    items: _categories.map((categorie) {
                      return DropdownMenuItem<String>(
                        value: categorie,
                        child: Text(categorie),
                      );
                    }).toList(),
                    onChanged: (valeur) {
                      if (valeur == null) return;
                      setLocalState(() => categorieChoisie = valeur);
                      
                    },
                    

                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
  value: prioriteChoisie,
  decoration: InputDecoration(
  labelText: "tasks.priority".tr(),
  border: const OutlineInputBorder(),
),
  items: _priorites.map((priorite) {
    return DropdownMenuItem<String>(
      value: priorite,
      child: Text(priorite),
    );
  }).toList(),
  onChanged: (valeur) {
    if (valeur == null) return;
    setLocalState(() => prioriteChoisie = valeur);
  },
),
                  const SizedBox(height: 12),
                  InkWell(
                    onTap: () async {
                      final h = await _choisirHeure();
                      if (h == null) return;
                      setLocalState(() => heureChoisie = h);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 14,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            heureChoisie ?? "tasks.choose_time".tr(),
                            style: const TextStyle(fontSize: 14),
                          ),
                          const Icon(Icons.access_time),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text("app.cancel".tr()),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final titre = titreCtrl.text.trim();
                    if (titre.isEmpty) return;
await _controleurTache.ajouterTache(
  titre: titre,
  heure: heureChoisie ?? "--:--",
  date: _dateSelectionnee,
  categorie: categorieChoisie,
  priorite: prioriteChoisie,
);
                    if (mounted) {
                      Navigator.pop(context);
                      setState(() {});
                    }
                  },
                  child: Text("app.add".tr()),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildCategorieBadge(String categorie) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        categorie,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildTacheItem(ModeleTache t) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Checkbox(
            value: t.terminee,
            onChanged: (v) async {
              await _controleurTache.changerEtatTache(
                idTache: t.id,
                terminee: v ?? false,
              );
              if (mounted) setState(() {});
            },
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  t.titre,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    decoration: t.terminee
                        ? TextDecoration.lineThrough
                        : TextDecoration.none,
                  ),
                ),
                const SizedBox(height: 6),
                _buildCategorieBadge(t.categorie),
                const SizedBox(height: 6),
_buildCategorieBadge(t.priorite),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(t.heure, style: TextStyle(color: Colors.white.withOpacity(0.7))),
          IconButton(
            onPressed: () async {
              await _controleurTache.supprimerTache(t.id);
              if (mounted) setState(() {});
            },
            icon: const Icon(Icons.delete, color: Colors.white),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controleurTache.dispose();
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
            Navigator.pushNamed(context, principal.screenRoute);
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _afficherAjoutTache,
        backgroundColor: const Color.fromARGB(
          255,
          217,
          174,
          245,
        ).withOpacity(0.9),
        child: const Icon(Icons.add, color: Colors.black),
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
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "calendar.title".tr(),
                  style: const TextStyle(
                    fontSize: 42,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(19),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.18),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: TableCalendar(
                    firstDay: DateTime.utc(2016, 1, 1),
                    lastDay: DateTime.utc(2036, 12, 31),
                    focusedDay: _moisAffiche,
                    selectedDayPredicate: (jour) =>
                        isSameDay(jour, _dateSelectionnee),
                    onDaySelected: (jourSelectionne, moisFocalise) {
                      setState(() {
                        _dateSelectionnee = jourSelectionne;
                        _moisAffiche = moisFocalise;
                      });
                    },
                  ),
                ),

                const SizedBox(height: 14),

                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: StreamBuilder<List<ModeleTache>>(
                      stream: _controleurTache.obtenirFluxTachesParDate(
                        _dateSelectionnee,
                      ),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData || snapshot.data!.isEmpty) {
                          return Center(
                            child: Text(
                              "tasks.no_tasks".tr(),
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.85),
                                fontSize: 16,
                              ),
                            ),
                          );
                        }

                        final taches = snapshot.data!;

                        final tachesEnCours = taches
                            .where((t) => !t.terminee)
                            .toList();

                        final tachesTerminees = taches
                            .where((t) => t.terminee)
                            .toList();

                        return ListView(
                          children: [
                            if (tachesEnCours.isNotEmpty) ...[
                              Text("tasks.in_progress".tr()),
                              ...tachesEnCours.map(_buildTacheItem),
                            ],
                            if (tachesTerminees.isNotEmpty) ...[
                              Text("tasks.completed".tr()),
                              ...tachesTerminees.map(_buildTacheItem),
                            ],
                          ],
                        );
                      },
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
