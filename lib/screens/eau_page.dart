import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ora/controlleurs/controleur_eau.dart';
import 'package:ora/models/modele_eau.dart';

class EauPage extends StatefulWidget {
  static const String screenRoute = 'page_eau';

  const EauPage({super.key});

  @override
  State<EauPage> createState() => _EauPageState();
}

class _EauPageState extends State<EauPage> {
  final ControleurEau _controleur = ControleurEau();

  ModeleEau? eau;
  List<ModeleEau> semaine = [];
  bool chargement = true;

  final double litreParVerre = 0.25;

  @override
  void initState() {
    super.initState();
    _charger();
  }

  Future<void> _charger() async {
    final data = await _controleur.chargerAujourdhui();
    final dataSemaine = await _controleur.chargerSemaine();

    if (!mounted) return;

    setState(() {
      eau = data;
      semaine = dataSemaine;
      chargement = false;
    });
  }

  Future<void> _ajouter() async {
    if (eau == null) return;

    final nouvelleEau = eau!.copyWith(
      verres: eau!.verres < eau!.objectif ? eau!.verres + 1 : eau!.verres,
      updatedAt: DateTime.now(),
      synced: false,
    );

    setState(() {
      eau = nouvelleEau;
    });

    await _controleur.sauvegarderEtSynchroniser(nouvelleEau);

    final dataSemaine = await _controleur.chargerSemaine();
    if (!mounted) return;

    setState(() {
      semaine = dataSemaine;
    });
  }

  Future<void> _retirer() async {
    if (eau == null) return;

    final nouvelleEau = eau!.copyWith(
      verres: eau!.verres > 0 ? eau!.verres - 1 : 0,
      updatedAt: DateTime.now(),
      synced: false,
    );

    setState(() {
      eau = nouvelleEau;
    });

    await _controleur.sauvegarderEtSynchroniser(nouvelleEau);

    final dataSemaine = await _controleur.chargerSemaine();
    if (!mounted) return;

    setState(() {
      semaine = dataSemaine;
    });
  }

  @override
  Widget build(BuildContext context) {
    final data = eau;
    final verres = data?.verres ?? 0;
    final objectif = data?.objectif ?? 12;
    final litres = verres * litreParVerre;
    final objectifLitres = objectif * litreParVerre;
    final progress = objectif == 0 ? 0.0 : (verres / objectif).clamp(0.0, 1.0);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text(
          'Eau',
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
              color: const Color(0xFF4FB3FF),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.water_drop, color: Colors.white),
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
          child: chargement
              ? const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(18, 18, 18, 28),
                  child: Column(
                    children: [
                      _carteConseil(),
                      const SizedBox(height: 16),
                      _carteObjectif(
                        litres: litres,
                        objectifLitres: objectifLitres,
                        progress: progress,
                        verres: verres,
                        objectif: objectif,
                      ),
                      const SizedBox(height: 16),
                      _carteHistorique(),
                    ],
                  ),
                ),
        ),
      ),
    );
  }

  Widget _carteConseil() {
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
                  "L’eau est la source de vie.\nN’oublie pas de t’hydrater !",
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
            "images/robot0.png",
            width: 82,
            errorBuilder: (_, __, ___) =>
                const Icon(Icons.smart_toy, color: Colors.white, size: 64),
          ),
        ],
      ),
    );
  }

  Widget _carteObjectif({
    required double litres,
    required double objectifLitres,
    required double progress,
    required int verres,
    required int objectif,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: _decorationCarte(),
      child: Column(
        children: [
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Objectif quotidien',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(height: 26),
          Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: litres.toStringAsFixed(1),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 44,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                TextSpan(
                  text: ' / ${objectifLitres.toStringAsFixed(1)} L',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.70),
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            progress >= 1
                ? 'Objectif atteint ! 🎉'
                : 'Continue, tu es proche !',
            style: TextStyle(
              color: Colors.white.withOpacity(0.85),
              fontSize: 14,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 22),
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 12,
              backgroundColor: Colors.white.withOpacity(0.18),
              color: const Color(0xFF62A8FF),
            ),
          ),
          const SizedBox(height: 26),

          Icon(
            Icons.local_drink_rounded,
            size: 130,
            color: const Color(0xFF7BC8FF).withOpacity(0.95),
          ),

          const SizedBox(height: 12),

          Text(
            '$verres / $objectif verres',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 21,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Bravo ! Tu suis ton objectif quotidien.',
            style: TextStyle(
              color: Colors.white.withOpacity(0.75),
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),

          const SizedBox(height: 18),

          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _retirer,
                  icon: const Icon(Icons.remove),
                  label: const Text('Retirer'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white.withOpacity(0.14),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _ajouter,
                  icon: const Icon(Icons.add),
                  label: const Text('Ajouter'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4FB3FF),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _carteHistorique() {
    final valeurs = _valeursSemaine();
    final jours = ['Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam', 'Dim'];
    final maxVal = 12.0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: _decorationCarte(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Historique',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 18),
          SizedBox(
            height: 125,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(7, (index) {
                final hauteur = (valeurs[index] / maxVal) * 86;

                return Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 350),
                        width: 18,
                        height: hauteur.clamp(10, 86),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          gradient: const LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: [Color(0xFF4D8DFF), Color(0xFF8CC8FF)],
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

  List<int> _valeursSemaine() {
    final maintenant = DateTime.now();

    final debutSemaine = maintenant.subtract(
      Duration(days: maintenant.weekday - 1),
    );

    return List.generate(7, (index) {
      final jour = debutSemaine.add(Duration(days: index));
      final date = DateFormat('yyyy-MM-dd').format(jour);

      final items = semaine.where((e) => e.date == date).toList();

      if (items.isEmpty) return 0;
      return items.first.verres;
    });
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
