import 'package:app/signUp.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:app/home.dart';
import 'auth_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/gestures.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

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
  DateTime currentTime = DateTime.now();

  void loginUser(String status) async {
    if (formKey.currentState!.validate()) {
      try {
        var url = Uri.parse('http://localhost/login.php');
        var response = await http.post(url, body: {
          'username': unameCont.text.toString(),
          'password': passCont.text,
          'status': status,
          'lastLogin': currentTime.toString(),
        });
        if (response.statusCode == 200) {
          var data = jsonDecode(response.body);
          bool success = data['success'];

          if (success) {
            final SharedPreferences prefs = await SharedPreferences.getInstance();
            await prefs.setBool('isLoggedIn', true);
            await prefs.setString('username', unameCont.text); // Save the username
            Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => Home(username: unameCont.text),
            ));
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
                loginUser("0");
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
          SizedBox(
            width: 140,
            child: ElevatedButton(
              onPressed: () {
                loginUser("1");
              },
              child: Text('Login as Admin'),
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
