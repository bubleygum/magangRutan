import 'package:app/chat.dart';
import 'package:app/home.dart';
import 'package:app/wishlist.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class prodDetail extends StatefulWidget {
  final String data;
  final String uname;
  final String status;
  const prodDetail(
      {required this.data, required this.uname, required this.status, Key? key})
      : super(key: key);

  @override
  State<prodDetail> createState() => prodDetailState();
}

class prodDetailState extends State<prodDetail> {
  Map<String, dynamic> prodData = {};
  DateTime currentTime = DateTime.now();

  @override
  void initState() {
    super.initState();
    fetchData();
    getUserData();
  }

  Map<String, dynamic> userData = {};
  Future<void> getUserData() async {
    final response = await http.post(
      Uri.parse('http://localhost/getUserData.php'),
      body: {'username': widget.uname},
    );
    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      print(jsonData);
      if (jsonData['success']) {
        if (jsonData.containsKey('data') &&
            jsonData['data'] is List &&
            jsonData['data'].length > 0) {
          var data = jsonData['data'][0];
          setState(() {
            userData = Map<String, dynamic>.from(data);
          });
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

  void fetchData() async {
    var url = Uri.parse('http://localhost/prodDetail.php');
    var queryParameters = {'prodCode': widget.data};

    try {
      var response = await http.post(url, body: queryParameters);

      if (response.statusCode == 200) {
        var jsonData = json.decode(response.body);

        if (jsonData['success']) {
          var data = jsonData['data'];

          setState(() {
            prodData = data;
          });
        } else {
          print(jsonData['message']);
        }
      } else {
        print('Request failed with status: ${response.statusCode}');
      }
    } catch (error) {
      print('Error sending request: $error');
    }
  }

  Future<void> addToWishlist(String prodName, String? picUrl) async {
    var url = Uri.parse('http://localhost/prodDetail.php');
    var queryParameters = {
      'uId': userData["UserId"],
      'addCode': prodName,
      'addTime': currentTime.toString(),
      'picUrl': picUrl,
    };

    try {
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
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                content: Text('Item sudah ada di wishlist!'),
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
        }
      } else {
        throw Exception('Request failed with status: ${response.statusCode}');
      }
    } catch (error) {
      print('Error sending request: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<dynamic> photos = prodData['photos'] ?? [];
    final prodName = prodData['ProdName'] ?? '';
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Text(
            "Detail Produk",
            style: TextStyle(
              color: Colors.black,
            ),
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 4,
        iconTheme: IconThemeData(
          color: Colors.black,
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.favorite,
              color: Color.fromRGBO(29, 133, 3, 1),
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => wishlist(
                          username: widget.uname,
                          status: widget.status,
                        )),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        //   child: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              SizedBox(
                height: 20,
              ),
              if (photos.isNotEmpty)
                CarouselSlider(
                  options: CarouselOptions(
                    height: 250,
                    autoPlay: true,
                  ),
                  items: photos.asMap().entries.map<Widget>((entry) {
                    final index = entry.key;
                    final photo = entry.value;
                    final picUrl = photo['UrlPhoto'];
                    return Builder(
                      builder: (BuildContext context) {
                        return Stack(
                          children: [
                            Image.network(
                              picUrl,
                              fit: BoxFit.cover,
                            ),
                            Positioned(
                              bottom: 8,
                              right: 8,
                              child: Container(
                                padding: EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.6),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  '${index + 1}',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    );
                  }).toList(),
                ),
              SizedBox(
                height: 20,
              ),
              Text(
                prodName,
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
              Text(
                "Harga",
                style: TextStyle(
                  color: Color.fromRGBO(61, 133, 3, 1),
                  fontSize: 20,
                ),
              ),
              SizedBox(
                height: 20,
              ),
              RichText(
                textAlign: TextAlign.start,
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: 'Deskripsi Produk',
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight:
                            FontWeight.bold, 
                      ),
                    ),
                    TextSpan(
                      text: '\n${prodData['Description']}',
                      style: TextStyle(
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 20,
              ),
              Column(
                children: [
                  Container(
                    // width: double.infinity,
                    // width: btnWidth,
                    child: ElevatedButton(
                      onPressed: () async {
                        await addToWishlist(
                          prodName,
                          photos.isNotEmpty ? photos[0]['UrlPhoto'] : null,
                        );
                      },
                      child: Text(
                        "Masukkan ke Wishlist",
                        style: TextStyle(fontSize: 15),
                      ),
                      style: ElevatedButton.styleFrom(
                        primary: Color.fromRGBO(29, 133, 3, 1),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(0),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Container(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => chat(
                                  uname: widget.uname,
                                  status: widget.status,
                                  product: prodData['ProdCode'])),
                        );
                      },
                      child: Text(
                        "Hubungi Sales Kami",
                        style: TextStyle(fontSize: 15),
                      ),
                      style: ElevatedButton.styleFrom(
                        primary: Color.fromRGBO(29, 133, 3, 1),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(0),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      // ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        onTap: (int index) {
          switch (index) {
            case 0:
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => wishlist(
                          username: widget.uname,
                          status: widget.status,
                        )),
              );
              break;
            case 1:
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => userHomeScreen(
                          uname: widget.uname,
                          status: widget.status,
                        )),
              );
              break;
            case 2:
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => chat(
                        uname: widget.uname,
                        status: widget.status,
                        product: "false")),
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
