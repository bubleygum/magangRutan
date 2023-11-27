import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class admin_chat extends StatefulWidget {
  final String idChatRep;
  final String uname;
  final String custId;
  const admin_chat(
      {required this.idChatRep,
      required this.uname,
      required this.custId,
      Key? key})
      : super(key: key);

  @override
  admin_chatState createState() => admin_chatState();
}

class admin_chatState extends State<admin_chat> {
  final TextEditingController _chatController = TextEditingController();
  List<ChatMessage> chatHistory = [];
  DateTime currentTime = DateTime.now();
  bool isLoading = false;
  late Timer timer;
  String userId = "";
  @override
  void initState() {
    super.initState();
    initializeData();
  }

  Future<void> initializeData() async {
    await getUserData();
    fetchChatHistory();
    startChatHistoryPolling();
    test();
  }

  @override
  void dispose() {
    stopChatHistoryPolling();
    super.dispose();
  }

  Future<void> test() async {
    print(widget.idChatRep);
    print(widget.custId);
  }

  Map<String, dynamic> userData = {};
  Future<void> getUserData() async {
    // print("here" + uname);
    final response = await http.post(
        Uri.parse('http://localhost/getUserData.php'),
        body: {'username': widget.uname});
    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      // print(response.body);

      if (jsonData['success']) {
        var data = jsonData['data'];
        setState(() {
          userData = jsonData;
          userId = jsonData['data'][0]['UserId'].toString();
          // print(userId);
        });
      } else {
        print(jsonData['message']);
      }
    } else {
      throw Exception('Failed to fetch user data');
    }
  }

  void fetchChatHistory() async {
    setState(() {
      isLoading = true;
    });

    var url = Uri.parse('http://localhost/adminChat.php');
    final response = await http.post(url,
        body: {'custId': widget.custId, 'idCabRep': widget.idChatRep});
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

  void startChatHistoryPolling() {
    const pollInterval = Duration(seconds: 10);
    timer = Timer.periodic(pollInterval, (Timer timer) {
      fetchChatHistory();
    });
  }

  void stopChatHistoryPolling() {
    timer.cancel();
  }

  void sendMessage(String message, String sender) async {
    var url = Uri.parse('http://localhost/adminChat.php');
    print(userId);
    final response = await http.post(url, body: {
      'custId': widget.custId,
      'idCabRep': widget.idChatRep,
      'message': message,
      'time': currentTime.toString(),
      'sender': sender,
      'salesId': userId
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
          Expanded(
            child: isLoading
                ? Center(
                    child: CircularProgressIndicator(),
                  )
                : ListView.builder(
                    itemCount: chatHistory.length,
                    itemBuilder: (context, index) {
                      final message = chatHistory[index];
                      final isCurrentUser = message.sender == "admin";
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
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
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
                      if (message.isNotEmpty && userId.isNotEmpty) {
                        sendMessage(message, "admin");
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
    );
  }
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
