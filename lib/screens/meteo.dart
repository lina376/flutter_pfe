import 'package:easy_localization/easy_localization.dart';
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
            textAlign: TextAlign.center,
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
        _erreur = "meteo.error".tr();
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

  if (texte.contains("rain") ||
      texte.contains("pluie") ||
      texte.contains("مطر")) {
    return Icons.water_drop_outlined;
  }

  if (texte.contains("cloud") ||
      texte.contains("nuage") ||
      texte.contains("سحاب")) {
    return Icons.cloud_outlined;
  }

  if (texte.contains("storm") ||
      texte.contains("orage") ||
      texte.contains("عاصفة")) {
    return Icons.flash_on_outlined;
  }

  if (texte.contains("wind") ||
      texte.contains("vent") ||
      texte.contains("رياح")) {
    return Icons.air;
  }

  if (texte.contains("sun") ||
      texte.contains("soleil") ||
      texte.contains("clear") ||
      texte.contains("dégagé") ||
      texte.contains("مشمس")) {
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
          Text(
            "meteo.details".tr(),
            style: const TextStyle(
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
                  titre: "meteo.feels_like".tr(),
                  valeur: "${meteo.ressenti}°C",
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _detailItem(
                  icon: Icons.water_drop_outlined,
                  titre: "meteo.humidity".tr(),
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
                  titre: "meteo.wind".tr(),
                  valeur: "${meteo.vent} km/h",
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _detailItem(
                  icon: Icons.speed,
                  titre: "meteo.pressure".tr(),
                  valeur: "${meteo.pression} hPa",
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _blocPrevisions() {
    if (_previsions.isEmpty) {
      return Center(
        child: Text(
          "meteo.no_forecast".tr(),
          style: const TextStyle(color: Colors.white),
        ),
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
          Text(
            "meteo.forecast".tr(),
            style: const TextStyle(
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
                        child: Text(
                          jour.jour,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Icon(
                          _iconePrincipale(jour.description),
                          color: Colors.white,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          jour.description,
                          style: const TextStyle(color: Colors.white70),
                        ),
                      ),
                      Expanded(
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
        children: [
          const Icon(Icons.lightbulb_outline, color: Colors.white, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "meteo.tip".tr(),
                  style: const TextStyle(
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
            Text(_erreur!, style: const TextStyle(color: Colors.white)),
            const SizedBox(height: 14),
            ElevatedButton(
              onPressed: _chargerMeteo,
              child: Text("app.retry".tr()),
            ),
          ],
        ),
      );
    }

    if (_meteoActuelle == null) {
      return Center(
        child: Text(
          "meteo.no_data".tr(),
          style: const TextStyle(color: Colors.white),
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
          icon: const Icon(Icons.chevron_left, color: Colors.white),
          onPressed: () {
            Navigator.pushReplacementNamed(context, principal.screenRoute);
          },
        ),
        title: Text(
          "meteo.title".tr(),
          style: const TextStyle(color: Colors.white),
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
