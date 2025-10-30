import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

String formatDate(Timestamp? timestamp) {
  if (timestamp == null) return '';
  DateTime dateTime = timestamp.toDate();
  DateTime now = DateTime.now();

  if (DateFormat('yyyy-MM-dd').format(dateTime) ==
      DateFormat('yyyy-MM-dd').format(now)) {
    return 'Today';
  } else if (DateFormat('yyyy-MM-dd').format(dateTime) ==
      DateFormat('yyyy-MM-dd').format(now.subtract(Duration(days: 1)))) {
    return 'Yesterday';
  } else {
    return DateFormat('MMMM d, yyyy').format(dateTime);
  }
}

String formatTimestamp(Timestamp? timestamp) {
  if (timestamp == null) return '';

  DateTime dateTime = timestamp.toDate();
  return DateFormat('hh:mm a').format(dateTime);
}
