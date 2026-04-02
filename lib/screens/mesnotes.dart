import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:ora/controlleurs/controleur_note.dart';
import 'package:ora/screens/notes2.dart';
import 'fav.dart';

class mesnotes extends StatefulWidget {
  static const String screenRoute = 'pagemesnotes';
  const mesnotes({super.key});

  @override
  State<mesnotes> createState() => _mesnotesState();
}

class _mesnotesState extends State<mesnotes> {
  final TextEditingController searchCtrl = TextEditingController();
  final ControleurNote _controleurNote = ControleurNote();

  @override
  void dispose() {
    searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _addNote() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const notes2()),
    );
  }

  Future<void> supprimerNoteEtFavori(String noteId) async {
    try {
      await _controleurNote.supprimerNote(noteId);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Erreur suppression : $e")));
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
                child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                  stream: _controleurNote.obtenirFluxNotes(),
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
                      final data = doc.data();
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
                        final data = doc.data();

                        final noteId = doc.id;
                        final titre = (data["titre"] ?? "Sans titre")
                            .toString();
                        final contenu = (data["contenu"] ?? "").toString();
                        final liked = (data["liked"] ?? false) == true;
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
                                        _controleurNote.formaterDate(date),
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
