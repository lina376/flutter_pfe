import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:math';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'notification_service.dart';

class notifications extends StatefulWidget {
  static const String screenRoute = 'pagenotifications';
  const notifications({super.key});

  @override
  State<notifications> createState() => _notificationsState();
}

class _notificationsState extends State<notifications> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  IconData _getIcon(String iconType) {
    switch (iconType) {
      case 'water':
        return Icons.water_drop;
      case 'doctor':
        return Icons.medical_services;
      case 'medicine':
        return Icons.medication;
      case 'sport':
        return Icons.fitness_center;
      case 'sleep':
        return Icons.bedtime;
      default:
        return Icons.notifications_active;
    }
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> _notificationsStream() {
    final user = _auth.currentUser;
    if (user == null) {
      return const Stream.empty();
    }

    return _firestore
        .collection('users')
        .doc(user.uid)
        .collection('notifications')
        .orderBy('scheduledFor', descending: true)
        .snapshots();
  }

  Future<void> _addTestNotifications() async {
    await NotificationService.sendWaterReminder(waterMl: 400);

    await NotificationService.sendDoctorAppointmentReminder(
      doctorName: 'Dr. Ahmed',
      appointmentDate: DateTime.now().add(const Duration(hours: 2)),
    );

    await NotificationService.sendMedicineReminder(
      medicineName: 'Vitamine D',
      reminderTime: DateTime.now().add(const Duration(minutes: 30)),
    );
  }

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
        actions: [
          IconButton(
            onPressed: _addTestNotifications,
            icon: const Icon(Icons.add_alert, color: Colors.white),
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
                    Transform.rotate(
                      angle: -pi / 3.8,
                      child: Image.asset('images/robot2.png', width: 100),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Expanded(
                  child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                    stream: _notificationsStream(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (snapshot.hasError) {
                        return const Center(
                          child: Text(
                            "Erreur de chargement",
                            style: TextStyle(color: Colors.white),
                          ),
                        );
                      }

                      final docs = snapshot.data?.docs ?? [];

                      if (docs.isEmpty) {
                        return const Center(
                          child: Text(
                            "Aucune notification",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        );
                      }

                      return ListView.separated(
                        itemCount: docs.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final doc = docs[index];
                          final data = doc.data();

                          final notif = AppNotification.fromFirestore(
                            doc.id,
                            data,
                            _getIcon(data['iconType'] ?? ''),
                          );

                          return GestureDetector(
                            onTap: () async {
                              await NotificationService.markAsRead(notif.id);

                              if (!context.mounted) return;

                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => NotificationDetailsPage(
                                    notification: notif,
                                  ),
                                ),
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                color: notif.isRead
                                    ? Colors.white.withOpacity(0.12)
                                    : Colors.white.withOpacity(0.22),
                                borderRadius: BorderRadius.circular(18),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.12),
                                ),
                              ),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    radius: 22,
                                    backgroundColor: Colors.white.withOpacity(
                                      0.25,
                                    ),
                                    child: Icon(
                                      notif.icon,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          notif.title,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w800,
                                            fontSize: 14,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          notif.body,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            color: Colors.white.withOpacity(
                                              0.85,
                                            ),
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Column(
                                    children: [
                                      Text(
                                        DateFormat(
                                          "HH:mm",
                                        ).format(notif.dateTime),
                                        style: TextStyle(
                                          color: Colors.white.withOpacity(0.85),
                                          fontSize: 11,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      IconButton(
                                        onPressed: () async {
                                          await NotificationService.deleteNotification(
                                            notif.id,
                                          );
                                        },
                                        icon: const Icon(
                                          Icons.delete_outline,
                                          color: Colors.white70,
                                          size: 20,
                                        ),
                                      ),
                                    ],
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
          ),
        ),
      ),
    );
  }
}

class NotificationDetailsPage extends StatelessWidget {
  final AppNotification notification;
  const NotificationDetailsPage({super.key, required this.notification});

  String _timeHHmm(DateTime d) => DateFormat("HH:mm").format(d);

  String _inHowLong(DateTime target) {
    final diff = target.difference(DateTime.now());

    if (diff.inSeconds <= 0) return "Maintenant";
    if (diff.inMinutes < 60) {
      return "Dans ${diff.inMinutes} minutes (${_timeHHmm(target)})";
    }
    if (diff.inHours < 24) {
      return "Dans ${diff.inHours} heures (${_timeHHmm(target)})";
    }
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
                    notification.title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    notification.body,
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

class AppNotification {
  final String id;
  final String title;
  final String body;
  final DateTime dateTime;
  final IconData icon;
  final bool isRead;
  final String type;
  final String iconType;
  final Map<String, dynamic> data;

  AppNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.dateTime,
    required this.icon,
    required this.isRead,
    required this.type,
    required this.iconType,
    required this.data,
  });

  factory AppNotification.fromFirestore(
    String id,
    Map<String, dynamic> json,
    IconData icon,
  ) {
    return AppNotification(
      id: id,
      title: (json['title'] ?? '').toString(),
      body: (json['body'] ?? '').toString(),
      dateTime:
          (json['scheduledFor'] as Timestamp?)?.toDate() ?? DateTime.now(),
      icon: icon,
      isRead: (json['isRead'] ?? false) == true,
      type: (json['type'] ?? '').toString(),
      iconType: (json['iconType'] ?? '').toString(),
      data: Map<String, dynamic>.from(json['data'] ?? {}),
    );
  }
}
