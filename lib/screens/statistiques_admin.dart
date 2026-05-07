import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:ora/controlleurs/controleur_statistique_admin.dart';
import 'package:ora/models/modele_statistique_admin.dart';

class StatistiquesAdminPage extends StatefulWidget {
  static const String screenRoute = 'statistiquesAdmin';

  const StatistiquesAdminPage({super.key});

  @override
  State<StatistiquesAdminPage> createState() => _StatistiquesAdminPageState();
}

class _StatistiquesAdminPageState extends State<StatistiquesAdminPage> {
  final ControleurStatistiqueAdmin _controleur = ControleurStatistiqueAdmin();
  String _periode = 'jour';

  Future<ModeleStatistiqueAdmin> get _futureStatistiques {
    return _controleur.chargerStatistiques(_periode);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Statistiques',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          style: const ButtonStyle(
            backgroundColor: WidgetStatePropertyAll<Color>(
              Color.fromARGB(194, 88, 70, 142),
            ),
          ),
          icon: const Icon(Icons.chevron_left, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('images/b5.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: FutureBuilder<ModeleStatistiqueAdmin>(
            future: _futureStatistiques,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                );
              }

              if (snapshot.hasError) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Text(
                      'Erreur : ${snapshot.error}',
                      style: const TextStyle(color: Colors.white, fontSize: 18),
                      textAlign: TextAlign.center,
                    ),
                  ),
                );
              }

              final statistiques = snapshot.data!;

              return RefreshIndicator(
                onRefresh: () async => setState(() {}),
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(18, 12, 18, 24),
                  children: [
                    _entete(),
                    const SizedBox(height: 16),
                    _filtrePeriode(),
                    const SizedBox(height: 18),
                    _cartesResume(statistiques),
                    const SizedBox(height: 18),
                    _carteGraphiqueGlobal(statistiques),
                    const SizedBox(height: 18),
                    _carteBarres(statistiques),
                    const SizedBox(height: 18),
                    _listeDetails(statistiques),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _entete() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tableau de bord admin',
          style: TextStyle(
            color: Colors.white,
            fontSize: 31,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 5),
        Text(
          'Suivi de l\'activité des utilisateurs ORA',
          style: TextStyle(color: Colors.white70, fontSize: 16),
        ),
      ],
    );
  }

  Widget _filtrePeriode() {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.14),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withOpacity(0.20)),
      ),
      child: Row(
        children: [
          _boutonPeriode('jour', 'Aujourd\'hui'),
          _boutonPeriode('semaine', 'Semaine'),
          _boutonPeriode('mois', 'Mois'),
        ],
      ),
    );
  }

  Widget _boutonPeriode(String valeur, String titre) {
    final selectionne = _periode == valeur;

    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _periode = valeur),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 11),
          decoration: BoxDecoration(
            color: selectionne
                ? const Color.fromARGB(230, 180, 167, 214)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Text(
            titre,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontWeight: selectionne ? FontWeight.bold : FontWeight.w500,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }

  Widget _cartesResume(ModeleStatistiqueAdmin statistiques) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.15,
      children: [
        _carteStat(
          icone: Icons.groups_rounded,
          titre: 'Utilisateurs',
          valeur: statistiques.totalUtilisateurs.toString(),
          sousTitre: 'comptes utilisateur',
        ),
        _carteStat(
          icone: Icons.water_drop_rounded,
          titre: 'Objectif eau',
          valeur: '${statistiques.pourcentageEau.toStringAsFixed(0)}%',
          sousTitre: '${statistiques.utilisateursEauObjectif} utilisateurs',
        ),
        _carteStat(
          icone: Icons.fitness_center_rounded,
          titre: 'Sport',
          valeur: '${statistiques.pourcentageSport.toStringAsFixed(0)}%',
          sousTitre: '${statistiques.utilisateursSport} utilisateurs',
        ),
        _carteStat(
          icone: Icons.smart_toy_rounded,
          titre: 'Chat ORA',
          valeur: '${statistiques.pourcentageChat.toStringAsFixed(0)}%',
          sousTitre: '${statistiques.utilisateursChat} utilisateurs',
        ),
      ],
    );
  }

 Widget _carteStat({
  required IconData icone,
  required String titre,
  required String valeur,
  required String sousTitre,
}) {
  return Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white.withOpacity(0.16),
      borderRadius: BorderRadius.circular(22),
      border: Border.all(color: Colors.white.withOpacity(0.22)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icone, color: Colors.white, size: 26),

        const Spacer(),

        Text(
          valeur,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 30,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 4),

        Text(
          titre,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),

        const SizedBox(height: 2),

        Text(
          sousTitre,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
          ),
        ),
      ],
    ),
  );
}
  Widget _carteGraphiqueGlobal(ModeleStatistiqueAdmin statistiques) {
    return _conteneurGraphique(
      titre: 'Répartition globale',
      enfant: SizedBox(
        height: 210,
        child: PieChart(
          PieChartData(
            centerSpaceRadius: 46,
            sectionsSpace: 3,
            sections: [
              _sectionPie('Eau', statistiques.pourcentageEau, Colors.lightBlueAccent),
              _sectionPie('Sport', statistiques.pourcentageSport, Colors.greenAccent),
              _sectionPie('Chat', statistiques.pourcentageChat, const Color(0xFFB4A7D6)),
            ],
          ),
        ),
      ),
    );
  }

  PieChartSectionData _sectionPie(String titre, double valeur, Color couleur) {
    final pourcentage = valeur.clamp(0, 100).toDouble();

    return PieChartSectionData(
      value: pourcentage <= 0 ? 1 : pourcentage,
      title: '${pourcentage.toStringAsFixed(0)}%',
      radius: 62,
      color: pourcentage <= 0 ? Colors.white24 : couleur,
      titleStyle: const TextStyle(
        color: Colors.white,
        fontSize: 15,
        fontWeight: FontWeight.bold,
      ),
    );
  }
