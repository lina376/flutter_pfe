import 'package:ora/models/modele_coach_ora.dart';
import 'package:ora/services/service_coach_ora.dart';

class ControleurCoachOra {
  final ServiceCoachOra _service = ServiceCoachOra();

  Future<ModeleCoachOra> chargerCoachAujourdhui() {
    return _service.construireCoachAujourdhui();
  }

  String creerQuestionPourAssistant(ModeleCoachOra coach) {
    return '''Analyse mon état aujourd’hui et donne-moi un conseil personnalisé court.
Hydratation: ${coach.eauBu.toStringAsFixed(1)}L / ${coach.objectifEau.toStringAsFixed(1)}L.
Sport: ${coach.minutesSport} min / ${coach.objectifSport} min.
Sommeil: ${coach.heuresSommeil.toStringAsFixed(1)} h.
Humeur: ${coach.humeur}.
Score bien-être: ${coach.scoreBienEtre}/100.''';
  }
}
