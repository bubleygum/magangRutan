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

class adminPromoDetail extends StatefulWidget {
  final String username;
  final String idPromo;
  final String namaPromo;
  final String descPromo;
  final String keterangan;
  final String imgPromo;
  final String releaseDate;
  final String createdDate;
  final String createdBy;
  final String endDate;
  const adminPromoDetail(
      {required this.username,
      required this.idPromo,
      required this.namaPromo,
      required this.descPromo,
      required this.keterangan,
      required this.imgPromo,
      required this.releaseDate,
      required this.createdDate,
      required this.createdBy,
      required this.endDate,
      Key? key})
      : super(key: key);

  @override
  State<adminPromoDetail> createState() => adminPromoDetailState();
}

class adminPromoDetailState extends State<adminPromoDetail> {
  dynamic image;

  Future<void> uploadImageToServer(Uint8List? bytes) async {
    if (bytes == null) {
      print('Error: Image bytes are null.');
      return;
    }
    var baseUrl = 'http://localhost/adminPromoDetail.php';
    var uploadUrl = Uri.parse('$baseUrl?idPromo=${widget.idPromo}');

    var request = http.MultipartRequest('POST', uploadUrl);

    request.fields['idPromo'] = widget.idPromo;
    request.files.add(
        http.MultipartFile.fromBytes('image', bytes, filename: 'image.jpg'));
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
        // On web, use the `bytes` property
        setState(() {
          image = platformFile.bytes;
        });
        await uploadImageToServer(platformFile.bytes);
      } else {
        // On mobile, use the `path` property
        File file = File(platformFile.path ?? '');
        setState(() {
          image = file;
        });
        await uploadImageToServer(file.readAsBytes() as Uint8List);
      }
    }
  }
  // Future<void> pickImageAndUpload() async {
  //   FilePickerResult? result =
  //       await FilePicker.platform.pickFiles(type: FileType.image);

  //   if (result != null && result.files.isNotEmpty) {
  //     var platformFile = result.files.first;
  //     Uint8List? bytes = platformFile.bytes;

  //     if (bytes != null) {
  //       setState(() {
  //         image = bytes;
  //       });
  //       await uploadImageToServer(bytes);
  //     }
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Promotion Detail",
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
            SizedBox(
              height: 10,
            ),
            widget.imgPromo.isNotEmpty
                ? Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        widget.imgPromo,
                        fit: BoxFit.cover,
                        width: MediaQuery.of(context).size.width,
                        height: 300,
                      ),
                    ),
                  )
                : Text(
                    "No Image",
                    style: TextStyle(fontSize: 20),
                  ),
            SizedBox(
              height: 10,
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                primary: Color.fromRGBO(29, 133, 3, 1),
              ),
              onPressed: () {
                pickImageAndUpload();
              },
              child: Text('Upload Photo'),
            ),
            SizedBox(
              height: 10,
            ),
            image != null
                ? Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: kIsWeb
                          ? Image.memory(
                              image,
                              fit: BoxFit.cover,
                              width: MediaQuery.of(context).size.width,
                              height: 300,
                            )
                          : Image.file(
                              File(image),
                              fit: BoxFit.cover,
                              width: MediaQuery.of(context).size.width,
                              height: 300,
                            ),
                    ),
                  )
                : Text(
                    "No Image",
                    style: TextStyle(fontSize: 20),
                  ),
            SizedBox(
              height: 10,
            ),
            Text(
              widget.namaPromo,
              style: TextStyle(
                color: Color.fromRGBO(0, 166, 82, 1),
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            Text(
              "Created Date: " + widget.createdDate,
              style: TextStyle(
                color: Colors.black,
                fontSize: 15,
              ),
            ),
            Text(
              "Released Date: " + widget.releaseDate,
              style: TextStyle(
                color: Colors.black,
                fontSize: 15,
              ),
            ),
            Text(
              "End Date: " + widget.endDate,
              style: TextStyle(
                color: Colors.black,
                fontSize: 15,
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Text(
              "Deskripsi",
              style: TextStyle(
                color: Colors.black,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              widget.descPromo,
              style: TextStyle(
                color: Colors.black,
                fontSize: 15,
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Text(
              "Keterangan",
              style: TextStyle(
                color: Colors.black,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              widget.keterangan,
              style: TextStyle(
                color: Colors.black,
                fontSize: 15,
              ),
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
