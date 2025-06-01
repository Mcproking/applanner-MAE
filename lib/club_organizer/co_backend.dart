import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class OrganizerService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<bool> createEvent(
    String eventName,
    String description,
    String catagoryKey,
    String date,
    String startTime,
    String endTime,
    String locationKey,
    DocumentReference clubRef,
  ) async {
    User? user = _auth.currentUser;
    bool _isComplete = false;

    if (user != null) {
      String uid = user.uid;
      DocumentSnapshot<Map<String, dynamic>> userDoc =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();

      if (userDoc.exists && userDoc.data() != null && userDoc['role'] == 1) {
        try {
          await _firestore
              .collection('events')
              .add({
                'name': eventName,
                'description': description,
                'catagory_key': catagoryKey,
                'date': date,
                'start_time': startTime,
                'end_time': endTime,
                'location_key': locationKey,
                'club': clubRef,
              })
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
    } else {
      return _isComplete;
    }
  }

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

  Future<bool?> completeEvent(String uid) async {
    final eventRef = _firestore.collection('events').doc(uid);
    final eventData = await eventRef.get();

    if (eventData.exists && eventData.data() != null) {
      try {
        eventRef.update({'isCompleted': true});
        return true;
      } catch (e) {
        rethrow;
      }
    }
    return null;
  }
}
