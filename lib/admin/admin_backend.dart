import 'package:cloud_firestore/cloud_firestore.dart';

class AdminService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<bool> manageEvenet(String uid, bool statement) async {
    bool _isComplete = false;
    final club =
        await FirebaseFirestore.instance.collection('events').doc(uid).get();

    if (club.exists && club.data() != null) {
      try {
        await _firestore
            .collection('events')
            .doc(uid)
            .update({'isApproved': statement})
            .then((_) => _isComplete = true)
            .catchError((err) {
              print(err);
              _isComplete = false;
            });
        return _isComplete;
      } catch (e) {
        rethrow;
      }
    } else {
      return _isComplete;
    }
  }
}
