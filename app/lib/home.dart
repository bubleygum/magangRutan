import 'package:app/admin_home.dart';
import 'package:app/cs_chatList.dart';
import 'package:app/login.dart';
import 'package:app/notification_service.dart';
import 'package:app/notif.dart';
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
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:dots_indicator/dots_indicator.dart';
import 'package:app/wishlist.dart';

class userHomeScreen extends StatefulWidget {
  final String uname;
  final String status;
  userHomeScreen({required this.uname, required this.status, Key? key})
      : super(key: key);

  @override
  _HomeScreenState createState() =>
      _HomeScreenState(uname: uname, status: status);
}

class _HomeScreenState extends State<userHomeScreen> {
  final String uname;
  final String status;
  List<String> carouselImages = [];
  List<Map<String, dynamic>> buttonData = [];
  late PageController _pageController = PageController();
  CarouselController _carouselController = CarouselController();
  int _currentCarouselIndex = 0;
  int _selectedButtonIndex = 0;
  DateTime currentTime = DateTime.now();
  _HomeScreenState({required this.uname, required this.status, Key? key});
  List<String> wishlistData = [];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
    // fetchCarouselImages();
    fetchWishlistData(uname);
    getUserData();
    fetchBtn();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> fetchCarouselImages() async {
    final response =
        await http.get(Uri.parse('http://localhost/fetchCarousel.php'));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      print(jsonDecode(response.body));
      setState(() {
        carouselImages = List<String>.from(data['data']);
      });
    } else {
      throw Exception('Failed to fetch carousel images');
    }
  }

  Future<void> fetchBtn() async {
    try {
      final response =
          await http.get(Uri.parse('http://localhost/fetchKategori.php'));

      if (response.statusCode == 200) {
        try {
          final data = jsonDecode(response.body);
          if (data['data'] is List<dynamic>) {
            setState(() {
              buttonData = List<Map<String, dynamic>>.from(data['data']);
            });
          }
        } catch (error) {
          print('Error parsing JSON: $error');
        }
      } else {
        throw Exception('Failed to fetch btn data');
      }
    } catch (error) {
      print('Error fetching data: $error');
    }
  }

  Map<String, dynamic> userData = {};
  Future<void> getUserData() async {
    final response = await http.post(
        Uri.parse('http://localhost/getUserData.php'),
        body: {'username': uname});
    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
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

  Widget buildSmoothPageIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        for (int i = 0; i < carouselImages.length; i++)
          Container(
            width: 8.0,
            height: 8.0,
            margin: EdgeInsets.symmetric(vertical: 10.0, horizontal: 2.0),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: i == _currentCarouselIndex
                  ? Color.fromRGBO(61, 133, 3, 1)
                  : Colors.grey,
            ),
          ),
      ],
    );
  }

  Widget _buildRoundedButton(String label, int index) {
    bool isSelected = index == _selectedButtonIndex;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25.0),
        color: isSelected ? Color.fromRGBO(249, 206, 6, 1) : Colors.white,
      ),
      child: ElevatedButton(
        onPressed: () {
          // Handle button click
          setState(() {
            _selectedButtonIndex = index;
          });
        },
        style: ElevatedButton.styleFrom(
          primary: Colors.transparent,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25.0),
            side: BorderSide(
              color: Color.fromRGBO(179, 192, 212, 1),
              width: 1.0,
            ),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.black : Colors.black,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Future<void> fetchWishlistData(String userId) async {
    final response = await http.post(
      Uri.parse('http://localhost/wishlist.php'),
      body: {'uId': userId},
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['success']) {
        setState(() {
          wishlistData = List<String>.from(data['data']);
        });
      }
    } else {
      throw Exception('Failed to fetch wishlist data');
    }
  }

  Future<void> addRemWishlist(String prodName, String? picUrl) async {
    try {
      var url = Uri.parse('http://localhost/prodDetail.php');
      var queryParameters = {
        'uId': userData["UserId"],
        'addCode': prodName,
        'addTime': currentTime.toString(),
        'picUrl': picUrl,
      };
      var response = await http.post(url, body: queryParameters);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success']) {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                content: Text('Item added to wishlist!'),
                actions: <Widget>[
                  TextButton(
                    child: Text('OK'),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              );
            },
          );
        } else {
          if (wishlistData.contains(prodName)) {
            await removeFromWishlist(prodName);
          } else {
            throw Exception('Failed to add item to wishlist');
          }
        }
      } else {
        throw Exception('Request failed with status: ${response.statusCode}');
      }
    } catch (error) {
      print('Error sending request: $error');
    }
  }

  Future<void> removeFromWishlist(String prodName) async {
    try {
      var url = Uri.parse('http://localhost/wishlist.php');
      var queryParameters = {
        'uId': userData["UserId"],
        'remove_id': prodName,
      };
      var response = await http.post(url, body: queryParameters);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success']) {
          // Remove the product from the local wishlist data
          setState(() {
            wishlistData.remove(prodName);
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
    final screenHeight = MediaQuery.of(context).size.height;
    final carouselHeight = screenHeight * 0.2;
    const EdgeInsets pagePadding = EdgeInsets.all(16.0);
    final cardHeight = screenHeight * 0.2378;
    return Scaffold(
      appBar: AppBar(
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
              icon: Icon(Icons.menu),
              color: Colors.black,
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            );
          },
        ),
        actions: [
          IconButton(
            icon: FaIcon(
              FontAwesomeIcons.solidEnvelope,
              color: Colors.black,
            ),
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
      body: SingleChildScrollView(
        child: Padding(
          padding: pagePadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              SizedBox(
                height: 5,
              ),
              // if (carouselImages.isNotEmpty)
              //   CarouselSlider(
              //     carouselController: _carouselController,
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
              //       onPageChanged: (index, reason) {
              //         setState(() {
              //           _currentCarouselIndex = index;
              //         });
              //       },
              //     ),
              //   ),
              SizedBox(
                height: 20,
              ),
              buildSmoothPageIndicator(),
              Row(
                children: <Widget>[
                  Expanded(
                    child: Text(
                      'Categories',
                      textAlign: TextAlign.start,
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      // Navigator.push(
                      //   context,
                      //   MaterialPageRoute(
                      //     builder: (context) => YourSeeAllScreen(),
                      //   ),
                      // );
                    },
                    child: Text(
                      'See all',
                      textAlign: TextAlign.end,
                      style: TextStyle(
                          color: Color.fromRGBO(61, 133, 3, 1),
                          fontWeight: FontWeight.w500,
                          fontSize: 14),
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 10,
              ),
              Container(
                height: 100,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: buttonData.length,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () {
                        if (buttonData[index]['IdKategori'] != null) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => prodList(
                                data:
                                    buttonData[index]['IdKategori']!.toString(),
                                uname: uname,
                                status: status,
                              ),
                            ),
                          );
                        }
                      },
                      child: Container(
                        margin: EdgeInsets.all(8.0),
                        child: Column(
                          children: [
                            CircleAvatar(
                              radius: 30,
                              backgroundImage: NetworkImage(
                                buttonData[index]['imgKategori']!,
                              ),
                            ),
                            SizedBox(height: 5),
                            Text(
                              buttonData[index]['NamaKategori']!,
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              Text(
                "Featured Product",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              Row(
                children: <Widget>[
                  Expanded(
                    child: Container(
                      height: 45,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Color.fromRGBO(179, 192, 212, 1),
                        ),
                        borderRadius: BorderRadius.circular(25.0),
                      ),
                      child: TextField(
                        decoration: InputDecoration(
                          prefixIcon: Icon(Icons.search),
                          hintText: "Search...",
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 20.0, vertical: 15.0),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 10),
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.green,
                    ),
                    child: IconButton(
                      icon: Icon(Icons.filter_list, color: Colors.white),
                      onPressed: () {
                        // Add filter functionality here
                      },
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  _buildRoundedButton("All", 0),
                  _buildRoundedButton("Newest", 1),
                  _buildRoundedButton("Best Sellers", 2),
                  _buildRoundedButton("Promo", 3),
                ],
              ),
              SizedBox(height: 20),
              GridView.count(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                children: List.generate(buttonData.length, (index) {
                  final productName = buttonData[index]['NamaKategori']!;
                  final isProductInWishlist =
                      wishlistData.contains(productName);
                  return GestureDetector(
                    child: Stack(
                      children: [
                        Card(
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                            side: BorderSide(
                              color: Color.fromRGBO(179, 192, 212, 1),
                              width: 1.0,
                            ),
                          ),
                          child: Column(
                            children: [
                              Container(
                                padding: EdgeInsets.all(8.0),
                                child: Align(
                                  alignment: Alignment.topRight,
                                  child: GestureDetector(
                                    onTap: () {
                                      // Handle heart icon click here
                                      addRemWishlist(productName,
                                          buttonData[index]['imgKategori']);
                                    },
                                    child: Icon(
                                      isProductInWishlist
                                          ? Icons.favorite
                                          : Icons.favorite_border,
                                      color: Color.fromRGBO(179, 192, 212, 1),
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Opacity(
                                  opacity: 0.5,
                                  child: Image.network(
                                    buttonData[index]['imgKategori']!,
                                  ),
                                ),
                              ),
                              Text(
                                productName,
                                style: TextStyle(
                                  color: Color.fromRGBO(0, 166, 82, 1),
                                  fontSize: 20,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    onTap: () {
                      if (buttonData[index]['IdKategori'] != null) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => prodList(
                              data: buttonData[index]['IdKategori']!.toString(),
                              uname: uname,
                              status: status,
                            ),
                          ),
                        );
                      }
                    },
                  );
                }),
              )
            ],
          ),
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
                    builder: (context) => userHomeScreen(
                          uname: uname,
                          status: status,
                        )),
              );
              break;
            case 1:
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => wishlist(
                          username: uname,
                          status: status,
                        )),
              );
              break;
            case 2:
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        chat(uname: uname, status: status, product: "false")),
              );
              break;
            case 3:
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        chat(uname: uname, status: status, product: "false")),
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
            label: '',
          ),
          BottomNavigationBarItem(
            icon: FaIcon(
              FontAwesomeIcons.heart,
              color: Color.fromRGBO(179, 192, 212, 1),
            ),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: FaIcon(
              FontAwesomeIcons.motorcycle,
              color: Color.fromRGBO(179, 192, 212, 1),
            ),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: FaIcon(
              FontAwesomeIcons.solidUser,
              color: Color.fromRGBO(179, 192, 212, 1),
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
                      builder: (context) => userHomeScreen(
                            uname: uname,
                            status: status,
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
                            status: status,
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
                  MaterialPageRoute(
                      builder: (context) =>
                          chat(uname: uname, status: status, product: "false")),
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
            //admin

            Divider(
              color: Color.fromRGBO(29, 133, 3, 1),
              thickness: 0.5,
            ),
            Visibility(
              visible: status == "1",
              child: ListTile(
                leading: FaIcon(
                  FontAwesomeIcons.rightFromBracket,
                  color: Color.fromRGBO(29, 133, 3, 1),
                ),
                title: Text(
                  'Admin Dashboard',
                  style: TextStyle(
                    color: Color.fromRGBO(61, 133, 3, 1),
                  ),
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => adminHome(
                              username: uname,
                            )),
                  );
                },
              ),
            ),
            Visibility(
              visible: status == "2",
              child: ListTile(
                leading: FaIcon(
                  FontAwesomeIcons.rightFromBracket,
                  color: Color.fromRGBO(29, 133, 3, 1),
                ),
                title: Text(
                  'Cust Service Chat',
                  style: TextStyle(
                    color: Color.fromRGBO(61, 133, 3, 1),
                  ),
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => csChatList(
                              username: uname,
                            )),
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}
