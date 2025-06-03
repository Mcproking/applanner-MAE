import 'package:applanner/auth/login.dart';
import 'package:applanner/main/navigation_bar.dart';
import 'package:applanner/main/splashScreen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';

// Refer to User Credentials.txt for different user role login

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'APPlanner',
      theme: ThemeData.dark().copyWith(scaffoldBackgroundColor: Colors.black),
      home: AuthGate(),
      color: Color.fromARGB(255, 18, 18, 18),
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Widget>(
      future: _getCurrentUser(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Splashscreen();
        }

        if (snapshot.hasData) {
          return snapshot.data!;
        } else {
          return const LoginPage();
        }
      },
    );
  }

  Future<Widget> _getCurrentUser() async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      String uid = user.uid;
      DocumentSnapshot<Map<String, dynamic>> userDoc =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();

      if (userDoc.exists) {
        int? role = userDoc.data()?['role'];

        switch (role) {
          case 0:
            return MainMenu();
          case 1:
            return MainMenu();
          case 2:
            return MainMenu();
          case null:
            // if the user data do not have role-related numbering
            throw FirebaseAuthException(
              code: 'internal-error',
              message: 'user data error',
            );
          default:
            // if the user data do not have role-related numbering
            throw FirebaseAuthException(
              code: 'internal-error',
              message: 'user data error',
            );
        }
      }
    }

    // If no user get from Auth
    return LoginPage();
  }
}
