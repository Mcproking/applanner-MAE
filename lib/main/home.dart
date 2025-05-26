import 'package:flutter/material.dart';

class Home extends StatefulWidget {
  Home({super.key});

  @override
  State<StatefulWidget> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.purple,
      body: Stack(
        children: [
          Positioned(
            child: Row(
              children: [
                SingleChildScrollView(
                  child: Form(child: Column(children: [const Text('helo')])),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
