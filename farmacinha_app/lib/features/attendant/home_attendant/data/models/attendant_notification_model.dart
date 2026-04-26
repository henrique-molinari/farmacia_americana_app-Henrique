import 'package:flutter/material.dart';

class AttendantNotification {
  final IconData icon;
  final Color iconBackground;
  final Color iconColor;
  final String timeLabel;
  final String title;
  final String description;
  final String? actionLabel;
  final String? chatId;

  const AttendantNotification({
    required this.icon,
    required this.iconBackground,
    required this.iconColor,
    required this.timeLabel,
    required this.title,
    required this.description,
    this.actionLabel,
    this.chatId,
  });
}
