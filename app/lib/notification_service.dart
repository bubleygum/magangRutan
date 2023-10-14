import 'package:app/admin_home.dart';
import 'package:app/admin_promoDetail.dart';
import 'package:app/admin_chatList.dart';
import 'package:app/chat.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    final AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('app_icon');

    final IOSInitializationSettings initializationSettingsIOS =
        IOSInitializationSettings(
      requestSoundPermission: false,
      requestBadgePermission: false,
      requestAlertPermission: false,
    );

    final InitializationSettings initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid, iOS: initializationSettingsIOS);

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }
}

Future<List<Map<String, dynamic>>> fetchDataFromApi(uid, status) async {
  final response = await http.post(
    Uri.parse('https://localhost/notif.php'),
    body: {
      'UserId': uid, 
      'userStat': status, 
    },
  );

  if (response.statusCode == 200) {
    final List<dynamic> jsonData = json.decode(response.body)['data'];
    return jsonData.cast<Map<String, dynamic>>();
  } else {
    throw Exception('Failed to load data from the API');
  }
}