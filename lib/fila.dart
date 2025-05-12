import 'package:flutter/material.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Layout Row')),
      body: Row(
        // mainAxisAlignment: MainAxisAlignment.start,
        // mainAxisAlignment: MainAxisAlignment.end,
        // mainAxisAlignment: MainAxisAlignment.spaceAround,
        // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        mainAxisAlignment: MainAxisAlignment.spaceBetween, // Distributes the space between the children evenly
        crossAxisAlignment: CrossAxisAlignment.start, // Aligns the children at the end of the row, vertically
        children: [
        Text('A', style: TextStyle(fontSize: 35)),
        Text('B', style: TextStyle(fontSize: 35)),
        Text('C', style: TextStyle(fontSize: 135)),
        Text('D', style: TextStyle(fontSize: 35)),
        Text('E', style: TextStyle(fontSize: 35)),
        ]),
    );
  }
}
