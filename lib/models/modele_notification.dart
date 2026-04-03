import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ModeleNotification {
  final String id;
  final String title;
  final String body;
  final DateTime dateTime;
  final bool isRead;
  final String type;
  final String iconType;
  final Map<String, dynamic> data;

  const ModeleNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.dateTime,
    required this.isRead,
    required this.type,
    required this.iconType,
    required this.data,
  });

  factory ModeleNotification.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final json = doc.data() ?? {};

    return ModeleNotification(
      id: doc.id,
      title: (json['title'] ?? '').toString(),
      body: (json['body'] ?? '').toString(),
      dateTime:
          (json['scheduledFor'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isRead: (json['isRead'] ?? false) == true,
      type: (json['type'] ?? '').toString(),
      iconType: (json['iconType'] ?? '').toString(),
      data: Map<String, dynamic>.from(json['data'] ?? {}),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'body': body,
      'type': type,
      'iconType': iconType,
      'isRead': isRead,
      'createdAt': Timestamp.now(),
      'scheduledFor': Timestamp.fromDate(dateTime),
      'data': data,
    };
  }

  IconData get icon {
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
}
