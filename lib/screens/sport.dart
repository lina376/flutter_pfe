import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ora/controlleurs/controleur_sport.dart';
import 'package:ora/models/modele_eau.dart';
import 'package:ora/models/modele_sante.dart';
import 'package:ora/models/modele_sport.dart';

class SportPage extends StatefulWidget {
  static const String screenRoute = 'page_sport';

  const SportPage({super.key});

  @override
  State<SportPage> createState() => _SportPageState();
}

class _SportPageState extends State<SportPage> {
  final ControleurSport _controleur = ControleurSport();

  DateTime semaineAffichee = DateTime.now();
  ModeleSport? sport;
  ModeleSante? sante;
  ModeleEau? eau;
  List<ModeleSport> semaine = [];
  bool chargement = true;

  @override
  void initState() {
    super.initState();
    _charger();
  }

  Future<void> _charger() async {
    try {
      final dataSport = await _controleur.chargerAujourdhui();
      final dataSante = await _controleur.obtenirSanteLiee();
      final dataEau = await _controleur.obtenirEauLiee();
      final dataSemaine = await _controleur.chargerSemaineDepuis(semaineAffichee);

      if (!mounted) return;

      setState(() {
        sport = dataSport;
        sante = dataSante;
        eau = dataEau;
        semaine = dataSemaine;
        chargement = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => chargement = false);
    }
  }

  Future<void> _changerSemaine(int offset) async {
    setState(() {
      semaineAffichee = semaineAffichee.add(Duration(days: offset * 7));
      chargement = true;
    });

    await _charger();
  }

  Future<void> _ajouterMinutes() async {
    if (sport == null) return;

    final nouveau = sport!.copyWith(
      minutes: (sport!.minutes + 10).clamp(0, 240).toInt(),
      updatedAt: DateTime.now(),
      synced: false,
    );

    setState(() => sport = nouveau);

    final data = await _controleur.modifierMinutes(nouveau, nouveau.minutes);
    final dataSemaine = await _controleur.chargerSemaineDepuis(semaineAffichee);

    if (!mounted) return;

    setState(() {
      sport = data;
      semaine = dataSemaine;
    });
  }

  Future<void> _retirerMinutes() async {
    if (sport == null) return;

    final nouveau = sport!.copyWith(
      minutes: (sport!.minutes - 10).clamp(0, 240).toInt(),
      updatedAt: DateTime.now(),
      synced: false,
    );

    setState(() => sport = nouveau);

    final data = await _controleur.modifierMinutes(nouveau, nouveau.minutes);
    final dataSemaine = await _controleur.chargerSemaineDepuis(semaineAffichee);

    if (!mounted) return;

    setState(() {
      sport = data;
      semaine = dataSemaine;
    });
  }

  Future<void> _modifierTypeSeance(String type) async {
    if (sport == null) return;

    final nouveau = sport!.copyWith(
      typeSeance: type,
      updatedAt: DateTime.now(),
      synced: false,
    );

    setState(() => sport = nouveau);

    final data = await _controleur.modifierTypeSeance(nouveau, type);

    if (!mounted) return;

    setState(() => sport = data);
  }


  Future<void> _modifierObjectifSport(String objectif) async {
    if (sport == null || sport!.objectifSport == objectif) return;

    final nouveau = sport!.copyWith(objectifSport: objectif);
    setState(() => sport = nouveau);

    final data = await _controleur.modifierObjectifSport(nouveau, objectif);
    final dataSemaine = await _controleur.chargerSemaineDepuis(semaineAffichee);

    if (!mounted) return;
    setState(() {
      sport = data;
      semaine = dataSemaine;
    });
  }

  Future<void> _modifierEtatSante(String etat) async {
    if (sport == null || sport!.etatSante == etat) return;

    final nouveau = sport!.copyWith(etatSante: etat);
    setState(() => sport = nouveau);

    final data = await _controleur.modifierEtatSante(nouveau, etat);
    final dataSemaine = await _controleur.chargerSemaineDepuis(semaineAffichee);

    if (!mounted) return;
    setState(() {
      sport = data;
      semaine = dataSemaine;
    });
  }

  Widget _enteteSemaine() {
    final debut = semaineAffichee.subtract(
      Duration(days: semaineAffichee.weekday - 1),
    );
    final fin = debut.add(const Duration(days: 6));

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          onPressed: () => _changerSemaine(-1),
          icon: const Icon(Icons.chevron_left, color: Colors.white),
        ),
        Text(
          '${DateFormat('dd/MM').format(debut)} - ${DateFormat('dd/MM').format(fin)}',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w900,
          ),
        ),
        IconButton(
          onPressed: () => _changerSemaine(1),
          icon: const Icon(Icons.chevron_right, color: Colors.white),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final data = sport;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text(
          'Sport',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFF35D07F),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.directions_run, color: Colors.white),
          ),
        ],
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('images/b2.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: chargement
              ? const Center(child: CircularProgressIndicator(color: Colors.white))
              : data == null
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Text(
                          'Impossible de charger les données sport. Vérifiez votre connexion puis réessayez.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.85),
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    )
                  : SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(18, 18, 18, 28),
                  child: Column(
                    children: [
                      _carteConseil(data),
                      const SizedBox(height: 16),
                      _carteResume(data),
                      const SizedBox(height: 16),
                      _carteProfilSport(data),
                      const SizedBox(height: 16),
                      _carteObjectif(data),
                      const SizedBox(height: 16),
                      _carteExercices(data),
                      const SizedBox(height: 16),
                      _enteteSemaine(),
                      const SizedBox(height: 10),
                      _carteHistorique(),
                      const SizedBox(height: 16),
                      _carteLienSanteEau(),
                    ],
                  ),
                ),
        ),
      ),
    );
  }

  Widget _carteConseil(ModeleSport data) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: _decorationCarte(),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Conseil ORA du jour',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  _controleur.conseilSport(sport: data, sante: sante, eau: eau),
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.82),
                    fontSize: 14,
                    height: 1.4,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Image.asset(
            'images/robot1.png',
            width: 82,
            errorBuilder: (_, __, ___) =>
                const Icon(Icons.smart_toy, color: Colors.white, size: 64),
          ),
        ],
      ),
    );
  }

  Widget _carteResume(ModeleSport data) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: _decorationCarte(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Résumé activité',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _badgeInfo(Icons.timer, '${data.minutes} min'),
              _badgeInfo(Icons.flag, '${data.objectifMinutes} min objectif'),
              _badgeInfo(Icons.local_fire_department, '${data.calories} kcal'),
              _badgeInfo(Icons.speed, data.intensite),
              _badgeInfo(Icons.track_changes, data.objectifSport),
              _badgeInfo(Icons.health_and_safety, data.etatSante),
            ],
          ),
        ],
      ),
    );
  }

  Widget _carteObjectif(ModeleSport data) {
    final progress = data.objectifMinutes == 0
        ? 0.0
        : (data.minutes / data.objectifMinutes).clamp(0.0, 1.0);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: _decorationCarte(),
      child: Column(
        children: [
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Objectif sportif',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(height: 22),
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 136,
                height: 136,
                child: CircularProgressIndicator(
                  value: progress,
                  strokeWidth: 11,
                  backgroundColor: Colors.white.withOpacity(0.13),
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    Color(0xFF35D07F),
                  ),
                ),
              ),
              Column(
                children: [
                  Text(
                    '${data.minutes}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 38,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  Text(
                    '/ ${data.objectifMinutes} min',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.72),
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 18),
          Text(
            progress >= 1
                ? 'Objectif atteint, bravo ! 🎉'
                : 'Ajoutez une petite séance pour avancer.',
            style: TextStyle(
              color: Colors.white.withOpacity(0.82),
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _retirerMinutes,
                  label: const Text('-5 min'),
                  style: _styleBouton(false),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _ajouterMinutes,
                  label: const Text('+5 min'),
                  style: _styleBouton(true),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _carteProfilSport(ModeleSport data) {
    final objectifs = ['Perte de poids', 'Prise de poids', 'Rester en forme'];
    final etats = ['Bonne santé', 'Malade'];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: _decorationCarte(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Profil sportif',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'Choisissez votre objectif. ORA adapte automatiquement la durée selon votre âge, poids, sommeil, santé et hydratation.',
            style: TextStyle(
              color: Colors.white.withOpacity(0.72),
              fontSize: 13,
              height: 1.35,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: objectifs.map((objectif) {
              final selected = data.objectifSport == objectif;
              return ChoiceChip(
                label: Text(objectif),
                selected: selected,
                onSelected: (_) => _modifierObjectifSport(objectif),
                selectedColor: const Color(0xFF35D07F),
                backgroundColor: const Color(0xFFB4A7D6),
                labelStyle: TextStyle(
                  color: Colors.white,
                  fontWeight: selected ? FontWeight.w900 : FontWeight.w700,
                ),
                side: BorderSide(color: Colors.white.withOpacity(0.18)),
              );
            }).toList(),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            children: etats.map((etat) {
              final selected = data.etatSante == etat;
              return ChoiceChip(
                label: Text(etat),
                selected: selected,
                onSelected: (_) => _modifierEtatSante(etat),
                selectedColor: const Color(0xFF35D07F),
                backgroundColor: const Color(0xFFB4A7D6),
                labelStyle: TextStyle(
                  color: Colors.white,
                  fontWeight: selected ? FontWeight.w900 : FontWeight.w700,
                ),
                side: BorderSide(color: Colors.white.withOpacity(0.18)),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _carteExercices(ModeleSport data) {
    final exercices = _controleur.exercicesRecommandes(
      sport: data,
      sante: sante,
      eau: eau,
    );

    IconData iconPour(String titre) {
      if (titre.contains('Marche')) return Icons.directions_walk;
      if (titre.contains('Cardio')) return Icons.directions_run;
      if (titre.contains('Yoga')) return Icons.self_improvement;
      if (titre.contains('Étirement')) return Icons.accessibility_new;
      if (titre.contains('Renforcement')) return Icons.fitness_center;
      return Icons.sports_gymnastics;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: _decorationCarte(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Exercices recommandés',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 14),
          Column(
            children: exercices.map((item) {
              final titre = item['titre'] as String;
              final selected = data.typeSeance == titre;

              return GestureDetector(
                onTap: () => _modifierTypeSeance(titre),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: selected
                        ? const Color(0xFF35D07F).withOpacity(0.24)
                        : Colors.white.withOpacity(0.09),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: selected
                          ? const Color(0xFF35D07F)
                          : Colors.white.withOpacity(0.14),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(iconPour(titre), color: Colors.white),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              titre,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              item['duree'] as String,
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.70),
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (selected)
                        const Icon(Icons.check_circle, color: Color(0xFF35D07F)),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _carteHistorique() {
    final valeurs = _valeursSemaine();
    final jours = ['Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam', 'Dim'];
    const maxMinutes = 60.0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: _decorationCarte(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Historique sport - Cette semaine',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 18),
          SizedBox(
            height: 145,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(7, (index) {
                final hauteur = (valeurs[index] / maxMinutes) * 100;

                return Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        '${valeurs[index]}',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.65),
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 6),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 350),
                        width: 18,
                        height: hauteur.clamp(12, 100),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(9),
                          gradient: const LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: [Color(0xFF19A463), Color(0xFF72F0AC)],
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        jours[index],
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.75),
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _carteLienSanteEau() {
    final age = sante?.age.toString() ?? '-';
    final poids = sante == null ? '-' : '${sante!.poids.toStringAsFixed(1)} kg';
    final sommeil = sante?.heuresSommeil.toStringAsFixed(1) ?? '-';
    final humeur = sante?.humeur ?? '-';
    final hydratation = eau == null ? '-' : '${eau!.verres}/${eau!.objectif} verres';
    final data = sport;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: _decorationCarte(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Lien avec Santé & Eau',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 14),
          _ligneLien(Icons.person, 'Âge', '$age ans'),
          _ligneLien(Icons.monitor_weight, 'Poids', poids),
          if (data != null) _ligneLien(Icons.track_changes, 'Objectif sport', data.objectifSport),
          if (data != null) _ligneLien(Icons.health_and_safety, 'État santé', data.etatSante),
          _ligneLien(Icons.bedtime, 'Sommeil', '$sommeil h'),
          _ligneLien(Icons.mood, 'Humeur', humeur),
          _ligneLien(Icons.water_drop, 'Hydratation', hydratation),
        ],
      ),
    );
  }

  Widget _ligneLien(IconData icon, String titre, String valeur) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.09),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white, size: 21),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              titre,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          Text(
            valeur,
            style: TextStyle(
              color: Colors.white.withOpacity(0.78),
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  List<int> _valeursSemaine() {
    final debutSemaine = semaineAffichee.subtract(
      Duration(days: semaineAffichee.weekday - 1),
    );

    return List.generate(7, (index) {
      final jour = debutSemaine.add(Duration(days: index));
      final date = DateFormat('yyyy-MM-dd').format(jour);
      final items = semaine.where((e) => e.date == date).toList();

      if (items.isEmpty) return 0;
      return items.first.minutes;
    });
  }

  Widget _badgeInfo(IconData icon, String texte) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.12),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.10)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: const Color(0xFF72F0AC), size: 18),
          const SizedBox(width: 7),
          Text(
            texte,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  ButtonStyle _styleBouton(bool principal) {
    return ElevatedButton.styleFrom(
      backgroundColor: principal
          ? const Color(0xFF35D07F)
          : Colors.white.withOpacity(0.14),
      foregroundColor: Colors.white,
      elevation: 0,
      padding: const EdgeInsets.symmetric(vertical: 14),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
    );
  }

  BoxDecoration _decorationCarte() {
    return BoxDecoration(
      color: Colors.white.withOpacity(0.12),
      borderRadius: BorderRadius.circular(24),
      border: Border.all(color: Colors.white.withOpacity(0.16)),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.12),
          blurRadius: 16,
          offset: const Offset(0, 8),
        ),
      ],
    );
  }
}
