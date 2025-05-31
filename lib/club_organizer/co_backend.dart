import 'package:cloud_firestore/cloud_firestore.dart';

class ClubOrgService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<bool> deleteEvent(String uid) async {
    bool _isComplete = false;
    print(uid);
    try {
      await _firestore.collection('events').doc(uid).delete();
      _isComplete = true;
      return _isComplete;
    } catch (e) {
      rethrow;
    }
  }
}
