import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sqflite/sqflite.dart';
import '../database/base_locale.dart';
import '../models/modele_note.dart';

class ServiceNote {
  final FirebaseAuth _authentification = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final BaseLocale _baseLocale = BaseLocale.instance;

  CollectionReference<Map<String, dynamic>>? get _notesRef {
    final utilisateur = _authentification.currentUser;
    if (utilisateur == null) return null;

    return _firestore
        .collection('users')
        .doc(utilisateur.uid)
        .collection('notes');
  }

  Future<void> _insererOuMajLocal(ModeleNote note) async {
    final db = await _baseLocale.database;
    await db.insert(
      'notes',
      note.toLocalMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<ModeleNote>> _obtenirNotesLocales() async {
    final db = await _baseLocale.database;

    final resultat = await db.query(
      'notes',
      where: 'estSupprimee = ?',
      whereArgs: [0],
      orderBy: 'date DESC',
    );

    return resultat.map((e) => ModeleNote.fromLocalMap(e)).toList();
  }

  Future<List<ModeleNote>> _obtenirNotesLocalesNonSynchronisees() async {
    final db = await _baseLocale.database;

    final resultat = await db.query(
      'notes',
      where: 'estSynchronisee = ?',
      whereArgs: [0],
    );

    return resultat.map((e) => ModeleNote.fromLocalMap(e)).toList();
  }

  Stream<List<ModeleNote>> obtenirFluxNotes() async* {
    final locales = await _obtenirNotesLocales();
    yield locales;

    try {
      await synchroniserDepuisFirebase();
    } catch (e) {
      print(' Erreur synchronisation depuis Firebase: $e');
    }

    final apresSync = await _obtenirNotesLocales();
    yield apresSync;

    final ref = _notesRef;
    if (ref == null) {
      yield await _obtenirNotesLocales();
      return;
    }

    yield* ref.orderBy('date', descending: true).snapshots().asyncMap((
      snapshot,
    ) async {
      for (final doc in snapshot.docs) {
        final note = ModeleNote.fromFirestore(doc);
        await _insererOuMajLocal(
          note.copyWith(estSynchronisee: true, estSupprimee: false),
        );
      }

      return await _obtenirNotesLocales();
    });
  }

  Future<void> synchroniserDepuisFirebase() async {
    final ref = _notesRef;
    if (ref == null) {
      print(' utilisateur non connecté');
      return;
    }

    final snapshot = await ref.orderBy('date', descending: true).get();

    for (final doc in snapshot.docs) {
      final note = ModeleNote.fromFirestore(doc);
      await _insererOuMajLocal(
        note.copyWith(estSynchronisee: true, estSupprimee: false),
      );
    }
  }

  Future<void> synchroniserVersFirebase() async {
    final ref = _notesRef;
    if (ref == null) {
      print('utilisateur non connecté');
      return;
    }

    final notesNonSync = await _obtenirNotesLocalesNonSynchronisees();

    for (final note in notesNonSync) {
      try {
        if (note.estSupprimee) {
          await ref.doc(note.id).delete().timeout(const Duration(seconds: 5));

          final db = await _baseLocale.database;
          await db.delete('notes', where: 'id = ?', whereArgs: [note.id]);
        } else {
          await ref
              .doc(note.id)
              .set(note.toMap())
              .timeout(const Duration(seconds: 5));

          await _insererOuMajLocal(note.copyWith(estSynchronisee: true));
        }
      } catch (e) {
        print('Erreur sync note ${note.id}: $e');
      }
    }
  }

  Future<String> ajouterNote({
    required String titre,
    required String contenu,
    required bool aimee,
  }) async {
    final id = _firestore.collection('tmp').doc().id;

    final note = ModeleNote(
      id: id,
      titre: titre.isEmpty ? 'Sans titre' : titre,
      contenu: contenu,
      liked: aimee,
      date: DateTime.now(),
      estSynchronisee: false,
      estSupprimee: false,
    );

    await _insererOuMajLocal(note);

    try {
      final ref = _notesRef;

      if (ref == null) {
        print('utilisateur non connecté');
        return id;
      }

      await ref.doc(id).set(note.toMap()).timeout(const Duration(seconds: 5));

      await _insererOuMajLocal(note.copyWith(estSynchronisee: true));
    } catch (e) {
      print(' Erreur ajout note cloud: $e');
    }

    return id;
  }

  Future<void> mettreAJourNote({
    required String idNote,
    required String titre,
    required String contenu,
    required bool aimee,
  }) async {
    final note = ModeleNote(
      id: idNote,
      titre: titre.isEmpty ? 'Sans titre' : titre,
      contenu: contenu,
      liked: aimee,
      date: DateTime.now(),
      estSynchronisee: false,
      estSupprimee: false,
    );

    await _insererOuMajLocal(note);

    try {
      final ref = _notesRef;

      if (ref == null) {
        print(' utilisateur non connecté');
        return;
      }

      await ref
          .doc(idNote)
          .set(note.toMap())
          .timeout(const Duration(seconds: 5));

      await _insererOuMajLocal(note.copyWith(estSynchronisee: true));
    } catch (e) {
      print('Erreur update note cloud: $e');
    }
  }

  Future<void> supprimerNote(String idNote) async {
    final db = await _baseLocale.database;

    await db.update(
      'notes',
      {'estSupprimee': 1, 'estSynchronisee': 0},
      where: 'id = ?',
      whereArgs: [idNote],
    );

    try {
      final ref = _notesRef;

      if (ref == null) {
        print(' utilisateur non connecté');
        return;
      }

      await ref.doc(idNote).delete().timeout(const Duration(seconds: 5));

      await db.delete('notes', where: 'id = ?', whereArgs: [idNote]);
    } catch (e) {
      print(' Erreur suppression note cloud: $e');
    }
  }

  Future<ModeleNote?> trouverNoteParTitre(String titreRecherche) async {
    final notes = await _obtenirNotesLocales();

    try {
      return notes.firstWhere(
        (note) =>
            note.titre.toLowerCase().trim() ==
            titreRecherche.toLowerCase().trim(),
      );
    } catch (e) {
      return null;
    }
  }

  Future<List<ModeleNote>> rechercherNotesParTitre(
    String titreRecherche,
  ) async {
    final notes = await _obtenirNotesLocales();

    return notes.where((note) {
      return note.titre.toLowerCase().contains(
        titreRecherche.toLowerCase().trim(),
      );
    }).toList();
  }
}
