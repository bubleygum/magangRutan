import 'package:app/admin_home.dart';
import 'package:app/admin_promoDetail.dart';
import 'package:app/admin_chatList.dart';
import 'package:app/chat.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class notif extends StatefulWidget {
  final String username;
  final String status;
  const notif({required this.username, required this.status, Key? key})
      : super(key: key);
  @override
  State<notif> createState() => notifState(uname: username, status: status);
}

class notifState extends State<notif> {
  final String uname;
  final String status;
  notifState({required this.uname, required this.status, Key? key});
  List<Map<String, dynamic>> chatNotifData = [];
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();
    initializeNotifications();
    getUserData();
    getUserData().then((_) {
      fetchChatNotif();
    });
  }

  void initializeNotifications() async {
    final AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('app_icon');

    final IOSInitializationSettings initializationSettingsIOS =
        IOSInitializationSettings(
      requestSoundPermission: false,
      requestBadgePermission: false,
      requestAlertPermission: false,
    );

    final InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  Map<String, dynamic> userData = {};
  Future<void> getUserData() async {
    final response = await http.post(
        Uri.parse('http://localhost/getUserData.php'),
        body: {'username': uname});
    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      // print(jsonData);
      if (jsonData['success']) {
        if (jsonData.containsKey('data') &&
            jsonData['data'] is List &&
            jsonData['data'].length > 0) {
          var data = jsonData['data'][0];
          setState(() {
            userData = Map<String, dynamic>.from(data);
          });
          // print(userData["UserId"]);
        } else {
          print('Invalid data format in the API response');
        }
      } else {
        // print(jsonData['message']);
      }
    } else {
      throw Exception('Failed to fetch user data');
    }
  }

  // Future<void> fetchChatNotif() async {
  //   final response = await http.post(
  //     Uri.parse('http://localhost/chatNotif.php'),
  //     body: {'UserId': userData["UserId"], 'userStat': userData["StatusUser"]},
  //   );
  //   if (response.statusCode == 200) {
  //     final data = jsonDecode(response.body);
  //     if (data['success']) {
  //       setState(() {
  //         chatNotifData = List<Map<String, dynamic>>.from(data['data']);
  //       });
  //     }
  //   } else {
  //     throw Exception('Failed to fetch notif data');
  //   }
  // }

  Future<void> fetchChatNotif() async {
    final response = await http.post(
      Uri.parse('http://localhost/chatNotif.php'),
      body: {'UserId': userData["UserId"], 'userStat': userData["StatusUser"]},
    );
    print(userData['UserId']);
    print(userData['StatusUser']);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['success']) {
        setState(() {
          chatNotifData = List<Map<String, dynamic>>.from(data['data']);
        });
        print(data['data']);
        if (chatNotifData.isNotEmpty) {
          final notification =
              chatNotifData[0]; 
          final title = notification['title'];
          final body = notification['body'];
          displayPushNotification(title, body);
        }
      }
    } else {
      throw Exception('Failed to fetch wishlist data');
    }
  }

  int notificationId = 0; // Initialize a counter

  void displayPushNotification(String title, String body) async {
    final AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'test',
      'test',
      'test',
      importance: Importance.max,
      priority: Priority.high,
    );
    final NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    await flutterLocalNotificationsPlugin.show(
      notificationId++,
      title,
      body,
      platformChannelSpecifics,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Notif List",
          style: TextStyle(
            color: Color.fromRGBO(61, 133, 3, 1),
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 4,
        iconTheme: IconThemeData(
          color: Color.fromRGBO(61, 133, 3, 1),
        ),
      ),
      body: ListView(
        children: [
          _buildCategoryListView("Chat", chatNotifData),
          // _buildCategoryListView("Product", productNotifData),
          // _buildCategoryListView("Promotion", promotionNotifData),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        onTap: (int index) {
          switch (index) {
            case 0:
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => notif(
                    username: uname,
                    status: status,
                  ),
                ),
              );
              break;
            case 1:
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => adminHome(username: uname),
                ),
              );
              break;
            case 2:
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => adminChatList(
                    username: uname,
                  ),
                ),
              );
              break;
          }
        },
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: FaIcon(
              FontAwesomeIcons.ad,
              color: Color.fromRGBO(29, 133, 3, 1),
            ),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: FaIcon(
              FontAwesomeIcons.home,
              color: Color.fromRGBO(29, 133, 3, 1),
            ),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: FaIcon(
              FontAwesomeIcons.message,
              color: Color.fromRGBO(29, 133, 3, 1),
            ),
            label: '',
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryListView(
      String category, List<Map<String, dynamic>> data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            category,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        if (data.isEmpty)
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              "No new message",
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: data.length,
            itemBuilder: (context, index) {
              final item = data[index];
              // print(data[index]);
              final custName = item['Sender'];
              return Card(
                margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                elevation: 4,
                child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: ListTile(
                    title: Text(custName),
                    trailing: TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => chat(
                              uname: uname,
                              status: status,
                              product: "false",
                            ),
                          ),
                        );
                      },
                      child: Text('Open'),
                    ),
                  ),
                ),
              );
            },
          ),
      ],
    );
  }
}
