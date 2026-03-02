List<Map<String, dynamic>> favorisGlobal = [];

bool isFavGlobal(String id) => favorisGlobal.any((e) => e["id"] == id);

void toggleFavGlobal(Map<String, dynamic> item) {
  final index = favorisGlobal.indexWhere((e) => e["id"] == item["id"]);
  if (index >= 0) {
    favorisGlobal.removeAt(index);
  } else {
    favorisGlobal.insert(0, item);
  }
}
