import 'package:flutter/material.dart';
import 'package:ora/controlleurs/contreleur_meteo.dart';
import 'package:ora/models/modele_meteo.dart';
import 'package:ora/screens/principal.dart';

class MeteoPage extends StatefulWidget {
  static const String screenRoute = 'pagemeteo';

  const MeteoPage({super.key});

  @override
  State<MeteoPage> createState() => _MeteoPageState();
}

class _MeteoPageState extends State<MeteoPage> {
  final ControleurMeteo _controleur = ControleurMeteo();

  bool _isLoading = false;
  String? _erreur;

  MeteoActuelle? _meteoActuelle;
  List<PrevisionJour> _previsions = [];

  @override
  void initState() {
    super.initState();
    _chargerMeteo();
  }

  Future<void> _chargerMeteo() async {
    setState(() {
      _isLoading = true;
      _erreur = null;
    });

    try {
      final meteo = await _controleur.chargerMeteoActuelle();
      final previsions = await _controleur.chargerPrevisions();

      if (!mounted) return;

      setState(() {
        _meteoActuelle = meteo;
        _previsions = previsions;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _erreur = "Erreur lors du chargement de la météo";
      });
    } finally {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });
    }
  }

  IconData _iconePrincipale(String description) {
    final texte = description.toLowerCase();

    if (texte.contains("pluie")) {
      return Icons.water_drop_outlined;
    }
    if (texte.contains("nuage")) {
      return Icons.cloud_outlined;
    }
    if (texte.contains("orage")) {
      return Icons.flash_on_outlined;
    }
    if (texte.contains("vent")) {
      return Icons.air;
    }
    if (texte.contains("soleil") || texte.contains("dégagé")) {
      return Icons.wb_sunny_outlined;
    }

    return Icons.wb_cloudy_outlined;
  }

  Widget _blocPrincipal() {
    final meteo = _meteoActuelle!;
    final icone = _iconePrincipale(meteo.description);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.18)),
      ),
      child: Column(
        children: [
          Text(
            meteo.ville,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 14),
          Icon(icone, size: 78, color: Colors.white),
          const SizedBox(height: 12),
          Text(
            "${meteo.temperature}°C",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 42,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            meteo.description,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white70, fontSize: 18),
          ),
        ],
      ),
    );
  }

  Widget _blocDetails() {
    final meteo = _meteoActuelle!;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.13),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white.withOpacity(0.18)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Détails",
            style: TextStyle(
              color: Colors.white,
              fontSize: 21,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _detailItem(
                  icon: Icons.device_thermostat,
                  titre: "Ressenti",
                  valeur: "${meteo.ressenti}°C",
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _detailItem(
                  icon: Icons.water_drop_outlined,
                  titre: "Humidité",
                  valeur: "${meteo.humidite}%",
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _detailItem(
                  icon: Icons.air,
                  titre: "Vent",
                  valeur: "${meteo.vent} km/h",
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _detailItem(
                  icon: Icons.speed,
                  titre: "Pression",
                  valeur: "${meteo.pression} hPa",
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _detailItem({
    required IconData icon,
    required String titre,
    required String valeur,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.10),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.white, size: 28),
          const SizedBox(height: 8),
          Text(
            titre,
            style: const TextStyle(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: 4),
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

  Widget _blocPrevisions() {
    if (_previsions.isEmpty) {
      return const Center(
        child: Text("Pas de prévisions", style: TextStyle(color: Colors.white)),
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.13),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white.withOpacity(0.18)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Prévisions",
            style: TextStyle(
              color: Colors.white,
              fontSize: 21,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 14),

          ..._previsions
              .take(5)
              .map(
                (jour) => Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.10),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: Text(
                          jour.jour,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Icon(
                          _iconePrincipale(jour.description),
                          color: Colors.white,
                        ),
                      ),
                      Expanded(
                        flex: 4,
                        child: Text(
                          jour.description,
                          style: const TextStyle(color: Colors.white70),
                        ),
                      ),
                      Expanded(
                        flex: 3,
                        child: Text(
                          "${jour.temperatureMax}° / ${jour.temperatureMin}°",
                          textAlign: TextAlign.end,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
        ],
      ),
    );
  }

  Widget _blocConseil() {
    final meteo = _meteoActuelle!;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.13),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white.withOpacity(0.18)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.lightbulb_outline, color: Colors.white, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Conseil ORA",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  meteo.conseil,
                  style: const TextStyle(color: Colors.white70, fontSize: 15),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _contenu() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.white),
      );
    }

    if (_erreur != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _erreur!,
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
            const SizedBox(height: 14),
            ElevatedButton(
              onPressed: _chargerMeteo,
              child: const Text("Réessayer"),
            ),
          ],
        ),
      );
    }

    if (_meteoActuelle == null) {
      return const Center(
        child: Text(
          "Aucune donnée météo",
          style: TextStyle(color: Colors.white),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _chargerMeteo,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        children: [
          _blocPrincipal(),
          const SizedBox(height: 16),
          _blocDetails(),
          const SizedBox(height: 16),
          _blocPrevisions(),
          const SizedBox(height: 16),
          _blocConseil(),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          style: const ButtonStyle(
            backgroundColor: WidgetStatePropertyAll<Color>(
              Color.fromARGB(194, 88, 70, 142),
            ),
          ),
          icon: const Icon(Icons.chevron_left, color: Colors.white),
          onPressed: () {
            Navigator.pushReplacementNamed(context, principal.screenRoute);
          },
        ),
        title: const Text(
          "Météo",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _chargerMeteo,
          ),
        ],
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("images/b5.png"),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(child: _contenu()),
      ),
    );
  }
}
