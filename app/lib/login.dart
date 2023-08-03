import 'package:app/admin_home.dart';
import 'package:app/cs_chatList.dart';
import 'package:app/signUp.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:app/home.dart';
import 'auth_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/gestures.dart';

class Login extends StatelessWidget {
  const Login({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: BlocProvider(
              create: (context) => AuthBloc(),
              child: LoginForm(),
            ),
          ),
        ),
      ),
    );
  }
}

class LoginForm extends StatefulWidget {
  @override
  _LoginFormState createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  TextEditingController unameCont = TextEditingController();
  TextEditingController passCont = TextEditingController();
  String? username;
  String? password;
  Map<String, dynamic> userData = {};
  DateTime currentTime = DateTime.now();

  void loginUser(String status) async {
    if (formKey.currentState!.validate()) {
      try {
        var url = Uri.parse('http://localhost/login.php');
        var response = await http.post(url, body: {
          'username': unameCont.text.toString(),
          'password': passCont.text,
          'lastLogin': currentTime.toString(),
        });
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
        if (response.statusCode == 200) {
          var data = jsonDecode(response.body);
          bool success = data['success'];
          if (success) {
            if (data.containsKey('data') &&
                data['data'] is List &&
                data['data'].length > 0) {
              var user = data['data'][0];
              setState(() {
                userData = Map<String, dynamic>.from(user);
              });
            } else {
              print('Invalid data format in the API response');
            }
            final SharedPreferences prefs =
                await SharedPreferences.getInstance();
            await prefs.setBool('isLoggedIn', true);
            await prefs.setString('username', unameCont.text);
            await prefs.setString('status', userData['Status']);
            print(userData['Status']);
            if (userData['Status'] == '1') {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => adminHome(username: unameCont.text),
              ));
            } else if (userData['Status'] == '2') {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => csChatList(username: unameCont.text),
              ));
            } else if (userData['Status'] == '3') {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => userHomeScreen(uname: unameCont.text),
              ));
            }

            BlocProvider.of<AuthBloc>(context).add(AuthEvent.login);
          } else {
            showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  title: Text('Login Failed'),
                  content:
                      Text('Incorrect username or password. Please try again.'),
                  actions: [
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
        }
      } catch (error) {
        print('Error: $error');
      }
    }
  }

  String? validateField(String? value) {
    if (value == null || value.isEmpty) {
      return 'This field is required';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      child: Column(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(bottom: 16.0),
            child: Image.network(
              'assets/logo.jpg',
              height: 80.0,
            ),
          ),
          Row(
            children: <Widget>[
              IconTheme(
                data: IconThemeData(color: Color.fromRGBO(29, 133, 3, 1)),
                child: Icon(Icons.person),
              ),
              Expanded(
                child: TextFormField(
                  controller: unameCont,
                  decoration: InputDecoration(
                    labelText: 'Nama Lengkap',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.zero,
                    ),
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                  ),
                  validator: validateField,
                  onSaved: (value) {
                    username = value;
                  },
                ),
              ),
            ],
          ),
          SizedBox(height: 12.0),
          Row(
            children: <Widget>[
              IconTheme(
                data: IconThemeData(color: Color.fromRGBO(29, 133, 3, 1)),
                child: Icon(Icons.lock),
              ),
              Expanded(
                child: TextFormField(
                  controller: passCont,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.zero,
                    ),
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                  ),
                  validator: validateField,
                  onSaved: (value) {
                    password = value;
                  },
                  obscureText: true,
                ),
              ),
            ],
          ),
          SizedBox(height: 20.0),
          SizedBox(
            width: 140,
            child: ElevatedButton(
              onPressed: () {
                loginUser("3");
              },
              child: Text('Login'),
              style: ElevatedButton.styleFrom(
                primary: Color.fromRGBO(29, 133, 3, 1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(0),
                ),
              ),
            ),
          ),
          SizedBox(height: 12.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: RichText(
                  text: TextSpan(children: [
                    TextSpan(
                      text: 'Belum punya akun? ',
                      style: TextStyle(
                        color: Colors.black,
                      ),
                    ),
                    TextSpan(
                        text: 'Sign Up',
                        style: TextStyle(
                            color: Color.fromRGBO(29, 133, 3, 1),
                            fontWeight: FontWeight.bold),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) => signUp()));
                          }),
                  ]),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
