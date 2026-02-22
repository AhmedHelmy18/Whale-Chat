import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

String formatDate(dynamic time) {
  if (time == null) return '';

  DateTime dateTime;

  if (time is Timestamp) {
    dateTime = time.toDate();
  } else if (time is DateTime) {
    dateTime = time;
  } else {
    return '';
  }

  return DateFormat('MMM d, yyyy').format(dateTime);
}

String formatTime(dynamic time) {
  if (time == null) return '';

  DateTime dateTime;

  if (time is Timestamp) {
    dateTime = time.toDate();
  } else if (time is DateTime) {
    dateTime = time;
  } else {
    return '';
  }

  return DateFormat('h:mm a').format(dateTime);
}

String formatChatDateHeader(dynamic time) {
  if (time == null) return '';

  DateTime dateTime;
  if (time is Timestamp) {
    dateTime = time.toDate();
  } else if (time is DateTime) {
    dateTime = time;
  } else {
    return '';
  }

  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final messageDate = DateTime(dateTime.year, dateTime.month, dateTime.day);

  final difference = messageDate.difference(today).inDays;

  if (difference == 0) return 'Today';
  if (difference == -1) return 'Yesterday';

  return DateFormat('MMM d, yyyy').format(dateTime);
}

String formatTimeAgo(dynamic time) {
  if (time == null) return '';

  DateTime dateTime;

  if (time is Timestamp) {
    dateTime = time.toDate();
  } else if (time is DateTime) {
    dateTime = time;
  } else {
    return '';
  }

  final now = DateTime.now();
  final difference = now.difference(dateTime);

  if (difference.inSeconds < 60) {
    return 'Just now';
  } else if (difference.inMinutes < 60) {
    return '${difference.inMinutes} min ago';
  } else if (difference.inHours < 24) {
    return '${difference.inHours} hours ago';
  } else if (difference.inDays < 7) {
    return '${difference.inDays} days ago';
  } else {
    return DateFormat('MMM d, yyyy').format(dateTime);
  }
}
