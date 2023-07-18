import 'package:flutter/material.dart';

class prodList extends StatefulWidget {
  final String data;

  const prodList({required this.data, Key? key}) : super(key: key);

  @override
  State<prodList> createState() => _prodListState();
}

class _prodListState extends State<prodList> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: prodListScreen(data: widget.data),
    );
  }
}

class prodListScreen extends StatelessWidget {
  final String data;

  const prodListScreen({required this.data, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Container(
          child: Text(
            data, 
            style: TextStyle(
              color: Color.fromRGBO(61, 133, 3, 1),
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
        ),
      ],
    );
  }
}
