import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:app/home.dart';
import 'package:app/chat.dart';

class wishlist extends StatefulWidget {
  final String username;
final String status;  
  wishlist({required this.username, required this.status,Key? key}) : super(key: key);

  @override
  State<wishlist> createState() => _WishlistState(uname: username, status: status);
}

class _WishlistState extends State<wishlist> {
  final String uname;
final String status;  
  _WishlistState({required this.uname, required this.status,Key? key});

  List<Map<String, dynamic>> wishlistData = [];

  @override
  void initState() {
    super.initState();
    getUserData();
  }

  Map<String, dynamic> userData = {};
  Future<void> getUserData() async {
    final response = await http.post(
      Uri.parse('http://localhost/getUserData.php'),
      body: {'username': widget.username},
    );
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
          if (userData['UserId'] != null) {
            fetchWishlistData(userData['UserId']);
          } else {
            print('UserId is null in the API response');
          }
        } else {
          print('Invalid data format in the API response');
        }
      } else {
        print(jsonData['message']);
      }
    } else {
      throw Exception('Failed to fetch user data');
    }
  }

  Future<void> fetchWishlistData(String userId) async {
    final response = await http.post(
      Uri.parse('http://localhost/wishlist.php'),
      body: {'uId': userId},
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      // print(data);
      if (data['success']) {
        setState(() {
          wishlistData = List<Map<String, dynamic>>.from(data['data']);
        });
      }
    } else {
      throw Exception('Failed to fetch wishlist data');
    }
  }

  Future<void> removeFromWishlist(String prodName) async {
    var url = Uri.parse('http://localhost/wishlist.php');
    var queryParameters = {
      'uId': userData["UserId"],
      'remove_id': prodName,
    };
    try {
      var response = await http.post(url, body: queryParameters);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success']) {
          setState(() {
            wishlistData.removeWhere((item) => item['ProdName'] == prodName);
          });
        } else {
          throw Exception('Failed to remove item from wishlist');
        }
      } else {
        throw Exception('Failed to send request');
      }
    } catch (error) {
      print('Error sending request: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Wishlist",
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
        itemCount: wishlistData.length,
        itemBuilder: (context, index) {
          final item = wishlistData[index];
          final prodName = item['ProdName'];
          final photoUrl = item['PhotoUrl'];
          return Card(
            margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
            elevation: 4,
            child: Padding(
              padding: EdgeInsets.all(8.0),
              child: ListTile(
                leading: Container(
                  width: 80,
                  height: 80,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8.0),
                    child: AspectRatio(
                      aspectRatio: 1,
                      child: Image.network(
                        photoUrl,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                title: Text(prodName),
                trailing: IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () {
                    removeFromWishlist(prodName);
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
                    builder: (context) => wishlist(username: uname, status: status,)),
              );
              break;
            case 1:
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => userHomeScreen(uname: uname, status: status,)),
              );
              break;
            case 2:
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => chat(
                          uname: uname,
                          status: status,
                          product: "false"
                        )),
              );
              break;
          }
        },
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: FaIcon(
              FontAwesomeIcons.heart,
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
