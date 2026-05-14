import 'package:easy_localization/easy_localization.dart';
import 'package:ora/models/modele_coach_ora.dart';
import 'package:ora/services/service_coach_ora.dart';

class ControleurCoachOra {
  final ServiceCoachOra _service = ServiceCoachOra();

  Future<ModeleCoachOra> chargerCoachAujourdhui() {
    return _service.construireCoachAujourdhui();
  }

  String creerQuestionPourAssistant(ModeleCoachOra coach) {
    return 'coach_question_assistant'.tr(args: [
      coach.eauBu.toStringAsFixed(1),
      coach.objectifEau.toStringAsFixed(1),
      coach.minutesSport.toString(),
      coach.objectifSport.toString(),
      coach.heuresSommeil.toStringAsFixed(1),
      coach.humeur,
      coach.scoreBienEtre.toString(),
    ]);
  }
}