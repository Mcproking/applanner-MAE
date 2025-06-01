import 'package:applanner/event/add_event.dart';
import 'package:applanner/event/event_info.dart';
import 'package:applanner/others/dropdownConst.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Event extends StatefulWidget {
  const Event({super.key});

  @override
  State<StatefulWidget> createState() => _EventState();
}

class _EventState extends State<Event> {
  DocumentReference? _clubOrgRef;

  int _userRole = 0;
  bool _isLoading = true;
  final bool _isEmpty = false;

  List<Map<String, dynamic>> _eventList = [];

  @override
  void initState() {
    super.initState();
    _fetchAllEvent();
    _getCurrentUser().then((_) => _fetchClubRef());
  }

  Future<void> _getCurrentUser() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final userData =
            await FirebaseFirestore.instance
                .collection('users')
                .doc(user.uid)
                .get();

        if (userData.exists && userData.data() != null) {
          setState(() {
            _userRole = userData['role'] ?? 0;
          });
        } else {
          setState(() {
            _userRole = userData['role'] ?? 0;
          });
        }
      }
    } catch (e) {
      setState(() {
        _userRole = 0;
      });
    }
  }

  Future<void> _fetchClubRef() async {
    if (_userRole == 1) {
      final user = FirebaseAuth.instance.currentUser;
      final userData =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user?.uid)
              .get();

      if (userData.exists && userData.data() != null) {
        setState(() {
          _clubOrgRef =
              userData['club_org'] is DocumentReference
                  ? userData['club_org']
                  : null;
        });
      } else {
        setState(() {
          _clubOrgRef = null;
        });
      }
    } else {
      setState(() {
        _clubOrgRef = null;
      });
    }
  }

  Future<void> _fetchAllEvent() async {
    try {
      final snapshot =
          await FirebaseFirestore.instance.collection('events').get();

      final List<Map<String, dynamic>> events = [];

      for (var docs in snapshot.docs) {
        final data = docs.data();
        data['id'] = docs.id;
        for (var item in dropdownConst.dropdownLocation) {
          final code = item['Code'];
          final name = item['Name'];
          if (data['location_key'] == code) {
            data['venue'] = name;
          }
        }

        data['event_image_URL'] =
            data.containsKey('imageURL') == true ? data['imageURL'] : null;

        if (data['club'] != null && data['club'] is DocumentReference) {
          final clubSnapshot = await (data['club'] as DocumentReference).get();
          final clubData = clubSnapshot.data() as Map<String, dynamic>;

          if (clubSnapshot.exists && clubSnapshot.data() != null) {
            setState(() {
              data['clubName'] = clubData['name'] ?? 'Unknown club';
            });
          } else {
            setState(() {
              data['clubName'] = 'Unknown club';
            });
          }
        } else {
          setState(() {
            data['clubName'] = 'Unknown club';
          });
        }

        events.add(data);
      }

      setState(() {
        _eventList = events;
        _isLoading = false;
      });
    } catch (e) {
      // print("Error fetching clubs: $e");
    }
  }

  Widget _buildEventCard(
    String uid,
    String eventName,
    String clubName,
    String date,
    String time,
    String venue,
    String description,
    String? eventImageURL,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Color.fromARGB(255, 85, 85, 85),
        borderRadius: BorderRadius.circular(5),
      ),
      margin: EdgeInsets.fromLTRB(0, 0, 0, 15),
      child: Column(
        children: [
          // Event Image : image cant be moved?
          ClipRRect(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(5),
              topRight: Radius.circular(5),
            ),
            child: SizedBox(
              width: MediaQuery.of(context).size.width,
              height: 80,
              child: Align(
                alignment: Alignment.center,
                child: Image(
                  image:
                      eventImageURL != null
                          ? NetworkImage(eventImageURL)
                          : AssetImage('images/event_default.png'),
                  fit: BoxFit.cover,
                  width: MediaQuery.of(context).size.width,
                ),
              ),
            ),
          ),

          Container(
            padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
            child: Column(
              children: [
                // Event titile
                Row(
                  children: [
                    Text(
                      eventName,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),

                // Make the club name pressable
                Row(children: [const Text("Organized By: "), Text(clubName)]),
                Row(children: [const Text("Date: "), Text(date)]),
                Row(children: [const Text("Time: "), Text(time)]),
                Row(children: [const Text("Venue: "), Text(venue)]),
                // descriptions
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        description,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                Divider(),

                // Actions buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _userRole != 0
                        ? const SizedBox.shrink()
                        :
                        // Book Button
                        GestureDetector(
                          onTap: () {},
                          child: Container(
                            decoration: BoxDecoration(
                              color: Color.fromARGB(255, 35, 175, 11),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: EdgeInsets.symmetric(
                              vertical: 10,
                              horizontal: 15,
                            ),
                            child: Row(
                              children: [
                                const Text(
                                  "Book",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Icon(Icons.book),
                              ],
                            ),
                          ),
                        ),

                    // More Info Button
                    GestureDetector(
                      onTap: () async {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => MoreEvent(uid: uid),
                          ),
                        ).then((result) {});
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: Color.fromARGB(255, 93, 36, 149),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: EdgeInsets.symmetric(
                          vertical: 10,
                          horizontal: 15,
                        ),
                        child: Row(
                          children: [
                            const Text(
                              "More Info",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(width: 4),
                            Icon(Icons.info),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // TODO: Need to fix the bug that the [+] is not located to the bottom
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 18, 18, 18),
      resizeToAvoidBottomInset: true,
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Stack(
                children: [
                  _isEmpty
                      ? const Center(child: Text("No Event Avaliable"))
                      // List all the events
                      : SingleChildScrollView(
                        padding: const EdgeInsets.all(10),
                        child: IntrinsicHeight(
                          child: Column(
                            children: [
                              ...List.generate(_eventList.length, (index) {
                                final item = _eventList[index];
                                if (item.containsKey('isApproved') == true) {
                                  if (item['isApproved'] == true) {
                                    return _buildEventCard(
                                      item['id'],
                                      item['name'],
                                      item['clubName'],
                                      item['date'],
                                      item['start_time'],
                                      item['venue'],
                                      item['description'],
                                      item['event_image_URL'],
                                    );
                                  } else {
                                    return SizedBox.shrink();
                                  }
                                } else {
                                  return SizedBox.shrink();
                                }
                              }),
                            ],
                          ),
                        ),
                      ),

                  // Floating button overlayed at bottom right when role is 1
                  _userRole == 1 && _clubOrgRef != null
                      ? Positioned(
                        bottom: 20,
                        right: 20,
                        child: FloatingActionButton(
                          backgroundColor: Color.fromARGB(255, 134, 53, 214),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) =>
                                        AddEvent(clubRef: _clubOrgRef!),
                              ),
                            );
                          },
                          child: const Icon(Icons.add),
                        ),
                      )
                      : SizedBox.shrink(),
                ],
              ),
    );
  }
}
