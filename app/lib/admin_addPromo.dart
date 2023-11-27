import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:app/admin_chatList.dart';
import 'package:app/admin_promoList.dart';
import 'package:app/admin_home.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'dart:convert';

class addPromo extends StatefulWidget {
  final String username;

  const addPromo({required this.username, Key? key}) : super(key: key);

  @override
  State<addPromo> createState() => addPromoState();
}

class addPromoState extends State<addPromo> {
  dynamic image;
  TextEditingController promoName = TextEditingController();
  TextEditingController descPromo = TextEditingController();
  TextEditingController keterangan = TextEditingController();
  DateTime? releaseDate;
  DateTime? endDate;
  bool isActive = true;
  Future<void> uploadImageToServer(Uint8List? bytes) async {
    if (bytes == null) {
      print('Error: Image bytes are null.');
      return;
    }

    var request = http.MultipartRequest(
        'POST', Uri.parse('http://localhost/adminAddPromo.php'));
    request.fields['promoName'] = promoName.text;
    request.fields['descPromo'] = descPromo.text;
    request.fields['keterangan'] = keterangan.text;
    request.fields['releaseDate'] = releaseDate.toString();
    request.fields['endDate'] = endDate.toString();
    request.fields['createdBy'] = widget.username;
    request.fields['status'] = isActive ? '1' : '0';;

    request.files.add(
      http.MultipartFile.fromBytes('image', bytes, filename: 'image.jpg'),
    );

    var response = await request.send();
    if (response.statusCode == 200) {
      var imageUrl = await response.stream.bytesToString();
      print('Image URL: $imageUrl');
    } else {
      print('Error during image upload: ${response.reasonPhrase}');
    }
  }

  Future<void> pickImageAndUpload() async {
    FilePickerResult? result =
        await FilePicker.platform.pickFiles(type: FileType.image);

    if (result != null && result.files.isNotEmpty) {
      var platformFile = result.files.first;
      if (kIsWeb) {
        setState(() {
          image = platformFile.bytes;
        });
        await uploadImageToServer(platformFile.bytes);
      } else {
        File file = File(platformFile.path ?? '');
        setState(() {
          image = file;
        });
        await uploadImageToServer(file.readAsBytes() as Uint8List);
      }
    }
  }

  bool areTextFieldsFilled() {
    return promoName.text.isNotEmpty &&
        descPromo.text.isNotEmpty &&
        keterangan.text.isNotEmpty &&
        releaseDate != null &&
        endDate != null;
  }

  void showValidationDialog(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Validation Error'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _selectReleaseDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );

    if (picked != null && picked != releaseDate) {
      setState(() {
        releaseDate = picked;
      });
    }
  }

  Future<void> _selectEndDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );

    if (picked != null && picked != endDate) {
      setState(() {
        endDate = picked;
      });
    }
  }

  Future<void> submitForm() async {
    pickImageAndUpload();
    if (areTextFieldsFilled()) {
      // You can customize the validation messages as needed
      if (releaseDate!.isAfter(endDate!)) {
        showValidationDialog('End date should be after release date.');
        return;
      }

      await Future.delayed(Duration(seconds: 1)); // Simulating upload delay

      print('Form submitted successfully!');
    } else {
      showValidationDialog('Please fill in all required fields.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Add Promotion",
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
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Nama Promo",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                textAlign: TextAlign.left,
              ),
            ),
            SizedBox(height: 5),
            TextFormField(
              controller: promoName,
              decoration: InputDecoration(
                hintText: 'Enter nama promo',
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
            SizedBox(height: 12.0),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Deskripsi Promo",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                textAlign: TextAlign.left,
              ),
            ),
            SizedBox(height: 5),
            TextFormField(
              controller: descPromo,
              decoration: InputDecoration(
                hintText: 'Enter deskripsi promo',
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
            SizedBox(height: 12.0),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Keterangan",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                textAlign: TextAlign.left,
              ),
            ),
            SizedBox(height: 5),
            TextFormField(
              controller: keterangan,
              decoration: InputDecoration(
                hintText: 'Enter keterangan promo',
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
            SizedBox(height: 12.0),
            ElevatedButton(
              onPressed: () => _selectReleaseDate(context),
              child: Text('Select Release Date'),
            ),
            SizedBox(height: 12.0),
            ElevatedButton(
              onPressed: () => _selectEndDate(context),
              child: Text('Select End Date'),
            ),
            SizedBox(height: 12.0),
            Row(
              children: [
                Text(
                  "Status:",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                SizedBox(width: 10),
                Row(
                  children: [
                    Radio(
                      value: true,
                      groupValue: isActive,
                      onChanged: (value) {
                        setState(() {
                          isActive = value as bool;
                        });
                      },
                    ),
                    Text('Active'),
                  ],
                ),
                Row(
                  children: [
                    Radio(
                      value: false,
                      groupValue: isActive,
                      onChanged: (value) {
                        setState(() {
                          isActive = value as bool;
                        });
                      },
                    ),
                    Text('Not Active'),
                  ],
                ),
              ],
            ),

            SizedBox(
              height: 10,
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                primary: Color.fromRGBO(29, 133, 3, 1),
              ),
              onPressed: () {
                submitForm();
              },
              child: Text('Submit'),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        onTap: (int index) {
          switch (index) {
            case 0:
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => adminPromoList(
                    username: widget.username,
                  ),
                ),
              );
              break;
            case 1:
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => adminHome(username: widget.username),
                ),
              );
              break;
            case 2:
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => adminChatList(
                    username: widget.username,
                  ),
                ),
              );
              break;
          }
        },
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: FaIcon(
              FontAwesomeIcons.ad,
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
