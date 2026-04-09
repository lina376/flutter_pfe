import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:ora/screens/principal.dart';

class LanguePage extends StatefulWidget {
  static const String screenRoute = 'pagelangue';

  const LanguePage({super.key});

  @override
  State<LanguePage> createState() => _LanguePageState();
}

class _LanguePageState extends State<LanguePage> {
  Future<void> changerLangue(Locale locale) async {
    await context.setLocale(locale);

    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('language.saved'.tr())));
  }

  Widget optionLangue({
    required String texte,
    required Locale locale,
    required IconData icon,
  }) {
    final bool selectionnee =
        context.locale.languageCode == locale.languageCode;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
      decoration: BoxDecoration(
        color: selectionnee
            ? Colors.white.withOpacity(0.22)
            : Colors.white.withOpacity(0.10),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: selectionnee ? Colors.white : Colors.white.withOpacity(0.20),
        ),
      ),
      child: ListTile(
        leading: Icon(icon, color: Colors.white),
        title: Text(
          texte,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        trailing: selectionnee
            ? const Icon(Icons.check_circle, color: Colors.white)
            : null,
        onTap: () => changerLangue(locale),
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
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 20),
              Text(
                'language.title'.tr(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 34,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 30),
              optionLangue(
                texte: 'language.fr'.tr(),
                locale: const Locale('fr'),
                icon: Icons.language,
              ),
              optionLangue(
                texte: 'language.en'.tr(),
                locale: const Locale('en'),
                icon: Icons.translate,
              ),
              optionLangue(
                texte: 'language.ar'.tr(),
                locale: const Locale('ar'),
                icon: Icons.g_translate,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
