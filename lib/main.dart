import 'package:applanner/auth/login.dart';
import 'package:applanner/auth/signup.dart';
import 'package:applanner/main/navigation_bar.dart';
import 'package:applanner/main/splashScreen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';

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
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Color.fromARGB(255, 90, 133, 243),
        ),
        useMaterial3: true,
      ),
      home: AuthGate(),
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
          // Notification related???
          // handle notifcation press related???
          return snapshot.data!;
        } else {
          return const Splashscreen();
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
            break;
          case 1:
            // rediect to club orgi page
            break;
          case 2:
            // redirect to admin page
            break;
          case null:
            print("Debug: Role data doesn't exist");
            // if the user data do not have role-related numbering
            throw FirebaseAuthException(
              code: 'internal-error',
              message: 'user data error',
            );
          default:
            print("Debug: Other issue here");
            // if the user data do not have role-related numbering
            throw FirebaseAuthException(
              code: 'internal-error',
              message: 'user data error',
            );
        }
      }
    }

    // If no user get from Auth
    return MainMenu();
  }
}
