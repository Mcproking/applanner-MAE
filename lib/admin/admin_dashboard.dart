import 'package:applanner/admin/admin_ManageEvent.dart';
import 'package:applanner/admin/admin_eventDetails.dart';
import 'package:applanner/others/dropdownConst.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AdminMenu extends StatefulWidget {
  final int initIndex;

  const AdminMenu({super.key, this.initIndex = 0});

  @override
  State<StatefulWidget> createState() => _AdminMenuState();
}

class _AdminMenuState extends State<AdminMenu> {
  String _name = 'Temp';
  String? _profileUrl;

  List<Map<String, dynamic>> _eventList = [];

  bool _isLoading = true;
  bool _isEmpty = false;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
    _fetchUnapprovedEventData();
  }

  Future<void> _fetchUserData() async {
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
            _name = userData.data()?['name'] ?? 'Temp';
            _profileUrl =
                userData.data()?.containsKey('profile_pic') == true
                    ? userData['profile_pic']
                    : null;
          });
        } else {
          setState(() {
            _name = 'Temp';
            _profileUrl = null;
          });
        }
      }
    } catch (e) {
      setState(() {
        _name = 'Temp';
        _profileUrl = null;
      });
    }
  }

  Future<void> _fetchUnapprovedEventData() async {
    try {
      final eventSnapshot =
          await FirebaseFirestore.instance.collection('events').get();

      final List<Map<String, dynamic>> events = [];

      for (var docs in eventSnapshot.docs) {
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

        if (!data.containsKey('isApproved')) {
          events.add(data);
        }
      }
      if (events.isEmpty) {
        setState(() {
          _eventList = events;
          _isEmpty = true;
          _isLoading = false;
        });
      } else {
        setState(() {
          _eventList = events;
          _isLoading = false;
        });
      }
    } catch (e) {
      // print("Debug $e");
    }
  }

  Widget _buildList(
    int i,
    int maxLength,
    String id,
    String eventName,
    String clubName,
    String venue,
    String time,
    String date,
  ) {
    return Container(
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
        color:
            i % 2 == 0
                ? Color.fromARGB(255, 153, 153, 153)
                : Colors.deepPurple.shade400,
        border: Border(
          bottom: BorderSide(
            color: Colors.white,
            width: i == maxLength - 1 ? 0 : 2,
          ),
        ),
      ),
      padding: EdgeInsets.symmetric(vertical: 2, horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            eventName,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          Text("Club: $clubName", style: TextStyle(color: Colors.black)),
          Text("Venue: $venue", style: TextStyle(color: Colors.black)),
          Text("Date: $date", style: TextStyle(color: Colors.black)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Time: $time", style: TextStyle(color: Colors.black)),
              GestureDetector(
                onTap: () async {
                  bool refreshWidget = false;

                  refreshWidget = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AdminEventDetails(uid: id),
                    ),
                  );

                  if (refreshWidget == true) {
                    _fetchUnapprovedEventData();
                  }
                },
                child: Text(
                  "More Info >>",
                  style: TextStyle(
                    color:
                        i % 2 == 0
                            ? Color.fromARGB(255, 134, 53, 214)
                            : Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 18, 18, 18),
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(20),
          child: IntrinsicHeight(
            child:
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : Column(
                      children: [
                        // Show image and name
                        Column(
                          children: [
                            CircleAvatar(
                              radius: 60,
                              backgroundImage:
                                  _profileUrl != null
                                      ? NetworkImage(_profileUrl!)
                                      : const AssetImage(
                                            'images/profile/default_profile.png',
                                          )
                                          as ImageProvider,
                            ),

                            const SizedBox(height: 20),
                            Text(
                              "Welcome, $_name",
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              "What would you want to do?",
                              style: TextStyle(fontSize: 20),
                            ),
                          ],
                        ),

                        Divider(),
                        const SizedBox(height: 8),

                        // show all the event that is created
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Column(
                            children: [
                              // heading
                              Container(
                                width: MediaQuery.of(context).size.width,

                                decoration: BoxDecoration(
                                  color: Color.fromARGB(255, 85, 85, 85),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      "Recently Created Events",
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              _isEmpty
                                  ? Container(
                                    width: MediaQuery.of(context).size.width,
                                    decoration: BoxDecoration(
                                      color: Colors.grey,
                                    ),
                                    child: Column(
                                      children: [
                                        SizedBox(height: 8),
                                        Text(
                                          "No Event",
                                          style: TextStyle(color: Colors.black),
                                        ),
                                        SizedBox(height: 8),
                                      ],
                                    ),
                                  )
                                  :
                                  // Listing
                                  SingleChildScrollView(
                                    child: IntrinsicHeight(
                                      child: Column(
                                        children: [
                                          ...List.generate(_eventList.length, (
                                            index,
                                          ) {
                                            final item = _eventList[index];

                                            return _buildList(
                                              index,
                                              _eventList.length,
                                              item['id'],
                                              item['name'],
                                              item['clubName'],
                                              item['venue'],
                                              item['start_time'],
                                              item['date'],
                                            );
                                          }),
                                        ],
                                      ),
                                    ),
                                  ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Divider(),

                        // Show Action Button
                        const SizedBox(height: 8),
                        Expanded(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const SizedBox(width: 16),
                              Expanded(
                                child: GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder:
                                            (context) => AdminManageEvent(),
                                      ),
                                    );
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 10,
                                      horizontal: 20,
                                    ),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      color: Color.fromARGB(255, 134, 53, 214),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(Icons.event_note),
                                        const SizedBox(width: 8),
                                        Text(
                                          "Manage Events",
                                          style: TextStyle(fontSize: 24),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                            ],
                          ),
                        ),
                      ],
                    ),
          ),
        ),
      ),
    );
  }
}
