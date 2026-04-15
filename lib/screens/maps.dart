import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../controlleurs/controleur_maps.dart';
import '../models/modele_maps.dart';
import 'principal.dart';

class MapsPage extends StatefulWidget {
  static const String screenRoute = 'pagemaps';

  const MapsPage({super.key});

  @override
  State<MapsPage> createState() => _MapsPageState();
}

class _MapsPageState extends State<MapsPage> {
  final ControleurMaps _controleur = ControleurMaps();
  final MapController _mapController = MapController();

  final TextEditingController _destinationController = TextEditingController();

  bool _isLoading = false;
  bool _isSearchingDestination = false;
  String? _erreur;

  ModeleMaps? _position;
  ModeleMaps? _destination;

  double? _distanceMetres;
  int? _tempsTrajetMinutes;
  DateTime? _heureArrivee;
  DateTime? _heureSortie;

  @override
  void initState() {
    super.initState();
    _chargerPosition();
  }

  @override
  void dispose() {
    _destinationController.dispose();
    super.dispose();
  }

  Future<void> _chargerPosition() async {
    setState(() {
      _isLoading = true;
      _erreur = null;
    });

    try {
      final position = await _controleur.chargerPositionActuelle();

      if (!mounted) return;

      setState(() {
        _position = position;

        if (position == null) {
          _erreur =
              "Impossible d'obtenir la position.\nVérifie le GPS et les permissions.";
        }
      });

      if (position != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          _mapController.move(
            LatLng(position.latitude, position.longitude),
            15,
          );
        });
      }
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _erreur = "Erreur lors du chargement de la localisation.";
      });
    } finally {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _rechercherDestination() async {
    final texte = _destinationController.text.trim();

    if (texte.isEmpty || _position == null) {
      return;
    }

    setState(() {
      _isSearchingDestination = true;
      _erreur = null;
    });

    try {
      final destination = await _controleur.rechercherDestination(texte);

      if (!mounted) return;

      if (destination == null) {
        setState(() {
          _erreur = "Destination introuvable.";
          _destination = null;
          _distanceMetres = null;
          _tempsTrajetMinutes = null;
          _heureSortie = null;
        });
        return;
      }

      final distance = _controleur.calculerDistance(
        _position!.latitude,
        _position!.longitude,
        destination.latitude,
        destination.longitude,
      );

      final temps = _controleur.calculerTempsTrajet(distance);

      setState(() {
        _destination = destination;
        _distanceMetres = distance;
        _tempsTrajetMinutes = temps;

        if (_heureArrivee != null) {
          _heureSortie = _controleur.calculerHeureSortie(
            heureArrivee: _heureArrivee!,
            tempsTrajetMinutes: temps,
          );
        }
      });

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _mapController.fitCamera(
          CameraFit.coordinates(
            coordinates: [
              LatLng(_position!.latitude, _position!.longitude),
              LatLng(destination.latitude, destination.longitude),
            ],
            padding: const EdgeInsets.all(50),
          ),
        );
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _erreur = "Erreur lors de la recherche de la destination.";
      });
    } finally {
      if (!mounted) return;

      setState(() {
        _isSearchingDestination = false;
      });
    }
  }

  Future<void> _choisirHeureArrivee() async {
    final TimeOfDay? time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (time == null) return;

    final now = DateTime.now();
    final arrivee = DateTime(
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );

    setState(() {
      _heureArrivee = arrivee;

      if (_tempsTrajetMinutes != null) {
        _heureSortie = _controleur.calculerHeureSortie(
          heureArrivee: arrivee,
          tempsTrajetMinutes: _tempsTrajetMinutes!,
        );
      }
    });
  }

  String _formatDistance(double metres) {
    if (metres >= 1000) {
      return "${(metres / 1000).toStringAsFixed(2)} km";
    }
    return "${metres.toStringAsFixed(0)} m";
  }

  String _formatHeure(DateTime dateTime) {
    final heure = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return "$heure:$minute";
  }

  Widget _blocPrincipal() {
    final position = _position!;

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
          const Text(
            "Ma position actuelle",
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 14),
          const Icon(Icons.location_on_outlined, size: 78, color: Colors.white),
          const SizedBox(height: 12),
          Text(
            position.nomLieu,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            position.adresse.isEmpty ? "Adresse inconnue" : position.adresse,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white70, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _blocDestination() {
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
            "Destination",
            style: TextStyle(
              color: Colors.white,
              fontSize: 21,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _destinationController,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: "Destination",
              hintStyle: const TextStyle(color: Colors.white70),
              filled: true,
              fillColor: Colors.white.withOpacity(0.10),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              prefixIcon: const Icon(Icons.search, color: Colors.white),
              suffixIcon: _isSearchingDestination
                  ? const Padding(
                      padding: EdgeInsets.all(12),
                      child: SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    )
                  : IconButton(
                      onPressed: _rechercherDestination,
                      icon: const Icon(
                        Icons.arrow_forward,
                        color: Colors.white,
                      ),
                    ),
            ),
            onSubmitted: (_) => _rechercherDestination(),
          ),
          if (_destination != null) ...[
            const SizedBox(height: 14),
            Text(
              _destination!.nomLieu,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              _destination!.adresse,
              style: const TextStyle(color: Colors.white70, fontSize: 15),
            ),
          ],
        ],
      ),
    );
  }

  Widget _blocCarte() {
    if (_position == null) return const SizedBox.shrink();

    final markers = <Marker>[
      Marker(
        point: LatLng(_position!.latitude, _position!.longitude),
        width: 50,
        height: 50,
        child: const Icon(Icons.location_on, size: 40, color: Colors.red),
      ),
    ];

    if (_destination != null) {
      markers.add(
        Marker(
          point: LatLng(_destination!.latitude, _destination!.longitude),
          width: 50,
          height: 50,
          child: const Icon(Icons.location_on, size: 40, color: Colors.blue),
        ),
      );
    }

    return Container(
      height: 280,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white.withOpacity(0.18)),
      ),
      clipBehavior: Clip.antiAlias,
      child: FlutterMap(
        mapController: _mapController,
        options: MapOptions(
          initialCenter: LatLng(_position!.latitude, _position!.longitude),
          initialZoom: 15,
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.example.ora',
          ),
          MarkerLayer(markers: markers),
          if (_destination != null)
            PolylineLayer(
              polylines: [
                Polyline(
                  points: [
                    LatLng(_position!.latitude, _position!.longitude),
                    LatLng(_destination!.latitude, _destination!.longitude),
                  ],
                  strokeWidth: 4,
                  color: Colors.white,
                ),
              ],
            ),
          RichAttributionWidget(
            attributions: [
              TextSourceAttribution('© OpenStreetMap contributors'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _blocCoordonnees() {
    final position = _position!;

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
            "Coordonnées",
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
                  icon: Icons.my_location,
                  titre: "Latitude",
                  valeur: position.latitude.toStringAsFixed(6),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _detailItem(
                  icon: Icons.explore_outlined,
                  titre: "Longitude",
                  valeur: position.longitude.toStringAsFixed(6),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _blocTrajet() {
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
            "Trajet",
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
                  icon: Icons.straighten,
                  titre: "Distance",
                  valeur: _distanceMetres != null
                      ? _formatDistance(_distanceMetres!)
                      : "--",
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _detailItem(
                  icon: Icons.access_time,
                  titre: "Temps",
                  valeur: _tempsTrajetMinutes != null
                      ? "${_tempsTrajetMinutes!} min"
                      : "--",
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ElevatedButton.icon(
            onPressed: _choisirHeureArrivee,
            icon: const Icon(Icons.schedule),
            label: const Text("Choisir l'heure d'arrivée"),
          ),
          const SizedBox(height: 12),
          Text(
            _heureArrivee != null
                ? "Heure d'arrivée : ${_formatHeure(_heureArrivee!)}"
                : "Heure d'arrivée : --",
            style: const TextStyle(color: Colors.white, fontSize: 15),
          ),
          const SizedBox(height: 6),
          Text(
            _heureSortie != null
                ? "Heure idéale de sortie : ${_formatHeure(_heureSortie!)}"
                : "Heure idéale de sortie : --",
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

  Widget _blocInfos() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.13),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white.withOpacity(0.18)),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline, color: Colors.white, size: 28),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Information ORA",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  "Cette page récupère la position actuelle, recherche une destination, calcule la distance, estime le temps de trajet et propose une heure idéale de sortie.",
                  style: TextStyle(color: Colors.white70, fontSize: 15),
                ),
              ],
            ),
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

  Widget _contenu() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.white),
      );
    }

    if (_erreur != null && _position == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _erreur!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
              const SizedBox(height: 14),
              ElevatedButton(
                onPressed: _chargerPosition,
                child: const Text("Réessayer"),
              ),
            ],
          ),
        ),
      );
    }

    if (_position == null) {
      return const Center(
        child: Text(
          "Aucune position disponible",
          style: TextStyle(color: Colors.white),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _chargerPosition,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        children: [
          _blocPrincipal(),
          const SizedBox(height: 16),
          _blocDestination(),
          const SizedBox(height: 16),
          _blocCarte(),
          const SizedBox(height: 16),
          _blocCoordonnees(),
          const SizedBox(height: 16),
          _blocTrajet(),
          const SizedBox(height: 16),
          _blocInfos(),
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
          "Maps",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _chargerPosition,
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
