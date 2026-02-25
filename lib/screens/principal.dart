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
                top: 10,
                left: 1,
                child: SizedBox(width: 395, height: 45, child: recherche()),
              ),
              Positioned(
                //frame de robot
                top: 80,
                left: 10,
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
                top: 80,
                left: 240,
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
                    top: 100,
                    left: 30,
                    child: SizedBox(
                      width: 120,
                      height: 44,
                      child: ElevatedButton(
                        onPressed: () {},
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
                    top: 150,
                    left: 50,
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
                    top: 168,
                    left: 70,
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
                    top: 183,
                    left: 90,
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
                    top: 130,
                    left: 120,
                    child: Image.asset("images/robot0.png", width: 95),
                  ),
                  Positioned(left: 220, top: 80, child: MesNotes()),
                  Positioned(
                    top: 280,
                    left: 10,
                    right: 10,
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
