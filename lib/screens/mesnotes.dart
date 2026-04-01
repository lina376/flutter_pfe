import 'package:flutter/material.dart';
import 'package:ora/screens/notes2.dart';
import 'dart:math';
import 'fav.dart';
import 'package:ora/screens/principal.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class mesnotes extends StatefulWidget {
  static const String screenRoute = 'pagemesnotes';
  const mesnotes({super.key});

  @override
  State<mesnotes> createState() => _mesnotesState();
}

class _mesnotesState extends State<mesnotes> {
  final TextEditingController searchCtrl = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

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

  Future<void> _addNote() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const notes2()),
    );
  }

  Stream<QuerySnapshot> _notesStream() {
    final user = _auth.currentUser;
    if (user == null) return const Stream.empty();

    return _firestore
        .collection('users')
        .doc(user.uid)
        .collection('notes')
        .orderBy('date', descending: true)
        .snapshots();
  }

  Future<void> supprimerNoteEtFavori(String noteId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      // 1) supprimer la note
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('notes')
          .doc(noteId)
          .delete();

      // 2) supprimer le favori lié à cette note
      final favorisQuery = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('favoris')
          .where('idOriginal', isEqualTo: 'note_$noteId')
          .get();

      for (final doc in favorisQuery.docs) {
        await doc.reference.delete();
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Erreur suppression : $e")));
    }
  }

  Future<void> _mettreAJourFavoriSiExiste({
    required String noteId,
    required String titre,
    required String contenu,
    required bool liked,
  }) async {
    final user = _auth.currentUser;
    if (user == null) return;

    final favorisRef = _firestore
        .collection('users')
        .doc(user.uid)
        .collection('favoris');

    final query = await favorisRef
        .where('idOriginal', isEqualTo: 'note_$noteId')
        .get();

    for (final doc in query.docs) {
      await doc.reference.update({
        'title': titre,
        'desc': contenu,
        'contenu': contenu,
        'liked': liked,
        'date': Timestamp.now(),
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
            Navigator.pop(context);
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
              Positioned(
                top: h * -0.01,
                right: h * 0.001,
                child: Transform.rotate(
                  angle: -pi / 3.8,
                  child: Image.asset('images/robot2.png', width: 180),
                ),
              ),
              Positioned(
                top: h * 0.20,
                left: 16,
                right: 16,
                bottom: 90,
                child: StreamBuilder<QuerySnapshot>(
                  stream: _notesStream(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return Center(
                        child: Text(
                          "Aucune note",
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                          ),
                        ),
                      );
                    }

                    final allDocs = snapshot.data!.docs;

                    final q = searchCtrl.text.trim().toLowerCase();
                    final docs = allDocs.where((doc) {
                      final data = doc.data() as Map<String, dynamic>;
                      final titre = (data["titre"] ?? "")
                          .toString()
                          .toLowerCase();
                      return q.isEmpty || titre.contains(q);
                    }).toList();

                    return ListView.separated(
                      padding: const EdgeInsets.only(bottom: 10),
                      itemCount: docs.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 14),
                      itemBuilder: (context, index) {
                        final doc = docs[index];
                        final data = doc.data() as Map<String, dynamic>;

                        final noteId = doc.id;
                        final titre = data["titre"] ?? "Sans titre";
                        final contenu = data["contenu"] ?? "";
                        final liked = data["liked"] ?? false;
                        final Timestamp? ts = data["date"] as Timestamp?;
                        final date = ts?.toDate() ?? DateTime.now();

                        return GestureDetector(
                          onTap: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => notes2(
                                  initial: {
                                    "id": noteId,
                                    "titre": titre,
                                    "contenu": contenu,
                                    "liked": liked,
                                    "date": date,
                                  },
                                ),
                              ),
                            );
                          },
                          child: Container(
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        _formatDate(date),
                                        style: TextStyle(
                                          color: Colors.white.withOpacity(0.75),
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        titre,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Row(
                                  children: [
                                    //  FAVORI
                                    FutureBuilder<bool>(
                                      future: isFavori("note_$noteId"),
                                      builder: (context, snapshot) {
                                        final isFav = snapshot.data ?? false;

                                        return GestureDetector(
                                          onTap: () async {
                                            await toggleFavori({
                                              "id": "note_$noteId",
                                              "type": "note",
                                              "title": titre,
                                              "desc": contenu,
                                              "contenu": contenu,
                                              "date": date,
                                            });
                                            setState(() {});
                                          },
                                          child: Icon(
                                            isFav
                                                ? Icons.favorite
                                                : Icons.favorite_border,
                                            color: Colors.redAccent,
                                            size: 18,
                                          ),
                                        );
                                      },
                                    ),

                                    const SizedBox(width: 8),

                                    //  DELETE
                                    GestureDetector(
                                      onTap: () async {
                                        await supprimerNoteEtFavori(noteId);
                                      },

                                      child: const Icon(
                                        Icons.delete_outline,
                                        color: Colors.white,
                                        size: 18,
                                      ),
                                    ),
                                  ],
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
