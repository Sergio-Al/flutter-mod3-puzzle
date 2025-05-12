import 'package:flutter/material.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Align(
            alignment: Alignment(0, 0),
            child: Container(
              width: 100,
              height: 150,
              color: Colors.red,
              child: Column(
                children: [
                  Text('A', style: TextStyle(fontSize: 25)),
                  Text('B', style: TextStyle(fontSize: 25)),
                  Text('C', style: TextStyle(fontSize: 25)),
                  ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
