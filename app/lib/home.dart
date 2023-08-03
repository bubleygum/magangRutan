import 'package:app/login.dart';
import 'package:app/prodDetail.dart';
import 'package:app/productList.dart';
import 'package:app/tentangKami.dart';
import 'package:app/wishlist.dart';
import 'package:app/chat.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class userHomeScreen extends StatefulWidget {
  final String uname;

  userHomeScreen({required this.uname, Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState(uname: uname);
}

class _HomeScreenState extends State<userHomeScreen> {
  final String uname;
  List<String> carouselImages = [];
  final List<Map<String, String>> buttonData = [
    {'imagePath': 'assets/btn1.jpg', 'label': 'Implement'},
    {'imagePath': 'assets/btn2.jpg', 'label': 'Traktor'},
    {'imagePath': 'assets/btn3.jpg', 'label': 'Mesin Penanam'},
    {'imagePath': 'assets/btn4.jpg', 'label': 'Combine Harvester'},
    {'imagePath': 'assets/btn5.png', 'label': 'Pengairan & Irigasi'},
    {'imagePath': 'assets/btn6.png', 'label': 'Mesin Pengering'},
    {'imagePath': 'assets/btn7.jpg', 'label': 'Mesin Sortir & Pengemasan'},
    {'imagePath': 'assets/btn8.jpg', 'label': 'Mesin Penggerak & Genset'},
    {'imagePath': 'assets/btn9.png', 'label': 'Mesin Industri'},
    {'imagePath': 'assets/btn10.jpg', 'label': 'Mesin Tambak'},
    {'imagePath': 'assets/btn11.png', 'label': 'Alat Pendukung Lain'},
  ];

  _HomeScreenState({required this.uname, Key? key});

  @override
  void initState() {
    super.initState();
    fetchCarouselImages();
    getUserData();
  }

  Future<void> fetchCarouselImages() async {
    final response =
        await http.get(Uri.parse('http://localhost/fetchCarousel.php'));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      // print(jsonDecode(response.body));
      setState(() {
        carouselImages = List<String>.from(data['data']);
      });
    } else {
      throw Exception('Failed to fetch carousel images');
    }
  }

  Map<String, dynamic> userData = {};
  Future<void> getUserData() async {
    final response = await http.post(
        Uri.parse('http://localhost/getUserData.php'),
        body: {'username': uname});
    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      // print(jsonDecode(response.body));
      if (jsonData['success']) {
        var data = jsonData['data'];
        setState(() {
          userData = jsonData;
        });
      } else {
        print(jsonData['message']);
      }
    } else {
      throw Exception('Failed to fetch user data');
    }
  }

  void navigateToProductDetail(String prodCode) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => prodDetail(data: prodCode, uname: uname),
      ),
    );
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

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final carouselHeight = screenHeight * 0.2;
    return Scaffold(
      appBar: AppBar(
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
              icon: Icon(Icons.menu),
              color: Color.fromRGBO(29, 133, 3, 1),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            );
          },
        ),
        actions: [
          IconButton(
            icon: FaIcon(
              FontAwesomeIcons.bell,
              color: Color.fromRGBO(29, 133, 3, 1),
            ),
            onPressed: () {
              
            },
          ),
        ],
        backgroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(
              height: 5,
            ),
            // if (carouselImages.isNotEmpty)
            //   CarouselSlider(
            //     items: carouselImages.map((image) {
            //       return Builder(
            //         builder: (BuildContext context) {
            //           return Container(
            //             width: double.infinity,
            //             height: carouselHeight,
            //             decoration: BoxDecoration(
            //               image: DecorationImage(
            //                 image: NetworkImage(image),
            //                 fit: BoxFit.cover,
            //               ),
            //             ),
            //           );
            //         },
            //       );
            //     }).toList(),
            //     options: CarouselOptions(
            //       height: carouselHeight,
            //       autoPlay: true,
            //       enlargeCenterPage: true,
            //       viewportFraction: 0.8,
            //       aspectRatio: 16 / 9,
            //     ),
            //   ),
            SizedBox(
              height: 20,
            ),
            Center(
              child: Text(
                "Produk Kami",
                style: TextStyle(
                  color: Color.fromRGBO(0, 166, 82, 1),
                  fontSize: 20,
                ),
              ),
            ),
            SizedBox(
              height: 10,
            ),
            GridView.count(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              children: List.generate(buttonData.length, (index) {
                return GestureDetector(
                  onTap: () {
                    navigateToProductDetail("0301ISKTR4-NT540FTT");
                  },
                  child: Card(
                    elevation: 2,
                    child: Container(
                      child: Column(
                        children: [
                          Expanded(
                            child: Opacity(
                              opacity: 0.5,
                              child: Image.network(
                                buttonData[index]['imagePath']!,
                              ),
                            ),
                          ),
                          Text(
                            buttonData[index]['label']!,
                            style: TextStyle(
                              color: Color.fromRGBO(0, 166, 82, 1),
                              fontSize: 20,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        onTap: (int index) {
          switch (index) {
            case 0:
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => wishlist(username: uname)),
              );
              break;
            case 1:
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => userHomeScreen(uname: uname)),
              );
              break;
            case 2:
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => chat(
                          uname: uname,
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
      drawer: Drawer(
        child: ListView(
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Color.fromRGBO(61, 133, 3, 1),
              ),
              child: Padding(
                padding: EdgeInsets.only(bottom: 16.0),
                child: Image.network(
                  'assets/logo.jpg',
                  height: 80.0,
                ),
              ),
            ),
            ListTile(
              leading: FaIcon(
                FontAwesomeIcons.home,
                color: Color.fromRGBO(29, 133, 3, 1),
              ),
              title: Text(
                'Produk Kami',
                style: TextStyle(
                  color: Color.fromRGBO(61, 133, 3, 1),
                ),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => userHomeScreen(uname: uname)),
                );
              },
            ),
            Divider(
              color: Color.fromRGBO(29, 133, 3, 1),
              thickness: 0.5,
            ),
            ListTile(
              leading: FaIcon(
                FontAwesomeIcons.circleInfo,
                color: Color.fromRGBO(29, 133, 3, 1),
              ),
              title: Text(
                'Tentang Kami',
                style: TextStyle(
                  color: Color.fromRGBO(61, 133, 3, 1),
                ),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => tentangKami(
                            username: uname,
                          )),
                );
              },
            ),
            Divider(
              color: Color.fromRGBO(29, 133, 3, 1),
              thickness: 0.5,
            ),
            ListTile(
              leading: FaIcon(
                FontAwesomeIcons.message,
                color: Color.fromRGBO(29, 133, 3, 1),
              ),
              title: Text(
                'Hubungi Kami',
                style: TextStyle(
                  color: Color.fromRGBO(61, 133, 3, 1),
                ),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => chat(uname: uname)),
                );
              },
            ),
            Divider(
              color: Color.fromRGBO(29, 133, 3, 1),
              thickness: 0.5,
            ),
            ListTile(
              leading: FaIcon(
                FontAwesomeIcons.rightFromBracket,
                color: Color.fromRGBO(29, 133, 3, 1),
              ),
              title: Text(
                'Logout',
                style: TextStyle(
                  color: Color.fromRGBO(61, 133, 3, 1),
                ),
              ),
              onTap: () {
                logout(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}
