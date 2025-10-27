import 'package:flutter/material.dart';

class TestPage extends StatelessWidget {
  const TestPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Teste'),),
      body: Padding(padding: EdgeInsets.all(16.0), child: Column(children: [
        ListTile(
          title: Text('Bruh'),
        ),
        Text('OI'),
      ],),),
      bottomNavigationBar: BottomNavigationBar(
          items: [
        BottomNavigationBarItem(
          icon: Icon(Icons.train_sharp),
          label: 'Train',
          tooltip: 'I always come back',
        ),
        BottomNavigationBarItem(
          label: 'Lol Lmao',
          tooltip: 'XD ez bro so ez',
            ),
      ]),
    );
  }
}
