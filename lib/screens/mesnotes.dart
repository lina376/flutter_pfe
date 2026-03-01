import 'package:flutter/material.dart';
import 'package:ora/screens/notes2.dart';
import 'dart:math';

import 'package:ora/screens/principal.dart';

class mesnotes extends StatefulWidget {
  static const String screenRoute = 'pagemesnotes';
  const mesnotes({super.key});

  @override
  State<mesnotes> createState() => _mesnotesState();
}

class _mesnotesState extends State<mesnotes> {
  final TextEditingController searchCtrl = TextEditingController();

  // ✅ بيانات تجريبية (تنجم تفسخهم)
  final List<Notee> notes = [
    Notee(id: '1', title: 'Note 1', date: DateTime(2026, 1, 2, 12, 8)),
    Notee(id: '2', title: 'Note 2', date: DateTime(2026, 1, 7, 19, 28)),
    Notee(id: '3', title: 'Note 3', date: DateTime(2026, 2, 4, 15, 15)),
  ];

  @override
  void dispose() {
    searchCtrl.dispose();
    super.dispose();
  }

  String _formatDate(DateTime d) {
    final day = d.day.toString().padLeft(2, '0');
    const months = [
      'Jan',
      'Fév',
      'Mar',
      'Avr',
      'Mai',
      'Juin',
      'Juil',
      'Aoû',
      'Sep',
      'Oct',
      'Nov',
      'Déc',
    ];
    final month = months[d.month - 1];
    final hour = d.hour.toString().padLeft(2, '0');
    final min = d.minute.toString().padLeft(2, '0');
    return "$day $month $hour:$min";
  }

  List<Notee> get _filteredNotes {
    final q = searchCtrl.text.trim().toLowerCase();
    if (q.isEmpty) return notes;
    return notes.where((n) => n.title.toLowerCase().contains(q)).toList();
  }

  Future<void> _addNote() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const notes2()),
    );

    if (result != null && result is String) {
      final text = result.trim();
      if (text.isEmpty) return;

      setState(() {
        notes.insert(
          0,
          Notee(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            title: text,
            date: DateTime.now(),
          ),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.of(context).size.height;

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
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("images/b6.png"),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              // ✅ Title
              Positioned(
                top: h * 0.04,
                left: h * 0.01,
                child: const Text(
                  "Mes",
                  style: TextStyle(
                    fontSize: 46,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Positioned(
                top: h * 0.09,
                left: h * 0.01,
                child: const Text(
                  "Notes",
                  style: TextStyle(
                    fontSize: 46,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              // ✅ Robot
              Positioned(
                top: h * -0.01,
                right: h * 0.001,
                child: Transform.rotate(
                  angle: -pi / 3.8,
                  child: Image.asset('images/robot2.png', width: 180),
                ),
              ),

              // ✅ LIST NOTES (بين العنوان و search bar)
              Positioned(
                top: h * 0.20,
                left: 16,
                right: 16,
                bottom: 90, // نخلي مكان للـ search bar
                child: ListView.separated(
                  padding: const EdgeInsets.only(bottom: 10),
                  itemCount: _filteredNotes.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 14),
                  itemBuilder: (context, index) {
                    final n = _filteredNotes[index];

                    return Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.18),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.15),
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _formatDate(n.date),
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.75),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  n.title,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              setState(() => n.liked = !n.liked);
                            },
                            icon: Icon(
                              n.liked ? Icons.favorite : Icons.favorite_border,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),

              // ✅ SEARCH + DRAW BTN (louta)
              Positioned(
                bottom: h * 0.01,
                left: h * 0.001,
                child: SizedBox(
                  width: 340,
                  height: 50,
                  child: barederecherche(
                    controller: searchCtrl,
                    onChanged: (_) => setState(() {}),
                  ),
                ),
              ),
              Positioned(
                bottom: h * 0.01,
                right: h * 0.01,
                child: Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.25),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.draw, color: Colors.white),
                    onPressed: _addNote,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class barederecherche extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String>? onChanged;

  const barederecherche({super.key, required this.controller, this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          const Icon(Icons.search, color: Colors.white),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
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

class Notee {
  final String id;
  final String title;
  final DateTime date;
  bool liked;

  Notee({
    required this.id,
    required this.title,
    required this.date,
    this.liked = false,
  });
}
