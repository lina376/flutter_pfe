import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ora/controlleurs/controleur_favori.dart';
import 'package:ora/models/modele_favori.dart';
import 'package:ora/screens/notes2.dart';

class Favorise extends StatefulWidget {
  static const String screenRoute = 'pagefavorise';
  const Favorise({super.key});

  @override
  State<Favorise> createState() => _FavoriseState();
}

class _FavoriseState extends State<Favorise> {
  final ControleurFavori _controleurFavori = ControleurFavori();

  Future<void> supprimerFavori(String docId) async {
    await _controleurFavori.supprimerFavori(docId);
  }

  Future<void> ouvrirFavori(ModeleFavori favori) async {
    if (favori.type == "note") {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => notes2(
            initial: {
              "id": favori.noteDocId.isNotEmpty
                  ? favori.noteDocId
                  : _controleurFavori.extraireIdNoteDepuisIdOriginal(
                      favori.idOriginal,
                    ),
              "titre": favori.title,
              "contenu": favori.contenu,
              "liked": true,
              "date": favori.date,
            },
          ),
        ),
      );
    }
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
          iconSize: 34,
          constraints: const BoxConstraints(minHeight: 50, minWidth: 50),
          onPressed: () {
            Navigator.pop(context);
          },
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
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                const Text(
                  "Favoriser",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 34,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: StreamBuilder<List<ModeleFavori>>(
                    stream: _controleurFavori.obtenirFluxFavoris(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (snapshot.hasError) {
                        return Center(
                          child: Text(
                            "Erreur de chargement",
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.8),
                            ),
                          ),
                        );
                      }

                      final favoris = snapshot.data ?? [];

                      if (favoris.isEmpty) {
                        return Center(
                          child: Text(
                            "Aucun favori",
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.8),
                            ),
                          ),
                        );
                      }

                      return ListView.separated(
                        itemCount: favoris.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 14),
                        itemBuilder: (context, index) {
                          final favori = favoris[index];
                          final dt = DateFormat(
                            "dd/MM/yyyy, HH:mm",
                          ).format(favori.date);

                          return GestureDetector(
                            onTap: () async {
                              await ouvrirFavori(favori);
                            },
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.18),
                                borderRadius: BorderRadius.circular(18),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.12),
                                ),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.favorite,
                                    color: Colors.redAccent,
                                    size: 30,
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          favori.title,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w800,
                                            fontSize: 15,
                                          ),
                                        ),
                                        const SizedBox(height: 3),
                                        Text(
                                          favori.desc,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            color: Colors.white.withOpacity(
                                              0.75,
                                            ),
                                            fontSize: 12,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          dt,
                                          style: TextStyle(
                                            color: Colors.white.withOpacity(
                                              0.9,
                                            ),
                                            fontSize: 10,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.delete_outline,
                                      color: Colors.white,
                                    ),
                                    onPressed: () async {
                                      await supprimerFavori(favori.id);
                                    },
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
          ),
        ),
      ),
    );
  }
}
