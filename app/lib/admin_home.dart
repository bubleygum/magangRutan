import 'dart:js_util';
import 'package:app/admin_addPromo.dart';
import 'package:app/admin_promoList.dart';
import 'package:app/admin_userList.dart';
import 'package:app/admin_chatList.dart';
import 'package:app/login.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class adminHome extends StatelessWidget {
  final String username;
  const adminHome({required this.username, Key? key});

  Future<void> logout(BuildContext context) async {
    SharedPreferences.getInstance().then((prefs) {
      prefs.setBool('isLoggedIn', false);
      prefs.remove('isLoggedIn');
      prefs.remove('username');
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => Login(),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    Color selectedColor = Color.fromRGBO(29, 133, 3, 1);
    return Scaffold(
      appBar: AppBar(
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
              icon: FaIcon(
                FontAwesomeIcons.rightFromBracket,
                color: Color.fromRGBO(29, 133, 3, 1),
              ),
              color: Color.fromRGBO(29, 133, 3, 1),
              onPressed: () {
                logout(context);
              },
            );
          },
        ),
        actions: [
          IconButton(
            icon: Icon(
              FontAwesomeIcons.ad,
              color: Color.fromRGBO(29, 133, 3, 1),
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => addPromo(username: username),
                ),
              );
            },
          ),
        ],
        backgroundColor: Colors.white,
      ),
      body: HomeScreen(
        uname: username,
        // status: status,
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: selectedColor,
        onTap: (int index) {
          switch (index) {
            case 0:
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => adminHome(username: username),
                ),
              );

              break;
            case 1:
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => adminPromoList(
                    username: username,
                  ),
                ),
              );
              break;
            case 2:
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => adminUserList(
                    username: username,
                  ),
                ),
              );
              break;
            case 3:
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => adminChatList(
                    username: username,
                  ),
                ),
              );
              break;
          }
        },
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: FaIcon(
              FontAwesomeIcons.home,
              color: Color.fromRGBO(29, 133, 3, 1),
            ),
            label: 'Beranda',
          ),
          BottomNavigationBarItem(
            icon: FaIcon(
              FontAwesomeIcons.ad,
              color: Color.fromRGBO(130, 143, 161, 1),
            ),
            label: 'Promo',
          ),
          BottomNavigationBarItem(
            icon: FaIcon(
              FontAwesomeIcons.peopleGroup,
              color: Color.fromRGBO(130, 143, 161, 1),
            ),
            label: 'List User',
          ),
          BottomNavigationBarItem(
            icon: FaIcon(
              FontAwesomeIcons.message,
              color: Color.fromRGBO(130, 143, 161, 1),
            ),
            label: 'Messages',
          ),
        ],
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  final String uname;
  // final String status;
  // HomeScreen({required this.uname, required this.status, Key? key})
  //     : super(key: key);
  HomeScreen({required this.uname, Key? key});
  @override
  _HomeScreenState createState() =>
      // _HomeScreenState(uname: uname, status: status);
      _HomeScreenState(uname: uname);
}

class _HomeScreenState extends State<HomeScreen> {
  final String uname;
  _HomeScreenState({required this.uname, Key? key});
  Future<String> fetchUserCount() async {
    final response = await http.post(
        Uri.parse('http://localhost/adminUserList.php'),
        body: {"jumlah": "true"});
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['success']) {
        print(data['total_rows']);
        return data['total_rows'];
      } else {
        throw Exception('Failed to fetch user count');
      }
    } else {
      throw Exception('Failed to fetch user count');
    }
  }

  Future<String> fetchPromoCount() async {
    final response = await http.post(
        Uri.parse('http://localhost/adminPromoList.php'),
        body: {"jumlah": "true"});
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['success']) {
        print(data['total_rows']);
        return data['total_rows'];
      } else {
        throw Exception('Failed to fetch user count');
      }
    } else {
      throw Exception('Failed to fetch user count');
    }
  }

  String? userId;
  Map<String, dynamic> userData = {};
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
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SizedBox(
              height: 20,
            ),
            Text(
              'Welcome to the admin panel',
              style: TextStyle(
                color: Color(0xFF141719),
                fontSize: 20,
                fontFamily: 'Open Sans',
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              'Managing and organizing the site is easier',
              style: TextStyle(
                color: Color(0xFF818EA1),
                fontSize: 14,
                fontFamily: 'Open Sans',
                fontWeight: FontWeight.w400,
              ),
            ),
            GridView.count(
              shrinkWrap: true,
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              padding: EdgeInsets.all(10),
              children: <Widget>[
                FutureBuilder<String>(
                  future: fetchUserCount(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.done) {
                      if (snapshot.hasError) {
                        return Text('Error: ${snapshot.error}');
                      }
                      return _buildGridItem(
                        label1: 'Jumlah User',
                        label2: snapshot.data.toString(),
                        imageAssetPath: 'btn5.png',
                        onPressed: () {},
                      );
                    } else {
                      return CircularProgressIndicator();
                    }
                  },
                ),
                FutureBuilder<String>(
                  future: fetchPromoCount(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.done) {
                      if (snapshot.hasError) {
                        return Text('Error: ${snapshot.error}');
                      }
                      return _buildGridItem(
                        label1: 'Promosi',
                        label2: snapshot.data.toString(),
                        imageAssetPath: 'btn5.png',
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => addPromo(
                                username: uname,
                              ),
                            ),
                          );
                        },
                      );
                    } else {
                      return CircularProgressIndicator();
                    }
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGridItem({
    required String imageAssetPath,
    required String label1,
    required String label2,
    required VoidCallback onPressed,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        child: Card(
          shape: RoundedRectangleBorder(
            side: BorderSide(width: 1, color: Color(0xFFB2C0D4)),
            borderRadius: BorderRadius.circular(15),
          ),
          child: IntrinsicHeight(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.all(10), // Adjust padding as needed
                  child: Text(
                    label1,
                    style: TextStyle(
                      color: Color(0xFF818EA1),
                      fontSize: 14,
                      fontFamily: 'Open Sans',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(10), // Adjust padding as needed
                  child: Text(
                    label2,
                    style: TextStyle(
                      color: Color(0xFF2B2B2B),
                      fontSize: 32,
                      fontFamily: 'Open Sans',
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Container(
                  height: 50,
                  padding: EdgeInsets.all(10),
                  child: Image.asset(
                    imageAssetPath,
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
