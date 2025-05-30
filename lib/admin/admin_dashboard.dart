import 'package:applanner/auth/login.dart';
import 'package:applanner/main/club.dart';
import 'package:applanner/main/event.dart';
import 'package:applanner/main/navigation_bar.dart';
import 'package:applanner/user_management/user_management_list.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AdminMenu extends StatefulWidget {
  final int initIndex;

  AdminMenu({super.key, this.initIndex = 0});

  @override
  State<StatefulWidget> createState() => _AdminMenuState();
}

class _AdminMenuState extends State<AdminMenu> {
  String _name = 'Temp';
  String? _profileUrl;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
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
            _profileUrl =
                userData.data()?.containsKey('profile_pic') == true
                    ? userData['profile_pic']
                    : null;
          });
        } else {
          setState(() {
            _name = 'Temp';
            _profileUrl = null;
          });
        }
      }
    } catch (e) {
      setState(() {
        _name = 'Temp';
        _profileUrl = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 20),
            // Show image and name
            Column(
              children: [
                CircleAvatar(
                  radius: 60,
                  backgroundImage:
                      _profileUrl != null
                          ? NetworkImage(_profileUrl!)
                          : const AssetImage(
                                'images/profile/default_profile.png',
                              )
                              as ImageProvider,
                ),

                const SizedBox(height: 20),
                Text(
                  "Welcome, $_name",
                  style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                ),
                Text(
                  "What would you want to do?",
                  style: TextStyle(fontSize: 20),
                ),
              ],
            ),

            Divider(),
            const SizedBox(height: 8),

            // show all the event that is created
            
            // add another button to redirect to list of all events 
            // Show Action Button
            const SizedBox(height: 8),
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(width: 16),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {},
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 10,
                          horizontal: 20,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Color.fromARGB(255, 134, 53, 214),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.group),
                            const SizedBox(width: 8),
                            Text("Clubs", style: TextStyle(fontSize: 24)),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 32),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {},
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 10,
                          horizontal: 20,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Color.fromARGB(255, 134, 53, 214),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.event),
                            const SizedBox(width: 8),
                            Text("Events", style: TextStyle(fontSize: 24)),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                ],
              ),
            ),

            // maybe show all the newly created event need to approve?
          ],
        ),
      ),
    );
  }
}
