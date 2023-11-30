import 'package:app/admin_home.dart';
import 'package:app/admin_promoDetail.dart';
import 'package:app/admin_chatList.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class adminPromoList extends StatefulWidget {
  final String username;

  const adminPromoList({required this.username, Key? key}) : super(key: key);
  @override
  State<adminPromoList> createState() => adminPromoListState(uname: username);
}

class adminPromoListState extends State<adminPromoList> {
  final String uname;

  adminPromoListState({required this.uname, Key? key});
  List<Map<String, dynamic>> promoListData = [];

  @override
  void initState() {
    super.initState();
    fetchPromoList();
  }

  Future<void> fetchPromoList() async {
    final response = await http.post(
      Uri.parse('http://localhost/adminPromoList.php'),
      body: {'UserId': uname},
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['success']) {
        setState(() {
          promoListData = List<Map<String, dynamic>>.from(data['data']);
        });
      }
    } else {
      throw Exception('Failed to fetch wishlist data');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Promotion List",
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
      body: ListView.builder(
        itemCount: promoListData.length,
        itemBuilder: (context, index) {
          final item = promoListData[index];
          final promoName = item['PromoName'];
          final idPromo = item['IdPromo'];
          final descPromo = item['DescPromo'];
          final keterangan = item['Keterangan'];
          final imgPromo = item['ImgPromo'];
          final releaseDate = item['ReleaseDate'];
          final createdDate = item['CreatedDate'];
          final createdBy = item['CreatedBy'];
          final endDate = item['EndDate'];
          final status;
          if (item['Status'] == "1") {
            status = "aktif";
          } else {
            status = "tidak aktif";
          }
          return Card(
            margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
            elevation: 4,
            child: Padding(
              padding: EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    promoName,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text("Status: $status"),
                  Text("Created Date: $createdDate"),
                  SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () {
                      // print("Username: $uname");
                      // print("ID Promo: $idPromo");
                      // print("Nama Promo: $promoName");
                      // print("Deskripsi Promo: $descPromo");
                      // print("Keterangan Promo: $keterangan");
                      // print("Image Promo: $imgPromo");
                      // print("Release Date: $releaseDate");
                      // print("Created By: $createdBy");
                      // print("Created Date: $createdDate");
                      // print("End Date: $endDate");
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => adminPromoDetail(
                            username: uname,
                            idPromo: idPromo,
                            namaPromo: promoName,
                            descPromo: descPromo,
                            keterangan: keterangan,
                            imgPromo: imgPromo,
                            releaseDate: releaseDate,
                            createdBy: createdBy,
                            createdDate: createdDate,
                            endDate: endDate,
                          ),
                        ),
                      );
                    },
                    child: Text("Upload Gambar"),
                    style: ElevatedButton.styleFrom(
                      primary: Color.fromRGBO(29, 133, 3, 1),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
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
                    username: uname,
                  ),
                ),
              );
              break;
            case 1:
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => adminHome(username: uname),
                ),
              );
              break;
            case 2:
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => adminChatList(
                    username: uname,
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
