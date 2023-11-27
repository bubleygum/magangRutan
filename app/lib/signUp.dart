import 'package:app/login.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:app/home.dart';
import 'auth_bloc.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/gestures.dart';

class signUp extends StatelessWidget {
  const signUp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: BlocProvider(
              create: (context) => AuthBloc(),
              child: signUpForm(),
            ),
          ),
        ),
      ),
    );
  }
}

class signUpForm extends StatefulWidget {
  @override
  signUpState createState() => signUpState();
}

enum dealerStat { dealer, nonDealer }

class signUpState extends State<signUpForm> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  TextEditingController unameCont = TextEditingController();
  TextEditingController passCont = TextEditingController();
  TextEditingController rePassCont = TextEditingController();
  TextEditingController emailCont = TextEditingController();
  TextEditingController noHPCont = TextEditingController();
  TextEditingController alamatCont = TextEditingController();
  TextEditingController provCont = TextEditingController();
  TextEditingController kabKotaCont = TextEditingController();
  TextEditingController kecCont = TextEditingController();
  TextEditingController kelCont = TextEditingController();
  TextEditingController kodPosCont = TextEditingController();
  TextEditingController nonDealer = TextEditingController();
  dealerStat? status;
  bool showTextField = false;
  DateTime currentTime = DateTime.now();
  String userJob = "";
  bool areFieldsEmpty = false;

  void signIn(String status) async {
    Map<String, String> requestBody;
    try {
      if (nonDealer.text == null || nonDealer.text.isEmpty) {
        userJob = "dealer";
      } else {
        userJob = nonDealer.text.toString();
      }
      var url = Uri.parse('http://localhost/signUp.php');
      if (status == "Member") {
        var response = await http.post(url, body: {
          'username': unameCont.text.toString(),
          'password': passCont.text.toString(),
          'email': emailCont.text.toString(),
          'noHP': noHPCont.text.toString(),
          'alamat': alamatCont.text.toString(),
          'prov': provCont.text.toString(),
          'kabKota': kabKotaCont.text.toString(),
          'kec': kecCont.text.toString(),
          'kel': kelCont.text.toString(),
          'kodPos': kodPosCont.text.toString(),
          'userJob': userJob,
          'createdDate': currentTime.toString(),
          'userStat': status,
        });
        if (response.statusCode == 200) {
          var data = jsonDecode(response.body);
          bool success = data['success'];

          if (success) {
            Navigator.of(context)
                .push(MaterialPageRoute(builder: (context) => Login()));
          }
        }
      } else {
        var response = await http.post(url, body: {
          'username': "",
          'password': "",
          'email': "",
          'noHP': "",
          'alamat': "",
          'prov': "",
          'kabKota': "",
          'kec': "",
          'kel': "",
          'kodPos': "",
          'userJob': "",
          'createdDate': currentTime.toString(),
          'userStat': status,
        });
        if (response.statusCode == 200) {
          var data = jsonDecode(response.body);
          bool success = data['success'];

          if (success) {
            Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => userHomeScreen(
                      uname: "",
                      status: "3",
                    )));
          }
        }
      }
    } catch (error) {
      print('Error: $error');
    }
  }

  //validation
  String? validateField(String? value) {
    if (value == null || value.isEmpty) {
      return 'This field is required';
    }
    return null;
  }

  String? validatePassword(String? pass) {
    RegExp regex =
        RegExp(r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*~]).{8,}$');
    if (pass == null || pass.isEmpty) {
      return 'This field is required';
    } else if (!regex.hasMatch(pass.trim())) {
      return 'Password memerlukan huruf besar, huruf kecil, angka, dan karakter spesial';
    }
  }

  String? validateRePass(String? pass) {
    RegExp regex =
        RegExp(r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*~]).{8,}$');
    if (pass == null || pass.isEmpty) {
      return 'This field is required';
    } else if (!regex.hasMatch(pass.trim())) {
      return 'Password memerlukan huruf besar, huruf kecil, angka, dan karakter spesial';
    } else if (pass != passCont.text.toString()) {
      return 'Password tidak sama';
    }
  }

  String? validateEmail(String? email) {
    if (email == null || email.isEmpty) {
      return 'This field is required';
    } else if (!EmailValidator.validate(email)) {
      return 'Email tidak valid';
    }
  }

  String? validatePhone(String? phone) {
    RegExp phoneRegex = RegExp(r'^[0-9]{10,12}$');
    if (phone == null || phone.isEmpty) {
      return 'This field is required';
    } else if (!phoneRegex.hasMatch(phone)) {
      return 'Harus berisi angka';
    }
  }

  bool checkFieldsEmpty() {
    return unameCont.text.isEmpty ||
        passCont.text.isEmpty ||
        rePassCont.text.isEmpty ||
        emailCont.text.isEmpty ||
        noHPCont.text.isEmpty ||
        alamatCont.text.isEmpty ||
        provCont.text.isEmpty ||
        kabKotaCont.text.isEmpty ||
        kecCont.text.isEmpty ||
        kelCont.text.isEmpty ||
        kodPosCont.text.isEmpty;
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      autovalidateMode: AutovalidateMode.always,
      child: Column(
        children: <Widget>[
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              "Create a new account",
              style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
              textAlign: TextAlign.left,
            ),
          ),
          Text(
            "Please put your information below to create a new account for using app",
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w400,
                color: Color.fromRGBO(130, 143, 161, 1)),
          ),
          SizedBox(
            height: 20,
          ),
          Column(children: <Widget>[
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Nama",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                textAlign: TextAlign.left,
              ),
            ),
            TextFormField(
              controller: unameCont,
              decoration: InputDecoration(
                hintText: 'Enter your name',
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
            ),
            SizedBox(height: 12.0),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Email",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                textAlign: TextAlign.left,
              ),
            ),
            TextFormField(
              controller: emailCont,
              decoration: InputDecoration(
                hintText: 'Enter your email',
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
              validator: validateEmail,
            ),
            SizedBox(height: 12.0),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Phone Number",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                textAlign: TextAlign.left,
              ),
            ),
            TextFormField(
              controller: noHPCont,
              decoration: InputDecoration(
                hintText: 'Enter your phone number',
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
              keyboardType: TextInputType.number,
              validator: validatePhone,
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
            TextFormField(
              controller: passCont,
              decoration: InputDecoration(
                hintText: 'Enter your password',
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
              validator: validatePassword,
              obscureText: true,
            ),
            SizedBox(height: 12.0),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Re-type Password",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                textAlign: TextAlign.left,
              ),
            ),
            TextFormField(
              controller: rePassCont,
              decoration: InputDecoration(
                hintText: 'Re-type Password',
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
              validator: validateRePass,
              obscureText: true,
            ),
            SizedBox(height: 12.0),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Alamat",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                textAlign: TextAlign.left,
              ),
            ),
            TextFormField(
              controller: alamatCont,
              decoration: InputDecoration(
                hintText: 'Alamat',
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
              validator: validateField,
            ),
            SizedBox(height: 12.0),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Provinsi",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                textAlign: TextAlign.left,
              ),
            ),
            TextFormField(
              controller: provCont,
              decoration: InputDecoration(
                hintText: 'Provinsi',
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
              validator: validateField,
            ),
            SizedBox(height: 12.0),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Kabupaten / Kota",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                textAlign: TextAlign.left,
              ),
            ),
            TextFormField(
              controller: kabKotaCont,
              decoration: InputDecoration(
                labelText: 'Kabupaten / Kota',
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
              validator: validateField,
            ),
            SizedBox(height: 12.0),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Kecamatan",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                textAlign: TextAlign.left,
              ),
            ),
            TextFormField(
              controller: kecCont,
              decoration: InputDecoration(
                labelText: 'Kecamatan',
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
              validator: validateField,
            ),
            SizedBox(height: 12.0),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Kelurahan",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                textAlign: TextAlign.left,
              ),
            ),
            TextFormField(
              controller: kelCont,
              decoration: InputDecoration(
                labelText: 'Kelurahan',
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
              validator: validateField,
            ),
            SizedBox(height: 12.0),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Kode Pos",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                textAlign: TextAlign.left,
              ),
            ),
            TextFormField(
              controller: kodPosCont,
              decoration: InputDecoration(
                labelText: 'Kode Pos',
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
              validator: validateField,
            ),
          ]),
          SizedBox(height: 12.0),
          Column(
            children: <Widget>[
              ListTile(
                title: const Text('Saya seorang dealer'),
                leading: Radio<dealerStat>(
                  value: dealerStat.dealer,
                  groupValue: status,
                  fillColor: MaterialStateColor.resolveWith(
                      (states) => Color.fromRGBO(29, 133, 3, 1)),
                  onChanged: (dealerStat? value) {
                    setState(() {
                      status = value;
                      showTextField = false;
                    });
                  },
                ),
              ),
              ListTile(
                title: const Text('Saya bukan seorang dealer'),
                leading: Radio<dealerStat>(
                  value: dealerStat.nonDealer,
                  groupValue: status,
                  fillColor: MaterialStateColor.resolveWith(
                      (states) => Color.fromRGBO(29, 133, 3, 1)),
                  onChanged: (dealerStat? value) {
                    setState(() {
                      status = value;
                      showTextField = true;
                    });
                  },
                ),
              ),
              Visibility(
                visible: showTextField,
                child: TextFormField(
                  controller: nonDealer,
                  decoration: InputDecoration(
                    labelText: 'Bidang pekerjaan anda',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.zero,
                    ),
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 20.0),
          Column(
            children: <Widget>[
              Container(
                height: 48.0,
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      areFieldsEmpty = checkFieldsEmpty();
                    });
                    if (!areFieldsEmpty) {
                      signIn("Member");
                    }
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
              SizedBox(height: 8.0),
              if (areFieldsEmpty)
                Text(
                  'Please fill all required fields.',
                  style: TextStyle(color: Colors.red),
                ),
            ],
          ),
          SizedBox(
            height: 20,
          ),
          Container(
            height: 48.0,
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                signIn("Guest");
              },
              child: Text('Sign In as Guest'),
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
                      text: "Already have an account? ",
                      style: TextStyle(
                        color: Colors.black,
                      ),
                    ),
                    TextSpan(
                        text: 'Sign In',
                        style: TextStyle(
                            color: Color.fromRGBO(0, 166, 82, 1),
                            fontWeight: FontWeight.bold),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) => Login()));
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
