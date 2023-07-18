import 'package:app/chat.dart';
import 'package:app/home.dart';
import 'package:app/tentangKami.dart';
import 'package:app/wishlist.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class prodDetail extends StatefulWidget {
  final String data;
  final String username;

  const prodDetail({required this.data, required this.username, Key? key})
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
      'username': widget.username,
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
    final prodName = prodData['ProdName'];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          prodName,
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
                          username: widget.username,
                        )),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                SizedBox(
                  height: 20,
                ),
                Text(
                  prodName,
                  style: TextStyle(
                    color: Color.fromRGBO(61, 133, 3, 1),
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                if (photos.isNotEmpty)
                  CarouselSlider(
                    options: CarouselOptions(
                      height: 200,
                      autoPlay: true,
                    ),
                    items: photos.map<Widget>((photo) {
                      final picUrl = photo['UrlPhoto'];
                      return Builder(
                        builder: (BuildContext context) {
                          return Image.network(
                            picUrl,
                            fit: BoxFit.cover,
                          );
                        },
                      );
                    }).toList(),
                  ),
                SizedBox(
                  height: 20,
                ),
                // Text(
                //   "Deskripsi",
                //   style: TextStyle(
                //     color: Color.fromRGBO(29, 133, 3, 1),
                //     fontSize: 20,
                //     fontWeight: FontWeight.bold,
                //   ),
                // ),
                Center(
                  child: RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      text: '${prodData['Description']}',
                      style: TextStyle(
                        color: Color.fromRGBO(29, 133, 3, 1),
                        fontSize: 20,
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                Column(
                  children: [
                    Container(
                      width: double.infinity,
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
                                      username: widget.username,
                                    )),
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
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        onTap: (int index) {
          switch (index) {
            case 0:
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => wishlist(username: widget.username)),
              );
              break;
            case 1:
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => Home(username: widget.username)),
              );
              break;
            case 2:
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => chat(
                          username: widget.username,
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