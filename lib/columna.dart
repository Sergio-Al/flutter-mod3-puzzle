import 'package:flutter/material.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Layout Column')),
      body: Column(
        // mainAxisAlignment: MainAxisAlignment.start,
        // mainAxisAlignment: MainAxisAlignment.center,
        // mainAxisAlignment: MainAxisAlignment.end,
        // mainAxisAlignment: MainAxisAlignment.spaceAround,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center,
        // crossAxisAlignment: CrossAxisAlignment.end,
        // crossAxisAlignment: CrossAxisAlignment.start
        // crossAxisAlignment: CrossAxisAlignment.stretch, // Stretches the children to fill the available width
        children: [
          Text('A', style: TextStyle(fontSize: 35)),
          Text('B', style: TextStyle(fontSize: 35)),
          Text('C', style: TextStyle(fontSize: 35)),
          Text('D', style: TextStyle(fontSize: 35)),
          Text('E', style: TextStyle(fontSize: 35)),
          SizedBox(width: double.infinity), // Fills the available widths
        ],
      ),
    );
  }
}
