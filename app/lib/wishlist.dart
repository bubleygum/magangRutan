import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:app/home.dart';
import 'package:app/chat.dart';
class wishlist extends StatefulWidget {
  final String username;

  wishlist({required this.username, Key? key}) : super(key: key);

  @override
  State<wishlist> createState() => _WishlistState(uname: username);
}

class _WishlistState extends State<wishlist> {
  final String uname;

  _WishlistState({required this.uname, Key? key});

  List<Map<String, dynamic>> wishlistData = [];

  @override
  void initState() {
    super.initState();
    fetchWishlistData();
  }

  Future<void> fetchWishlistData() async {
    var url = Uri.parse('http://localhost/wishlist.php');
    var queryParameters = {'username': widget.username};
    try {
      var response = await http.post(url, body: queryParameters);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success']) {
          setState(() {
            wishlistData = List<Map<String, dynamic>>.from(data['data']);
          });
        }
      } else {
        throw Exception('Failed to fetch wishlist data');
      }
    } catch (error) {
      print('Error sending request: $error');
    }
  }

  Future<void> removeFromWishlist(String prodName) async {
    var url = Uri.parse('http://localhost/wishlist.php');
    var queryParameters = {
      'username': widget.username,
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
                MaterialPageRoute(builder: (context) => wishlist(username: uname)),
              );
              break;
            case 1:
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => Home(username: uname)),
              );
              break;
            case 2:
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => chat(username: uname,)),
              );
              break;
          }
        },
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: FaIcon(FontAwesomeIcons.heart,color:Color.fromRGBO(29, 133, 3, 1),),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: FaIcon(FontAwesomeIcons.home, color:Color.fromRGBO(29, 133, 3, 1), ),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: FaIcon(FontAwesomeIcons.message,color:Color.fromRGBO(29, 133, 3, 1),),
            label: '',
          ),
        ],
      ),
    );
  }
}
