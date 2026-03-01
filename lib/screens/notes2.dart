import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ora/screens/mesnotes.dart';
import 'package:ora/screens/principal.dart';

class notes2 extends StatefulWidget {
  static const String screenRoute = 'pagenotes2';
  const notes2({super.key});

  @override
  State<notes2> createState() => _notes2State();
}

class _notes2State extends State<notes2> {
  final titreCtrl = TextEditingController();
  final contenuCtrl = TextEditingController();

  bool bold = false;
  bool italic = false;
  bool liked = false;

  @override
  void dispose() {
    titreCtrl.dispose();
    contenuCtrl.dispose();
    super.dispose();
  }

  void _save() {
    final titre = titreCtrl.text.trim();
    final contenu = contenuCtrl.text.trim();

    if (titre.isEmpty && contenu.isEmpty) return;

    Navigator.pop(context, {
      "titre": titre.isEmpty ? "Sans titre" : titre,
      "contenu": contenu,
      "liked": liked,
      "date": DateTime.now(),
    });
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final dateTxt = DateFormat("MMM d, yyyy").format(now); // Apr 1, 2025
    final timeTxt = DateFormat("h:mm a").format(now); // 9:41 AM

    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("images/b6.png"),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              Positioned(
                top: 8,
                left: MediaQuery.of(context).size.height * 0.01,
                child: IconButton(
                  style: const ButtonStyle(
                    backgroundColor: WidgetStatePropertyAll<Color>(
                      Color.fromARGB(194, 88, 70, 142),
                    ),
                  ),
                  icon: const Icon(Icons.chevron_left, color: Colors.white),
                  onPressed: () {
                    Navigator.pushNamed(context, mesnotes.screenRoute);
                  },
                  tooltip: 'chevron',
                  iconSize: 40,
                  constraints: const BoxConstraints(
                    minHeight: 50,
                    minWidth: 50,
                  ),
                ),
              ),
              Positioned(
                top: 8,
                right: MediaQuery.of(context).size.height * 0.01,
                child: IconButton(
                  style: const ButtonStyle(
                    backgroundColor: WidgetStatePropertyAll<Color>(
                      Color.fromARGB(194, 88, 70, 142),
                    ),
                  ),
                  icon: const Icon(Icons.home, color: Colors.white),
                  onPressed: () {
                    Navigator.pushNamed(context, principal.screenRoute);
                  },
                  tooltip: 'home',
                  iconSize: 40,
                  constraints: const BoxConstraints(
                    minHeight: 50,
                    minWidth: 50,
                  ),
                ),
              ),

              Positioned(
                top: MediaQuery.of(context).size.height * 0.03,
                left: MediaQuery.of(context).size.height * 0.08,
                right: MediaQuery.of(context).size.height * 0.08,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _date(dateTxt),
                    const SizedBox(width: 10),
                    _date(timeTxt),
                  ],
                ),
              ),

              Positioned(
                top: MediaQuery.of(context).size.height * 0.09,
                left: MediaQuery.of(context).size.height * 0.02,
                right: MediaQuery.of(context).size.height * 0.02,
                bottom: MediaQuery.of(context).size.height * 0.1,
                child: Column(
                  children: [
                    // Title
                    Container(
                      height: 48,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.14),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.18),
                        ),
                      ),
                      child: TextField(
                        controller: titreCtrl,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                        decoration: const InputDecoration(
                          hintText: "Titre",
                          hintStyle: TextStyle(color: Colors.white70),
                          border: InputBorder.none,
                        ),
                      ),
                    ),

                    SizedBox(height: MediaQuery.of(context).size.height * 0.01),

                    // grand note
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.14),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.18),
                          ),
                        ),
                        child: TextField(
                          controller: contenuCtrl,
                          maxLines: null,
                          expands: true,
                          textAlignVertical: TextAlignVertical.top,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: bold
                                ? FontWeight.w800
                                : FontWeight.w500,
                            fontStyle: italic
                                ? FontStyle.italic
                                : FontStyle.normal,
                            height: 1.3,
                          ),
                          decoration: const InputDecoration(
                            hintText: "Écrivez ici...",
                            hintStyle: TextStyle(color: Colors.white70),
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              Positioned(
                left: MediaQuery.of(context).size.height * 0.04,
                right: MediaQuery.of(context).size.height * 0.04,
                bottom: MediaQuery.of(context).size.height * 0.01,
                child: Container(
                  height: 52,
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.18),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: Colors.white.withOpacity(0.2)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _Btn(
                        label: "I",
                        isActive: italic,
                        onTap: () => setState(() => italic = !italic),
                      ),
                      _Btn(
                        label: "B",
                        isActive: bold,
                        onTap: () => setState(() => bold = !bold),
                      ),
                      _Btn(
                        icon: liked ? Icons.favorite : Icons.favorite_border,
                        isActive: liked,
                        onTap: () => setState(() => liked = !liked),
                      ),

                      _Btn(icon: Icons.check, onTap: _save),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _date(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.15)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: Colors.white.withOpacity(0.85),
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _Btn({
    IconData? icon,
    String? label,
    bool isActive = false,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? Colors.white.withOpacity(0.22) : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: icon != null
            ? Icon(icon, color: Colors.white, size: 18)
            : Text(
                label ?? "",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                ),
              ),
      ),
    );
  }
}
