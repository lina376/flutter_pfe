import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/service_note.dart';
import '../services/service_favori.dart';

class ControleurNote {
  final ServiceNote _serviceNote = ServiceNote();
  final ServiceFavori _serviceFavori = ServiceFavori();

  Stream<QuerySnapshot<Map<String, dynamic>>> obtenirFluxNotes() {
    return _serviceNote.obtenirFluxNotes();
  }

  Future<void> supprimerNote(String idNote) async {
    await _serviceNote.supprimerNote(idNote);
    await _serviceFavori.supprimerFavoriLieANote(idNote);
  }

  Future<void> enregistrerNote({
    String? idNote,
    required String titre,
    required String contenu,
    required bool aimee,
  }) async {
    if (idNote != null && idNote.isNotEmpty) {
      await _serviceNote.mettreAJourNote(
        idNote: idNote,
        titre: titre,
        contenu: contenu,
        aimee: aimee,
      );

      await _serviceFavori.mettreAJourFavoriLieANote(
        idNote: idNote,
        titre: titre.isEmpty ? 'Sans titre' : titre,
        contenu: contenu,
        aimee: aimee,
      );
    } else {
      final nouvelId = await _serviceNote.ajouterNote(
        titre: titre,
        contenu: contenu,
        aimee: aimee,
      );

      if (aimee && nouvelId.isNotEmpty) {
        await _serviceFavori.basculerFavoriNote(
          idNote: nouvelId,
          titre: titre.isEmpty ? 'Sans titre' : titre,
          contenu: contenu,
          date: DateTime.now(),
        );
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
