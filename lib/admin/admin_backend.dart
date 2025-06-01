import 'package:cloud_firestore/cloud_firestore.dart';

class AdminService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<bool> manageEvenet(String uid, bool statement) async {
    bool isComplete = false;
    final club =
        await FirebaseFirestore.instance.collection('events').doc(uid).get();

    if (club.exists && club.data() != null) {
      try {
        await _firestore
            .collection('events')
            .doc(uid)
            .update({'isApproved': statement})
            .then((_) => isComplete = true)
            .catchError((err) {
              // print(err);
              isComplete = false;
              return isComplete;
            });
        return isComplete;
      } catch (e) {
        rethrow;
      }
    } else {
      return isComplete;
    }
  }
}
