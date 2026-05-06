import 'package:flutter/material.dart';

class SantePage extends StatefulWidget {
  static const String screenRoute = 'page_sante';

  const SantePage({super.key});

  @override
  State<SantePage> createState() => _SantePageState();
}

class _SantePageState extends State<SantePage> {
  double heuresSommeil = 7.0;
  double poids = 65.0;
  String humeur = 'Heureux';
  String activite = 'Normale';
  int age = 20;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text(
          'Santé',
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
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 28),
            child: Column(
              children: [
                _carteConseil(),
                const SizedBox(height: 16),
                _carteProfil(),
                const SizedBox(height: 16),
                _carteSommeil(),
                const SizedBox(height: 16),
                _carteHumeur(),
                const SizedBox(height: 16),
                _cartePoids(),
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
                  'Prenez soin de votre sommeil, votre humeur et votre énergie au quotidien.',
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

  Widget _carteProfil() {
    final objectifHydratation = ((poids * 0.035).clamp(1.0, 4.0));

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.12),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.white.withOpacity(0.16)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          // INFOS
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

                const Text(
                  'Votre profil santé',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                  ),
                ),

                const SizedBox(height: 16),

                Row(
                  children: [
                    _badgeInfo(Icons.cake, '$age ans'),
                    const SizedBox(width: 8),
                    _badgeInfo(
                      Icons.monitor_weight,
                      '${poids.toStringAsFixed(1)} kg',
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                _badgeInfo(Icons.directions_walk, 'Activité $activite'),

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
                  onPressed: () {
                    // modifier profil
                  },
                  icon: const Icon(Icons.edit),
                  label: const Text('Modifier'),
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

          // ROBOT
          Container(
            width: 110,
            height: 170,
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
                width: 85,
                errorBuilder: (_, __, ___) =>
                    const Icon(Icons.smart_toy, color: Colors.white, size: 65),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _carteSommeil() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: _decorationCarte(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Sommeil',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 18),
          Center(
            child: Text(
              '${heuresSommeil.toStringAsFixed(1)} h',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 42,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          Slider(
            value: heuresSommeil,
            min: 0,
            max: 12,
            divisions: 24,
            activeColor: const Color(0xFF8E72FF),
            inactiveColor: Colors.white.withOpacity(0.2),
            onChanged: (v) {
              setState(() => heuresSommeil = v);
            },
          ),
          Text(
            heuresSommeil < 6
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

  Widget _carteHumeur() {
    final humeurs = [
      {'nom': 'Heureux', 'emoji': '😊'},
      {'nom': 'Normal', 'emoji': '😐'},
      {'nom': 'Fatigué', 'emoji': '😴'},
      {'nom': 'Stressé', 'emoji': '😵'},
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: _decorationCarte(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Humeur',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: humeurs.map((item) {
              final selected = humeur == item['nom'];
              return Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => humeur = item['nom']!),
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
                          item['nom']!,
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

  Widget _cartePoids() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: _decorationCarte(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Poids',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 18),
          Center(
            child: Text(
              '${poids.toStringAsFixed(1)} kg',
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
                  onPressed: () => setState(() => poids -= 0.5),
                  icon: const Icon(Icons.remove),
                  label: const Text('Retirer'),
                  style: _styleBouton(false),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => setState(() => poids += 0.5),
                  icon: const Icon(Icons.add),
                  label: const Text('Ajouter'),
                  style: _styleBouton(true),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _miniInfo(IconData icon, String valeur, String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.10),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.white.withOpacity(0.12)),
        ),
        child: Column(
          children: [
            Icon(icon, color: Colors.white, size: 24),
            const SizedBox(height: 8),
            Text(
              valeur,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                color: Colors.white.withOpacity(0.68),
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
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
