import 'dart:async';
import 'package:app/wishlist.dart';
import 'package:app/home.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class chat extends StatefulWidget {
  final String username;

  const chat({required this.username, Key? key}) : super(key: key);

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

  @override
  void initState() {
    super.initState();
    fetchFAQs();
    fetchChatHistory();
    startChatHistoryPolling();
  }

  @override
  void dispose() {
    stopChatHistoryPolling();
    super.dispose();
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

    var url = Uri.parse('http://localhost/chat.php');
    final response = await http.post(url, body: {'username': widget.username});

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
        print('Request failed: ${data['message']}');
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

  void startChatHistoryPolling() {
    const pollInterval = Duration(seconds: 5); // Poll every 5 seconds
    timer = Timer.periodic(pollInterval, (Timer timer) {
      fetchChatHistory();
    });
  }

  void stopChatHistoryPolling() {
    timer.cancel();
  }

  void sendFAQAnalytics(int faqId) {}

  void sendMessage(String message, String sender) async {
    var url = Uri.parse('http://localhost/chat.php');
    final response = await http.post(url, body: {
      'username': widget.username,
      'message': message,
      'time': currentTime.toString(),
      'sender': sender,
    });

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['success']) {
        print("Message sent");
      }
    } else {
      print('Request failed with status: ${response.statusCode}');
    }
  }

void getWA() async {
  var url = Uri.parse('http://localhost/chat.php');
  final response = await http.post(url, body: {
    'username': widget.username,
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
              sendMessage("Baik, sales kami akan segera melayani anda", "admin");
              sendMessage("Chat", widget.username);
            },
            child: Text('Chat'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              sendMessage("Call", widget.username);
              getWA(); // Call the getWA function
            },
            child: Text('Call'),
          ),
        ],
      );
    },
  );
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Chat",
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
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Align(
              alignment: Alignment.topLeft,
              child: FractionallySizedBox(
                widthFactor: 0.65,
                child: Container(
                  decoration: BoxDecoration(
                    color: Color.fromRGBO(29, 133, 3, 0.3),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  padding: EdgeInsets.all(8.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Text(
                          'FAQ',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Color.fromRGBO(29, 133, 3, 1),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      SizedBox(height: 8.0),
                      Divider(
                        color: Color.fromRGBO(29, 133, 3, 1),
                        thickness: 2.0,
                      ),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: faqList.length,
                        itemBuilder: (context, index) {
                          final faq = faqList[index];
                          final dropdownState = dropdownStates[index];
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    dropdownStates[index] = !dropdownState;
                                  });
                                },
                                child: Container(
                                  color: dropdownState ? Color.fromRGBO(255, 255, 255, 0.5) : null,
                                  child: Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Text(
                                      faq.question,
                                      style: TextStyle(
                                          color: Color.fromRGBO(29, 133, 3, 1),
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ),
                              ),
                              if (dropdownState)
                                Container(
                                  padding: EdgeInsets.all(8.0),
                                  child: Text(
                                    faq.answer,
                                    style: TextStyle(
                                      color: Color.fromRGBO(29, 133, 3, 1),
                                    ),
                                  ),
                                ),
                              SizedBox(height: 8.0),
                              Divider(
                                color: Color.fromRGBO(29, 133, 3, 1),
                                thickness: 1.0,
                              ),
                            ],
                          );
                        },
                      ),
                      Center(
                        child: ElevatedButton(
                          onPressed: isButtonDisabled ? null : hubungiKamiBtn,
                          child: Text('Hubungkan dengan sales'),
                          style: ElevatedButton.styleFrom(
                          primary: Color.fromRGBO(29, 133, 3, 0.3),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(0),
                          ),
                        ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: isLoading
                ? Center(
                    child: CircularProgressIndicator(),
                  )
                : ListView.builder(
                    itemCount: chatHistory.length,
                    itemBuilder: (context, index) {
                      final message = chatHistory[index];
                      final isCurrentUser = message.sender == widget.username;
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
                                ? Color.fromRGBO(29, 133, 3, 1)
                                : Color.fromRGBO(29, 133, 3, 0.3),
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          child: Text(
                            message.message,
                            style: TextStyle(
                              fontSize: 15,
                              color: isCurrentUser
                                  ? Colors.white
                                  : Color.fromRGBO(29, 133, 3, 1),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _chatController,
                    decoration: InputDecoration(
                      hintText: 'Type a message...',
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(
                    Icons.send,
                    color: Color.fromRGBO(29, 133, 3, 1),
                  ),
                  onPressed: () {
                    final message = _chatController.text.trim();
                    if (message.isNotEmpty) {
                      sendMessage(message, widget.username);
                      _chatController.clear();
                    }
                  },
                ),
              ],
            ),
          ),
        ],
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
