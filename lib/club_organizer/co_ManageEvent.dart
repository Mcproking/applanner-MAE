import 'package:applanner/club_organizer/co_EventDetail.dart';
import 'package:applanner/others/dropdownConst.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ClubOrgManageEvent extends StatefulWidget {
  ClubOrgManageEvent({super.key});

  @override
  State<StatefulWidget> createState() => _COManageEvent();
}

class _COManageEvent extends State<ClubOrgManageEvent> {
  List<Map<String, dynamic>> _eventList = [];

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _getAllEventByClub();
  }

  Future<void> _getAllEventByClub() async {
    try {
      final eventSnapshot =
          await FirebaseFirestore.instance.collection('events').get();

      final user = FirebaseAuth.instance.currentUser;
      final userData =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user?.uid)
              .get();

      final List<Map<String, dynamic>> eventsByClub = [];

      if (userData.exists && userData.data() != null) {
        DocumentReference clubRef = userData.data()?['club_org'];
        final club = await clubRef.get();

        for (var docs in eventSnapshot.docs) {
          if (docs.data()['club'] == clubRef) {
            final data = docs.data();
            data['id'] = docs.id;

            for (var item in dropdownConst.dropdownLocation) {
              final code = item['Code'];
              final name = item['Name'];
              if (data['location_key'] == code) {
                data['venue'] = name;
              }
            }

            for (var item in dropdownConst.dropdownCatagory) {
              final code = item['Code'];
              final catagory = item['Catagory'];
              final icon = item['Icons'];
              if (data['catagory_key'] == code) {
                data['catagory'] = catagory;
              }
            }

            data['event_image_URL'] =
                data.containsKey('imageURL') == true ? data['imageURL'] : null;

            if (data['club'] != null && data['club'] is DocumentReference) {
              final clubSnapshot =
                  await (data['club'] as DocumentReference).get();
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
            eventsByClub.add(data);
            // print("data from $data");
          }
        }
        setState(() {
          _eventList = eventsByClub;
          _isLoading = false;
        });
      }
    } catch (e) {}
  }

  Widget _buildEventCard(Map<String, dynamic> data, int index) {
    final _textStyle = TextStyle(
      fontWeight: FontWeight.bold,
      color: Colors.black,
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
                        data.containsKey('isApproved')
                            ? data['isApproved']
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
                        data['name'],
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      Text(data['catagory']),
                      Text(data['venue']),
                      Text(data['date']),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(data['start_time']),
                          GestureDetector(
                            onTap: () async {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (context) =>
                                          ClubOrgEventDetail(uid: data['id']),
                                ),
                              ).then((result) {
                                if (result) {
                                  _getAllEventByClub();
                                }
                              });
                            },
                            child: Text(
                              "More Info >>",
                              style: TextStyle(
                                color:
                                    index % 2 == 0
                                        ? Color.fromARGB(255, 134, 53, 214)
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
      backgroundColor: Color.fromARGB(255, 18, 18, 18),
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: Text('Manage Event'),
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
                          ? const Center(child: Text('No event created'))
                          : IntrinsicHeight(
                            child: Column(
                              children: [
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
