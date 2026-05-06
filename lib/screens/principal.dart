import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ora/screens/sante.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ora/screens/admin_home.dart';
import 'package:ora/controlleurs/controleur_principal.dart';
import 'package:ora/models/modele_principale.dart';
import 'package:ora/screens/calendrier.dart';
import 'package:ora/screens/chat.dart';
import 'package:ora/screens/mesnotes.dart';
import 'package:ora/screens/notifications.dart';
import 'package:ora/screens/meteo.dart';
import 'package:ora/screens/alarmes.dart';
import 'package:ora/screens/maps.dart';
import 'package:ora/screens/langue.dart';
import 'package:ora/screens/eau_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ora/screens/eau1.dart';

class principal extends StatefulWidget {
  static const String screenRoute = 'pageprincipal';

  const principal({super.key});

  @override
  State<principal> createState() => _principalState();
}

class _principalState extends State<principal> {
  final ControleurPrincipal _controleurPrincipal = ControleurPrincipal();
  bool isAdmin = false;
  DateTime _moisAffiche = DateTime.now();
  DateTime _dateSelectionnee = DateTime.now();
  bool _notif = true;

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _logout() async {
    await _controleurPrincipal.seDeconnecter();
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, 'pageconnecter');
  }

  Future<void> verifierRole() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) return;

    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    final role = doc.data()?['role'] ?? 'user';

    if (role == 'admin') {
      setState(() {
        isAdmin = true;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    verifierRole();
  }

  Future<String> creerConversation(String premierMessage) async {
    return _controleurPrincipal.creerConversation(
      premierMessage: premierMessage,
    );
  }

  void _ouvrirProfilDepuisMenu() {
    Navigator.pop(context);
    Navigator.pushNamed(context, 'pageprofil');
  }

  void _ouvrirFavorisDepuisMenu() {
    Navigator.pop(context);
    Navigator.pushNamed(context, 'pagefavorise');
  }

  Future<void> _deconnecterDepuisMenu() async {
    Navigator.pop(context);
    await _logout();
  }

  void _parametre() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      isDismissible: true,
      enableDrag: true,
      barrierColor: Colors.black.withOpacity(0.25),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setLocal) {
            return GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                color: Colors.transparent,
                child: SafeArea(
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: GestureDetector(
                      onTap: () {},
                      child: Padding(
                        padding: const EdgeInsets.only(
                          left: 10,
                          top: 50,
                          bottom: 50,
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            width: MediaQuery.of(context).size.width * 0.72,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 14,
                            ),
                            decoration: BoxDecoration(
                              color: const Color.fromARGB(
                                255,
                                20,
                                6,
                                31,
                              ).withOpacity(0.58),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.22),
                              ),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                StreamBuilder<ModeleUtilisateurPrincipal?>(
                                  stream: _controleurPrincipal
                                      .obtenirFluxUtilisateur(),
                                  builder: (context, snapshot) {
                                    final utilisateur = snapshot.data;
                                    final nomAffichage = _controleurPrincipal
                                        .obtenirNomAffichageSelonLangue(
                                          utilisateur,
                                          context.locale.languageCode,
                                        );
                                    final photoUrl =
                                        utilisateur?.photoUrl ?? '';

                                    return Container(
                                      margin: const EdgeInsets.only(bottom: 12),
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.08),
                                        borderRadius: BorderRadius.circular(16),
                                        border: Border.all(
                                          color: Colors.white.withOpacity(0.08),
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          CircleAvatar(
                                            radius: 24,
                                            backgroundColor: Colors.white
                                                .withOpacity(0.18),
                                            backgroundImage: photoUrl.isNotEmpty
                                                ? NetworkImage(photoUrl)
                                                : null,
                                            child: photoUrl.isEmpty
                                                ? const Icon(
                                                    Icons.person,
                                                    color: Colors.white,
                                                    size: 24,
                                                  )
                                                : null,
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Text(
                                              nomAffichage,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.w700,
                                                fontSize: 15,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                                _list(
                                  icon: Icons.person_outline,
                                  title: 'menu.profile'.tr(),
                                  onTap: _ouvrirProfilDepuisMenu,
                                ),
                                _list(
                                  icon: Icons.favorite_border,
                                  title: 'menu.favorites'.tr(),
                                  onTap: _ouvrirFavorisDepuisMenu,
                                ),
                                const Divider(
                                  color: Colors.white24,
                                  height: 18,
                                ),
                                _list(
                                  icon: Icons.map_outlined,
                                  title: 'menu.maps'.tr(),
                                  onTap: () {
                                    Navigator.pop(context);
                                    Navigator.pushNamed(
                                      context,
                                      MapsPage.screenRoute,
                                    );
                                  },
                                ),
                                _list(
                                  icon: Icons.language,
                                  title: 'menu.language'.tr(),
                                  onTap: () {
                                    Navigator.pop(context);
                                    Navigator.pushNamed(
                                      context,
                                      LanguePage.screenRoute,
                                    );
                                  },
                                ),
                                ListTile(
                                  contentPadding: EdgeInsets.zero,
                                  leading: const Icon(
                                    Icons.notifications_none,
                                    color: Colors.white,
                                  ),
                                  title: Text(
                                    'menu.notifications'.tr(),
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                  trailing: Switch(
                                    value: _notif,
                                    onChanged: (v) {
                                      setLocal(() => _notif = v);
                                      setState(() => _notif = v);
                                    },
                                  ),
                                ),
                                const SizedBox(height: 6),
                                TextButton(
                                  onPressed: _deconnecterDepuisMenu,
                                  child: Text(
                                    'menu.logout'.tr(),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      decoration: TextDecoration.underline,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _list({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: Colors.white),
      title: Text(title, style: const TextStyle(color: Colors.white)),
      trailing: const Icon(Icons.chevron_right, color: Colors.white70),
      onTap: onTap,
    );
  }

  Widget _buildUserTitle() {
    return StreamBuilder<ModeleUtilisateurPrincipal?>(
      stream: _controleurPrincipal.obtenirFluxUtilisateur(),
      builder: (context, snapshot) {
        final utilisateur = snapshot.data;
        final title = _controleurPrincipal.obtenirNomAffichageSelonLangue(
          utilisateur,
          context.locale.languageCode,
        );

        return Text(
          title,
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.2,
          ),
        );
      },
    );
  }

  Widget _buildPhotoProfil() {
    return StreamBuilder<ModeleUtilisateurPrincipal?>(
      stream: _controleurPrincipal.obtenirFluxUtilisateur(),
      builder: (context, snapshot) {
        final utilisateur = snapshot.data;
        final photoUrl = utilisateur?.photoUrl ?? '';

        return Padding(
          padding: const EdgeInsets.only(right: 5),
          child: GestureDetector(
            onTap: () {
              Navigator.pushNamed(context, 'pageprofil');
            },
            child: CircleAvatar(
              radius: 20,
              backgroundColor: const Color.fromARGB(92, 88, 70, 142),
              backgroundImage: photoUrl.isNotEmpty
                  ? NetworkImage(photoUrl)
                  : null,
              child: photoUrl.isEmpty
                  ? const Icon(Icons.person, color: Colors.white, size: 20)
                  : null,
            ),
          ),
        );
      },
    );
  }

  Widget sectionHistorique() {
    final user = _controleurPrincipal.obtenirUtilisateurActuel();

    if (user == null) {
      return Center(
        child: Text(
          'principal.no_user'.tr(),
          style: const TextStyle(color: Colors.white),
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 20),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.12),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withOpacity(0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'principal.history'.tr(),
                style: const TextStyle(
                  color: Colors.black87,
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                ),
              ),
              Text(
                DateFormat('dd/MM/yyyy').format(_dateSelectionnee),
                style: TextStyle(
                  color: Colors.white.withOpacity(0.78),
                  fontWeight: FontWeight.w700,
                  fontSize: 11,
                ),
              ),
            ],
          ),
          Expanded(
            child: StreamBuilder<List<ModeleConversation>>(
              stream: _controleurPrincipal.obtenirFluxConversationsParDate(
                _dateSelectionnee,
              ),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: Text(
                      'principal.loading'.tr(),
                      style: TextStyle(color: Colors.white.withOpacity(0.8)),
                    ),
                  );
                }
                final conversations = snapshot.data ?? [];

                if (conversations.isEmpty) {
                  return Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'principal.empty'.tr(),
                      style: TextStyle(color: Colors.white.withOpacity(0.75)),
                    ),
                  );
                }

                return ListView.separated(
                  itemCount: conversations.length,
                  physics: const ClampingScrollPhysics(),
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final conversation = conversations[index];

                    return GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          chat.screenRoute,
                          arguments: conversation.id,
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.10),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.12),
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              height: 34,
                              width: 34,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.16),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.history,
                                color: Colors.white.withOpacity(0.85),
                                size: 18,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    conversation.titre.isEmpty
                                        ? 'principal.new_discussion'.tr()
                                        : conversation.titre,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 13,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    conversation.dernierMessage,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.7),
                                      fontSize: 11,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              conversation.heureFormattee,
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.65),
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final taille = MediaQuery.of(context).size;
    final hauteur = taille.height;
    final largeur = taille.width;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: _buildUserTitle(),
        centerTitle: true,
        leading: IconButton(
          style: const ButtonStyle(
            backgroundColor: WidgetStatePropertyAll<Color>(
              Color.fromARGB(89, 88, 70, 142),
            ),
          ),
          icon: const Icon(Icons.menu, color: Colors.white),
          onPressed: _parametre,
          tooltip: 'parametre',
          iconSize: 25,
          constraints: const BoxConstraints(minHeight: 25, minWidth: 25),
        ),
        actions: [
          if (isAdmin)
            Positioned(
              top: 50,
              right: 30,
              child: GestureDetector(
                onTap: () {
                  Navigator.pushNamed(context, AdminHome.screenRoute);
                },
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: Color.fromARGB(92, 88, 70, 142),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.admin_panel_settings, color: Colors.white),
                ),
              ),
            ),
          _buildPhotoProfil(),
          IconButton(
            style: const ButtonStyle(
              backgroundColor: WidgetStatePropertyAll<Color>(
                Color.fromARGB(92, 88, 70, 142),
              ),
            ),
            icon: const Icon(Icons.notifications_active, color: Colors.white),
            onPressed: () {
              Navigator.pushNamed(context, notifications.screenRoute);
            },
            tooltip: 'notification',
            iconSize: 25,
            constraints: const BoxConstraints(minHeight: 25, minWidth: 25),
          ),
        ],
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("images/b1.png"),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: SizedBox(
              height: hauteur < 820 ? 930 : hauteur * 1.12,
              child: Stack(
                children: [
                  Stack(
                    children: [
                      Positioned(
                        top: hauteur * 0.01,
                        left: largeur * 0.05,
                        child: SizedBox(
                          width: largeur * 0.5,
                          height: 165,
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.10),
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.16),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        top: hauteur * 0.03,
                        left: largeur * 0.08,
                        child: SizedBox(
                          width: 120,
                          height: 44,
                          child: ElevatedButton(
                            onPressed: () async {
                              final texte = 'principal.new_discussion'.tr();
                              final conversationId = await creerConversation(
                                texte,
                              );

                              if (conversationId.isNotEmpty && mounted) {
                                Navigator.pushNamed(
                                  context,
                                  chat.screenRoute,
                                  arguments: conversationId,
                                );
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color.fromARGB(
                                221,
                                80,
                                7,
                                137,
                              ).withOpacity(0.20),
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(22),
                              ),
                            ),
                            child: Text(
                              'principal.discuss'.tr(),
                              style: const TextStyle(
                                color: Color.fromARGB(255, 50, 43, 43),
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        top: hauteur * 0.09,
                        left: largeur * 0.105,
                        child: SizedBox(
                          width: 35,
                          height: 15,
                          child: Container(
                            decoration: BoxDecoration(
                              color: const Color.fromARGB(
                                221,
                                80,
                                7,
                                137,
                              ).withOpacity(0.20),
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.18),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        top: hauteur * 0.111,
                        left: largeur * 0.145,
                        child: SizedBox(
                          width: 25,
                          height: 12,
                          child: Container(
                            decoration: BoxDecoration(
                              color: const Color.fromARGB(
                                221,
                                80,
                                7,
                                137,
                              ).withOpacity(0.20),
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.18),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        top: hauteur * 0.125,
                        left: largeur * 0.18,
                        child: SizedBox(
                          width: 20,
                          height: 8,
                          child: Container(
                            decoration: BoxDecoration(
                              color: const Color.fromARGB(
                                221,
                                80,
                                7,
                                137,
                              ).withOpacity(0.20),
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.18),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        top: hauteur * 0.068,
                        left: largeur * 0.28,
                        child: Image.asset("images/robot0.png", width: 95),
                      ),
                      Positioned(
                        right: largeur * 0.04,
                        top: hauteur * 0.01,
                        bottom: largeur * 1.92,
                        child: const AccesRapidesNotesAlarmes(),
                      ),
                      Positioned(
                        top: hauteur * 0.22,
                        left: largeur * 0.05,
                        right: largeur * 0.05,
                        child: const CarteMeteoAccueil(),
                      ),

                      Positioned(
                        top: hauteur * 0.288,
                        left: largeur * 0.05,
                        right: largeur * 0.05,
                        child: const BarreBienEtre(),
                      ),
                      Positioned(
                        top: hauteur * 0.39,
                        left: largeur * 0.05,
                        right: largeur * 0.05,
                        child: GestureDetector(
                          onTap: () {
                            Navigator.pushNamed(
                              context,
                              Calendrier.screenRoute,
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.all(19),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.18),
                              borderRadius: BorderRadius.circular(18),
                            ),
                            child: TableCalendar(
                              sixWeekMonthsEnforced: true,
                              rowHeight: 35,
                              firstDay: DateTime.utc(2016, 1, 1),
                              lastDay: DateTime.utc(2036, 12, 31),
                              focusedDay: _moisAffiche,
                              startingDayOfWeek: StartingDayOfWeek.sunday,
                              selectedDayPredicate: (jour) =>
                                  isSameDay(jour, _dateSelectionnee),
                              onDaySelected: (jourSelectionne, moisFocalise) {
                                setState(() {
                                  _dateSelectionnee = jourSelectionne;
                                  _moisAffiche = moisFocalise;
                                });
                              },
                              headerStyle: HeaderStyle(
                                formatButtonVisible: false,
                                titleCentered: true,
                                titleTextFormatter: (date, locale) =>
                                    DateFormat(
                                      'MMM yyyy',
                                      context.locale.languageCode,
                                    ).format(date),
                                titleTextStyle: const TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w700,
                                ),
                                leftChevronIcon: const Icon(
                                  Icons.chevron_left,
                                  color: Colors.black,
                                ),
                                rightChevronIcon: const Icon(
                                  Icons.chevron_right,
                                  color: Colors.black,
                                ),
                              ),
                              daysOfWeekStyle: DaysOfWeekStyle(
                                weekdayStyle: TextStyle(
                                  color: Colors.black.withOpacity(0.70),
                                ),
                                weekendStyle: TextStyle(
                                  color: Colors.black.withOpacity(0.70),
                                ),
                              ),
                              calendarStyle: CalendarStyle(
                                outsideDaysVisible: false,
                                defaultTextStyle: const TextStyle(
                                  color: Colors.black,
                                ),
                                weekendTextStyle: const TextStyle(
                                  color: Colors.black,
                                ),
                                todayDecoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.08),
                                  shape: BoxShape.circle,
                                ),
                                selectedDecoration: const BoxDecoration(
                                  color: Color(0xFF2F7BFF),
                                  shape: BoxShape.circle,
                                ),
                                selectedTextStyle: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        left: largeur * 0.025,
                        right: largeur * 0.025,
                        top: hauteur * 0.777,
                        child: SizedBox(
                          height: hauteur * 0.35,
                          child: sectionHistorique(),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class CarteMeteoAccueil extends StatelessWidget {
  const CarteMeteoAccueil({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, MeteoPage.screenRoute),
      child: Container(
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.16),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: Colors.white.withOpacity(0.20)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.92),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.cloud_queue_rounded,
                color: Color.fromARGB(255, 79, 179, 255),
                size: 21,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'menu.weather'.tr(),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            Text(
              'Prévisions',
              style: TextStyle(
                color: Colors.white.withOpacity(0.72),
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 6),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              color: Colors.white70,
              size: 13,
            ),
          ],
        ),
      ),
    );
  }
}

class AccesRapidesNotesAlarmes extends StatelessWidget {
  const AccesRapidesNotesAlarmes({super.key});

  Widget _boutonAcces({
    required BuildContext context,
    required IconData icon,
    required String titre,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 3),
          padding: const EdgeInsets.symmetric(horizontal: 8.1, vertical: 8.4),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.08),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.white.withOpacity(0.10)),
          ),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  icon,
                  color: const Color.fromARGB(255, 79, 179, 255),
                  size: 23,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  titre,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.39,
      height: 170,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.12),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white.withOpacity(0.18)),
        ),
        child: Column(
          children: [
            _boutonAcces(
              context: context,
              icon: Icons.note_alt,
              titre: 'principal.notes'.tr(),
              onTap: () => Navigator.pushNamed(context, mesnotes.screenRoute),
            ),
            const SizedBox(height: 6),
            _boutonAcces(
              context: context,
              icon: Icons.alarm_rounded,
              titre: 'menu.alarms'.tr(),
              onTap: () =>
                  Navigator.pushNamed(context, AlarmesPage.screenRoute),
            ),
          ],
        ),
      ),
    );
  }
}

class BarreBienEtre extends StatelessWidget {
  const BarreBienEtre({super.key});

  Widget item({
    required IconData icon,
    required String titre,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.10),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.18)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(height: 5),
              Text(
                titre,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 75,
      padding: const EdgeInsets.symmetric(horizontal: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.15)),
      ),
      child: Row(
        children: [
          item(
            icon: Icons.favorite,
            titre: "Santé",
            color: Colors.redAccent,
            onTap: () {
              Navigator.pushNamed(context, SantePage.screenRoute);
            },
          ),
          item(
            icon: Icons.water_drop,
            titre: "Eau",
            color: Colors.blue,
            onTap: () async {
              final prefs = await SharedPreferences.getInstance();

              final uid = FirebaseAuth.instance.currentUser?.uid ?? 'guest';

              final configure =
                  prefs.getBool('${uid}_profil_hydratation_configure') ?? false;

              Navigator.pushNamed(
                context,
                configure
                    ? EauPage.screenRoute
                    : ConfigurationHydratationPage.screenRoute,
              );
            },
          ),
          item(
            icon: Icons.directions_run,
            titre: "Sport",
            color: Colors.green,
            onTap: () {},
          ),
          item(
            icon: Icons.school,
            titre: "Apprendre",
            color: Colors.orange,
            onTap: () {},
          ),
        ],
      ),
    );
  }
}
