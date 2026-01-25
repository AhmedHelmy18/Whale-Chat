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
