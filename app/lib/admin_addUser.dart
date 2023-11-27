import 'package:app/admin_userList.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:email_validator/email_validator.dart';

class addUser extends StatelessWidget {
  final String uname;
  addUser({required this.uname, Key? key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Add User",
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
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: addUserForm(
              username: uname,
            ),
          ),
        ),
      ),
    );
  }
}

class addUserForm extends StatefulWidget {
  final String username;

  const addUserForm({required this.username, Key? key}) : super(key: key);
  @override
  addUserState createState() => addUserState();
}

enum dealerStat { admin, salesRep }

class addUserState extends State<addUserForm> {
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
  bool areFieldsEmpty = false;

  void addUser(String status) async {
    if (status == "admin") {
      var url = Uri.parse('http://localhost/adminAddUser.php');
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
        'userJob': "",
        'createdDate': currentTime.toString(),
        'userStat': "1",
      });
      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);

        if (data['success']) {
          Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => adminUserList(
                    username: widget.username,
                  )));
        }
      }
    } else if (status == "salesRep") {
      var url = Uri.parse('http://localhost/addUser.php');
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
        'userJob': "",
        'createdDate': currentTime.toString(),
        'userStat': "2",
      });
      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);

        if (data['success']) {
          Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => adminUserList(
                    username: widget.username,
                  )));
        }
      }
    }
  }

  //validation
  String? validateField(String? value) {
    if (value == null || value.isEmpty) {
      return 'This field is required';
    }
    return null;
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
          Column(
            children: <Widget>[
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Nama Lengkap",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.left,
                ),
              ),
              TextFormField(
                controller: unameCont,
                decoration: InputDecoration(
                  hintText: 'Nama Lengkap',
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
                  "Password",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.left,
                ),
              ),
              TextFormField(
                controller: passCont,
                decoration: InputDecoration(
                  labelText: 'Password',
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
                obscureText: true,
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
                  labelText: 'Email',
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
                  labelText: 'Nomor HP',
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
                  "Alamat",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.left,
                ),
              ),
              TextFormField(
                controller: alamatCont,
                decoration: InputDecoration(
                  labelText: 'Alamat',
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
                  labelText: 'Provinsi',
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
            ],
          ),
          
          Column(
            children: <Widget>[
              ListTile(
                title: const Text('Admin'),
                leading: Radio<dealerStat>(
                  value: dealerStat.admin,
                  groupValue: status,
                  fillColor: MaterialStateColor.resolveWith(
                      (states) => Color.fromRGBO(29, 133, 3, 1)),
                  onChanged: (dealerStat? value) {
                    setState(() {
                      status = value;
                      print(status);
                    });
                  },
                ),
              ),
              ListTile(
                title: const Text('Sales Rep'),
                leading: Radio<dealerStat>(
                  value: dealerStat.salesRep,
                  groupValue: status,
                  fillColor: MaterialStateColor.resolveWith(
                      (states) => Color.fromRGBO(29, 133, 3, 1)),
                  onChanged: (dealerStat? value) {
                    setState(() {
                      status = value;
                      print(status);
                    });
                  },
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
                    if (formKey.currentState!.validate()) {
                      if (status == dealerStat.admin) {
                        addUser('admin');
                      } else if (status == dealerStat.salesRep) {
                        addUser('salesRep');
                      }
                    } else {
                      setState(() {
                        areFieldsEmpty = true;
                      });
                    }
                  },
                  child: Text('Add New User'),
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
        ],
      ),
    );
  }
}
