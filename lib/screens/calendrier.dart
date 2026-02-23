import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';

class Calendrier extends StatefulWidget {
  const Calendrier({super.key});

  @override
  State<Calendrier> createState() => _CalendrierState();
}

class _CalendrierState extends State<Calendrier> {
  DateTime _mois = DateTime.now();
  DateTime _jour = DateTime.now();

  static DateTime _onlyDate(DateTime d) => DateTime(d.year, d.month, d.day);

  final Map<DateTime, List<Todo>> _tasksByDay = {
    _onlyDate(DateTime.now()): [
      Todo("Tache 1", "10:00", true),
      Todo("Tache 2", "11:00", true),
      Todo("Tache 3", "12:30", false),
    ],
    _onlyDate(DateTime.now().add(const Duration(days: 3))): [
      Todo("Réunion", "09:00", false),
      Todo("Rapport", "15:00", false),
    ],
  };

  List<Todo> get _tasksOfSelectedDay => _tasksByDay[_onlyDate(_jour)] ?? [];

  void _toggleTask(int index, bool? value) {
    final key = _onlyDate(_jour);
    final list = _tasksByDay[key];
    if (list == null) return;

    setState(() {
      list[index] = list[index].copyWith(done: value ?? false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.chevron_left, color: Colors.white),
          onPressed: () => Navigator.pop(context),
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

                // ✅ Card Calendar
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.18),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: TableCalendar(
                    firstDay: DateTime.utc(2016, 1, 1),
                    lastDay: DateTime.utc(2036, 12, 31),
                    focusedDay: _mois,
                    selectedDayPredicate: (day) => isSameDay(day, _jour),
                    onDaySelected: (selectedDay, focusedDay) {
                      setState(() {
                        _jour = selectedDay;
                        _mois = focusedDay;
                      });
                    },
                    startingDayOfWeek: StartingDayOfWeek.sunday,
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
                    child: _tasksOfSelectedDay.isEmpty
                        ? const Center(
                            child: Text(
                              "Aucune tâche",
                              style: TextStyle(color: Colors.white),
                            ),
                          )
                        : ListView.separated(
                            itemCount: _tasksOfSelectedDay.length,
                            separatorBuilder: (_, __) =>
                                Divider(color: Colors.white.withOpacity(0.15)),
                            itemBuilder: (context, index) {
                              final t = _tasksOfSelectedDay[index];
                              return Row(
                                children: [
                                  Checkbox(
                                    value: t.done,
                                    onChanged: (v) => _toggleTask(index, v),
                                    side: BorderSide(
                                      color: Colors.white.withOpacity(0.8),
                                    ),
                                    checkColor: Colors.white,
                                    activeColor: const Color(0xFF2F7BFF),
                                  ),
                                  Expanded(
                                    child: Text(
                                      t.title,
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        decoration: t.done
                                            ? TextDecoration.lineThrough
                                            : TextDecoration.none,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    t.time,
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

class Todo {
  final String title;
  final String time;
  final bool done;

  Todo(this.title, this.time, this.done);

  Todo copyWith({String? title, String? time, bool? done}) =>
      Todo(title ?? this.title, time ?? this.time, done ?? this.done);
}
