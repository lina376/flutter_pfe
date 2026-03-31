import 'package:flutter/material.dart';
import 'package:ora/screens/principal.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Calendrier extends StatefulWidget {
  static const String screenRoute = 'pagecalendrier';

  const Calendrier({super.key});

  @override
  State<Calendrier> createState() => _CalendrierState();
}

class _CalendrierState extends State<Calendrier> {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  DateTime _moisAffiche = DateTime.now();
  DateTime _dateSelectionnee = DateTime.now();

  static DateTime _dateSansHeure(DateTime d) {
    return DateTime(d.year, d.month, d.day);
  }

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

  Future<void> ajouterTacheFirebase({
    required String titre,
    required String heure,
    required DateTime date,
  }) async {
    final user = _auth.currentUser;
    if (user == null) return;

    final dateChoisie = _dateSansHeure(date);

    await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('taches')
        .add({
          'titre': titre,
          'heure': heure,
          'date': Timestamp.fromDate(dateChoisie),
          'terminee': false,
          'createdAt': Timestamp.now(),
        });
  }

  Future<void> changerEtatTacheFirebase(String tacheId, bool valeur) async {
    final user = _auth.currentUser;
    if (user == null) return;

    await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('taches')
        .doc(tacheId)
        .update({'terminee': valeur});
  }

  Future<void> supprimerTacheFirebase(String tacheId) async {
    final user = _auth.currentUser;
    if (user == null) return;

    await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('taches')
        .doc(tacheId)
        .delete();
  }

  Stream<QuerySnapshot> streamTachesDuJour() {
    final user = _auth.currentUser;
    if (user == null) {
      return const Stream.empty();
    }

    final debutJour = DateTime(
      _dateSelectionnee.year,
      _dateSelectionnee.month,
      _dateSelectionnee.day,
    );

    final finJour = debutJour.add(const Duration(days: 1));

    return _firestore
        .collection('users')
        .doc(user.uid)
        .collection('taches')
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(debutJour))
        .where('date', isLessThan: Timestamp.fromDate(finJour))
        .orderBy('date')
        .snapshots();
  }

  void _afficherAjoutTache() {
    final titreCtrl = TextEditingController();
    String? heureChoisie;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
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
                  onPressed: () async {
                    final titre = titreCtrl.text.trim();
                    if (titre.isEmpty) return;

                    await ajouterTacheFirebase(
                      titre: titre,
                      heure: heureChoisie ?? "--:--",
                      date: _dateSelectionnee,
                    );

                    if (mounted) {
                      Navigator.pop(context);
                    }
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

  Widget _buildTacheItem(Tache t) {
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
              await changerEtatTacheFirebase(t.id, v ?? false);
            },
            side: BorderSide(color: Colors.white.withOpacity(0.8)),
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
          const SizedBox(width: 8),
          Text(t.heure, style: TextStyle(color: Colors.white.withOpacity(0.7))),
          IconButton(
            onPressed: () async {
              await supprimerTacheFirebase(t.id);
            },
            icon: const Icon(Icons.delete, color: Colors.white),
          ),
        ],
      ),
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
            Navigator.pushNamed(context, principal.screenRoute);
          },
          tooltip: 'chevron',
          iconSize: 40,
          constraints: const BoxConstraints(minHeight: 50, minWidth: 50),
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
                    startingDayOfWeek: StartingDayOfWeek.sunday,
                    selectedDayPredicate: (jour) =>
                        isSameDay(jour, _dateSelectionnee),
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
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white.withOpacity(0.18)),
                    ),
                    child: StreamBuilder<QuerySnapshot>(
                      stream: streamTachesDuJour(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }

                        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                          return Center(
                            child: Text(
                              "Aucune tâche",
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.85),
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          );
                        }

                        final taches = snapshot.data!.docs.map((doc) {
                          return Tache.fromFirestore(
                            doc.id,
                            doc.data() as Map<String, dynamic>,
                          );
                        }).toList();

                        final tachesEnCours = taches
                            .where((t) => !t.terminee)
                            .toList();
                        final tachesTerminees = taches
                            .where((t) => t.terminee)
                            .toList();

                        return ListView(
                          children: [
                            if (tachesEnCours.isNotEmpty) ...[
                              const Text(
                                "En cours",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 10),
                              ...tachesEnCours.map((t) => _buildTacheItem(t)),
                              const SizedBox(height: 20),
                            ],
                            if (tachesTerminees.isNotEmpty) ...[
                              const Text(
                                "Terminées",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 10),
                              ...tachesTerminees.map((t) => _buildTacheItem(t)),
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

class Tache {
  final String id;
  final String titre;
  final String heure;
  final DateTime date;
  final bool terminee;

  Tache({
    required this.id,
    required this.titre,
    required this.heure,
    required this.date,
    required this.terminee,
  });

  factory Tache.fromFirestore(String id, Map<String, dynamic> data) {
    return Tache(
      id: id,
      titre: data['titre'] ?? '',
      heure: data['heure'] ?? '--:--',
      date: (data['date'] as Timestamp).toDate(),
      terminee: data['terminee'] ?? false,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'titre': titre,
      'heure': heure,
      'date': Timestamp.fromDate(date),
      'terminee': terminee,
      'createdAt': Timestamp.now(),
    };
  }
}
