import 'dart:ffi';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MemberService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<bool?> joinEvent(String uid) async {
    try {
      bool _isJoinedEvent = false, _isJoinedUser = false;
      final eventRef = await _firestore.collection('events').doc(uid);
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
          _isJoinedEvent = true;
        }
        // if the event have rsvp, but the user is not rsvp
        else if (eventJoinedArray != null &&
            !eventJoinedArray.contains(userRef)) {
          await eventRef.update({
            'rsvp': FieldValue.arrayUnion([userRef]),
          });
          _isJoinedEvent = true;
        }

        // if the user do not have rsvp
        if (userJoinedArray == null) {
          await userRef.update(rsvpUser);
          _isJoinedUser = true;
        } else if (userJoinedArray != null &&
            !userJoinedArray.contains(eventRef)) {
          await userRef.update({
            'rsvp': FieldValue.arrayUnion([eventRef]),
          });
          _isJoinedUser = true;
        }

        return _isJoinedEvent && _isJoinedEvent == true ? true : null;
      } else {
        return false;
      }
    } catch (e) {
      rethrow;
    }
  }
}
