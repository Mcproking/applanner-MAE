import 'package:applanner/club_organizer/co_ManageEvent.dart';
import 'package:applanner/member/member_rsvpList.dart';
import 'package:flutter/material.dart';

class MoreMenu extends StatefulWidget {
  MoreMenu({super.key});

  @override
  State<StatefulWidget> createState() => _MoreMenuState();
}

class _MoreMenuState extends State<MoreMenu> {
  static final List<Map<String, dynamic>> _listButton = [
    {
      'icon': Icons.event_note,
      'label': 'Created Events',
      'redirect': ClubOrgManageEvent(),
    },
    {
      'icon': Icons.event_available,
      'label': "RSVP'ed Events",
      'redirect': RSVPList(),
    },
  ];

  Widget _buildCard(IconData icon, String label, Widget redirect) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => redirect),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Color.fromARGB(255, 119, 119, 119),
        ),
        padding: EdgeInsets.symmetric(vertical: 20, horizontal: 10),
        margin: EdgeInsets.fromLTRB(10, 10, 10, 5),
        child: Row(
          children: [
            Icon(icon, size: 35),
            const SizedBox(width: 10),
            Text(label, style: TextStyle(fontSize: 24, color: Colors.white)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            ...List.generate(_listButton.length, (index) {
              final item = _listButton[index];
              return _buildCard(item['icon'], item['label'], item['redirect']);
            }),
          ],
        ),
      ),
    );
  }
}
