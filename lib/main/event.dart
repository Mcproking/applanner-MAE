import 'package:applanner/event/add_event.dart';
import 'package:applanner/others/dropdownConst.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Event extends StatefulWidget {
  Event({super.key});

  @override
  State<StatefulWidget> createState() => _EventState();
}

class _EventState extends State<Event> {
  final TextEditingController _searchController = TextEditingController();
  DocumentReference? _clubOrgRef;

  int _userRole = 0;
  bool _isLoading = true;
  bool _isEmpty = false;
  bool _isFilterOpen = false;

  // show only approved events
  static final List<Map<String, dynamic>> _tempData = [
    {
      'id': 'abc',
      'eventName': 'Event 1',
      'clubName': 'Club 1',
      'date': '11/12/23',
      'time': '0902',
      'venue': 'Audi 1',
      'description': 'Short Description',
      'eventImageURL': null,
    },
    {
      'id': '123',
      'eventName': 'Event 2',
      'clubName': 'Club 2',
      'date': '21/4/23',
      'time': '2202',
      'venue': 'Audi 2',
      'description':
          "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Integer consectetur dolor venenatis diam lobortis, nec malesuada dolor finibus. Duis vel viverra odio. Suspendisse elementum facilisis ex, ac pretium nisl volutpat vel. Mauris fermentum, elit at luctus varius, ipsum arcu vestibulum nulla, ac fermentum velit neque eu nisl. Mauris euismod est sit amet sagittis sodales. Donec ut orci sit amet nisi commodo bibendum id eget elit. Nulla fermentum felis eros, eu feugiat velit posuere vitae. In sed fermentum felis, nec lobortis lorem. Etiam nisl ex, finibus in ipsum ut, mollis congue diam. Vestibulum volutpat ac nunc et porttitor. Praesent nec hendrerit mauris. ",
      'eventImageURL':
          "https://cdn.donmai.us/sample/bc/f4/__original_drawn_by_mito_go_go_king__sample-bcf4eb5593414c80c794d9e53a491214.jpg",
    },
    {
      'id': 'fgdas',
      'eventName': 'Event 3',
      'clubName': 'Club 3',
      'date': '21/4/23',
      'time': '2202',
      'venue': 'Audi 2',
      'description':
          "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Vestibulum ultricies sem nec sapien condimentum, vel consequat justo porttitor. In venenatis id purus id convallis",
      'eventImageURL':
          "https://cdn.donmai.us/sample/e5/55/__original_drawn_by_mito_go_go_king__sample-e5554e648649067c5f8776ab30ceb235.jpg",
    },
  ];
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

        print(data);
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
      print("Error fetching clubs: $e");
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
                          : AssetImage('images/event_default.jpg'),
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
                      onTap: () {},
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

  // need to build the search and filter system
  Widget _searchBar() {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              labelText: "Search",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ),
        SizedBox(width: 10),

        SizedBox(
          height: 60,
          child: GestureDetector(
            onTap: () {
              setState(() {
                _isFilterOpen = !_isFilterOpen;
              });
            },
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 15),
              margin: EdgeInsets.symmetric(vertical: 2),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Color.fromARGB(255, 134, 53, 214),
              ),
              child: Icon(Icons.menu),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFilter() {
    return Container(
      decoration: BoxDecoration(color: Color.fromARGB(255, 119, 119, 119)),
      child: const Text("temp"),
    );
  }

  // TODO: Need to fix the bug that the [+] is not located to the bottom
  // TODO: Add guest access, only ask to login when they want to book the events
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
                              _searchBar(),
                              Visibility(
                                visible: _isFilterOpen,
                                child: _buildFilter(),
                              ),

                              SizedBox(height: 10),

                              ...List.generate(_eventList.length, (index) {
                                final item = _eventList[index];
                                if (item.containsKey('isApproved') == true) {
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
                              }),
                            ],
                          ),
                        ),
                      ),

                  // Floating button overlayed at bottom right when role is 1
                  _userRole == 1 && _clubOrgRef != null
                      ? Positioned(
                        bottom: 00,
                        right: 00,
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
