import 'package:app/chat.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ListCs extends StatefulWidget {
  final String uname;
  final String uId;
  final String status;
  final String product;

  const ListCs({
    required this.uname,
    required this.uId,
    required this.status,
    required this.product,
    Key? key,
  }) : super(key: key);

  @override
  ListCsState createState() => ListCsState();
}

class ListCsState extends State<ListCs> {
  bool hasSelectedRep = false;
  List<Map<String, dynamic>> repList = [];
  @override
  void initState() {
    super.initState();
    fetchCabRep();
    // checkSelectedRep();
  }

  Future<void> fetchCabRep() async {
    // print(widget.uId);
    final response = await http.post(
      Uri.parse('http://localhost/userCS.php'),
      body: {'fetch': "true"},
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['success']) {
        setState(() {
          repList = List<Map<String, dynamic>>.from(data['data']);
        });
        // print(repList);
      } else {
        throw Exception('Failed to fetch representative data');
      }
    }
  }

  Future<void> checkSelectedRep() async {
    final response = await http.post(
      Uri.parse('http://localhost/userCS.php'),
      body: {'check': "true", 'uId': widget.uId},
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['success']) {
        setState(() {
          hasSelectedRep = true;
        });
      } else {
        setState(() {
          hasSelectedRep = false;
        });
      }
    } else {
      throw Exception('Failed to fetch list data');
    }
  }

  Future<void> selectCabRep(String repId) async {
    print(repId + "id: " + widget.uId);
    final response = await http.post(
      Uri.parse('http://localhost/userCS.php'),
      body: {'selected': "true", 'uId': widget.uId, 'repId': repId},
    );

    // print('Response body: ${response.body}');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['success']) {
        navigateToChatPage();
      } else {
        throw Exception('Failed to select cabrep');
      }
    } else {
      throw Exception('Failed to fetch cabrep data');
    }
  }

  void navigateToChatPage() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => chat(
          uname: widget.uname,
          status: widget.status,
          product: "false",
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (hasSelectedRep) {
      navigateToChatPage();
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    } else if (repList.isNotEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Select a Representative'),
        ),
        body: ListView.builder(
          itemCount: repList.length,
          itemBuilder: (context, index) {
            final rep = repList[index];
            return ListTile(
              title: Text(rep['CabRepName'] ?? ''),
              subtitle: Text(rep['Alamat'] ?? ''),
              trailing: ElevatedButton(
                onPressed: () {
                  selectCabRep(rep['IdCabRep']);
                },
                child: Text('Select'),
              ),
            );
          },
        ),
      );
    } else {
      return Scaffold(
        body: Center(
          child: Text("No representatives available."),
        ),
      );
    }
  }
}
