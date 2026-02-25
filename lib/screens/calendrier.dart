import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';

class Calendrier extends StatefulWidget {
  const Calendrier({super.key});

  @override
  State<Calendrier> createState() => _CalendrierState();
}

class _CalendrierState extends State<Calendrier> {
  // Date affichée (mois) + date sélectionnée
  DateTime _moisAffiche = DateTime.now();
  DateTime _dateSelectionnee = DateTime.now();

  // Normalisation ken jour m a
  static DateTime _dateSansHeure(DateTime d) =>
      DateTime(d.year, d.month, d.day);

  // Tâches par date
  final Map<DateTime, List<Tache>> _tachesParDate = {
    // lblasa eli nkhazen feha map key->valeur
    _dateSansHeure(DateTime.now()): [
      Tache("Tâche 1", "10:00", true),
      Tache("Tâche 2", "11:00", true),
      Tache("Tâche 3", "12:30", false),
    ],
    _dateSansHeure(DateTime.now().add(const Duration(days: 2))): [
      Tache("Réunion", "09:00", false),
      Tache("Rapport", "15:00", false),
    ],
  };

  // Liste des tâches du jour sélectionné
  List<Tache> get _tachesDuJour =>
      _tachesParDate[_dateSansHeure(_dateSelectionnee)] ?? [];
  // Changer état (done) d’une tâche
  void _changerEtatTache(int index, bool? valeur) {
    final cle = _dateSansHeure(_dateSelectionnee);
    final liste = _tachesParDate[cle];
    if (liste == null) return;

    setState(() {
      liste[index] = liste[index].copyWith(done: valeur ?? false);
    });
  }

  // Choisir l’heure (TimePicker)
  Future<String?> _choisirHeure() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked == null) return null;

    final hh = picked.hour.toString().padLeft(
      2,
      '0',
    ); // mithel 9 yrodha 09 bech tben w9t
    final mm = picked.minute.toString().padLeft(2, '0');
    return "$hh:$mm";
  }

  // Dialog ajout tâche (titre + heure)
  void _afficherAjoutTache() {
    final titreCtrl = TextEditingController();
    String? heureChoisie;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          //bech yaaml t7dith
          builder: (context, setLocalState) {
            return AlertDialog(
              title: const Text("Nouvelle tâche"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: titreCtrl,
                    decoration: const InputDecoration(
                      labelText: "Titre",
                      border: OutlineInputBorder(),
                    ),
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
                            heureChoisie ?? "Choisir l'heure",
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
                  child: const Text("Annuler"),
                ),
                ElevatedButton(
                  onPressed: () {
                    final titre = titreCtrl.text.trim();
                    if (titre.isEmpty) return;

                    final cle = _dateSansHeure(_dateSelectionnee);

                    setState(() {
                      _tachesParDate.putIfAbsent(cle, () => []);
                      _tachesParDate[cle]!.add(
                        Tache(titre, heureChoisie ?? "--:--", false),
                      );
                    });

                    Navigator.pop(context);
                  },
                  child: const Text("Ajouter"),
                ),
              ],
            );
          },
        );
      },
    );
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

      // buttom+
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
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,

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
                const Text(
                  "Calendrier",
                  style: TextStyle(
                    fontSize: 42,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 14),

                // Carte Calendrier
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

                    startingDayOfWeek: StartingDayOfWeek.sunday,

                    selectedDayPredicate: (jour) => isSameDay(
                      jour,
                      _dateSelectionnee,
                    ), //ylawn nhar leli khtarto

                    onDaySelected: (jourSelectionne, moisFocalise) {
                      setState(() {
                        _dateSelectionnee = jourSelectionne;
                        _moisAffiche = moisFocalise;
                      });
                    },

                    headerStyle: HeaderStyle(
                      formatButtonVisible: false,
                      titleCentered: true,
                      titleTextFormatter: (date, locale) =>
                          DateFormat('MMM yyyy', 'en_US').format(date),
                      titleTextStyle: const TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w700,
                      ),
                      leftChevronIcon: const Icon(
                        Icons.chevron_left,
                        color: Colors.black,
                      ),
                      rightChevronIcon: const Icon(
                        Icons.chevron_right,
                        color: Colors.black,
                      ),
                    ),

                    daysOfWeekStyle: DaysOfWeekStyle(
                      weekdayStyle: TextStyle(
                        color: Colors.black.withOpacity(0.70),
                      ),
                      weekendStyle: TextStyle(
                        color: Colors.black.withOpacity(0.70),
                      ),
                    ),

                    calendarStyle: CalendarStyle(
                      outsideDaysVisible: false,
                      defaultTextStyle: const TextStyle(color: Colors.black),
                      weekendTextStyle: const TextStyle(color: Colors.black),
                      todayDecoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.08),
                        shape: BoxShape.circle,
                      ),
                      selectedDecoration: const BoxDecoration(
                        color: Color(0xFF2F7BFF),
                        shape: BoxShape.circle,
                      ),
                      selectedTextStyle: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 14),

                // Panel tâches
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white.withOpacity(0.18)),
                    ),
                    child: _tachesDuJour.isEmpty
                        ? Center(
                            child: Text(
                              "Aucune tâche",
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.85),
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          )
                        : ListView.separated(
                            itemCount: _tachesDuJour.length,
                            separatorBuilder: (_, __) =>
                                Divider(color: Colors.white.withOpacity(0.15)),
                            itemBuilder: (context, index) {
                              final t = _tachesDuJour[index];
                              return Row(
                                children: [
                                  Checkbox(
                                    value: t.terminee,
                                    onChanged: (v) =>
                                        _changerEtatTache(index, v),
                                    side: BorderSide(
                                      color: Colors.white.withOpacity(0.8),
                                    ),
                                    checkColor: Colors.white,
                                    activeColor: const Color(0xFF2F7BFF),
                                  ),
                                  Expanded(
                                    child: Text(
                                      t.titre,
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        decoration: t.terminee
                                            ? TextDecoration.lineThrough
                                            : TextDecoration.none,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    t.heure,
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.7),
                                    ),
                                  ),
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

// Modèle tache
class Tache {
  final String titre;
  final String heure;
  final bool terminee;

  Tache(this.titre, this.heure, this.terminee);

  Tache copyWith({String? titre, String? heure, bool? done}) =>
      Tache(titre ?? this.titre, heure ?? this.heure, done ?? terminee);
}
