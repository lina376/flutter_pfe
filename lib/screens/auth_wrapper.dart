import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:ora/screens/admin_home.dart';
import 'package:ora/screens/principal.dart';
import 'package:ora/screens/rencontre.dart';

class AuthWrapper extends StatelessWidget {
  static const String screenRoute = 'auth_wrapper';

  const AuthWrapper({super.key});

  Future<String> _chargerRole(String uid) async {
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .get();
    return (doc.data()?['role'] ?? 'user').toString();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final user = snapshot.data;
        if (user == null) return const rencontre();

        return FutureBuilder<String>(
          future: _chargerRole(user.uid),
          builder: (context, roleSnapshot) {
            if (roleSnapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            final role = roleSnapshot.data ?? 'user';
            if (role == 'admin') return const AdminHome();

            if (!user.emailVerified) {
              FirebaseAuth.instance.signOut();
              return const rencontre();
            }

            return const principal();
          },
        );
      },
    );
  }
}
