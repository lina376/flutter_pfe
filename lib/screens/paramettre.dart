import 'package:flutter/material.dart';

class Paramettre extends StatelessWidget {
  const Paramettre({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.white.withOpacity(0.10),
      child: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 12),

            ListTile(
              leading: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.menu, color: Colors.white),
              ),
              title: const Text(
                "Paramètres",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                ),
              ),
              onTap: () {},
            ),

            const Divider(color: Colors.white24),

            ListTile(
              leading: const Icon(Icons.person_outline, color: Colors.white),
              title: const Text(
                "Profil",
                style: TextStyle(color: Colors.white),
              ),
              trailing: const Icon(Icons.chevron_right, color: Colors.white70),
              onTap: () {},
            ),

            ListTile(
              leading: const Icon(Icons.favorite_border, color: Colors.white),
              title: const Text(
                "Favoriser",
                style: TextStyle(color: Colors.white),
              ),
              trailing: const Icon(Icons.chevron_right, color: Colors.white70),
              onTap: () {},
            ),

            const Divider(color: Colors.white24),

            SwitchListTile(
              value: true,
              onChanged: (v) {},
              activeColor: Colors.white,
              title: const Text(
                "Notifications",
                style: TextStyle(color: Colors.white),
              ),
            ),

            ListTile(
              leading: const Icon(Icons.language, color: Colors.white),
              title: const Text(
                "Langage",
                style: TextStyle(color: Colors.white),
              ),
              trailing: const Icon(Icons.chevron_right, color: Colors.white70),
              onTap: () {},
            ),

            const Spacer(),

            TextButton(
              onPressed: () {},
              child: const Text(
                "Déconnecter",
                style: TextStyle(color: Colors.white),
              ),
            ),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
