import 'package:shared_preferences/shared_preferences.dart';

class ServiceLangue {
  static const String _cleLangue = 'langue_code';

  Future<void> sauvegarderLangue(String codeLangue) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_cleLangue, codeLangue);
  }

  Future<String?> chargerLangue() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_cleLangue);
  }
}
