import 'package:flutter/material.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(title: Text('Layout Stack')),
      body: Stack(
        children: [
          Align(
            alignment: Alignment(0, 0),
            child: Text('1', style: TextStyle(fontSize: 50)),
          ),
          Align(
            alignment: Alignment(1, 0),
            child: Text('2', style: TextStyle(fontSize: 50)),
          ),
          Align(
            alignment: Alignment(1, 1),
            child: Text('3', style: TextStyle(fontSize: 50)),
          ),
          Align(
            alignment: Alignment(0, 1),
            child: Text('4', style: TextStyle(fontSize: 50)),
          ),
          Align(
            alignment: Alignment(-1, 1),
            child: Text('5', style: TextStyle(fontSize: 50)),
          ),
          Align(
            alignment: Alignment(-1, 0),
            child: Text('6', style: TextStyle(fontSize: 50)),
          ),
          Align(
            alignment: Alignment(-1, -1),
            child: Text('7', style: TextStyle(fontSize: 50)),
          ),
          Align(
            alignment: Alignment(0, -1),
            child: Text('8', style: TextStyle(fontSize: 50)),
          ),
          Align(
            alignment: Alignment(1, -1),
            child: Text('9', style: TextStyle(fontSize: 50)),
          ),
          Align(
            alignment: Alignment(0, 0.5),
            child: Text('A', style: TextStyle(fontSize: 50)),
          ),
        ],
      ),
    );
  }
}
