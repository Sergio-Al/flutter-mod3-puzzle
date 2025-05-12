import 'package:flutter/material.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title:Text('Layout Flex')),
      body: Flex(
        direction: Axis.vertical,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        
        children: [
          Text('A', style: TextStyle(fontSize: 35)),
          Text('B', style: TextStyle(fontSize: 35)),
          Text('C', style: TextStyle(fontSize: 35)),
          Text('D', style: TextStyle(fontSize: 35)),
          Text('E', style: TextStyle(fontSize: 35)),
        ],
      )
    );
  }
}
