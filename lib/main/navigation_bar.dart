import 'package:applanner/admin/admin_dashboard.dart';
import 'package:applanner/main/club.dart';
import 'package:applanner/main/event.dart';
import 'package:applanner/main/home.dart';
import 'package:applanner/main/more.dart';
import 'package:applanner/member/member_scanQR.dart';
import 'package:applanner/user_management/user_management_list.dart';
import 'package:applanner/user_management/user_profile.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
  String _name = 'Temp';
  int _role = 0;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
    _fetchUserData(); // init the passed index
  }

  // static List<Widget> _screens = <Widget>[Home(), UserManegementList()];

  final List<Map<String, dynamic>> _screens = [
    {
      'icon': Icons.home,
      'icon_select': Icons.home_outlined,
      'label': 'Home',
      'redirect': Home(),
    },
    {
      'icon': Icons.accessible_forward,
      'icon_select': Icons.accessible,
      'label': 'Events',
      'redirect': Event(),
    },
    {
      'icon': Icons.qr_code_scanner,
      'icon_select': Icons.qr_code_outlined,
      'label': 'Scan',
      'redirect': MemberScanQR(),
    },
    {
      'icon': Icons.group,
      'icon_select': Icons.group_outlined,
      'label': 'Clubs',
      'redirect': Club(),
    },
    {
      'icon': Icons.menu,
      'icon_select': Icons.menu_outlined,
      'label': 'More',
      'redirect': MoreMenu(),
    },
  ];

  final List<Map<String, dynamic>> _adminScreen = [
    {
      'icon': Icons.home,
      'icon_select': Icons.home_outlined,
      'label': 'Home',
      'redirect': AdminMenu(),
    },
    {
      'icon': Icons.event,
      'icon_select': Icons.event_outlined,
      'label': 'Event',
      'redirect': Event(),
    },
    {
      'icon': Icons.group,
      'icon_select': Icons.group_outlined,
      'label': 'Clubs',
      'redirect': Club(),
    },
  ];

  String? _profileUrl;

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
            Container(child: _topNavigationBar()),
            Expanded(
              child:
                  _role == 2
                      ? _adminScreen[_selectedIndex]['redirect']
                      : _screens[_selectedIndex]['redirect'],
            ),
            Container(child: _bottomNavigationBar()),
          ],
        ),
      ),
    );
  }

  Future<void> _fetchUserData() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final userData =
            await FirebaseFirestore.instance
                .collection('users')
                .doc(user.uid)
                .get();

        if (userData.exists && userData.data() != null) {
          setState(() {
            _name = userData.data()?['name'] ?? 'Temp';
            _role = userData.data()?['role'] ?? '0';
            _profileUrl =
                userData.data()?.containsKey('profile_pic') == true
                    ? userData['profile_pic']
                    : null;
          });
        } else {
          setState(() {
            _name = 'Temp';
            _role = 0;
            _profileUrl = null;
          });
        }
      }
    } catch (e) {
      setState(() {
        _name = 'Temp';
        _role = 0;
        _profileUrl = null;
      });
    }
  }

  Widget _topNavigationBar() {
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
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => UserManegementList()),
              );
            },
            child: CircleAvatar(
              backgroundImage:
                  _profileUrl != null
                      ? NetworkImage(_profileUrl!)
                      : const AssetImage('images/profile/default_profile.png')
                          as ImageProvider,
            ),
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
        children:
            _role == 2
                ? List.generate(_adminScreen.length, (index) {
                  final item = _adminScreen[index];
                  return _buildNavItem(
                    index,
                    item['icon'],
                    item['icon_select'],
                    item['label'],
                  );
                })
                : List.generate(_screens.length, (index) {
                  final item = _screens[index];
                  return _buildNavItem(
                    index,
                    item['icon'],
                    item['icon_select'],
                    item['label'],
                  );
                }),
      ),
    );
  }

  Widget _buildNavItem(
    int index,
    IconData icon,
    IconData iconSelected,
    String label,
  ) {
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
                isSelected ? iconSelected : icon,
                color: iconColor,
                size: 30,
              ),
              Text(label),
            ],
          ),
        ),
      ),
    );
  }
}
