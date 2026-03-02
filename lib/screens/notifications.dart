import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:math';

class notifications extends StatefulWidget {
  static const String screenRoute = 'pagenotifications';
  const notifications({super.key});

  @override
  State<notifications> createState() => _notificationsState();
}

class _notificationsState extends State<notifications> {
  final List<Notification> listeNotifications = [
    Notification(
      id: "n1",
      titre: "Notification tache",
      description: "C'est l'heure de votre tâche",
      dateTime: DateTime.now().add(const Duration(minutes: 5)),
      icon: Icons.check_box_outlined,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.of(context).size.height;
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
          onPressed: () => Navigator.pop(context),
          iconSize: 40,
          constraints: const BoxConstraints(minHeight: 50, minWidth: 50),
        ),
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
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),

                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        "Notifications",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 33,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    Positioned(
                      top: h * -0.01,
                      right: h * 0.01,
                      child: Transform.rotate(
                        angle: -pi / 3.8,
                        child: Image.asset('images/robot2.png', width: 100),
                      ),
                    ),
                  ],
                ),

                Expanded(
                  child: ListView.separated(
                    itemCount: listeNotifications.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final n = listeNotifications[index];

                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  NotificationDetailsPage(notification: n),
                            ),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.18),
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.12),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(n.icon, color: Colors.black87),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  n.titre,
                                  style: const TextStyle(
                                    color: Colors.black87,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Icon(
                                Icons.keyboard_arrow_down,
                                color: Colors.black54,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class NotificationDetailsPage extends StatelessWidget {
  final Notification notification;
  const NotificationDetailsPage({super.key, required this.notification});

  String _timeHHmm(DateTime d) => DateFormat("HH:mm").format(d);

  String _inHowLong(DateTime target) {
    final diff = target.difference(DateTime.now());
    if (diff.inSeconds <= 0) return "Maintenant";
    if (diff.inMinutes < 60)
      return "Dans ${diff.inMinutes} minutes (${_timeHHmm(target)})";
    if (diff.inHours < 24)
      return "Dans ${diff.inHours} heures (${_timeHHmm(target)})";
    return "Le ${DateFormat('dd/MM/yyyy').format(target)} (${_timeHHmm(target)})";
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
          onPressed: () => Navigator.pop(context),
          iconSize: 40,
          constraints: const BoxConstraints(minHeight: 50, minWidth: 50),
        ),
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
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // cercle icon
                  Container(
                    width: 110,
                    height: 110,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.22),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.35),
                        width: 3,
                      ),
                    ),
                    child: Icon(
                      notification.icon,
                      size: 44,
                      color: Colors.amber,
                    ),
                  ),

                  const SizedBox(height: 18),

                  Text(
                    notification.titre,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                    ),
                  ),

                  const SizedBox(height: 10),

                  Text(
                    notification.description,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const SizedBox(height: 10),

                  Text(
                    _inHowLong(notification.dateTime),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
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

class Notification {
  final String id;
  final String titre;
  final String description;
  final DateTime dateTime;
  final IconData icon;

  Notification({
    required this.id,
    required this.titre,
    required this.description,
    required this.dateTime,
    required this.icon,
  });
}
