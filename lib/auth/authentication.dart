import "package:firebase_auth/firebase_auth.dart";
import "package:cloud_firestore/cloud_firestore.dart";

class AuthenticationService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<User?> createUserWithEmail(
    String email,
    String password,
    String name,
    String studentId,
    String university,
  ) async {
    try {
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);

      User? user = userCredential.user;

      if (user != null) {
        await saveUserDetails(name, studentId, email, university);
      }
      return user;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> saveUserDetails(
    String name,
    String studentID,
    String email,
    String university,
  ) async {
    User? user = _auth.currentUser;

    if (user != null) {
      try {
        await _firestore.collection('users').doc(user.uid).set({
          'name': name,
          'Id': studentID,
          'email': email,
          'university': university,
          'role': 0, // role-based numbering: 0-Std, 1-Club Orgi, 2-Admin
        });
      } catch (e) {
        rethrow;
      }
    }
  }

  Future<User?> signInWithEmail(String email, String password) async {
    if (!RegExp(r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.edu$").hasMatch(email)) {
      throw FirebaseAuthException(
        code: 'invalid-email',
        message: 'Invalid email format',
      );
    }

    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } on FirebaseAuthException {
      rethrow;
    }
  }
}
