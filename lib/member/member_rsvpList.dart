import 'package:applanner/others/dropdownConst.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class RSVPList extends StatefulWidget {
  const RSVPList({super.key});

  @override
  State<StatefulWidget> createState() => _RSVPListState();
}

class _RSVPListState extends State<RSVPList> {
  List<Map<String, dynamic>> _eventList = [];

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _getAllEvent();
  }

  Future<void> _getAllEvent() async {
    try {
      String userUid = FirebaseAuth.instance.currentUser!.uid;
      final userRef = FirebaseFirestore.instance
          .collection('users')
          .doc(userUid);
      final userSnapshot = await userRef.get();
      final userData = userSnapshot.data();

      final List<Map<String, dynamic>> eventDatas = [];

      if (userSnapshot.exists && userSnapshot.data() != null) {
        List<DocumentReference>? eventRsvpList;

        if (userData!.containsKey('rsvp') == true) {
          final rsvpRaw = userData['rsvp'] as List<dynamic>;
          eventRsvpList = rsvpRaw.cast<DocumentReference>();
        } else {
          setState(() {
            _eventList = eventDatas;
            _isLoading = false;
          });
          return;
        }

        for (var eventRsvp in eventRsvpList) {
          final eventRef = await eventRsvp.get();
          final eventData = eventRef.data() as Map<String, dynamic>;
          Map<String, dynamic> event = {};

          if (eventRef.exists && eventRef.data() != null) {
            event = eventData;
            event['id'] = eventRef.id;

            for (var item in dropdownConst.dropdownLocation) {
              final code = item['Code'];
              final name = item['Name'];
              if (event['location_key'] == code) {
                event['venue'] = name;
              }
            }

            for (var item in dropdownConst.dropdownCatagory) {
              final code = item['Code'];
              final catagory = item['Catagory'];
              if (event['catagory_key'] == code) {
                event['catagory'] = catagory;
              }
            }

            if (eventData.containsKey('attended')) {
              List<DocumentReference>? attendedData;
              final rawAttendedData = eventData['attended'] as List<dynamic>;
              attendedData = rawAttendedData.cast<DocumentReference>();

              if (attendedData.contains(userRef)) {
                event['isAttended'] = true;
              } else {
                event['isAttended'] = false;
              }
            }
          }

          eventDatas.add(event);
        }
        setState(() {
          _eventList = eventDatas;
          _isLoading = false;
        });
      }
    } catch (e) {
      // print("Debug: $e");
    }
  }

  Widget _buildEventCard(Map<String, dynamic> data, int index) {
    final textStyle = TextStyle(
      fontWeight: FontWeight.bold,
      color: index % 2 == 0 ? Colors.black : Colors.white,
    );

    return Container(
      margin: EdgeInsets.fromLTRB(0, 0, 0, 15),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Container(
          decoration: BoxDecoration(
            color:
                index % 2 == 0
                    ? Color.fromARGB(255, 153, 153, 153)
                    : Colors.deepPurpleAccent.shade200,
          ),
          child: IntrinsicHeight(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Container(
                  width: 10,
                  decoration: BoxDecoration(
                    color:
                        data.containsKey('isAttended')
                            ? data['isAttended']
                                ? Colors.green
                                : Colors.red
                            : Colors.yellow,
                  ),
                ),

                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 3),
                      Text(
                        data['name'] ?? 'Unknown Name',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: index % 2 == 0 ? Colors.black : Colors.white,
                        ),
                      ),
                      Text(
                        data['catagory'] ?? 'Unknown Catagory',
                        style: textStyle,
                      ),
                      Text(data['venue'] ?? 'Unknown Venue', style: textStyle),
                      Text(data['date'] ?? 'Unknown Date', style: textStyle),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            data['start_time'] ?? 'Unknown Time',
                            style: textStyle,
                          ),
                          GestureDetector(
                            onTap: () async {
                              // Navigator.push(
                              //   context,
                              //   MaterialPageRoute(
                              //     builder:
                              //         (context) =>
                              //             ClubOrgEventDetail(uid: data['id']),
                              //   ),
                              // ).then((result) {
                              //   if (result) {
                              //     _getAllEventByClub();
                              //   }
                              // });
                            },
                            child: Text(
                              "More Info >>",
                              style: TextStyle(
                                color:
                                    index % 2 == 0
                                        ? Color.fromARGB(255, 98, 39, 158)
                                        : Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 3),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("RSVP Events"),
        backgroundColor: Color.fromARGB(255, 51, 51, 51),
        shadowColor: Color.fromARGB(255, 119, 119, 119),
      ),
      body: SafeArea(
        child:
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                  padding: EdgeInsets.all(10),
                  child:
                      _eventList.isEmpty == true
                          ? const Center(child: Text("No Event RSVP"))
                          : IntrinsicHeight(
                            child: Column(
                              children: [
                                // Legends
                                SizedBox(
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: [
                                      // attended Legend
                                      Row(
                                        children: [
                                          Container(
                                            width: 10,
                                            height: 10,
                                            decoration: BoxDecoration(
                                              color: Colors.green,
                                              shape: BoxShape.circle,
                                            ),
                                          ),
                                          const SizedBox(width: 4),
                                          Text("Attended"),
                                        ],
                                      ),
                                      // Not Attended Legend
                                      Row(
                                        children: [
                                          Container(
                                            width: 10,
                                            height: 10,
                                            decoration: BoxDecoration(
                                              color: Colors.red,
                                              shape: BoxShape.circle,
                                            ),
                                          ),
                                          const SizedBox(width: 4),
                                          Text("Missed"),
                                        ],
                                      ),
                                      // Not yet stat Legend
                                      Row(
                                        children: [
                                          Container(
                                            width: 10,
                                            height: 10,
                                            decoration: BoxDecoration(
                                              color: Colors.yellow,
                                              shape: BoxShape.circle,
                                            ),
                                          ),
                                          const SizedBox(width: 4),
                                          Text("Not yet start"),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 8),

                                ...List.generate(_eventList.length, (index) {
                                  return _buildEventCard(
                                    _eventList[index],
                                    index,
                                  );
                                }),
                              ],
                            ),
                          ),
                ),
      ),
    );
  }
}
