import '../models/modele_tache.dart';
import '../services/service_tache.dart';

class ControleurTache {
  final ServiceTache _serviceTache = ServiceTache();

  Stream<List<ModeleTache>> obtenirFluxTaches() {
    return _serviceTache.obtenirFluxTaches();
  }

  Stream<List<ModeleTache>> obtenirFluxTachesParDate(DateTime date) {
    return _serviceTache.obtenirFluxTachesParDate(date);
  }

  Future<void> ajouterTache({
    required String titre,
    required String heure,
    required DateTime date,
    required String categorie,
    String priorite = 'moyenne',
  }) {
    return _serviceTache.ajouterTache(
      titre: titre,
      heure: heure,
      date: date,
      categorie: categorie,
      priorite: priorite,
    );
  }

  Future<void> supprimerTache(String idTache) {
    return _serviceTache.supprimerTache(idTache);
  }

  Future<void> changerEtatTache({
    required String idTache,
    required bool terminee,
  }) {
    return _serviceTache.changerEtatTache(idTache: idTache, terminee: terminee);
  }

  Future<void> synchroniserTaches() async {
    await _serviceTache.synchroniserVersFirebase();
    await _serviceTache.synchroniserDepuisFirebase();
  }

  Future<List<ModeleTache>> recupererTachesParDateTriees(DateTime date) {
    return _serviceTache.recupererTachesParDateTriees(date);
  }

  List<ModeleTache> trierParPriorite(List<ModeleTache> taches) {
    return _serviceTache.trierParPriorite(taches);
  }

  List<ModeleTache> filtrerParDate(List<ModeleTache> taches, DateTime date) {
    return taches.where((tache) {
      return tache.date.year == date.year &&
          tache.date.month == date.month &&
          tache.date.day == date.day;
    }).toList();
  }

  void dispose() {
    _serviceTache.dispose();
  }
}
