import '../models/modele_note.dart';
import '../services/service_note.dart';
import '../services/service_favori.dart';

class ControleurNote {
  final ServiceNote _serviceNote = ServiceNote();
  final ServiceFavori _serviceFavori = ServiceFavori();

  Stream<List<ModeleNote>> obtenirFluxNotes() {
    return _serviceNote.obtenirFluxNotes();
  }

  Future<void> supprimerNote(String idNote) async {
    await _serviceNote.supprimerNote(idNote);

    try {
      await _serviceFavori.supprimerFavoriLieANote(idNote);
    } catch (_) {}
  }

  Future<void> enregistrerNote({
    String? idNote,
    required String titre,
    required String contenu,
    required bool aimee,
  }) async {
    final titreFinal = titre.isEmpty ? 'Sans titre' : titre;

    if (idNote != null && idNote.isNotEmpty) {
      await _serviceNote.mettreAJourNote(
        idNote: idNote,
        titre: titreFinal,
        contenu: contenu,
        aimee: aimee,
      );

      try {
        await _serviceFavori.mettreAJourFavoriLieANote(
          idNote: idNote,
          titre: titreFinal,
          contenu: contenu,
          aimee: aimee,
        );
      } catch (_) {}
    } else {
      final nouvelId = await _serviceNote.ajouterNote(
        titre: titreFinal,
        contenu: contenu,
        aimee: aimee,
      );

      if (nouvelId.isNotEmpty && aimee) {
        try {
          await _serviceFavori.basculerFavoriNote(
            idNote: nouvelId,
            titre: titreFinal,
            contenu: contenu,
            date: DateTime.now(),
          );
        } catch (_) {}
      }
    }
  }

  String formaterDate(DateTime date) {
    final jour = date.day.toString().padLeft(2, '0');
    const mois = [
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
    final moisTexte = mois[date.month - 1];
    final heure = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');

    return "$jour $moisTexte $heure:$minute";
  }
}
