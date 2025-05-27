import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class UserProfile extends StatefulWidget {
  UserProfile({super.key});

  @override
  State<StatefulWidget> createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {
  String _studentId = 'T123';
  String _studentName = 'Temp';
  String _email = 'temp@uni.edu';
  String _university = 'Temp University';
  String? _profileImageUrl;

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUserProfile();
  }

  Future<void> _fetchUserProfile() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final userEmail = user.email ?? 'temp@uni.edu';
        final userData =
            await FirebaseFirestore.instance
                .collection('users')
                .doc(user.uid)
                .get();

        if (userData.exists && userData.data() != null) {
          setState(() {
            _studentId = userData['Id'] ?? "T123";
            _studentName = userData['name'] ?? 'Guest';
            _email = userEmail;
            _university = userData['university'] ?? 'Temp University';
            _profileImageUrl =
                userData.data()?.containsKey('profile_pic') == true
                    ? userData['proile_pic']
                    : null;
            _isLoading = false;
          });
        } else {
          setState(() {
            _studentName = 'Temp';
            _email = 'temp@uni.edu';
            _profileImageUrl = null;
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      setState(() {
        _studentName = 'Temp';
        _email = 'temp@uni.edu';
        _profileImageUrl = null;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 18, 18, 18),
      appBar: AppBar(
        title: const Text("Profile"),
        backgroundColor: Color.fromARGB(255, 51, 51, 51),
        shadowColor: Color.fromARGB(255, 119, 119, 119),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              //image, need to add stack to add edit pen
              Stack(
                alignment: Alignment(0.7, 0.7),
                children: [
                  // image
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: CircleAvatar(
                      radius: 60.0,
                      backgroundImage:
                          _profileImageUrl != null
                              ? NetworkImage(_profileImageUrl!)
                              : const AssetImage(
                                    'images/profile/default_profile.png',
                                  )
                                  as ImageProvider,
                    ),
                  ),

                  // editing pen
                  GestureDetector(
                    onTap: () {
                      print('Redirect to upload_profile.dart');
                    },
                    child: AnimatedContainer(
                      duration: Duration(milliseconds: 200),
                      padding: EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: Colors.grey,
                        borderRadius: BorderRadius.circular(60),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black,
                            offset: Offset(0, 2),
                            blurRadius: 5,
                          ),
                        ],
                      ),
                      child: Icon(Icons.edit, size: 30),
                    ),
                  ),
                ],
              ),

              // Student ID
              SizedBox(
                width: MediaQuery.of(context).size.width,
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: 'ID',
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 15,
                      vertical: 5,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Colors.white),
                    ),
                  ),
                  child: Text(
                    _studentId,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Student Name
              SizedBox(
                width: MediaQuery.of(context).size.width,
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: 'Name',
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 15,
                      vertical: 5,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Colors.white),
                    ),
                  ),
                  child: Text(
                    _studentName,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Email
              SizedBox(
                width: MediaQuery.of(context).size.width,
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: 'Email',
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 15,
                      vertical: 5,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Colors.white),
                    ),
                  ),
                  child: Text(
                    _email,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // University
              SizedBox(
                width: MediaQuery.of(context).size.width,
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: 'University',
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 15,
                      vertical: 5,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Colors.white),
                    ),
                  ),
                  child: Text(
                    _university,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Button functions
              GestureDetector(
                onTap: () {},

                child: AnimatedContainer(
                  duration: Duration(milliseconds: 200),
                  decoration: BoxDecoration(
                    color: Color.fromARGB(255, 134, 53, 214),
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black,
                        offset: Offset(0, 2),
                        blurRadius: 2,
                      ),
                    ],
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                  child: Row(
                    children: [
                      Icon(Icons.edit),
                      const SizedBox(width: 5),
                      const Text(
                        "Edit Profile",
                        style: TextStyle(color: Colors.white, fontSize: 20),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 15),

              GestureDetector(
                onTap: () {},
                child: AnimatedContainer(
                  duration: Duration(milliseconds: 200),
                  decoration: BoxDecoration(
                    color: Colors.pink,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                  child: Row(
                    children: [
                      Icon(Icons.delete),
                      const SizedBox(width: 5),
                      const Text(
                        "Delete Account",
                        style: TextStyle(color: Colors.white, fontSize: 20),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
