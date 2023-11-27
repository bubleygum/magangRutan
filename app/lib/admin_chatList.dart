import 'package:app/admin_Chat.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:app/admin_promoList.dart';
import 'package:app/admin_home.dart';

class adminChatList extends StatefulWidget {
  final String username;

  const adminChatList({required this.username, Key? key}) : super(key: key);
  @override
  State<adminChatList> createState() =>
      adminChatListScreenState(uname: username);
}

class adminChatListScreenState extends State<adminChatList> {
  final String uname;

  adminChatListScreenState({required this.uname, Key? key});
  List<Map<String, dynamic>> chatListData = [];

  @override
  void initState() {
    super.initState();
    fetchChatList();
  }

  Future<void> fetchChatList() async {
    final response = await http.post(
      Uri.parse('http://localhost/adminChatList.php'),
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
      throw Exception('Failed to fetch chat list data');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Chat List",
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
                        builder: (context) => admin_chat(
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
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        onTap: (int index) {
          switch (index) {
            case 0:
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => adminPromoList(
                    username: uname,
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
}
