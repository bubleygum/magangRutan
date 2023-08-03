import 'package:app/login.dart';
import 'package:app/cs_Chat.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class csChatList extends StatefulWidget {
  final String username;

  const csChatList({required this.username, Key? key}) : super(key: key);
  @override
  State<csChatList> createState() => chatListScreenState(uname: username);
}

class chatListScreenState extends State<csChatList> {
  final String uname;

  chatListScreenState({required this.uname, Key? key});
  List<Map<String, dynamic>> chatListData = [];

  @override
  void initState() {
    super.initState();
    fetchChatList();
  }

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

  Future<void> fetchChatList() async {
    final response = await http.post(
      Uri.parse('http://localhost/csChatList.php'),
      body: {'uname': uname},
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['success']) {
        setState(() {
          chatListData = List<Map<String, dynamic>>.from(data['data']);
        });
      }
    } else {
      throw Exception('Failed to fetch wishlist data');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          "Chat List",
          style: TextStyle(
            color: Color.fromRGBO(61, 133, 3, 1),
            fontWeight: FontWeight.bold,
          ),
        ),
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
      ),
      body: ListView.builder(
        itemCount: chatListData.length,
        itemBuilder: (context, index) {
          final item = chatListData[index];
          final custName = item['CustName'];
          final custId = item['CustId'];
          final idChatRep = item['IdCabRep'];
          return Card(
            margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
            elevation: 4,
            child: Padding(
              padding: EdgeInsets.all(8.0),
              child: ListTile(
                title: Text(custName),
                trailing: IconButton(
                  icon: FaIcon(
                    FontAwesomeIcons.message,
                    color: Color.fromRGBO(29, 133, 3, 1),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => cs_chat(
                          idChatRep: idChatRep,
                          uname: uname,
                          custId: custId,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
