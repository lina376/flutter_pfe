import 'package:flutter/material.dart';
import 'package:ora/controlleurs/controleur_coach_ora.dart';
import 'package:ora/controlleurs/controleur_principal.dart';
import 'package:ora/models/modele_coach_ora.dart';
import 'package:ora/screens/chat.dart';
import 'package:ora/screens/eau_page.dart';
import 'package:ora/screens/sante.dart';
import 'package:ora/screens/sport.dart';
import 'package:easy_localization/easy_localization.dart';
class CoachOraPage extends StatefulWidget {
  static const String screenRoute = 'pagecoachora';

  const CoachOraPage({super.key});

  @override
  State<CoachOraPage> createState() => _CoachOraPageState();
}

class _CoachOraPageState extends State<CoachOraPage> {
  final ControleurCoachOra _controleur = ControleurCoachOra();
  final ControleurPrincipal _controleurPrincipal = ControleurPrincipal();
  late Future<ModeleCoachOra> _futureCoach;

  @override
  void initState() {
    super.initState();
    _futureCoach = _controleur.chargerCoachAujourdhui();
  }

  Future<void> _recharger() async {
    setState(() {
      _futureCoach = _controleur.chargerCoachAujourdhui();
    });
    await _futureCoach;
  }

  Future<void> _ouvrirChatAvecCoach(ModeleCoachOra coach) async {
    final question = _controleur.creerQuestionPourAssistant(coach);
    final id = await _controleurPrincipal.creerConversation(
      premierMessage: 'Coach ORA - Conseil personnalisé',
      contexteType: 'coach_ora',
      contexteId: coach.date,
    );

    if (!mounted) return;

    Navigator.pushNamed(
      context,
      chat.screenRoute,
      arguments: id.isEmpty
          ? null
          : {
              'conversationId': id,
              'questionInitiale': question,
            },
    );
  }

  Color _couleurScore(int score) {
    if (score >= 80) return const Color(0xFF4CAF50);
    if (score >= 55) return const Color(0xFFFFB74D);
    return const Color(0xFFFF6B6B);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.chevron_left, color: Colors.white, size: 34),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text("coach.title".tr(),
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800),
        ),
        centerTitle: true,
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('images/b1.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: FutureBuilder<ModeleCoachOra>(
            future: _futureCoach,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                );
              }

              if (snapshot.hasError) {
                return _messageErreur();
              }

              final coach = snapshot.data!;

              return RefreshIndicator(
                onRefresh: _recharger,
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(18, 16, 18, 28),
                  children: [
                    _carteScore(coach),
                    const SizedBox(height: 14),
                    _carteConseil(coach),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: _miniStat(
                            icon: Icons.water_drop,
                            titre: "coach.hydration".tr(),
                            valeur:
                                '${coach.eauBu.toStringAsFixed(1)} / ${coach.objectifEau.toStringAsFixed(1)} L',
                            couleur: Colors.lightBlueAccent,
                            onTap: () => Navigator.pushNamed(
                              context,
                              EauPage.screenRoute,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _miniStat(
                            icon: Icons.directions_run,
                            titre: "coach.sport".tr(),
                            valeur:
                                '${coach.minutesSport} / ${coach.objectifSport} min',
                            couleur: Colors.greenAccent,
                            onTap: () => Navigator.pushNamed(
                              context,
                              SportPage.screenRoute,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: _miniStat(
                            icon: Icons.bedtime,
                            titre: "coach.sleep".tr(),
                            valeur: '${coach.heuresSommeil.toStringAsFixed(1)} h',
                            couleur: Colors.deepPurpleAccent.shade100,
                            onTap: () => Navigator.pushNamed(
                              context,
                              SantePage.screenRoute,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _miniStat(
                            icon: Icons.mood,
                            titre: "coach.mood".tr(),
                            valeur: coach.humeur,
                            couleur: Colors.pinkAccent.shade100,
                            onTap: () => Navigator.pushNamed(
                              context,
                              SantePage.screenRoute,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    _carteRecommandation(
                      icon: Icons.water_drop_outlined,
                      titre: "coach.hydration_recommendation".tr(),
                      texte: coach.recommandationHydratation,
                    ),
                    const SizedBox(height: 10),
                    _carteRecommandation(
                      icon: Icons.fitness_center,
                      titre: "coach.sport_recommendation".tr(),
                      texte: coach.recommandationSport,
                    ),
                    const SizedBox(height: 10),
                    _carteRecommandation(
                      icon: Icons.health_and_safety,
                      titre: "coach.health_alert".tr(),
                      texte: coach.alerteSante,
                    ),
                    const SizedBox(height: 18),
                    _boutonAssistant(coach),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _messageErreur() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: Colors.white, size: 48),
            const SizedBox(height: 12),
             Text(
"coach.load_error".tr(),
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
            const SizedBox(height: 14),
            ElevatedButton(
              onPressed: _recharger,
              child: Text("app.retry".tr()),
            ),
          ],
        ),
      ),
    );
  }

  Widget _carteScore(ModeleCoachOra coach) {
    final couleur = _couleurScore(coach.scoreBienEtre);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: _decorationCarte(),
      child: Row(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                height: 92,
                width: 92,
                child: CircularProgressIndicator(
                  value: coach.scoreBienEtre / 100,
                  strokeWidth: 9,
                  color: couleur,
                  backgroundColor: Colors.white.withOpacity(0.16),
                ),
              ),
              Text(
                '${coach.scoreBienEtre}%',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                 Text(
             "coach.wellbeing_score".tr(),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  coach.etatGeneral,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.85),
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "${"coach.updated".tr()} : ${coach.date}",
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.65),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _carteConseil(ModeleCoachOra coach) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: _decorationCarte(),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image.asset('images/robot3.png', width: 58, height: 58),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                 Text(
                  "coach.daily_tip".tr(),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  coach.conseilDuJour,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.86),
                    fontSize: 14,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _miniStat({
    required IconData icon,
    required String titre,
    required String valeur,
    required Color couleur,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 118,
        padding: const EdgeInsets.all(14),
        decoration: _decorationCarte(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: couleur, size: 28),
            const Spacer(),
            Text(
              titre,
              style: TextStyle(
                color: Colors.white.withOpacity(0.75),
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              valeur,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _carteRecommandation({
    required IconData icon,
    required String titre,
    required String texte,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _decorationCarte(),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 42,
            width: 42,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.14),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: Colors.white, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titre,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  texte,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.82),
                    fontSize: 13,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _boutonAssistant(ModeleCoachOra coach) {
    return SizedBox(
      height: 54,
      child: ElevatedButton.icon(
        onPressed: () => _ouvrirChatAvecCoach(coach),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF6D4CC2).withOpacity(0.92),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
        icon: const Icon(Icons.smart_toy_outlined),
        label:  Text(
"coach.talk".tr(),
          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
        ),
      ),
    );
  }

  BoxDecoration _decorationCarte() {
    return BoxDecoration(
      color: const Color.fromARGB(210, 28, 7, 55).withOpacity(0.58),
      borderRadius: BorderRadius.circular(24),
      border: Border.all(color: Colors.white.withOpacity(0.16)),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.18),
          blurRadius: 18,
          offset: const Offset(0, 10),
        ),
      ],
    );
  }
}
