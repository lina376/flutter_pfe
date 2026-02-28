import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';

class principal extends StatefulWidget {
  const principal({super.key});

  @override
  State<principal> createState() => _principalState();
}

class _principalState extends State<principal> {
  // Date affichée (mois) + date sélectionnée
  DateTime _moisAffiche = DateTime.now();
  DateTime _dateSelectionnee = DateTime.now();

  // Normalisation ken jour m a
  static DateTime _dateSansHeure(DateTime d) =>
      DateTime(d.year, d.month, d.day);
  final List<ElementHistorique> listeHistorique = [];

  void ajouterHistorique({
    required String titre,
    required String sousTitre,
    required IconData icone,
  }) {
    setState(() {
      listeHistorique.insert(
        0,
        ElementHistorique(
          titre: titre,
          sousTitre: sousTitre,
          dateHeure: DateTime.now(),
          icone: icone,
        ),
      );
    });
  }

  String formaterHeure(DateTime date) {
    final heures = date.hour.toString().padLeft(2, '0');
    final minutes = date.minute.toString().padLeft(2, '0');
    return "$heures:$minutes";
  }

  Widget sectionHistorique() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 18),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.12),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withOpacity(0.15)),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start, //bech titktib historique aal lisar
        children: [
          Positioned(
            child: Text(
              "Historique",
              style: TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.w800,
                fontSize: 14,
              ),
            ),
          ),

          Expanded(
            child: listeHistorique.isEmpty
                ? Align(
                    //? ken l condition s7i7a yarja3 min ? w ken ghalta yarja3 :
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Aucune activité pour le moment",
                      style: TextStyle(color: Colors.white.withOpacity(0.75)),
                    ),
                  )
                : ListView.separated(
                    itemCount: listeHistorique.length,
                    physics: const ClampingScrollPhysics(),
                    separatorBuilder: (_, __) => const SizedBox(
                      height: 10,
                    ), //yaamal espace baad koul 3onsor
                    itemBuilder: (context, index) {
                      final element =
                          listeHistorique[index]; //koul historique aando index

                      return Container(
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
                                element.icone,
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
                                    element.titre,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 13,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    element.sousTitre,
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
                            SizedBox(
                              width: MediaQuery.of(context).size.height * 0.01,
                            ),
                            Text(
                              formaterHeure(element.dateHeure),
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.65),
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
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
        actions: [
          IconButton(
            style: const ButtonStyle(
              backgroundColor: WidgetStatePropertyAll<Color>(
                Color.fromARGB(92, 88, 70, 142),
              ),
            ),
            icon: const Icon(Icons.notifications_active, color: Colors.white),
            onPressed: () {},
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
          onPressed: () {},
          tooltip: 'parametre',
          iconSize: 25,
          constraints: const BoxConstraints(minHeight: 25, minWidth: 25),
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
          child: Stack(
            children: [
              Positioned(
                top: MediaQuery.of(context).size.height * 0.001,
                left: MediaQuery.of(context).size.height * 0.0001,
                child: SizedBox(width: 395, height: 45, child: recherche()),
              ),
              Positioned(
                //frame de robot
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
                      border: Border.all(color: Colors.white.withOpacity(0.18)),
                    ),
                  ),
                ),
              ),

              Positioned(
                //frame de notes
                top: MediaQuery.of(context).size.height * 0.08,
                right: MediaQuery.of(context).size.height * 0.02,
                child: SizedBox(
                  width: 130,
                  height: 170,
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: Colors.white.withOpacity(0.18)),
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
                        onPressed: () {
                          ajouterHistorique(
                            titre: "Chat avec ORA",
                            sousTitre: "Discussion commencée",
                            icone: Icons.chat_bubble_outline,
                          );
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
                        padding: const EdgeInsets.all(14),
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
                        padding: const EdgeInsets.all(14),
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
                        padding: const EdgeInsets.all(14),
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
                    child: MesNotes(),
                  ),
                  Positioned(
                    top: MediaQuery.of(context).size.height * 0.3,
                    left: MediaQuery.of(context).size.height * 0.02,
                    right: MediaQuery.of(context).size.height * 0.02,
                    child: Container(
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
                  Positioned(
                    //historique
                    left: MediaQuery.of(context).size.height * 0.01,
                    right: MediaQuery.of(context).size.height * 0.01,
                    bottom: MediaQuery.of(context).size.height * 0.025,
                    child: SizedBox(height: 110, child: sectionHistorique()),
                  ),
                ],
              ),
            ],
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
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
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
    return SizedBox(
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
    );
  }
}

class ElementHistorique {
  final String titre;
  final String sousTitre;
  final DateTime dateHeure;
  final IconData icone;

  ElementHistorique({
    required this.titre,
    required this.sousTitre,
    required this.dateHeure,
    required this.icone,
  });
}
