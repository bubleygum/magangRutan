import 'dart:ui';

import 'package:app/wishlist.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:app/home.dart';
import 'package:app/chat.dart';

class tentangKami extends StatelessWidget {
  final String username;
final String status;
  const tentangKami({required this.username,required this.status, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Tentang Kami",
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
        actions: [
          IconButton(
            icon: Icon(
              Icons.favorite,
              color: Color.fromRGBO(29, 133, 3, 1),
            ),
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => wishlist(username: username,status: status,)),
                );
            },
          ),
        ],
      ),
      body: tentangKamiScreen(),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        onTap: (int index) {
          switch (index) {
            case 0:
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => wishlist(username: username, status: status,)),
              );
              break;
            case 1:
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => userHomeScreen(uname: username, status: status,)),
              );
              break;
            case 2:
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => chat(uname: username,status: status,product: "false")),
              );
              break;
          }
        },
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: FaIcon(FontAwesomeIcons.heart,color:Color.fromRGBO(29, 133, 3, 1),),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: FaIcon(FontAwesomeIcons.home, color:Color.fromRGBO(29, 133, 3, 1), ),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: FaIcon(FontAwesomeIcons.message,color:Color.fromRGBO(29, 133, 3, 1),),
            label: '',
          ),
        ],
      ),
    );
  }
}

class tentangKamiScreen extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(8),
      children: <Widget>[
        Container(
          color: Colors.white,
          child: Center(
            child: Column(
              children: [
                Text("Tentang Kami",
                    style: TextStyle(
                        color: Color.fromRGBO(29, 133, 3, 1),
                        fontSize: 15,
                        fontWeight: FontWeight.bold)),
                Center(
                  child: RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      text:
                          'PT RUTAN adalah perusahaan swasta nasional yang lebih dari 80 tahun terus berdedikasi sebagai mitra dan solusi dalam menghadapi permasalahan ketahanan pangan menuju "Indonesia Lumbung Pangan Dunia 2045". Kami terus berkomitmen untuk memberikan pelayanan dan kenyamanan terbaik kepada pelanggan.\n',
                      style: TextStyle(
                          color: Color.fromRGBO(29, 133, 3, 1), fontSize: 15),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        Container(
          color: Color.fromRGBO(29, 133, 3, 1),
          child: Center(
            child: Column(
              children: [
                Text("\nVisi",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.bold)),
                Center(
                  child: RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      text:
                          'PT RUTAN harus menjadi pelopor dan pemimpin dalam menyediakan alat dan mesin sebagai solusi di bidang pertanian, perkebunan, kehutanan, peternakan, perikanan, dan kelautan dengan menerapkan teknologi yang modern serta management yang profesional.\n',
                      style: TextStyle(color: Colors.white, fontSize: 15),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        Container(
          color: Colors.white,
          child: Center(
            child: Column(
              children: [
                Text("\nMisi",
                    style: TextStyle(
                        color: Color.fromRGBO(29, 133, 3, 1),
                        fontSize: 15,
                        fontWeight: FontWeight.bold)),
                Center(
                  child: RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      text:
                          'KOMPETITIF :Memberikan harga bersaing.Menyediakan produk bermutu tinggi dengan teknologi modern. \n\n',
                      style: TextStyle(
                          color: Color.fromRGBO(29, 133, 3, 1), fontSize: 15),
                      children: <TextSpan>[
                        TextSpan(
                          text:
                              'MENGUTAMAKAN PELANGGAN :Memberikan pelayanan maksimal.Meningkatan after sales service untuk menjaga loyalitas pelanggan. MANAJEMEN & SUMBER DAYA \n\n',
                          style: TextStyle(
                              color: Color.fromRGBO(29, 133, 3, 1),
                              fontSize: 15),
                        ),
                        TextSpan(
                          text:
                              'PROFESIONAL :Mengembangkan budaya organisasi dan manajemen yang profesional.Meningkatkan kompetensi sumber daya manusia yang handal.\n',
                          style: TextStyle(
                              color: Color.fromRGBO(29, 133, 3, 1),
                              fontSize: 15),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        Container(
          color: Color.fromRGBO(29, 133, 3, 1),
          child: Center(
            child: Column(
              children: [
                Text("\nKomitmen Perusahaan",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.bold)),
                Center(
                  child: RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      text:
                          'TEKNOLOGI MAJU (Advance in Technology)Secara berkesinambungan kami akan mengerahkan segenap pengetahuan dan kemampuan kami untuk membawa serta mengenalkan alat dan mesin yang berteknologi modern ke pasar Indonesia dan tepat guna.\n',
                      style: TextStyle(color: Colors.white, fontSize: 15),
                      children: <TextSpan>[
                        TextSpan(
                          text:
                              'INVESTASI MENGUNTUNGKAN (Good Investment)Kami percaya bahwa investasi yang sehat dapat dianalogikan seperti mengamati pertumbuhan padi yang membuahkan hasil melimpah. Kami berkomitmen untuk selalu mendampingi pelanggan kami progress demi progress untuk mencapai investasi yang menguntungkan.\n',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 15),
                        ),
                        TextSpan(
                          text:
                              'MUTU PRODUK YANG TERJAMIN (Good Quality Product)Dengan sistem seleksi dan uji coba mesin yang ketat, kami harus memastikan bahwa produk yang berteknologi maju yang kami tawarkan harus sempurna dan dapat diaplikasikan sesuai kebutuhan pasar.\n',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 15),
                        ),
                        TextSpan(
                          text:
                              'PELANGGAN YANG LOYAL (Customer Satisfaction)Kami akan selalu menargetkan diri kami lebih dari perusahaan lain Kami tidak hanya berkomitmen untuk membuat pelanggan kami puas, tapi kami juga ingin memposisikan diri sebagai mitra atau partner dari setiap\n',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 15),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
