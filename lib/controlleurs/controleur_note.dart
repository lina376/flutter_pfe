import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:easy_localization/easy_localization.dart';

import '../models/modele_note.dart';
import '../services/service_note.dart';
import '../services/service_favori.dart';

class ControleurNote {
  final ServiceNote _serviceNote = ServiceNote();
  final ServiceFavori _serviceFavori = ServiceFavori();

  Stream<List<ModeleNote>> obtenirFluxNotes() {
    return _serviceNote.obtenirFluxNotes();
  }

  Future<void> synchroniserNotes() async {
    await _serviceNote.synchroniserVersFirebase();
    await _serviceNote.synchroniserDepuisFirebase();
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
    final titreFinal =
        titre.isEmpty ? 'note_sans_titre'.tr() : titre;

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

  String formaterDate(DateTime date, BuildContext context) {
    return DateFormat(
      'dd MMM HH:mm',
      context.locale.toString(),
    ).format(date);
  }
}