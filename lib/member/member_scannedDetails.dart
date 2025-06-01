import 'package:applanner/member/member_backend.dart';
import 'package:applanner/others/dropdownConst.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

class MemberScannedDetails extends StatefulWidget {
  late String uid;
  MemberScannedDetails({super.key, required this.uid});

  @override
  State<StatefulWidget> createState() => _MemberScannedDetails();
}

class _MemberScannedDetails extends State<MemberScannedDetails> {
  late String _uid;

  String _eventName = 'Temp Name';
  String _clubName = 'Unknown Club';
  String _eventVenue = 'Unknown Venue';

  List<Map<String, dynamic>> _attendList = [];
  List<DocumentReference>? _rsvpList;
  List<DocumentReference>? _attendRefList;

  MemberService _memberService = MemberService();

  bool _isAttendee = false;
  bool _isAttended = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _uid = widget.uid;
    _fetchEvent().then((_) => _compareAttendees());
  }

  Future<void> _compareAttendees() async {
    try {
      String userUid = FirebaseAuth.instance.currentUser!.uid;
      final userRef = FirebaseFirestore.instance
          .collection('users')
          .doc(userUid);

      // print(!_attendRefList!.contains(userRef));
      if (_rsvpList!.contains(userRef) && _attendRefList == null) {
        setState(() {
          _isAttendee = true;
          _isLoading = false;
        });
      } else if (_rsvpList!.contains(userRef) &&
          !_attendRefList!.contains(userRef)) {
        setState(() {
          _isAttendee = true;
          _isLoading = false;
        });
      } else {
        setState(() {
          _isAttended = true;
          _isAttendee = true;
          _isLoading = false;
        });
      }
    } catch (e) {
      print("Debug: $e");
    }
  }

  Future<void> _fetchEvent() async {
    if (!(_uid.isEmpty || _uid == '')) {
      final eventRef = FirebaseFirestore.instance
          .collection('events')
          .doc(_uid);
      final eventData = await eventRef.get();

      if (eventData.exists && eventData.data() != null) {
        final clubSnapshot =
            await (eventData['club'] as DocumentReference).get();
        final clubData = clubSnapshot.data() as Map<String, dynamic>;

        // get club name
        if (clubSnapshot.exists && clubSnapshot.data() != null) {
          setState(() {
            _clubName = clubData['name'] ?? 'Unknown club';
          });
        } else {
          setState(() {
            _clubName = 'Unknown club';
          });
        }
      } else {
        setState(() {
          _clubName = 'Unknown club';
        });
      }

      // get event name
      _eventName = eventData['name'];

      // et event venue
      for (var item in dropdownConst.dropdownLocation) {
        final code = item['Code'];
        final name = item['Name'];
        if (eventData['location_key'] == code) {
          _eventVenue = name!;
        }
      }

      // get rsvp list
      if (eventData.data()!.containsKey('rsvp') == true) {
        final rsvpRaw = eventData['rsvp'] as List<dynamic>;
        final List<DocumentReference> rsvpRefs =
            rsvpRaw.cast<DocumentReference>();

        List<Map<String, dynamic>> rsvpUsers = [];

        for (DocumentReference ref in rsvpRefs) {
          final snapshot = await ref.get();
          if (snapshot.exists && snapshot.data() != null) {
            rsvpUsers.add(snapshot.data() as Map<String, dynamic>);
          }
        }

        setState(() {
          _rsvpList = rsvpRefs;
          _attendList = rsvpUsers;
        });
      }

      if (eventData.data()!.containsKey('attended') == true) {
        final attendedRaw = eventData['attended'] as List<dynamic>;
        final List<DocumentReference> attendedRefs =
            attendedRaw.cast<DocumentReference>();

        List<Map<String, dynamic>> rsvpUsers = [];

        for (DocumentReference ref in attendedRefs) {
          final snapshot = await ref.get();
          if (snapshot.exists && snapshot.data() != null) {
            rsvpUsers.add(snapshot.data() as Map<String, dynamic>);
          }
        }

        setState(() {
          _attendRefList = attendedRefs;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(
          context,
          true,
        ); // Send `false` back to the previous screen
        return false; // Prevent default pop (because we already did it manually)
      },
      child: Scaffold(
        appBar: AppBar(title: Text("Scanned Event Code")),
        body: SafeArea(
          child: SingleChildScrollView(
            child: Container(
              width: MediaQuery.of(context).size.width,
              padding: const EdgeInsets.all(20),
              child:
                  _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            _eventName,
                            style: TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            "By $_eventName",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            _eventVenue,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 28),

                          Text(
                            "Wish to attend this event?",
                            style: TextStyle(fontSize: 20),
                          ),
                          const SizedBox(height: 8),

                          !_isAttendee
                              ? const Text("You did not RSVP this event")
                              : _isAttended
                              ? const Text("You already attended this event")
                              : GestureDetector(
                                onTap: () async {
                                  bool? isCompleted;

                                  isCompleted = await _memberService
                                      .attendEvent(_uid);

                                  if (isCompleted == true) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        backgroundColor:
                                            Colors.greenAccent.shade200,
                                        content: Text("Enjoy your event"),
                                      ),
                                    );

                                    Navigator.pop(context, true);
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text("Internal Error"),
                                        backgroundColor:
                                            Colors.redAccent.shade200,
                                      ),
                                    );
                                  }
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.greenAccent.shade200,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  padding: EdgeInsets.symmetric(
                                    vertical: 15,
                                    horizontal: 30,
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(Icons.check, color: Colors.black),
                                      const SizedBox(width: 12),
                                      Text(
                                        "Attend this event",
                                        style: TextStyle(color: Colors.black),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                          const SizedBox(height: 20),
                        ],
                      ),
            ),
          ),
        ),
      ),
    );
  }
}
