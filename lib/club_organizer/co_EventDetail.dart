import 'package:applanner/club_organizer/co_attendQR.dart';
import 'package:applanner/club_organizer/co_backend.dart';
import 'package:applanner/others/dropdownConst.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ClubOrgEventDetail extends StatefulWidget {
  late String uid;
  ClubOrgEventDetail({super.key, required this.uid});

  @override
  State<StatefulWidget> createState() => _COEventDetail();
}

class _COEventDetail extends State<ClubOrgEventDetail> {
  late String _uid;

  String _eventName = 'Sample Name';
  String _eventDescription = '';
  IconData _catagoryIcon = Icons.close;
  String _catagoryName = '';
  String _date = '';
  String _startTime = '';
  String _endTime = '';
  String _venueName = '';
  String _clubName = '';
  bool? _eventStatus;
  bool? _eventComplete;

  bool _isApproved = false;
  bool _isLoading = true;

  final OrganizerService _clubOrgService = OrganizerService();

  @override
  void initState() {
    super.initState();
    _uid = widget.uid;
    _getEventDetails();
  }

  Future<void> _getEventDetails() async {
    try {
      final eventData =
          await FirebaseFirestore.instance.collection('events').doc(_uid).get();

      // Get club name
      if (eventData['club'] != null && eventData['club'] is DocumentReference) {
        final clubSnapshot =
            await (eventData['club'] as DocumentReference).get();
        final clubData = clubSnapshot.data() as Map<String, dynamic>;

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

      if (eventData.exists && eventData.data() != null) {
        setState(() {
          _eventName = eventData['name'] ?? 'Sample Name';
          _eventDescription = eventData['description'] ?? 'No Description';

          for (var item in dropdownConst.dropdownCatagory) {
            final code = item['Code'];
            final catagory = item['Catagory'];
            final icon = item['Icons'];
            if (eventData['catagory_key'] == code) {
              _catagoryIcon = icon;
              _catagoryName = catagory;
            }
          }

          _date = eventData['date'] ?? 'No Date';
          _startTime = eventData['start_time'] ?? 'No Time';
          _endTime = eventData['end_time'] ?? 'No Time';

          for (var item in dropdownConst.dropdownLocation) {
            final code = item['Code'];
            final name = item['Name'];
            if (eventData['location_key'] == code) {
              _venueName = name!;
            }
          }

          if (eventData.data()?.containsKey('isApproved') ?? false) {
            _eventStatus = eventData['isApproved'];
          } else {
            _eventStatus = null;
          }

          _isApproved = eventData.data()?.containsKey('isApproved') ?? false;

          if (eventData.data()?.containsKey('isCompleted') ?? false) {
            _eventComplete = eventData['isCompleted'];
          } else {
            _eventComplete = null;
          }

          _isLoading = false;
        });
      }
    } catch (e) {
      // print('Debug: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Event Details")),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(20),
          child:
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : Column(
                    children: [
                      // Club Name
                      SizedBox(
                        width: MediaQuery.of(context).size.width,
                        child: InputDecorator(
                          decoration: InputDecoration(
                            labelText: 'Club',
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 15,
                              vertical: 5,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(color: Colors.white),
                            ),
                          ),
                          child: Text(
                            _clubName,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Event Name
                      SizedBox(
                        width: MediaQuery.of(context).size.width,
                        child: InputDecorator(
                          decoration: InputDecoration(
                            labelText: 'Event Name',
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 15,
                              vertical: 5,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(color: Colors.white),
                            ),
                          ),
                          child: Text(
                            _eventName,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Description
                      SizedBox(
                        width: MediaQuery.of(context).size.width,
                        child: InputDecorator(
                          decoration: InputDecoration(
                            labelText: 'Description',
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 15,
                              vertical: 5,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(color: Colors.white),
                            ),
                          ),
                          child: Text(
                            _eventDescription,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                            maxLines: 3,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Catagory
                      SizedBox(
                        width: MediaQuery.of(context).size.width,
                        child: InputDecorator(
                          decoration: InputDecoration(
                            labelText: 'Catagory',
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 15,
                              vertical: 5,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(color: Colors.white),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(_catagoryIcon),
                              const SizedBox(width: 8),
                              Text(
                                _catagoryName,
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Event Date
                      SizedBox(
                        width: MediaQuery.of(context).size.width,
                        child: InputDecorator(
                          decoration: InputDecoration(
                            labelText: 'Date',
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 15,
                              vertical: 5,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(color: Colors.white),
                            ),
                          ),
                          child: Text(
                            _date,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                            maxLines: 3,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Start & End Time
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: SizedBox(
                              width: MediaQuery.of(context).size.width,
                              child: InputDecorator(
                                decoration: InputDecoration(
                                  labelText: 'Start Time',
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: 15,
                                    vertical: 5,
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: BorderSide(color: Colors.white),
                                  ),
                                ),
                                child: Text(
                                  _startTime,
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                  maxLines: 3,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: SizedBox(
                              width: MediaQuery.of(context).size.width,
                              child: InputDecorator(
                                decoration: InputDecoration(
                                  labelText: 'End Time',
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: 15,
                                    vertical: 5,
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: BorderSide(color: Colors.white),
                                  ),
                                ),
                                child: Text(
                                  _endTime,
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                  maxLines: 3,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Location
                      SizedBox(
                        width: MediaQuery.of(context).size.width,
                        child: InputDecorator(
                          decoration: InputDecoration(
                            labelText: 'Description',
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 15,
                              vertical: 5,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(color: Colors.white),
                            ),
                          ),
                          child: Text(
                            _venueName,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                            maxLines: 3,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Event Status
                      SizedBox(
                        width: MediaQuery.of(context).size.width,
                        child: InputDecorator(
                          decoration: InputDecoration(
                            labelText: 'Status',
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 15,
                              vertical: 5,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(color: Colors.white),
                            ),
                          ),
                          child: Text(
                            _eventStatus == null
                                ? "Not Yet Approve"
                                : _eventStatus == true && _eventComplete == null
                                ? "Approved"
                                : _eventStatus == true && _eventComplete == null
                                ? "Rejected"
                                : "Event Finish",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                            maxLines: 3,
                          ),
                        ),
                      ),

                      const SizedBox(height: 10),
                      Divider(),
                      const SizedBox(height: 10),

                      // action box list
                      !_isApproved && _eventStatus == null
                          ? Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: GestureDetector(
                                  onTap: () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        backgroundColor:
                                            Colors.redAccent.shade200,
                                        content: Row(
                                          children: [
                                            // Text prompt
                                            Expanded(
                                              child: const Text(
                                                "Delete Event?",
                                                style: TextStyle(
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),

                                            // Action Button
                                            GestureDetector(
                                              onTap: () async {
                                                bool isCompleted;
                                                ScaffoldMessenger.of(
                                                  context,
                                                ).hideCurrentSnackBar();

                                                isCompleted =
                                                    await _clubOrgService
                                                        .deleteEvent(_uid);

                                                if (isCompleted) {
                                                  Navigator.pop(context, true);
                                                } else {
                                                  ScaffoldMessenger.of(
                                                    context,
                                                  ).showSnackBar(
                                                    SnackBar(
                                                      content: Text(
                                                        "Internal Error",
                                                      ),
                                                      backgroundColor:
                                                          Colors
                                                              .redAccent
                                                              .shade200,
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
                                                  color:
                                                      Colors.redAccent.shade100,
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: Colors.black,
                                                      offset: Offset(0, 2),
                                                      blurRadius: 5,
                                                      blurStyle:
                                                          BlurStyle.inner,
                                                    ),
                                                  ],
                                                ),
                                                child: Text(
                                                  "Delete",
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 20,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 30,
                                          horizontal: 15,
                                        ),
                                        duration: const Duration(
                                          milliseconds: 3000,
                                        ),
                                      ),
                                    );
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.redAccent.shade200,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    padding: EdgeInsets.symmetric(
                                      vertical: 15,
                                      horizontal: 30,
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(Icons.delete, color: Colors.black),
                                        const SizedBox(width: 12),
                                        Text(
                                          "Delete Event",
                                          style: TextStyle(color: Colors.black),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          )
                          : _eventComplete == null
                          ? Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder:
                                            (context) => ClubOrgQRCode(
                                              uid: _uid,
                                              name: _eventName,
                                            ),
                                      ),
                                    ).then((value) {
                                      if (value == true) {
                                        _getEventDetails();
                                      }
                                    });
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
                                          "Attendance",
                                          style: TextStyle(color: Colors.black),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          )
                          : SizedBox.shrink(),
                    ],
                  ),
        ),
      ),
    );
  }
}
