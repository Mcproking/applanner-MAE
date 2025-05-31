import 'package:applanner/admin/admin_eventDetails.dart';
import 'package:applanner/others/dropdownConst.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AdminManageEvent extends StatefulWidget {
  AdminManageEvent({super.key});

  @override
  State<StatefulWidget> createState() => _AdminManageEventState();
}

class _AdminManageEventState extends State<AdminManageEvent> {
  List<Map<String, dynamic>> _eventList = [];

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _getAllEvent();
  }

  Future<void> _getAllEvent() async {
    try {
      final eventsSnapshot =
          await FirebaseFirestore.instance.collection('events').get();

      final List<Map<String, dynamic>> events = [];

      for (var docs in eventsSnapshot.docs) {
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
        print("data from $data");
      }

      setState(() {
        _eventList = events;
        _isLoading = false;
      });
    } catch (e) {
      print("Error fetching clubs: $e");
    }
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
                                          AdminEventDetails(uid: data['id']),
                                ),
                              );
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
      appBar: AppBar(title: Text('Manage Event')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(10),
          child: IntrinsicHeight(
            child: Column(
              children: [
                ...List.generate(_eventList.length, (index) {
                  return _buildEventCard(_eventList[index], index);
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
