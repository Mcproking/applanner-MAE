import 'package:applanner/main/home.dart';
import 'package:applanner/user_management/user_management_list.dart';
import 'package:applanner/user_management/user_profile.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class MainMenu extends StatefulWidget {
  final int initialIndex;

  MainMenu({super.key, this.initialIndex = 0});

  @override
  State<StatefulWidget> createState() => _MainMenuState();
}

class _MainMenuState extends State<MainMenu> {
  late int _selectedIndex;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex; // init the passed index
  }

  static List<Widget> _screens = <Widget>[Home(), UserManegementList()];

  // lets say 4 screen 1 scan QR

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 18, 18, 18),
      body: SafeArea(
        child: Flex(
          direction: Axis.vertical,
          children: [
            Container(child: _TopNavigationBar()),
            Expanded(child: _screens[_selectedIndex]),
            Container(child: _bottomNavigationBar()),
          ],
        ),
      ),
    );
  }

  Widget _TopNavigationBar() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
      decoration: BoxDecoration(color: Color.fromARGB(255, 51, 51, 51)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Image.asset(
            'images/applannerlighttheme.png',
            width: MediaQuery.of(context).size.width * 0.3,
            height: MediaQuery.of(context).size.height * 0.05,
          ),
          Container(
            color: Colors.pink,
            child: Text("something else goes here"),
          ),
        ],
      ),
    );
  }

  Widget _bottomNavigationBar() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 5.0, vertical: 15),
      decoration: BoxDecoration(color: Color.fromARGB(255, 51, 51, 51)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(_screens.length, (index) {
          return _buildNavItem(index);
        }),
      ),
    );
  }

  Widget _buildNavItem(int index) {
    final isSelected = _selectedIndex == index;
    final iconColor =
        isSelected ? Color.fromARGB(255, 153, 153, 153) : Colors.purple;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          _onItemTapped(index);
        },
        child: AnimatedContainer(
          duration: Duration(milliseconds: 100),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(20)),
            color:
                isSelected
                    ? Color.fromARGB(255, 134, 53, 214)
                    : Colors.transparent,
            border: Border(
              bottom:
                  isSelected
                      ? BorderSide(
                        color: Color.fromARGB(255, 134, 53, 214),
                        width: 2.0,
                      )
                      : BorderSide.none,
            ),
          ),
          padding: EdgeInsets.symmetric(vertical: 3.0),
          margin: EdgeInsets.only(left: 5, right: 5),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(
                isSelected
                    ? (index == 0
                        ? Icons.home_outlined
                        : index == 1
                        ? Icons.account_box
                        : Icons.more_horiz_outlined)
                    : (index == 0
                        ? Icons.home
                        : index == 1
                        ? Icons.account_box_outlined
                        : Icons.more_horiz),
                color: iconColor,
                size: 30,
              ),
              Text((index == 0 ? "Home" : "More")),
            ],
          ),
        ),
      ),
    );
  }
}
