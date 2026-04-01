import 'package:flutter/material.dart';
import 'package:ora/screens/calendrier.dart';
import 'package:ora/screens/chat.dart';
import 'package:ora/screens/mesnotes.dart';
import 'package:ora/screens/notifications.dart';

import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class principal extends StatefulWidget {
  static const String screenRoute = 'pageprincipal';
  const principal({super.key});

  @override
  State<principal> createState() => _principalState();
}

class _principalState extends State<principal> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late User signedInUser;

  DateTime _moisAffiche = DateTime.now();
  DateTime _dateSelectionnee = DateTime.now();

  bool _notif = true;

  @override
  void initState() {
    super.initState();
    getCurrenUser();
  }

  void getCurrenUser() {
    final user = _auth.currentUser;
    if (user != null) {
      signedInUser = user;
    }
  }

  Future<void> _logout() async {
    await _auth.signOut();
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, 'pageconnecter');
  }

  Future<String> creerConversation(String premierMessage) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) return "";

    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('conversations')
        .add({
          'titre': premierMessage,
          'dernierMessage': premierMessage,
          'dateCreation': Timestamp.now(),
          'dateMaj': Timestamp.now(),
        });

    return doc.id;
  }

  void _Parametre() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      barrierColor: Colors.black.withOpacity(0.25),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setLocal) {
            return SafeArea(
              child: Align(
                alignment: Alignment.topLeft,
                child: Padding(
                  padding: const EdgeInsets.only(left: 10, top: 50, bottom: 50),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.7,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(
                          255,
                          20,
                          6,
                          31,
                        ).withOpacity(0.5),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.22),
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _list(
                            icon: Icons.person_outline,
                            title: "Profil",
                            onTap: () {
                              Navigator.pop(context);
                              Navigator.pushNamed(context, 'pageprofil');
                            },
                          ),
                          _list(
                            icon: Icons.favorite_border,
                            title: "Favoriser",
                            onTap: () {
                              Navigator.pop(context);
                              Navigator.pushNamed(context, 'pagefavorise');
                            },
                          ),
                          const Divider(color: Colors.white24, height: 18),
                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: const Icon(
                              Icons.notifications_none,
                              color: Colors.white,
                            ),
                            title: const Text(
                              "Notifications",
                              style: TextStyle(color: Colors.white),
                            ),
                            trailing: Switch(
                              value: _notif,
                              onChanged: (v) {
                                setLocal(() => _notif = v);
                                setState(() => _notif = v);
                              },
                            ),
                          ),
                          TextButton(
                            onPressed: () async {
                              Navigator.pop(context);
                              await _logout();
                            },
                            child: const Text(
                              "Déconnecter",
                              style: TextStyle(
                                color: Colors.white,
                                decoration: TextDecoration.underline,
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
          },
        );
      },
    );
  }

  Widget _list({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: Colors.white),
      title: Text(title, style: const TextStyle(color: Colors.white)),
      trailing: const Icon(Icons.chevron_right, color: Colors.white70),
      onTap: onTap,
    );
  }

  Widget _buildUserTitle() {
    final user = _auth.currentUser;

    if (user == null) {
      return const Text(
        "ORA",
        textAlign: TextAlign.center,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.2,
        ),
      );
    }

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || !snapshot.data!.exists) {
          return const Text(
            "ORA",
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.2,
            ),
          );
        }

        final data = snapshot.data!.data() as Map<String, dynamic>;
        final String nom = (data['nom'] ?? '').toString().trim();
        final String prenom = (data['prenom'] ?? '').toString().trim();

        final String title = (nom.isEmpty && prenom.isEmpty)
            ? "ORA"
            : "~ ${nom.toUpperCase()} ${prenom.toUpperCase()} ~";

        return Text(
          title,
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.2,
          ),
        );
      },
    );
  }

  Widget sectionHistorique() {
    final user = _auth.currentUser;

    if (user == null) {
      return const Center(
        child: Text("Aucun utilisateur", style: TextStyle(color: Colors.white)),
      );
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 20),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.12),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withOpacity(0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Historique",
            style: TextStyle(
              color: Colors.black87,
              fontWeight: FontWeight.w800,
              fontSize: 14,
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .doc(user.uid)
                  .collection('conversations')
                  .orderBy('dateMaj', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: Text(
                      "Chargement...",
                      style: TextStyle(color: Colors.white.withOpacity(0.8)),
                    ),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Aucune activité pour le moment",
                      style: TextStyle(color: Colors.white.withOpacity(0.75)),
                    ),
                  );
                }

                final docs = snapshot.data!.docs;

                return ListView.separated(
                  itemCount: docs.length,
                  physics: const ClampingScrollPhysics(),
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final data = docs[index].data() as Map<String, dynamic>;
                    final conversationId = docs[index].id;

                    String heure = "";
                    if (data['dateMaj'] != null) {
                      final date = (data['dateMaj'] as Timestamp).toDate();
                      heure =
                          "${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}";
                    }

                    return GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          chat.screenRoute,
                          arguments: conversationId,
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.10),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.12),
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              height: 34,
                              width: 34,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.16),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.history,
                                color: Colors.white.withOpacity(0.85),
                                size: 18,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    data['titre'] ?? '',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 13,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    data['dernierMessage'] ?? '',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.7),
                                      fontSize: 11,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              heure,
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.65),
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
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
        title: _buildUserTitle(),
        centerTitle: true,
        actions: [
          IconButton(
            style: const ButtonStyle(
              backgroundColor: WidgetStatePropertyAll<Color>(
                Color.fromARGB(92, 88, 70, 142),
              ),
            ),
            icon: const Icon(Icons.notifications_active, color: Colors.white),
            onPressed: () {
              Navigator.pushNamed(context, notifications.screenRoute);
            },
            tooltip: 'notification',
            iconSize: 25,
            constraints: const BoxConstraints(minHeight: 25, minWidth: 25),
          ),
        ],
        leading: IconButton(
          style: const ButtonStyle(
            backgroundColor: WidgetStatePropertyAll<Color>(
              Color.fromARGB(89, 88, 70, 142),
            ),
          ),
          icon: const Icon(Icons.menu, color: Colors.white),
          onPressed: () => _Parametre(),
          tooltip: 'parametre',
          iconSize: 25,
          constraints: const BoxConstraints(minHeight: 25, minWidth: 25),
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
          child: SingleChildScrollView(
            child: SizedBox(
              height: MediaQuery.of(context).size.height,
              child: Stack(
                children: [
                  Positioned(
                    top: MediaQuery.of(context).size.height * 0.001,
                    left: MediaQuery.of(context).size.height * 0.0001,
                    child: const SizedBox(
                      width: 395,
                      height: 45,
                      child: recherche(),
                    ),
                  ),
                  Positioned(
                    top: MediaQuery.of(context).size.height * 0.08,
                    left: MediaQuery.of(context).size.height * 0.02,
                    child: SizedBox(
                      width: 210,
                      height: 170,
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.18),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: MediaQuery.of(context).size.height * 0.08,
                    right: MediaQuery.of(context).size.height * 0.02,
                    child: GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(context, mesnotes.screenRoute);
                      },
                      child: SizedBox(
                        width: 130,
                        height: 170,
                        child: Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.18),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Stack(
                    children: [
                      Positioned(
                        top: MediaQuery.of(context).size.height * 0.095,
                        left: MediaQuery.of(context).size.height * 0.035,
                        child: SizedBox(
                          width: 120,
                          height: 44,
                          child: ElevatedButton(
                            onPressed: () async {
                              final texte = "Nouvelle discussion";
                              final conversationId = await creerConversation(
                                texte,
                              );

                              if (conversationId.isNotEmpty) {
                                Navigator.pushNamed(
                                  context,
                                  chat.screenRoute,
                                  arguments: conversationId,
                                );
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color.fromARGB(
                                221,
                                80,
                                7,
                                137,
                              ).withOpacity(0.20),
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(22),
                              ),
                            ),
                            child: const Text(
                              "Discuter",
                              style: TextStyle(
                                color: Color.fromARGB(255, 50, 43, 43),
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        top: MediaQuery.of(context).size.height * 0.155,
                        left: MediaQuery.of(context).size.height * 0.05,
                        child: SizedBox(
                          width: 35,
                          height: 15,
                          child: Container(
                            decoration: BoxDecoration(
                              color: const Color.fromARGB(
                                221,
                                80,
                                7,
                                137,
                              ).withOpacity(0.20),
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.18),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        top: MediaQuery.of(context).size.height * 0.174,
                        left: MediaQuery.of(context).size.height * 0.07,
                        child: SizedBox(
                          width: 25,
                          height: 12,
                          child: Container(
                            decoration: BoxDecoration(
                              color: const Color.fromARGB(
                                221,
                                80,
                                7,
                                137,
                              ).withOpacity(0.20),
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.18),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        top: MediaQuery.of(context).size.height * 0.19,
                        left: MediaQuery.of(context).size.height * 0.09,
                        child: SizedBox(
                          width: 20,
                          height: 8,
                          child: Container(
                            decoration: BoxDecoration(
                              color: const Color.fromARGB(
                                221,
                                80,
                                7,
                                137,
                              ).withOpacity(0.20),
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.18),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        top: MediaQuery.of(context).size.height * 0.13,
                        left: MediaQuery.of(context).size.height * 0.12,
                        child: Image.asset("images/robot0.png", width: 95),
                      ),
                      Positioned(
                        right: MediaQuery.of(context).size.height * 0.001,
                        top: MediaQuery.of(context).size.height * 0.08,
                        child: const MesNotes(),
                      ),
                      Positioned(
                        top: MediaQuery.of(context).size.height * 0.3,
                        left: MediaQuery.of(context).size.height * 0.02,
                        right: MediaQuery.of(context).size.height * 0.02,
                        child: GestureDetector(
                          onTap: () {
                            Navigator.pushNamed(
                              context,
                              Calendrier.screenRoute,
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.all(19),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.18),
                              borderRadius: BorderRadius.circular(18),
                            ),
                            child: TableCalendar(
                              sixWeekMonthsEnforced: true,
                              rowHeight: 35,
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
                                    DateFormat(
                                      'MMM yyyy',
                                      'en_US',
                                    ).format(date),
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
                                defaultTextStyle: const TextStyle(
                                  color: Colors.black,
                                ),
                                weekendTextStyle: const TextStyle(
                                  color: Colors.black,
                                ),
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
                        ),
                      ),
                      Positioned(
                        left: MediaQuery.of(context).size.height * 0.01,
                        right: MediaQuery.of(context).size.height * 0.01,
                        bottom: MediaQuery.of(context).size.height * -0.08,
                        child: SizedBox(
                          height: MediaQuery.of(context).size.height * 0.4,
                          child: sectionHistorique(),
                        ),
                      ),
                    ],
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

class recherche extends StatelessWidget {
  const recherche({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: const Color.fromARGB(159, 255, 255, 255).withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.search, color: Colors.white),
          const SizedBox(width: 10),
          const Expanded(
            child: TextField(
              style: TextStyle(color: Color.fromARGB(75, 255, 255, 255)),
              decoration: InputDecoration(
                hintText: "Chercher",
                hintStyle: TextStyle(color: Colors.white70),
                border: InputBorder.none,
              ),
            ),
          ),
          const Icon(Icons.mic, color: Colors.white),
        ],
      ),
    );
  }
}

class MesNotes extends StatelessWidget {
  const MesNotes({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, mesnotes.screenRoute);
      },
      child: SizedBox(
        width: 170,
        height: 170,
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.note_alt,
                  color: Color.fromARGB(255, 79, 179, 255),
                  size: 28,
                ),
              ),
              const SizedBox(height: 14),
              const Text(
                "Mes \nNotes",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
