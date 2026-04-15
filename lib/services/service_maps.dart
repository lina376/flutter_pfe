import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import '../models/modele_maps.dart';

class ServiceMaps {
  Future<bool> verifierServiceGPS() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  Future<bool> verifierPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    return permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse;
  }

  Future<Position?> obtenirPositionActuelle() async {
    final gpsActif = await verifierServiceGPS();
    if (!gpsActif) return null;

    final permissionOk = await verifierPermission();
    if (!permissionOk) return null;

    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }

  Future<String> obtenirAdresse(double latitude, double longitude) async {
    try {
      final placemarks = await placemarkFromCoordinates(latitude, longitude);

      if (placemarks.isEmpty) {
        return "Adresse inconnue";
      }

      final p = placemarks.first;

      final street = p.street ?? "";
      final locality = p.locality ?? "";
      final country = p.country ?? "";

      if (street.isEmpty && locality.isEmpty && country.isEmpty) {
        return "Adresse inconnue";
      }

      if (street.isNotEmpty && locality.isNotEmpty) {
        return "$street, $locality";
      }

      if (locality.isNotEmpty && country.isNotEmpty) {
        return "$locality, $country";
      }

      if (locality.isNotEmpty) {
        return locality;
      }

      if (country.isNotEmpty) {
        return country;
      }

      return "Adresse inconnue";
    } catch (_) {
      return "Adresse inconnue";
    }
  }

  Future<ModeleMaps?> obtenirDestinationDepuisNom(String nomLieu) async {
    try {
      final locations = await locationFromAddress(nomLieu);

      if (locations.isEmpty) return null;

      final location = locations.first;
      final adresse = await obtenirAdresse(
        location.latitude,
        location.longitude,
      );

      return ModeleMaps(
        latitude: location.latitude,
        longitude: location.longitude,
        adresse: adresse,
        nomLieu: nomLieu,
      );
    } catch (_) {
      return null;
    }
  }

  double calculerDistance(double lat1, double lng1, double lat2, double lng2) {
    return Geolocator.distanceBetween(lat1, lng1, lat2, lng2);
  }

  int calculerTempsTrajet(double distanceMetres) {
    const double vitesseMetresParSeconde = 50000 / 3600;
    final double tempsSecondes = distanceMetres / vitesseMetresParSeconde;
    return (tempsSecondes / 60).round();
  }

  DateTime calculerHeureSortie({
    required DateTime heureArrivee,
    required int tempsTrajetMinutes,
  }) {
    return heureArrivee.subtract(Duration(minutes: tempsTrajetMinutes));
  }
}
