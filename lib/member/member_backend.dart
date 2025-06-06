import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MemberService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<bool?> joinEvent(String uid) async {
    try {
      bool isJoinedEvent = false, isJoinedUser = false;
      final eventRef = _firestore.collection('events').doc(uid);
      String useruid = _auth.currentUser!.uid;
      final userRef = _firestore.collection('users').doc(useruid);
      final eventData = await eventRef.get();
      final userData = await userRef.get();

      if (eventData.exists && eventData.data() != null) {
        List<DocumentReference>? eventJoinedArray, userJoinedArray;

        if (eventData.data()?.containsKey('rsvp') == true) {
          final rsvpRaw = eventData['rsvp'] as List<dynamic>;
          eventJoinedArray = rsvpRaw.cast<DocumentReference>();
        }

        if (userData.data()?.containsKey('rsvp') == true) {
          final rsvpRaw = userData['rsvp'] as List<dynamic>;
          userJoinedArray = rsvpRaw.cast<DocumentReference>();
        }

        // if the event nor user do not have rsvp yet in db
        Map<String, dynamic> rsvpEvent = {
          'rsvp': [userRef],
        };

        Map<String, dynamic> rsvpUser = {
          'rsvp': [eventRef],
        };

        // if the event do not have rsvp
        if (eventJoinedArray == null) {
          await eventRef.update(rsvpEvent);
          isJoinedEvent = true;
        }
        // if the event have rsvp, but the user is not rsvp
        else if (!eventJoinedArray.contains(userRef)) {
          await eventRef.update({
            'rsvp': FieldValue.arrayUnion([userRef]),
          });
          isJoinedEvent = true;
        }

        // if the user do not have rsvp
        if (userJoinedArray == null) {
          await userRef.update(rsvpUser);
          isJoinedUser = true;
        } else if (!userJoinedArray.contains(eventRef)) {
          await userRef.update({
            'rsvp': FieldValue.arrayUnion([eventRef]),
          });
          isJoinedUser = true;
        }

        return isJoinedEvent && isJoinedUser == true ? true : null;
      } else {
        return false;
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<bool?> attendEvent(String uid) async {
    try {
      String userUid = _auth.currentUser!.uid;
      final userRef = _firestore.collection('users').doc(userUid);
      final eventRef = _firestore.collection('events').doc(uid);
      final eventData = await eventRef.get();

      if (eventData.data()?.containsKey('attended') == true) {
        await eventRef.update({
          'attended': FieldValue.arrayUnion([userRef]),
        });
        return true;
      } else {
        await eventRef.update({
          'attended': [userRef],
        });
        return true;
      }
    } catch (e) {
      rethrow;
    }
  }
}