Widget _carteBarres(ModeleStatistiqueAdmin statistiques) {
  return _conteneurGraphique(
    titre: 'Activité par utilisateurs',
    enfant: SizedBox(
      height: 260,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,

          maxY: statistiques.totalUtilisateurs <= 1
              ? 5
              : statistiques.totalUtilisateurs.toDouble(),

          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: 1,
            getDrawingHorizontalLine: (value) {
              return FlLine(
                color: Colors.white12,
                strokeWidth: 1,
              );
            },
          ),

          borderData: FlBorderData(show: false),

          titlesData: FlTitlesData(
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),

            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),

            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 28,
                getTitlesWidget: (value, meta) {
                  return Text(
                    value.toInt().toString(),
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 10,
                    ),
                  );
                },
              ),
            ),

            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  final titres = ['Eau', 'Sport', 'Chat'];

                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      titres[value.toInt()],
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          barGroups: [
            _barre(
              0,
              statistiques.utilisateursEauObjectif,
              Colors.lightBlueAccent,
            ),

            _barre(
              1,
              statistiques.utilisateursSport,
              Colors.greenAccent,
            ),

            _barre(
              2,
              statistiques.utilisateursChat,
              const Color(0xFFB4A7D6),
            ),
          ],
        ),
      ),
    ),
  );
}
  BarChartGroupData _barre(int x, int valeur, Color couleur) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: valeur.toDouble(),
          color: couleur,
          width: 28,
          borderRadius: BorderRadius.circular(8),
        ),
      ],
    );
  }

  Widget _listeDetails(ModeleStatistiqueAdmin statistiques) {
    return _conteneurGraphique(
      titre: 'Détails',
      enfant: Column(
        children: [
          _ligneDetail(
            icone: Icons.water_drop_outlined,
            titre: 'Ont atteint l\'objectif d\'eau',
            valeur: '${statistiques.utilisateursEauObjectif}/${statistiques.totalUtilisateurs}',
          ),
          _ligneDetail(
            icone: Icons.directions_run_rounded,
            titre: 'Ont fait une activité sportive',
            valeur: '${statistiques.utilisateursSport}/${statistiques.totalUtilisateurs}',
          ),
          _ligneDetail(
            icone: Icons.chat_bubble_outline_rounded,
            titre: 'Ont utilisé le chat ORA',
            valeur: '${statistiques.utilisateursChat}/${statistiques.totalUtilisateurs}',
          ),
        ],
      ),
    );
  }

  Widget _ligneDetail({
    required IconData icone,
    required String titre,
    required String valeur,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Icon(icone, color: Colors.white, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              titre,
              style: const TextStyle(color: Colors.white, fontSize: 15),
            ),
          ),
          Text(
            valeur,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _conteneurGraphique({required String titre, required Widget enfant}) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.14),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.20)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            titre,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          enfant,
        ],
      ),
    );
  }
}
