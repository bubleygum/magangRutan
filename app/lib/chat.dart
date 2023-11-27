import 'dart:async';
import 'package:app/wishlist.dart';
import 'package:app/home.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:app/notification_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class chat extends StatefulWidget {
  final String uname;
  final String status;
  final String product;
  const chat(
      {required this.uname,
      required this.status,
      required this.product,
      Key? key})
      : super(key: key);

  @override
  _ChatState createState() => _ChatState();
}

class _ChatState extends State<chat> {
  final TextEditingController _chatController = TextEditingController();
  List<FAQ> faqList = [];
  List<ChatMessage> chatHistory = [];
  List<bool> dropdownStates = [];
  DateTime currentTime = DateTime.now();
  bool isLoading = false;
  String noWA = "";
  late Timer timer;
  bool hasSelectedRep = false;
  @override
  void initState() {
    super.initState();
    // checkSelectedRep();
    getUserData();
    // fetchCabRep();
    fetchFAQs();
    fetchChatHistory();
    startChatHistoryPolling();
  }

  @override
  void dispose() {
    stopChatHistoryPolling();
    super.dispose();
  }

  void _navigateToChatPage() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => chat(
          uname: widget.uname,
          status: widget.status,
          product: "false",
        ),
      ),
    );
  }

  Future<void> checkSelectedRep() async {
    final response = await http.post(Uri.parse('http://localhost/userCS.php'),
        body: {'check': "true", 'uId': userData['UserId']});
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      print(data);
      if (data['success']) {
        setState(() {
          hasSelectedRep = true;
        });
      } else {
        setState(() {
          hasSelectedRep = false;
        });
      }
    } else {
      throw Exception('Failed to fetch list data');
    }
  }

  Map<String, dynamic> userData = {};
  Future<void> getUserData() async {
    print("uname" + widget.uname);
    final response = await http.post(
        Uri.parse('http://localhost/getUserData.php'),
        body: {'username': widget.uname});
    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
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

  List<Map<String, dynamic>> repList = [];
  Future<void> fetchCabRep() async {
    final response = await http.post(Uri.parse('http://localhost/userCS.php'),
        body: {'fetch': "true"});
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      print(data);
      if (data['success']) {
        setState(() {
          repList = List<Map<String, dynamic>>.from(data['data']);
        });
      }
    } else {
      throw Exception('Failed to fetch wishlist data');
    }
  }

  Future<void> selectCabRep(String repId) async {
    final response = await http.post(Uri.parse('http://localhost/userCS.php'),
        body: {'selected': "true", 'uId': userData['UserId'], 'repId': repId});
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['success']) {
        setState(() {
          hasSelectedRep = true;
        });
        _navigateToChatPage();
      } else {
        throw Exception('Failed to select cabrep');
      }
    } else {
      throw Exception('Failed to fetch cabrep data');
    }
  }

  void fetchFAQs() async {
    var url = Uri.parse('http://localhost/faq.php');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['success']) {
        List<FAQ> faqs = [];
        List<bool> states = [];
        for (var faqData in data['data']) {
          FAQ faq = FAQ(
            id: faqData['IdFaq'],
            question: faqData['Ask'],
            answer: faqData['Question'],
          );
          faqs.add(faq);
          states.add(false);
        }
        setState(() {
          faqList = faqs;
          dropdownStates = states;
        });
      }
    } else {
      print('Request failed with status: ${response.statusCode}');
    }
  }

  void fetchChatHistory() async {
    setState(() {
      isLoading = true;
    });
    // print("chat Hist " + userData["UserId"]);
    if (userData['UserId'] == null) {
      print("User data kosong :(");
    } else {
      var url = Uri.parse('http://localhost/chat.php');
      final response = await http.post(url, body: {
        'uId': userData["UserId"],
        'userStat': userData["StatusUser"]
      });
      // print(jsonDecode(response.body));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success']) {
          if (data.containsKey('data')) {
            List<ChatMessage> history = [];
            for (var chatData in data['data']) {
              ChatMessage message = ChatMessage(
                message: chatData['Message'],
                time: chatData['TimeSend'],
                sender: chatData['Sender'],
              );
              history.add(message);
            }
            setState(() {
              chatHistory = history;
              isLoading = false;
            });
          }
        } else {
          print('RequestAAA failed: ${data['message']}');
          setState(() {
            isLoading = false;
          });
        }
      } else {
        print('Request failed with status: ${response.statusCode}');
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  void startChatHistoryPolling() {
    const pollInterval = Duration(seconds: 10);
    timer = Timer.periodic(pollInterval, (Timer timer) {
      fetchChatHistory();
    });
  }

  void stopChatHistoryPolling() {
    timer.cancel();
  }

  Future<void> sendFAQAnalytics(FAQ faq) async {
    var url = Uri.parse('http://localhost/faq.php');
    var response = await http.post(url, body: {
      'faqId': faq.id.toString(),
      'userId': userData['UserId'],
      'timeView': currentTime.toString(),
    });

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      if (jsonData['success']) {
        print(jsonData['success']);
      } else {
        print(jsonData['message']);
      }
    } else {
      throw Exception('Failed to send FAQ analytic');
    }
  }

  // void showNotification(String message, String sender) {
  //   final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  //   const AndroidNotificationDetails androidPlatformChannelSpecifics =
  //       AndroidNotificationDetails(
  //     '1',
  //     'test',
  //     'test',
  //     importance: Importance.max,
  //     priority: Priority.high,
  //   );
  //   const IOSNotificationDetails iOSPlatformChannelSpecifics =
  //       IOSNotificationDetails();
  //   const NotificationDetails platformChannelSpecifics = NotificationDetails(
  //       android: androidPlatformChannelSpecifics,
  //       iOS: iOSPlatformChannelSpecifics);
  //   String notificationTitle = sender == widget.uname ? 'You' : sender;
  //   String notificationBody = message;

  //   flutterLocalNotificationsPlugin.show(
  //     0,
  //     notificationTitle,
  //     notificationBody,
  //     platformChannelSpecifics,
  //     payload: 'additional_data_here',
  //   );
  // }

  void sendMessage(String message, String sender) async {
    var url = Uri.parse('http://localhost/chat.php');
    final response = await http.post(url, body: {
      'uId': userData["UserId"],
      'message': message,
      'time': currentTime.toString(),
      'sender': sender,
    });

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['success']) {
        print("Message sent");
        // showNotification(message, sender);
      }
    } else {
      print('Request failed with status: ${response.statusCode}');
    }
  }

  void getWA() async {
    var url = Uri.parse('http://localhost/chat.php');
    final response = await http.post(url, body: {
      'uId': userData["UserId"],
      'getWA': "true",
    });
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['success']) {
        final whatsappNumbers = data['data'];
        if (whatsappNumbers.isNotEmpty) {
          final hp = whatsappNumbers[0]['hp'].toString();
          final url = "https://wa.me/$hp";
          launch(url);
        }
      }
    } else {
      print('Request failed with status: ${response.statusCode}');
    }
  }

  bool isButtonDisabled = false;
  void hubungiKamiBtn() async {
    //     // setState(() {
//     //   isButtonDisabled = true;
//     // });
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Hubungi dengan'),
          actions: <Widget>[
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                sendMessage("Chat", widget.uname);
                const Duration(seconds: 5);
                sendMessage(
                    "Baik, sales kami akan segera melayani anda", "admin");
              },
              child: Text('Chat'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                sendMessage("Call", widget.uname);
                getWA();
              },
              child: Text('Call'),
            ),
          ],
        );
      },
    );
  }

  void navigateToFAQDetail(FAQ faq) {
    // Navigator.push(
    //   context,
    //   MaterialPageRoute(
    //     builder: (context) => FAQDetailPage(faq: faq),
    //   ),
    // );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.product != "false") {
      sendMessage("Saya mau bertanya mengenai, Product: ${widget.product}",
          widget.uname);
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Sales",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 4,
        iconTheme: IconThemeData(
          color: Color.fromRGBO(61, 133, 3, 1),
        ),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Expanded(
            child: isLoading
                ? Center(
                    child: CircularProgressIndicator(),
                  )
                : ListView.builder(
                    itemCount: chatHistory.length,
                    itemBuilder: (context, index) {
                      final message = chatHistory[index];
                      final isCurrentUser = message.sender == widget.uname;
                      return Align(
                        alignment: isCurrentUser
                            ? Alignment.topRight
                            : Alignment.topLeft,
                        child: Container(
                          margin: EdgeInsets.symmetric(
                              vertical: 4.0, horizontal: 8.0),
                          padding: EdgeInsets.all(8.0),
                          decoration: BoxDecoration(
                            color: isCurrentUser
                                ? Color.fromRGBO(0, 166, 82, 1)
                                : Color.fromRGBO(240, 240, 240, 1),
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          child: Text(
                            message.message,
                            style: TextStyle(
                              fontSize: 15,
                              color:
                                  isCurrentUser ? Colors.white : Colors.black,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 6,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Divider(
                    color: Color.fromRGBO(29, 133, 3, 1),
                    thickness: 2.0,
                  ),
                  SizedBox(height: 8.0),
                  CarouselSlider(
                    options: CarouselOptions(
                      height: 200.0,
                      autoPlay: true,
                      autoPlayInterval: Duration(seconds: 3),
                      autoPlayAnimationDuration: Duration(milliseconds: 800),
                      autoPlayCurve: Curves.fastOutSlowIn,
                      aspectRatio: 2.0,
                      onPageChanged: (index, reason) {},
                    ),
                    items: faqList.map((faq) {
                      return Builder(
                        builder: (BuildContext context) {
                          return GestureDetector(
                            onTap: () {
                              sendFAQAnalytics(faq);
                              // navigateToFAQDetail(faq);
                            },
                            child: Card(
                              margin: EdgeInsets.symmetric(horizontal: 5.0),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              child: Container(
                                width: MediaQuery.of(context).size.width * 0.9,
                                padding: EdgeInsets.all(16.0),
                                child: Text(
                                  faq.question,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    }).toList(),
                  ),
                  SizedBox(height: 8.0),
                  Divider(
                    color: Color.fromRGBO(29, 133, 3, 1),
                    thickness: 2.0,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ElevatedButton(
                      onPressed: isButtonDisabled ? null : hubungiKamiBtn,
                      child: Text('Hubungkan dengan sales'),
                      style: ElevatedButton.styleFrom(
                        primary: Color.fromRGBO(29, 133, 3, 0.3),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    child: TextField(
                      controller: _chatController,
                      decoration: InputDecoration(
                        hintText: 'Type a message...',
                        filled: true,
                        fillColor: Color.fromRGBO(240, 240, 240, 1),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20.0),
                          borderSide: BorderSide(
                            color: Color.fromRGBO(240, 240, 240, 1),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Container(
                  margin: EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color.fromRGBO(29, 133, 3, 1),
                  ),
                  child: IconButton(
                    icon: Icon(
                      Icons.send,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      final message = _chatController.text.trim();
                      if (message.isNotEmpty) {
                        sendMessage(message, widget.uname);
                        _chatController.clear();
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      // bottomNavigationBar: BottomNavigationBar(
      //   type: BottomNavigationBarType.fixed,
      //   onTap: (int index) {
      //     switch (index) {
      //       case 0:
      //         Navigator.push(
      //           context,
      //           MaterialPageRoute(
      //               builder: (context) => wishlist(
      //                     username: widget.uname,
      //                     status: widget.status,
      //                   )),
      //         );
      //         break;
      //       case 1:
      //         Navigator.push(
      //           context,
      //           MaterialPageRoute(
      //               builder: (context) => userHomeScreen(
      //                     uname: widget.uname,
      //                     status: widget.status,
      //                   )),
      //         );
      //         break;
      //       case 2:
      //         Navigator.push(
      //           context,
      //           MaterialPageRoute(
      //               builder: (context) => chat(
      //                   uname: widget.uname,
      //                   status: widget.status,
      //                   product: "false")),
      //         );
      //         break;
      //     }
      //   },
      //   items: const <BottomNavigationBarItem>[
      //     BottomNavigationBarItem(
      //       icon: FaIcon(
      //         FontAwesomeIcons.heart,
      //         color: Color.fromRGBO(29, 133, 3, 1),
      //       ),
      //       label: '',
      //     ),
      //     BottomNavigationBarItem(
      //       icon: FaIcon(
      //         FontAwesomeIcons.home,
      //         color: Color.fromRGBO(29, 133, 3, 1),
      //       ),
      //       label: '',
      //     ),
      //     BottomNavigationBarItem(
      //       icon: FaIcon(
      //         FontAwesomeIcons.message,
      //         color: Color.fromRGBO(29, 133, 3, 1),
      //       ),
      //       label: '',
      //     ),
      //   ],
      // ),
    );
  }
}

class FAQ {
  final String id;
  final String question;
  final String answer;

  FAQ({
    required this.id,
    required this.question,
    required this.answer,
  });
}

class ChatMessage {
  final String message;
  final String time;
  final String sender;

  ChatMessage({
    required this.message,
    required this.time,
    required this.sender,
  });
}
