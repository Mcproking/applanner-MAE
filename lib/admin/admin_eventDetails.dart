import 'package:applanner/admin/admin_backend.dart';
import 'package:applanner/main/navigation_bar.dart';
import 'package:applanner/others/dropdownConst.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AdminEventDetails extends StatefulWidget {
  late String uid;
  AdminEventDetails({super.key, required this.uid});

  @override
  State<StatefulWidget> createState() => _AdminEventDetailsState();
}

class _AdminEventDetailsState extends State<AdminEventDetails> {
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

  bool _isApproved = false;
  bool _isLoading = true;

  final AdminService _adminService = AdminService();

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

          _isLoading = false;
        });
      }
    } catch (e) {}
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
                                : _eventStatus == true
                                ? "Approved"
                                : "Rejected",
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
                      _isApproved
                          ? SizedBox.shrink()
                          : Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: GestureDetector(
                                  onTap: () async {
                                    late bool _isComplete;

                                    _isComplete = await _adminService
                                        .manageEvenet(_uid, true);

                                    if (_isComplete) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            "Event Approve",
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          backgroundColor: Colors.green,
                                        ),
                                      );

                                      Navigator.pop(context, true);
                                    } else {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            "Internal Error Occor",
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          backgroundColor: Colors.red,
                                        ),
                                      );
                                    }
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.green,
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
                                          "Approve",
                                          style: TextStyle(color: Colors.black),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),

                              const SizedBox(width: 16),
                              Expanded(
                                child: GestureDetector(
                                  onTap: () async {
                                    late bool _isComplete;

                                    _isComplete = await _adminService
                                        .manageEvenet(_uid, false);

                                    if (_isComplete) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            "Event Reject",
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          backgroundColor:
                                              Colors.redAccent.shade200,
                                        ),
                                      );

                                      Navigator.pop(context, true);
                                    } else {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            "Internal Error Occor",
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          backgroundColor: Colors.red,
                                        ),
                                      );
                                    }
                                  },
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                      vertical: 15,
                                      horizontal: 30,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.red,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(Icons.close, color: Colors.black),
                                        const SizedBox(width: 12),
                                        Text(
                                          "Reject",
                                          style: TextStyle(color: Colors.black),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                    ],
                  ),
        ),
      ),
    );
  }
}
