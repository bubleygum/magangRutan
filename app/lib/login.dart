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
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: BlocProvider(
            create: (context) => AuthBloc(),
            child: LoginForm(),
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
  TextEditingController emailCont = TextEditingController();
  TextEditingController passCont = TextEditingController();
  String? email;
  String? password;
  Map<String, dynamic> userData = {};
  DateTime currentTime = DateTime.now();

  void loginUser(String status) async {
    if (formKey.currentState!.validate()) {
      try {
        var url = Uri.parse('http://localhost/login.php');
        var response = await http.post(url, body: {
          'email': emailCont.text.toString(),
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
            print(userData["FullName"]);
            final SharedPreferences prefs =
                await SharedPreferences.getInstance();
            await prefs.setBool('isLoggedIn', true);
            await prefs.setString('username', userData["FullName"]);
            await prefs.setString('status', userData['Status']);
            if (userData['Status'] == '1') {
              print("login");
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) =>
                    userHomeScreen(uname: userData["FullName"], status: "1"),
              ));
            } else if (userData['Status'] == '2') {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) =>
                    userHomeScreen(uname: userData["FullName"], status: "2"),
              ));
            } else if (userData['Status'] == '3') {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) =>
                    userHomeScreen(uname: userData["FullName"], status: "3"),
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
            padding: EdgeInsets.only(top: 20.0),
            child: Image.network(
              'assets/logo.jpg',
              height: 80.0,
            ),
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              "Welcome to Rubicon",
              style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
              textAlign: TextAlign.left,
            ),
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              "Please enter your address below to start using app",
              style: TextStyle(
                  fontSize: 16, color: Color.fromRGBO(130, 143, 161, 1)),
              textAlign: TextAlign.left,
            ),
          ),
          SizedBox(
            height: 20,
          ),
          Column(
            children: <Widget>[
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
                  hintText: 'Enter your email',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25.0),
                    borderSide: BorderSide(
                      color: Color.fromRGBO(
                          240, 240, 240, 1), // Set border color here
                    ),
                  ),
                  filled: true,
                  fillColor: Color.fromRGBO(
                      240, 240, 240, 1), // Set text field background color here
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                ),
                validator: validateField,
                onSaved: (value) {
                  email = value;
                },
                enableInteractiveSelection: false,
              ),
              SizedBox(height: 12.0),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Password",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.left,
                ),
              ),
              SizedBox(height: 5),
              TextFormField(
                controller: passCont,
                decoration: InputDecoration(
                  hintText: 'Password',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25.0),
                    borderSide:
                        BorderSide(color: Color.fromRGBO(240, 240, 240, 1)),
                  ),
                  filled: true,
                  fillColor: Color.fromRGBO(240, 240, 240, 1),
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                ),
                validator: validateField,
                onSaved: (value) {
                  password = value;
                },
                obscureText: true,
              ),
              SizedBox(height: 8.0),
              GestureDetector(
                onTap: () {
                  // Add your password reset navigation logic here
                  // For example, you can use Navigator to navigate to a reset password page.
                  // Navigator.of(context).push(MaterialPageRoute(
                  //   builder: (context) => ResetPasswordPage(),
                  // ));
                },
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    "Forgot Password?",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color: Color.fromRGBO(0, 166, 82, 1),
                    ),
                    textAlign: TextAlign.left,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 20.0),
          Container(
            height: 48.0,
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                loginUser("3");
              },
              child: Text('Sign In'),
              style: ElevatedButton.styleFrom(
                primary: Color.fromRGBO(0, 166, 82, 1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25.0),
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
                      text: "Don't have an account? ",
                      style: TextStyle(
                        color: Colors.black,
                      ),
                    ),
                    TextSpan(
                        text: 'Sign Up',
                        style: TextStyle(
                            color: Color.fromRGBO(0, 166, 82, 1),
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
