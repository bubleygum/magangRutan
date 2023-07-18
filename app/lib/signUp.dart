import 'package:app/login.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:app/home.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'auth_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:email_validator/email_validator.dart';

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
            Navigator.of(context)
                .push(MaterialPageRoute(builder: (context) => Home(username: "",)));
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
                  validator: validatePassword,
                  obscureText: true,
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
                  controller: rePassCont,
                  decoration: InputDecoration(
                    labelText: 'Re-type Password',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.zero,
                    ),
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                  ),
                  validator: validateRePass,
                  obscureText: true,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.0),
          Row(
            children: <Widget>[
              IconTheme(
                data: IconThemeData(color: Color.fromRGBO(29, 133, 3, 1)),
                child: Icon(Icons.mail),
              ),
              Expanded(
                child: TextFormField(
                  controller: emailCont,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.zero,
                    ),
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                  ),
                  validator: validateEmail,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.0),
          Row(
            children: <Widget>[
              IconTheme(
                data: IconThemeData(color: Color.fromRGBO(29, 133, 3, 1)),
                child: Icon(Icons.phone_android),
              ),
              Expanded(
                child: TextFormField(
                  controller: noHPCont,
                  decoration: InputDecoration(
                    labelText: 'Nomor HP',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.zero,
                    ),
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                  ),
                  keyboardType: TextInputType.number,
                  validator: validatePhone,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.0),
          Row(
            children: <Widget>[
              IconTheme(
                data: IconThemeData(color: Color.fromRGBO(29, 133, 3, 1)),
                child: Icon(Icons.house),
              ),
              Expanded(
                child: TextFormField(
                  controller: alamatCont,
                  decoration: InputDecoration(
                    labelText: 'Alamat',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.zero,
                    ),
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                  ),
                  validator: validateField,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.0),
          Row(
            children: <Widget>[
              IconTheme(
                data: IconThemeData(color: Color.fromRGBO(29, 133, 3, 0)),
                child: Icon(Icons.lock),
              ),
              Expanded(
                child: TextFormField(
                  controller: provCont,
                  decoration: InputDecoration(
                    labelText: 'Provinsi',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.zero,
                    ),
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                  ),
                  validator: validateField,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.0),
          Row(
            children: <Widget>[
              IconTheme(
                data: IconThemeData(color: Color.fromRGBO(29, 133, 3, 0)),
                child: Icon(Icons.lock),
              ),
              Expanded(
                child: TextFormField(
                  controller: kabKotaCont,
                  decoration: InputDecoration(
                    labelText: 'Kabupaten / Kota',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.zero,
                    ),
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                  ),
                  validator: validateField,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.0),
          Row(
            children: <Widget>[
              IconTheme(
                data: IconThemeData(color: Color.fromRGBO(29, 133, 3, 0)),
                child: Icon(Icons.lock),
              ),
              Expanded(
                child: TextFormField(
                  controller: kecCont,
                  decoration: InputDecoration(
                    labelText: 'Kecamatan',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.zero,
                    ),
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                  ),
                  validator: validateField,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.0),
          Row(
            children: <Widget>[
              IconTheme(
                data: IconThemeData(color: Color.fromRGBO(29, 133, 3, 0)),
                child: Icon(Icons.lock),
              ),
              Expanded(
                child: TextFormField(
                  controller: kelCont,
                  decoration: InputDecoration(
                    labelText: 'Kelurahan',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.zero,
                    ),
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                  ),
                  validator: validateField,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.0),
          Row(
            children: <Widget>[
              IconTheme(
                data: IconThemeData(color: Color.fromRGBO(29, 133, 3, 0)),
                child: Icon(Icons.lock),
              ),
              Expanded(
                child: TextFormField(
                  controller: kodPosCont,
                  decoration: InputDecoration(
                    labelText: 'Kode Pos',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.zero,
                    ),
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                  ),
                  validator: validateField,
                ),
              ),
            ],
          ),
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
              SizedBox(
                width: 140,
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
                    primary: Color.fromRGBO(29, 133, 3, 1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(0),
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
          SizedBox(height: 20,),
          SizedBox(
            width: 140,
            child: ElevatedButton(
              onPressed: () {
                signIn("Guest");
              },
              child: Text('Sign In as Guest'),
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
    );
  }
}
