import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:app/admin_chatList.dart';
import 'package:app/listCS.dart';
import 'package:app/notif.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:app/login.dart';

class editProfile extends StatefulWidget {
  final String username;
  final String status;
  const editProfile({required this.username, required this.status, Key? key})
      : super(key: key);

  @override
  editProfileState createState() =>
      editProfileState(uname: username, status: status);
}

class editProfileState extends State<editProfile> {
  final String uname;
  final String status;
  editProfileState({required this.uname, required this.status});
  Map<String, dynamic> userData = {};
  String? userId;
  String? email;
  String? phoneNumber;
  TextEditingController namaCont = TextEditingController();
  TextEditingController emailCont = TextEditingController();
  TextEditingController phoneCont = TextEditingController();
  TextEditingController oldPassCont = TextEditingController();
  TextEditingController newPassCont = TextEditingController();
  TextEditingController comNewPassCont = TextEditingController();
  bool showOldPass = true;
  bool showNewPass = true;
  bool showComNewPass = true;
  @override
  void initState() {
    super.initState();
    getUserData();
  }

  Future<void> getUserData() async {
    // print("here" + uname);
    final response = await http.post(
        Uri.parse('http://localhost/getUserData.php'),
        body: {'username': uname});
    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      // print(response.body);

      if (jsonData['success']) {
        var data = jsonData['data'];
        setState(() {
          userData = jsonData;
          userId = jsonData['data'][0]['UserId'].toString();
          email = jsonData['data'][0]['Email'].toString();
          phoneNumber = jsonData['data'][0]['Hp'].toString();
        });
      } else {
        print(jsonData['message']);
      }
    } else {
      throw Exception('Failed to fetch user data');
    }
  }

  void showAlert(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Alert"),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("OK"),
            ),
          ],
        );
      },
    );
  }

  void saveData(
    String name,
    String? email,
    String? phone,
    String? oldPass,
    String? newPass,
  ) async {
    print('name: $name, email: $email, phone: $phone, oldPass: $oldPass, newPass: $newPass');
    if (name.isEmpty ||
        email == null ||
        email.isEmpty ||
        phone == null ||
        phone.isEmpty) {
      showAlert("Name, Email, and Phone Number cannot be empty.");
      return;
    }

    if (oldPass != null &&
        newPass != null &&
        oldPass.isNotEmpty &&
        newPass.isNotEmpty &&
        comNewPassCont.text.isNotEmpty) {
      if (newPassCont.text == comNewPassCont.text) {
        final response = await http.post(
          Uri.parse('http://localhost/editProfile.php'),
          body: {
            'uId': userId!,
            'nama': name,
            'email': email,
            'noHP': phone,
            'oldPass': oldPass,
            'newPass': newPass,
          },
        );

        if (response.statusCode == 200) {
          final jsonData = jsonDecode(response.body);

          if (jsonData['success']) {
            showAlert("Data saved successfully!");
          } else {
            showAlert(jsonData['message']);
          }
        } else {
          throw Exception('Failed to save user data');
        }
      } else {
        showAlert("New Password and Confirm New Password do not match.");
      }
    } else {
      final response = await http.post(
        Uri.parse('http://localhost/editProfile.php'),
        body: {
          'uId': userId!,
          'nama': name,
          'email': email,
          'noHP': phone,
        },
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);

        if (jsonData['success']) {
          showAlert("Data saved successfully!");
        } else {
          showAlert(jsonData['message']);
        }
      } else {
        throw Exception('Failed to save user data');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          color: Colors.black,
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          'Edit Profile',
          style: TextStyle(color: Colors.black),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
      ),
      body: Padding(
        
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Nama",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                textAlign: TextAlign.left,
              ),
            ),
            SizedBox(height: 5),
            TextFormField(
              controller: namaCont,
              decoration: InputDecoration(
                hintText: uname,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25.0),
                  borderSide: BorderSide(
                    color: Color.fromRGBO(240, 240, 240, 1),
                  ),
                ),
                filled: true,
                fillColor: Color.fromRGBO(240, 240, 240, 1),
                contentPadding:
                    EdgeInsets.symmetric(vertical: 5, horizontal: 10),
              ),
              enableInteractiveSelection: false,
            ),
            SizedBox(height: 15),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Email",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                textAlign: TextAlign.left,
              ),
            ),
            SizedBox(height: 5),
            TextFormField(
              controller: emailCont,
              decoration: InputDecoration(
                hintText: email,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25.0),
                  borderSide: BorderSide(
                    color: Color.fromRGBO(240, 240, 240, 1),
                  ),
                ),
                filled: true,
                fillColor: Color.fromRGBO(240, 240, 240, 1),
                contentPadding:
                    EdgeInsets.symmetric(vertical: 5, horizontal: 10),
              ),
              enableInteractiveSelection: false,
            ),
            SizedBox(height: 15),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Phone Number",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                textAlign: TextAlign.left,
              ),
            ),
            SizedBox(height: 5),
            TextFormField(
              controller: phoneCont,
              decoration: InputDecoration(
                hintText: phoneNumber,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25.0),
                  borderSide: BorderSide(
                    color: Color.fromRGBO(240, 240, 240, 1),
                  ),
                ),
                filled: true,
                fillColor: Color.fromRGBO(240, 240, 240, 1),
                contentPadding:
                    EdgeInsets.symmetric(vertical: 5, horizontal: 10),
              ),
              enableInteractiveSelection: false,
            ),
            SizedBox(height: 15),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Old Password",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                textAlign: TextAlign.left,
              ),
            ),
            SizedBox(height: 5),
            TextFormField(
              controller: oldPassCont,
              decoration: InputDecoration(
                hintText: "Enter Your Old Password",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25.0),
                  borderSide: BorderSide(
                    color: Color.fromRGBO(240, 240, 240, 1),
                  ),
                ),
                filled: true,
                fillColor: Color.fromRGBO(240, 240, 240, 1),
                contentPadding:
                    EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                suffixIcon: GestureDetector(
                  onTap: () {
                    setState(() {
                      showOldPass = !showOldPass;
                    });
                  },
                  child: Icon(
                    showOldPass ? Icons.visibility : Icons.visibility_off,
                    color: Colors.grey,
                  ),
                ),
              ),
              enableInteractiveSelection: false,
              obscureText: showOldPass,
            ),
            SizedBox(height: 15),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "New Password",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                textAlign: TextAlign.left,
              ),
            ),
            SizedBox(height: 5),
            TextFormField(
              controller: newPassCont,
              decoration: InputDecoration(
                hintText: "Enter New Password",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25.0),
                  borderSide: BorderSide(
                    color: Color.fromRGBO(240, 240, 240, 1),
                  ),
                ),
                filled: true,
                fillColor: Color.fromRGBO(240, 240, 240, 1),
                contentPadding:
                    EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                suffixIcon: GestureDetector(
                  onTap: () {
                    setState(() {
                      showNewPass = !showNewPass;
                    });
                  },
                  child: Icon(
                    showNewPass ? Icons.visibility : Icons.visibility_off,
                    color: Colors.grey,
                  ),
                ),
              ),
              enableInteractiveSelection: false,
              obscureText: showNewPass,
            ),
            SizedBox(height: 15),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Comfirm New Password",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                textAlign: TextAlign.left,
              ),
            ),
            SizedBox(height: 5),
            TextFormField(
              controller: comNewPassCont,
              decoration: InputDecoration(
                hintText: "Comfirm New Password",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25.0),
                  borderSide: BorderSide(
                    color: Color.fromRGBO(240, 240, 240, 1),
                  ),
                ),
                filled: true,
                fillColor: Color.fromRGBO(240, 240, 240, 1),
                contentPadding:
                    EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                suffixIcon: GestureDetector(
                  onTap: () {
                    setState(() {
                      showComNewPass = !showComNewPass;
                    });
                  },
                  child: Icon(
                    showComNewPass ? Icons.visibility : Icons.visibility_off,
                    color: Colors.grey,
                  ),
                ),
              ),
              enableInteractiveSelection: false,
              obscureText: showComNewPass,
            ),
            SizedBox(height: 15),
            Container(
              height: 48.0,
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  saveData(
                    namaCont.text.isEmpty ? uname : namaCont.text,
                    emailCont.text.isEmpty ? email : emailCont.text,
                    phoneCont.text.isEmpty ? phoneNumber : phoneCont.text,
                    oldPassCont.text.isEmpty ? null : oldPassCont.text,
                    newPassCont.text.isEmpty ? null : newPassCont.text,
                  );
                },
                child: Text('Save'),
                style: ElevatedButton.styleFrom(
                  primary: Color.fromRGBO(0, 166, 82, 1),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25.0),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
