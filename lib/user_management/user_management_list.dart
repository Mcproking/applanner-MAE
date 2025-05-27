import 'package:applanner/auth/login.dart';
import 'package:applanner/user_management/user_profile.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class UserManegementList extends StatefulWidget {
  UserManegementList({super.key});

  @override
  State<StatefulWidget> createState() => _UserManegementState();
}

class _UserManegementState extends State<UserManegementList> {
  static final List<Map<String, dynamic>> _listButton = [
    {
      'icon': Icons.account_box_rounded,
      'label': 'Account Details',
      'redirect': UserProfile(),
    },
  ];

  GestureDetector _buildCard(IconData icon, String label, Widget redirect) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => redirect),
        );
      },
      child: AnimatedContainer(
        duration: Duration(milliseconds: 100),
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
    return SingleChildScrollView(
      child: Column(
        children: [
          ...List.generate(_listButton.length, (index) {
            final item = _listButton[index];
            return _buildCard(item['icon'], item['label'], item['redirect']);
          }),

          // Logout Button
          GestureDetector(
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  backgroundColor: Colors.redAccent.shade200,
                  content: Row(
                    children: [
                      Expanded(
                        child: const Text(
                          "Proceed To Logout?",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          ScaffoldMessenger.of(context).hideCurrentSnackBar();
                          FirebaseAuth.instance.signOut().then((val) {
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const LoginPage(),
                              ),
                              (Route<dynamic> route) => false,
                            );
                          });
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Text(
                                'Account logged out successfully.',
                              ),
                              backgroundColor: Colors.green,
                            ),
                          );
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            vertical: 5,
                            horizontal: 10,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.redAccent.shade100,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black,
                                offset: Offset(0, 2),
                                blurRadius: 5,
                                blurStyle: BlurStyle.inner,
                              ),
                            ],
                          ),
                          child: Text(
                            "Logout",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.symmetric(
                    vertical: 30,
                    horizontal: 15,
                  ),
                  duration: const Duration(milliseconds: 3000),
                ),
              );
            },
            child: AnimatedContainer(
              duration: Duration(milliseconds: 100),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Colors.redAccent.shade400,
              ),
              padding: EdgeInsets.symmetric(vertical: 20, horizontal: 10),
              margin: EdgeInsets.fromLTRB(10, 5, 10, 10),
              child: Row(
                children: [
                  Icon(Icons.logout, size: 35),
                  const SizedBox(width: 10),
                  Text("Logout", style: TextStyle(fontSize: 24)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
