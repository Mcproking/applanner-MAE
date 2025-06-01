import 'package:applanner/member/member_rsvpList.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class MemberMenu extends StatefulWidget {
  final int initIndex;

  const MemberMenu({super.key, this.initIndex = 0});

  @override
  State<StatefulWidget> createState() => _MembernMenuState();
}

class _MembernMenuState extends State<MemberMenu> {
  String _name = 'Temp';
  String? _profileUrl;

  bool _isLoading = false;

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
            _isLoading = false;
          });
        } else {
          setState(() {
            _name = 'Temp';
            _profileUrl = null;
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      setState(() {
        _name = 'Temp';
        _profileUrl = null;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 18, 18, 18),
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(20),
          child: IntrinsicHeight(
            child:
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : Column(
                      children: [
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
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              "What would you want to do?",
                              style: TextStyle(fontSize: 20),
                            ),
                          ],
                        ),

                        Divider(),
                        const SizedBox(height: 8),

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
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => RSVPList(),
                                      ),
                                    );
                                  },
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
                                        Icon(Icons.event_note),
                                        const SizedBox(width: 8),
                                        Text(
                                          "Manage RSVP",
                                          style: TextStyle(fontSize: 24),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                            ],
                          ),
                        ),
                      ],
                    ),
          ),
        ),
      ),
    );
  }
}
