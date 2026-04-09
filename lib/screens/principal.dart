import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

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

class principal extends StatefulWidget {
  static const String screenRoute = 'pageprincipal';

  const principal({super.key});

  @override
  State<principal> createState() => _principalState();
}

class _principalState extends State<principal> {
  final ControleurPrincipal _controleurPrincipal = ControleurPrincipal();

  DateTime _moisAffiche = DateTime.now();
  DateTime _dateSelectionnee = DateTime.now();
  bool _notif = true;

  Future<void> _logout() async {
    await _controleurPrincipal.seDeconnecter();
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, 'pageconnecter');
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
                                  icon: Icons.cloud_outlined,
                                  title: 'menu.weather'.tr(),
                                  onTap: () {
                                    Navigator.pop(context);
                                    Navigator.pushNamed(
                                      context,
                                      MeteoPage.screenRoute,
                                    );
                                  },
                                ),
                                _list(
                                  icon: Icons.alarm,
                                  title: 'menu.alarms'.tr(),
                                  onTap: () {
                                    Navigator.pop(context);
                                    Navigator.pushNamed(
                                      context,
                                      AlarmesPage.screenRoute,
                                    );
                                  },
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
          Text(
            'principal.history'.tr(),
            style: const TextStyle(
              color: Colors.black87,
              fontWeight: FontWeight.w800,
              fontSize: 14,
            ),
          ),
          Expanded(
            child: StreamBuilder<List<ModeleConversation>>(
              stream: _controleurPrincipal.obtenirFluxConversations(),
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
    final hauteur = MediaQuery.of(context).size.height;

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
            image: AssetImage("images/b5.png"),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: SizedBox(
              height: MediaQuery.of(context).size.height,
              child: Stack(
                children: [
                  Positioned(
                    top: hauteur * 0.001,
                    left: hauteur * 0.0001,
                    child: const SizedBox(
                      width: 395,
                      height: 45,
                      child: Recherche(),
                    ),
                  ),
                  Positioned(
                    top: hauteur * 0.08,
                    left: hauteur * 0.02,
                    child: SizedBox(
                      width: 210,
                      height: 170,
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.18),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: hauteur * 0.08,
                    right: hauteur * 0.02,
                    child: GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(context, mesnotes.screenRoute);
                      },
                      child: SizedBox(
                        width: 130,
                        height: 170,
                        child: Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.18),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Stack(
                    children: [
                      Positioned(
                        top: hauteur * 0.095,
                        left: hauteur * 0.035,
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
                        top: hauteur * 0.155,
                        left: hauteur * 0.05,
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
                        top: hauteur * 0.174,
                        left: hauteur * 0.07,
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
                        top: hauteur * 0.19,
                        left: hauteur * 0.09,
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
                        top: hauteur * 0.13,
                        left: hauteur * 0.12,
                        child: Image.asset("images/robot0.png", width: 95),
                      ),
                      Positioned(
                        right: hauteur * 0.001,
                        top: hauteur * 0.08,
                        child: const MesNotes(),
                      ),
                      Positioned(
                        top: hauteur * 0.3,
                        left: hauteur * 0.02,
                        right: hauteur * 0.02,
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
                        left: hauteur * 0.01,
                        right: hauteur * 0.01,
                        bottom: hauteur * -0.08,
                        child: SizedBox(
                          height: hauteur * 0.4,
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

class Recherche extends StatelessWidget {
  const Recherche({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: const Color.fromARGB(159, 255, 255, 255).withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.search, color: Colors.white),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              style: const TextStyle(color: Color.fromARGB(75, 255, 255, 255)),
              decoration: InputDecoration(
                hintText: 'principal.search'.tr(),
                hintStyle: const TextStyle(color: Colors.white70),
                border: InputBorder.none,
              ),
            ),
          ),
          const Icon(Icons.mic, color: Colors.white),
        ],
      ),
    );
  }
}

class MesNotes extends StatelessWidget {
  const MesNotes({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, mesnotes.screenRoute);
      },
      child: SizedBox(
        width: 170,
        height: 170,
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.note_alt,
                  color: Color.fromARGB(255, 79, 179, 255),
                  size: 28,
                ),
              ),
              const SizedBox(height: 14),
              Text(
                'principal.notes'.tr(),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
