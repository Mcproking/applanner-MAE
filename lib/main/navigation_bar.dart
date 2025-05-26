import 'package:applanner/main/home.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class MainMenu extends StatefulWidget {
  MainMenu({super.key});

  @override
  State<StatefulWidget> createState() => _MainMenuState();
}

class _MainMenuState extends State<MainMenu> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green,
      body: SafeArea(
        child: Flex(
          mainAxisAlignment: MainAxisAlignment.start,
          direction: Axis.vertical,
          children: [
            Positioned(left: 0, right: 0, top: 0, child: _TopNavigationBar()),

            Padding(padding: const EdgeInsets.only(top: 30), child: Home()),
          ],
        ),
      ),
    );
  }

  Widget _TopNavigationBar() {
    return Container(
      padding: EdgeInsets.all(5),
      margin: EdgeInsets.only(),
      decoration: BoxDecoration(color: Colors.blueAccent),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Image(
            image: AssetImage('images/applannerlighttheme.png'),
            width: 36,
            height: 20,
          ),
          Container(color: Colors.pink, child: Text("image goes here lmao")),
        ],
      ),
    );
  }
}
