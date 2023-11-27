import 'package:app/editProfile.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:app/admin_chatList.dart';
import 'package:app/listCS.dart';
import 'package:app/notif.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:app/login.dart';

class Profile extends StatefulWidget {
  final String username;
  final String status;
  const Profile({required this.username, required this.status, Key? key})
      : super(key: key);

  @override
  ProfileState createState() => ProfileState(uname: username, status: status);
}

class ProfileState extends State<Profile> {
  final String uname;
  final String status;
  ProfileState({required this.uname, required this.status});
  Map<String, dynamic> userData = {};
  String? userId;
  @override
  void initState() {
    super.initState();
    getUserData();
  }

  Future<void> logout(BuildContext context) async {
    SharedPreferences.getInstance().then((prefs) {
      prefs.setBool('isLoggedIn', false);
      prefs.remove('isLoggedIn');
      prefs.remove('username');
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => Login()),
      );
    });
  }

  Future<void> getUserData() async {
    // print("here" + uname);
    final response = await http.post(
        Uri.parse('http://localhost/getUserData.php'),
        body: {'username': uname});
    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      // print(response.body);

      if (jsonData['success']) {
        var data = jsonData['data'];
        setState(() {
          userData = jsonData;
          userId = jsonData['data'][0]['UserId'].toString();
        });
      } else {
        print(jsonData['message']);
      }
    } else {
      throw Exception('Failed to fetch user data');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          color: Colors.black,
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          IconButton(
            icon: FaIcon(
              FontAwesomeIcons.solidEnvelope,
              color: Colors.black,
            ),
            onPressed: () {
              if (status == "1") {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => adminChatList(
                      username: uname,
                    ),
                  ),
                );
              } else if (status == "3") {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ListCs(
                      uname: uname,
                      uId: userId.toString(),
                      status: status,
                      product: "false",
                    ),
                  ),
                );
              }
            },
          ),
          IconButton(
            icon: FaIcon(
              FontAwesomeIcons.solidBell,
              color: Colors.black,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => notif(
                    username: uname,
                    status: status,
                  ),
                ),
              );
            },
          ),
        ],
        backgroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                FaIcon(
                  FontAwesomeIcons.userCircle,
                  size: 40.0,
                  color: Colors.grey,
                ),
                SizedBox(width: 16.0),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome',
                      style: TextStyle(
                        color: Color(0xFF828FA1),
                        fontFamily: 'Open Sans',
                        fontSize: 14.0,
                        fontStyle: FontStyle.normal,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    Text(
                      uname,
                      style: TextStyle(
                        color: Colors.black,
                        fontFamily: 'Open Sans',
                        fontSize: 16,
                        fontStyle: FontStyle.normal,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                Spacer(),
                GestureDetector(
                  onTap: () {
                    logout(context);
                  },
                  child: FaIcon(
                    FontAwesomeIcons.signOutAlt,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
            Divider(
              color: Colors.black,
              thickness: 0.5,
            ),
            GestureDetector(
              onTap: () {
                print("pressed");
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => editProfile(username: uname, status: status)
                  ),
                );
              },
              child: Row(
                children: [
                  FaIcon(
                    FontAwesomeIcons.userCircle,
                    size: 30.0,
                    color: Colors.black,
                  ),
                  Text(
                    " Profile",
                    style: TextStyle(
                      fontSize: 16,
                      fontFamily: 'Open Sans',
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  Spacer(),
                  FaIcon(
                    FontAwesomeIcons.chevronRight,
                    size: 15.0,
                    color: Colors.grey,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
