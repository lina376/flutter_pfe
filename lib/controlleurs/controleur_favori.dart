import '../models/modele_favori.dart';
import '../services/service_favori.dart';

class ControleurFavori {
  final ServiceFavori _serviceFavori = ServiceFavori();

  Stream<List<ModeleFavori>> obtenirFluxFavoris() {
    return _serviceFavori.obtenirFluxFavoris();
  }

  Future<bool> estFavori(String idOriginal) {
    return _serviceFavori.estFavori(idOriginal);
  }

  Future<void> supprimerFavori(String idFavori) {
    return _serviceFavori.supprimerFavori(idFavori);
  }

  Future<void> basculerFavoriNote({
    required String idNote,
    required String titre,
    required String contenu,
    required DateTime date,
  }) {
    return _serviceFavori.basculerFavoriNote(
      idNote: idNote,
      titre: titre,
      contenu: contenu,
      date: date,
    );
  }

  String extraireIdNoteDepuisIdOriginal(String idOriginal) {
    return idOriginal.replaceFirst('note_', '');
  }
}
