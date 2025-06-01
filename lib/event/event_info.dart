import 'package:applanner/member/member_backend.dart';
import 'package:applanner/others/dropdownConst.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class MoreEvent extends StatefulWidget {
  late String uid;

  MoreEvent({super.key, required this.uid});

  @override
  State<StatefulWidget> createState() => _MoreEventState();
}

class _MoreEventState extends State<MoreEvent> {
  late String _uid;

  String _eventName = 'Temp Name';
  String _eventDesc = 'ababa';
  String _eventVenue = 'Venue';
  String _eventCatagory = 'Catagory';
  String _eventStartTime = '00:00';
  String _eventEndTime = '00:00';
  String _eventDate = 'Date ges herer';
  String _clubName = 'club name goes here';
  String? _eventImage;
  int _eventRSVP = 0;
  List<Map<String, dynamic>> _attendList = [];

  bool _isLoading = true;
  bool _isCompleted = false;

  MemberService _memberService = MemberService();

  @override
  void initState() {
    super.initState();
    _uid = widget.uid;
    _fetchEventData();
  }

  Future<void> _fetchEventData() async {
    try {
      final eventData =
          await FirebaseFirestore.instance.collection('events').doc(_uid).get();

      if (eventData.exists && eventData.data() != null) {
        if (eventData['club'] != null &&
            eventData['club'] is DocumentReference) {
          final clubSnapshot =
              await (eventData['club'] as DocumentReference).get();
          final clubData = clubSnapshot.data() as Map<String, dynamic>;

          if (clubSnapshot.exists && clubSnapshot.data() != null) {
            setState(() {
              _clubName = clubData['name'] ?? 'Unknown Club';
            });
          } else {
            setState(() {
              _clubName = 'Unknown Club';
            });
          }
        } else {
          setState(() {
            _clubName = 'Unknown Club';
          });
        }

        if (eventData.data()!.containsKey('isCompleted') == true) {
          List<DocumentReference>? attendListRaw;

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
            _attendList = rsvpUsers;
          });
        }

        setState(() {
          _eventName = eventData['name'];
          _eventDesc = eventData['description'];
          _eventDate = eventData['date'];
          _eventStartTime = eventData['start_time'];
          _eventEndTime = eventData['end_time'];

          for (var item in dropdownConst.dropdownCatagory) {
            final code = item['Code'];
            final catagory = item['Catagory'];
            if (eventData['catagory_key'] == code) {
              _eventCatagory = catagory;
            }
          }

          for (var item in dropdownConst.dropdownLocation) {
            final code = item['Code'];
            final name = item['Name'];
            if (eventData['location_key'] == code) {
              _eventVenue = name!;
            }
          }

          _eventImage =
              eventData.data()?.containsKey("imageURL") == true
                  ? eventData['imageURL']
                  : null;

          List<dynamic>? rsvpRaw =
              eventData.data()?.containsKey('rsvp') == true
                  ? eventData['rsvp']
                  : null;

          _eventRSVP = rsvpRaw != null ? rsvpRaw.length : 0;

          _isCompleted =
              eventData['isCompleted'] == true
                  ? eventData['isCompleted']
                  : false;

          _isLoading = false;
        });
      } else {
        setState(() {
          _eventName = "Unknown data";
          _eventDesc = "Unknown data";
          _eventDate = "Unknown data";
          _eventStartTime = "Unknwon data";
          _eventEndTime = "Unknown data";
          _eventCatagory = "Unknown Catagory";
          _eventVenue = "Unknown Venue";
        });
      }
    } catch (e) {
      print("debug: $e");
    }
  }

  Widget _buildCard(Map<String, dynamic> data, int index, int maxIndex) {
    return Container(
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
        color:
            index % 2 == 0
                ? Color.fromARGB(255, 153, 153, 153)
                : Colors.deepPurple.shade400,
        border: Border(
          bottom: BorderSide(
            color: Colors.white,
            width: index == maxIndex - 1 ? 0 : 2,
          ),
        ),
      ),
      padding: EdgeInsets.symmetric(vertical: 2, horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            data['name'] ?? 'Unknown Name',
            style: TextStyle(fontSize: 16, color: Colors.black),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Detail"),
        backgroundColor: Color.fromARGB(255, 51, 51, 51),
        shadowColor: Color.fromARGB(255, 119, 119, 119),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Show banner image in more bigger form
            SizedBox(
              width: MediaQuery.of(context).size.width,
              height: 250,
              child: Align(
                child: Image(
                  image:
                      _eventImage != null
                          ? NetworkImage(_eventImage!)
                          : AssetImage('images/event_default.jpg'),
                  fit: BoxFit.cover,
                  width: MediaQuery.of(context).size.width,
                ),
              ),
            ),

            // Details
            Container(
              padding: EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  //show name
                  Text(
                    _eventName,
                    style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),

                  // show description
                  Text(_eventDesc, style: TextStyle(fontSize: 20)),

                  // divider
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(child: Divider()),
                      const SizedBox(width: 8),
                      const Text("Event Details"),
                      const SizedBox(width: 8),
                      Expanded(child: Divider()),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // show remaining detail
                  //// Date
                  Text(
                    "Date: $_eventDate",
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 8),

                  //// Start Time
                  Text(
                    "Start Time: $_eventStartTime",
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 8),

                  //// End Time
                  Text(
                    "End Time: $_eventEndTime",
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 8),

                  //// Venue
                  Text(
                    "Venue: $_eventVenue",
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 8),

                  /// Catagory
                  Text(
                    "Catagory: $_eventCatagory",
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 8),

                  /// show num of rsvp's
                  Text(
                    "Number of RSVP: $_eventRSVP",
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 16),

                  // show rvsp button or show attend list
                  _isCompleted
                      ? Container(
                        decoration: BoxDecoration(),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Column(
                            children: [
                              // Header
                              Container(
                                width: MediaQuery.of(context).size.width,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: Color.fromARGB(255, 85, 85, 85),
                                  border: Border(
                                    bottom: BorderSide(
                                      color: Colors.white,
                                      width: 4,
                                    ),
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      "Attended Members",
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              SingleChildScrollView(
                                child: Column(
                                  children: [
                                    ...List.generate(_attendList.length, (
                                      index,
                                    ) {
                                      return _buildCard(
                                        _attendList[index],
                                        index,
                                        _attendList.length,
                                      );
                                    }),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                      : GestureDetector(
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              backgroundColor: Colors.greenAccent.shade100,
                              duration: Duration(milliseconds: 1500),
                              content: Row(
                                children: [
                                  // text prompt
                                  Expanded(
                                    child: const Text(
                                      "RVSP this Event?",
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ),

                                  GestureDetector(
                                    onTap: () async {
                                      bool? _isJoined;
                                      ScaffoldMessenger.of(
                                        context,
                                      ).hideCurrentSnackBar();

                                      _isJoined = await _memberService
                                          .joinEvent(_uid);

                                      if (_isJoined == null) {
                                        Navigator.pop(context, true);
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            backgroundColor:
                                                Colors
                                                    .lightGreenAccent
                                                    .shade400,
                                            duration: Duration(
                                              milliseconds: 1500,
                                            ),
                                            content: Text(
                                              "You have RSVP'ed this Event before",
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        );
                                      }

                                      if (_isJoined != null && _isJoined) {
                                        Navigator.pop(context, true);
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            backgroundColor:
                                                Colors.greenAccent.shade200,
                                            duration: Duration(
                                              milliseconds: 1500,
                                            ),
                                            content: Text(
                                              "RSVP'ed this Event",
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        );
                                      }

                                      if (_isJoined != null && !_isJoined) {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            backgroundColor:
                                                Colors.redAccent.shade200,
                                            duration: Duration(
                                              milliseconds: 1500,
                                            ),
                                            content: Text(
                                              "Internal Error",
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        );
                                      }
                                    },
                                    child: Container(
                                      padding: EdgeInsets.symmetric(
                                        vertical: 5,
                                        horizontal: 10,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.greenAccent.shade400,
                                        borderRadius: BorderRadius.circular(10),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black,
                                            offset: Offset(0, 2),
                                            blurRadius: 5,
                                            blurStyle: BlurStyle.inner,
                                          ),
                                        ],
                                      ),
                                      child: Text(
                                        "RSVP",
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 20,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            vertical: 16,
                            horizontal: 10,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.greenAccent.shade200,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.white,
                                offset: Offset(0, 2),
                                blurRadius: 5,
                                blurStyle: BlurStyle.inner,
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.book, color: Colors.black),
                              const SizedBox(width: 8),
                              Text(
                                "Book Now",
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
