import 'package:app/admin_addUser.dart';
import 'package:app/admin_home.dart';
import 'package:app/admin_promoList.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class adminUserList extends StatefulWidget {
  final String username;

  const adminUserList({required this.username, Key? key}) : super(key: key);
  @override
  State<adminUserList> createState() => adminUserListState(uname: username);
}

class adminUserListState extends State<adminUserList> {
  final String uname;
  bool sortAscending = true;
  String? searchQuery;
  adminUserListState({required this.uname, Key? key});
  List<Map<String, dynamic>> userListData = [];

  @override
  void initState() {
    super.initState();
    fetchUserList();
  }

  Future<void> fetchUserList() async {
    final response = await http.get(
      Uri.parse('http://localhost/adminUserList.php'),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['success']) {
        setState(() {
          userListData = List<Map<String, dynamic>>.from(data['data']);
        });
      }
    } else {
      throw Exception('Failed to fetch user data');
    }
  }

  void sortData(String column) {
    setState(() {
      if (sortAscending) {
        userListData.sort((a, b) => a[column].compareTo(b[column]));
      } else {
        userListData.sort((a, b) => b[column].compareTo(a[column]));
      }
      sortAscending = !sortAscending;
    });
  }

  List<Map<String, dynamic>> get filteredUserList {
    if (searchQuery == null || searchQuery!.isEmpty) {
      return userListData;
    } else {
      return userListData
          .where((user) =>
              user['UserId'].toString().contains(searchQuery!) ||
              user['FullName'].toString().contains(searchQuery!) ||
              user['Hp'].toString().contains(searchQuery!) ||
              user['Email'].toString().contains(searchQuery!) ||
              user['Alamat'].toString().contains(searchQuery!) ||
              user['provinsi'].toString().contains(searchQuery!) ||
              user['KotaKab'].toString().contains(searchQuery!) ||
              user['Kecamatan'].toString().contains(searchQuery!) ||
              user['Kelurahan'].toString().contains(searchQuery!) ||
              user['Kode Pos'].toString().contains(searchQuery!) ||
              user['Keterangan'].toString().contains(searchQuery!) ||
              user['Created Date'].toString().contains(searchQuery!) ||
              user['Status User'].toString().contains(searchQuery!) ||
              user['Last Login'].toString().contains(searchQuery!))
          .toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "User List",
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
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              onChanged: (value) {
                setState(() {
                  searchQuery = value.toLowerCase();
                });
              },
              decoration: InputDecoration(
                labelText: "Search",
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25.0),
                  borderSide: BorderSide(),
                ),
              ),
            ),
          ),
          SizedBox(
            width: 140,
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => addUser(
                          uname: widget.username,
                        )));
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
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: DataTable(
                  columns: <DataColumn>[
                    DataColumn(
                      label: Expanded(
                        child: InkWell(
                          onTap: () => sortData('UserId'),
                          child: Row(
                            children: [
                              Text(
                                'UserId',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Icon(sortAscending
                                  ? Icons.arrow_upward
                                  : Icons.arrow_downward),
                            ],
                          ),
                        ),
                      ),
                    ),
                    DataColumn(
                      label: Expanded(
                        child: Text(
                          'FullName',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    DataColumn(
                      label: Expanded(
                        child: Text(
                          'HP',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    DataColumn(
                      label: Expanded(
                        child: Text(
                          'Email',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    DataColumn(
                      label: Expanded(
                        child: Text(
                          'Alamat',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    DataColumn(
                      label: Expanded(
                        child: Text(
                          'Provinsi',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    DataColumn(
                      label: Expanded(
                        child: Text(
                          'Kota/Kab',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    DataColumn(
                      label: Expanded(
                        child: Text(
                          'Kecamatan',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    DataColumn(
                      label: Expanded(
                        child: Text(
                          'Kelurahan',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    DataColumn(
                      label: Expanded(
                        child: Text(
                          'Kode Pos',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    DataColumn(
                      label: Expanded(
                        child: Text(
                          'Keterangan',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    DataColumn(
                      label: Expanded(
                        child: Text(
                          'Created Date',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    DataColumn(
                      label: Expanded(
                        child: Text(
                          'Status User',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    DataColumn(
                      label: Expanded(
                        child: Text(
                          'Last Login',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                  rows:
                      List<DataRow>.generate(filteredUserList.length, (index) {
                    final userData = filteredUserList[index];
                    return DataRow(
                      cells: <DataCell>[
                        DataCell(Text(userData['UserId'] ?? '')),
                        DataCell(Text(userData['FullName'] ?? '')),
                        DataCell(Text(userData['Hp'] ?? '')),
                        DataCell(Text(userData['Email'] ?? '')),
                        DataCell(Text(userData['Alamat'] ?? '')),
                        DataCell(Text(userData['provinsi'] ?? '')),
                        DataCell(Text(userData['KotaKab'] ?? '')),
                        DataCell(Text(userData['Kecamatan'] ?? '')),
                        DataCell(Text(userData['Kelurahan'] ?? '')),
                        DataCell(Text(userData['KodePos'] ?? '')),
                        DataCell(Text(userData['Keterangan'] ?? '')),
                        DataCell(Text(userData['CreatedDate'] ?? '')),
                        DataCell(Text(userData['StatusUser'] ?? '')),
                        DataCell(Text(userData['LastLogin'] ?? '')),
                      ],
                    );
                  }),
                ),
              ),
            ),
          ),
        ],
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
                  builder: (context) => adminUserList(
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
