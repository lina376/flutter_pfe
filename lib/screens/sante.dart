import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ora/controlleurs/controleur_sante.dart';
import 'package:ora/models/modele_sante.dart';
import 'package:easy_localization/easy_localization.dart';
class SantePage extends StatefulWidget {
  static const String screenRoute = 'page_sante';

  const SantePage({super.key});

  @override
  State<SantePage> createState() => _SantePageState();
}

class _SantePageState extends State<SantePage> {
  final ControleurSante _controleur = ControleurSante();
  DateTime semaineAffichee = DateTime.now();
  ModeleSante? sante;
  List<ModeleSante> semaine = [];
  bool chargement = true;

  @override
  void initState() {
    super.initState();
    _charger();
  }

  Future<void> _charger() async {
    final data = await _controleur.chargerAujourdhui();
    final dataSemaine = await _controleur.chargerSemaineDepuis(semaineAffichee);

    if (!mounted) return;

    setState(() {
      sante = data;
      semaine = dataSemaine;
      chargement = false;
    });
  }

  Future<void> _changerSemaine(int offset) async {
    setState(() {
      semaineAffichee = semaineAffichee.add(Duration(days: offset * 7));
      chargement = true;
    });

    await _charger();
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

  Future<void> _modifierSommeil(double valeur) async {
    if (sante == null) return;

    final nouveau = sante!.copyWith(
      heuresSommeil: valeur,
      updatedAt: DateTime.now(),
      synced: false,
    );

    setState(() => sante = nouveau);

    final data = await _controleur.modifierSommeil(nouveau, valeur);
    final dataSemaine = await _controleur.chargerSemaine();

    if (!mounted) return;

    setState(() {
      sante = data;
      semaine = dataSemaine;
    });
  }

  Future<void> _modifierHumeur(String valeur) async {
    if (sante == null) return;

    final nouveau = sante!.copyWith(
      humeur: valeur,
      updatedAt: DateTime.now(),
      synced: false,
    );

    setState(() => sante = nouveau);

    final data = await _controleur.modifierHumeur(nouveau, valeur);
    final dataSemaine = await _controleur.chargerSemaine();

    if (!mounted) return;

    setState(() {
      sante = data;
      semaine = dataSemaine;
    });
  }

  Future<void> _modifierPoids(double valeur) async {
    if (sante == null) return;

    final poidsCorrige = valeur < 0
        ? 0.0
        : double.parse(valeur.toStringAsFixed(1));

    final nouveau = sante!.copyWith(
      poids: poidsCorrige,
      updatedAt: DateTime.now(),
      synced: false,
    );

    setState(() => sante = nouveau);

    final data = await _controleur.modifierPoids(nouveau, poidsCorrige);
    final dataSemaine = await _controleur.chargerSemaine();

    if (!mounted) return;

    setState(() {
      sante = data;
      semaine = dataSemaine;
    });
  }

  Future<void> _ouvrirModifierProfil() async {
    if (sante == null) return;

    final ageController = TextEditingController(text: sante!.age.toString());
    final poidsController = TextEditingController(
      text: sante!.poids.toStringAsFixed(1),
    );
    String activiteChoisie = sante!.activite;

    final resultat = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setLocal) {
            return Padding(
              padding: EdgeInsets.only(
                left: 18,
                right: 18,
                bottom: MediaQuery.of(context).viewInsets.bottom + 18,
              ),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1138).withOpacity(0.96),
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(color: Colors.white.withOpacity(0.16)),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Modifier le profil santé',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 18),
                    _champModal('Âge', ageController, 'ans'),
                    const SizedBox(height: 12),
                    _champModal('Poids', poidsController, 'kg'),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        _choixActiviteModal(
                          titre: 'Faible',
                          valeur: 'Faible',
                          selected: activiteChoisie == 'Faible',
                          onTap: () =>
                              setLocal(() => activiteChoisie = 'Faible'),
                        ),
                        const SizedBox(width: 8),
                        _choixActiviteModal(
                          titre: 'Normale',
                          valeur: 'Normale',
                          selected: activiteChoisie == 'Normale',
                          onTap: () =>
                              setLocal(() => activiteChoisie = 'Normale'),
                        ),
                        const SizedBox(width: 8),
                        _choixActiviteModal(
                          titre: 'Sportif',
                          valeur: 'Sportif',
                          selected: activiteChoisie == 'Sportif',
                          onTap: () =>
                              setLocal(() => activiteChoisie = 'Sportif'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () {
                          final age = int.tryParse(ageController.text.trim());
                          final poids = double.tryParse(
                            poidsController.text.trim(),
                          );

                          if (age == null || poids == null) return;

                          Navigator.pop(context, {
                            'age': age,
                            'poids': poids,
                            'activite': activiteChoisie,
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFF5C8A),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                        ),
                        child: const Text(
                          'Enregistrer',
                          style: TextStyle(fontWeight: FontWeight.w900),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );

    if (resultat == null || sante == null) return;

    final data = await _controleur.modifierProfil(
      sante: sante!,
      age: resultat['age'],
      poids: resultat['poids'],
      activite: resultat['activite'],
    );

    final dataSemaine = await _controleur.chargerSemaine();

    if (!mounted) return;

    setState(() {
      sante = data;
      semaine = dataSemaine;
    });
  }

  Widget _carteScoreSante(ModeleSante data) {
    final score = _calculerScoreSante(data);

    Color couleur = Colors.red;

    if (score >= 80) {
      couleur = Colors.greenAccent;
    } else if (score >= 60) {
      couleur = Colors.orangeAccent;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: _decorationCarte(),
      child: Column(
        children: [
           Text(
            "health.score".tr(),
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),

          const SizedBox(height: 18),

          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 120,
                height: 120,
                child: CircularProgressIndicator(
                  value: score / 100,
                  strokeWidth: 10,
                  backgroundColor: Colors.white.withOpacity(0.12),
                  valueColor: AlwaysStoppedAnimation<Color>(couleur),
                ),
              ),

              Column(
                children: [
                  Text(
                    '$score%',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                    ),
                  ),

                   Text(
                    "health.today".tr(),
                    style: TextStyle(
                      color: Colors.white70,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 18),

          Text(
            score >= 85
                ? 'ORA détecte un excellent équilibre général ✨'
                : score >= 70
                ? 'Votre santé est stable aujourd’hui 💪'
                : score >= 50
                ? 'ORA recommande plus de repos et d’hydratation 💧'
                : 'Fatigue détectée. Votre corps a besoin de récupération 🌙',
            style: TextStyle(
              color: Colors.white.withOpacity(0.82),
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final data = sante;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title:  Text(
          "health.title".tr(),
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
              color: const Color(0xFFFF5C8A),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.favorite, color: Colors.white),
          ),
        ],
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("images/b2.png"),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: chargement || data == null
              ? const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(18, 18, 18, 28),
                  child: Column(
                    children: [
                      _carteConseil(data),
                      const SizedBox(height: 16),
                      _carteProfil(data),
                      const SizedBox(height: 16),
                      _carteScoreSante(data),
                      const SizedBox(height: 16),
                      _carteSommeil(data),
                      const SizedBox(height: 16),
                      _enteteSemaine(),
                      const SizedBox(height: 10),
                      _carteHistoriqueSommeil(),
                      const SizedBox(height: 16),
                      _carteHumeur(data),
                      const SizedBox(height: 16),
                      _carteHistoriqueHumeur(),
                      const SizedBox(height: 16),
                      _cartePoids(data),
                    ],
                  ),
                ),
        ),
      ),
    );
  }

  Widget _carteConseil(ModeleSante data) {
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
                 Text(
                  "health.daily_tip".tr(),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  _conseilSante(data),
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
            "images/robot2.png",
            width: 82,
            errorBuilder: (_, __, ___) =>
                const Icon(Icons.smart_toy, color: Colors.white, size: 64),
          ),
        ],
      ),
    );
  }

  Widget _carteProfil(ModeleSante data) {
    final objectifHydratation = (data.poids * 0.035).clamp(1.0, 4.0);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: _decorationCarte(),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Bonjour 👋',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                 Text(
                  "health.profile".tr(),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _badgeInfo(Icons.cake, '${data.age} ans'),
                    _badgeInfo(
                      Icons.monitor_weight,
                      '${data.poids.toStringAsFixed(1)} kg',
                    ),
                    _badgeInfo(
                      Icons.directions_walk,
                      'Activité ${data.activite}',
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4FB3FF).withOpacity(0.20),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.water_drop,
                        color: Color(0xFF7BC8FF),
                        size: 22,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${objectifHydratation.toStringAsFixed(1)} L / jour',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                ElevatedButton.icon(
                  onPressed: _ouvrirModifierProfil,
                  icon: const Icon(Icons.edit),
                  label: Text("app.edit".tr()),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white.withOpacity(0.14),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 14),
          Container(
            width: 100,
            height: 165,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(26),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.white.withOpacity(0.18),
                  Colors.white.withOpacity(0.05),
                ],
              ),
            ),
            child: Center(
              child: Image.asset(
                "images/robot0.png",
                width: 78,
                errorBuilder: (_, __, ___) =>
                    const Icon(Icons.smart_toy, color: Colors.white, size: 65),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _carteSommeil(ModeleSante data) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: _decorationCarte(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
           Text(
            "health.sleep".tr(),
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 18),
          Center(
            child: Text(
              '${data.heuresSommeil.toStringAsFixed(1)} h',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 42,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          Slider(
            value: data.heuresSommeil,
            min: 0,
            max: 12,
            divisions: 24,
            activeColor: const Color(0xFF8E72FF),
            inactiveColor: Colors.white.withOpacity(0.2),
            onChanged: _modifierSommeil,
          ),
          Text(
            data.heuresSommeil < 6
                ? 'ORA : Essayez de dormir plus tôt ce soir.'
                : 'ORA : Bon rythme de sommeil, continuez comme ça.',
            style: TextStyle(
              color: Colors.white.withOpacity(0.82),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _carteHumeur(ModeleSante data) {
    final humeurs = [
  {'key': 'Heureux', 'label': 'health.happy'.tr(), 'emoji': '😊'},
  {'key': 'Normal', 'label': 'health.normal'.tr(), 'emoji': '😐'},
  {'key': 'Fatigué', 'label': 'health.tired'.tr(), 'emoji': '😴'},
  {'key': 'Stressé', 'label': 'health.stressed'.tr(), 'emoji': '😵'},
];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: _decorationCarte(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
           Text(
            "health.mood".tr(),
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: humeurs.map((item) {
  final key = item['key']!;
  final label = item['label']!;
  final selected = data.humeur == key;

  return Expanded(
    child: GestureDetector(
      onTap: () => _modifierHumeur(key),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: selected
                          ? const Color(0xFFFFC857).withOpacity(0.32)
                          : Colors.white.withOpacity(0.09),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: selected
                            ? const Color(0xFFFFC857)
                            : Colors.white.withOpacity(0.14),
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(
                          item['emoji']!,
                          style: const TextStyle(fontSize: 24),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          label,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _cartePoids(ModeleSante data) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: _decorationCarte(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
           Text(
            "health.weight".tr(),
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 18),
          Center(
            child: Text(
              '${data.poids.toStringAsFixed(1)} kg',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 38,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _modifierPoids(data.poids - 0.1),
                  icon: const Icon(Icons.remove),
                  label:  Text("water.remove".tr()),
                  style: _styleBouton(false),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _modifierPoids(data.poids + 0.1),
                  icon: const Icon(Icons.add),
                  label:  Text("water.add".tr()),
                  style: _styleBouton(true),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _carteHistoriqueSommeil() {
    final valeurs = _valeursSommeilSemaine();
    final jours = [
  "water.mon".tr(),
  "water.tue".tr(),
  "water.wed".tr(),
  "water.thu".tr(),
  "water.fri".tr(),
  "water.sat".tr(),
  "water.sun".tr(),
];
    const maxHeures = 10.0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: _decorationCarte(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
           Text(
            "health.sleep_history".tr(),
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
                final hauteur = (valeurs[index] / maxHeures) * 100;

                return Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        '${valeurs[index].toStringAsFixed(1)}h',
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
                            colors: [Color(0xFF7C4DFF), Color(0xFFB39DFF)],
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

  Widget _carteHistoriqueHumeur() {
    final valeurs = _valeursHumeurSemaine();
    final jours = ['Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam', 'Dim'];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: _decorationCarte(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
           Text(
            "health.mood_history".tr(),
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 18),
          SizedBox(
            height: 170,
            child: Row(
              children: [
                const Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('😊', style: TextStyle(fontSize: 18)),
                    Text('😐', style: TextStyle(fontSize: 18)),
                    Text('😴', style: TextStyle(fontSize: 18)),
                    Text('😵', style: TextStyle(fontSize: 18)),
                  ],
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: CustomPaint(
                    painter: HumeurChartPainter(valeurs),
                    child: Container(),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: List.generate(7, (index) {
              return Expanded(
                child: Center(
                  child: Text(
                    jours[index],
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.75),
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  int _calculerScoreSante(ModeleSante data) {
    int score = 40;

    // sommeil
    if (data.heuresSommeil >= 8) {
      score += 30;
    } else if (data.heuresSommeil >= 6) {
      score += 20;
    } else if (data.heuresSommeil >= 4) {
      score += 10;
    }

    // humeur
    switch (data.humeur) {
      case 'Heureux':
        score += 25;
        break;

      case 'Normal':
        score += 15;
        break;

      case 'Fatigué':
        score += 5;
        break;

      case 'Stressé':
        score -= 10;
        break;
    }

    // activité
    switch (data.activite) {
      case 'Sportif':
        score += 10;
        break;

      case 'Normale':
        score += 5;
        break;
    }

    return score.clamp(0, 100);
  }
String _conseilSante(ModeleSante data) {
  double objectifHydratation = data.poids * 0.035;

  if (data.activite == 'Sportif') {
    objectifHydratation += 0.5;
  }

  if (data.humeur == 'Stressé') {
    objectifHydratation += 0.3;
  }

  if (data.heuresSommeil <= 5) {
    objectifHydratation += 0.2;
  }

  objectifHydratation = objectifHydratation.clamp(1.5, 4.0);

  if (data.heuresSommeil <= 4) {
    return "health.tip_sleep".tr(
      args: [objectifHydratation.toStringAsFixed(1)],
    );
  }

  if (data.humeur == 'Stressé') {
    return "health.tip_stress".tr(
      args: [objectifHydratation.toStringAsFixed(1)],
    );
  }

  if (data.humeur == 'Fatigué') {
    return "health.tip_tired".tr(
      args: [objectifHydratation.toStringAsFixed(1)],
    );
  }

  if (data.activite == 'Sportif') {
    return "health.tip_sport".tr(
      args: [objectifHydratation.toStringAsFixed(1)],
    );
  }

  if (data.heuresSommeil >= 7 && data.humeur == 'Heureux') {
    return "health.tip_excellent".tr();
  }

  return "health.tip_normal".tr(
    args: [objectifHydratation.toStringAsFixed(1)],
  );
}
  List<double> _valeursSommeilSemaine() {
    final debutSemaine = semaineAffichee.subtract(
      Duration(days: semaineAffichee.weekday - 1),
    );

    return List.generate(7, (index) {
      final jour = debutSemaine.add(Duration(days: index));
      final date = DateFormat('yyyy-MM-dd').format(jour);
      final items = semaine.where((e) => e.date == date).toList();

      if (items.isEmpty) return 0.0;
      return items.first.heuresSommeil;
    });
  }

  List<int> _valeursHumeurSemaine() {
    final debutSemaine = semaineAffichee.subtract(
      Duration(days: semaineAffichee.weekday - 1),
    );

    return List.generate(7, (index) {
      final jour = debutSemaine.add(Duration(days: index));
      final date = DateFormat('yyyy-MM-dd').format(jour);
      final items = semaine.where((e) => e.date == date).toList();

      if (items.isEmpty) return 0;

      switch (items.first.humeur) {
        case 'Heureux':
          return 3;
        case 'Normal':
          return 2;
        case 'Fatigué':
          return 1;
        case 'Stressé':
          return 0;
        default:
          return 0;
      }
    });
  }

  Widget _champModal(
    String label,
    TextEditingController controller,
    String suffixe,
  ) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        suffixText: suffixe,
        labelStyle: const TextStyle(color: Colors.white70),
        suffixStyle: const TextStyle(color: Colors.white70),
        filled: true,
        fillColor: Colors.white.withOpacity(0.12),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(18)),
      ),
    );
  }

  Widget _choixActiviteModal({
    required String titre,
    required String valeur,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 13),
          decoration: BoxDecoration(
            color: selected
                ? const Color(0xFFFF5C8A).withOpacity(0.35)
                : Colors.white.withOpacity(0.10),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: selected
                  ? const Color(0xFFFF5C8A)
                  : Colors.white.withOpacity(0.16),
            ),
          ),
          child: Center(
            child: Text(
              titre,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 12,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _badgeInfo(IconData icon, String texte) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.10),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.12)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 18),
          const SizedBox(width: 6),
          Text(
            texte,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
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
          ? const Color(0xFFFF5C8A)
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

class HumeurChartPainter extends CustomPainter {
  final List<int> valeurs;

  HumeurChartPainter(this.valeurs);

  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = Colors.white.withOpacity(0.10)
      ..strokeWidth = 1;

    final linePaint = Paint()
      ..color = const Color(0xFF67E28A)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    final pointPaint = Paint()
      ..color = const Color(0xFF67E28A)
      ..style = PaintingStyle.fill;

    for (int i = 0; i < 4; i++) {
      final y = size.height * i / 3;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    final points = <Offset>[];

    for (int i = 0; i < valeurs.length; i++) {
      final x = size.width * i / (valeurs.length - 1);
      final y = size.height - ((valeurs[i] / 3) * size.height);
      points.add(Offset(x, y));
    }

    if (points.isEmpty) return;

    final path = Path()..moveTo(points.first.dx, points.first.dy);

    for (final point in points.skip(1)) {
      path.lineTo(point.dx, point.dy);
    }

    canvas.drawPath(path, linePaint);

    for (final point in points) {
      canvas.drawCircle(
        point,
        8,
        Paint()..color = Colors.white.withOpacity(0.18),
      );
      canvas.drawCircle(point, 5, pointPaint);
    }
  }

  @override
  bool shouldRepaint(covariant HumeurChartPainter oldDelegate) {
    return oldDelegate.valeurs != valeurs;
  }
}
