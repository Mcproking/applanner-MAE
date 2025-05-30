import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ClubDetails extends StatefulWidget {
  final String uid;

  const ClubDetails({super.key, required this.uid});

  @override
  State<StatefulWidget> createState() => _ClubDetailsState();
}

class _ClubDetailsState extends State<ClubDetails> {
  late String _uid; // get from pass-in from parent
  String _clubName = 'Club Name';
  String _clubDescription = 'Club Description';
  String? _clubIconURL;
  DocumentReference? _clubOrganizer;

  // Data Storing for ClubOrg
  String _studentName = 'Temp';
  String? _studentProfileImageURL;

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _uid = widget.uid;
    _getClubDetails().then((_) => _fetchOrganizerDetails());
  }

  Future<void> _getClubDetails() async {
    try {
      final clubData =
          await FirebaseFirestore.instance.collection('clubs').doc(_uid).get();

      if (clubData.exists && clubData.data() != null) {
        setState(() {
          _clubName = clubData['name'] ?? 'Club Name';
          _clubDescription = clubData['description'] ?? 'Club Description';
          _clubOrganizer =
              clubData['organizer'] is DocumentReference
                  ? clubData['organizer']
                  : null;
          _clubIconURL =
              clubData.data()?.containsKey('clubIcon') == true
                  ? clubData['clubIcon']
                  : null;
          _isLoading = false;
        });
      } else {
        setState(() {
          _clubName = 'Club Name';
          _clubDescription = 'Club Description';
          _clubIconURL = null;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _clubName = 'Club Name';
        _clubDescription = 'Club Description';
        _clubIconURL = null;
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchOrganizerDetails() async {
    try {
      final user = await _clubOrganizer!.get();
      final userData = user.data() as Map<String, dynamic>;

      if (user.exists && user.data() != null) {
        setState(() {
          _studentName = userData['name'] ?? 'temp';
          _studentProfileImageURL =
              userData.containsKey('profile_pic') == true
                  ? userData['profile_pic']
                  : null;
        });
      } else {
        setState(() {
          _studentName = 'Temp';
          _studentProfileImageURL = null;
        });
      }
    } catch (e) {
      setState(() {
        _studentName = 'Temp';
        _studentProfileImageURL = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("temp nae"),
        backgroundColor: Color.fromARGB(255, 51, 51, 51),
        shadowColor: Color.fromARGB(255, 119, 119, 119),
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Container(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    // Club's Image and name
                    Row(
                      children: [
                        Image(
                          image:
                              _clubIconURL != null
                                  ? NetworkImage(_clubIconURL!)
                                  : AssetImage('iamges/event_default.jpg'),
                          fit: BoxFit.cover,
                          width: 64,
                          height: 64,
                        ),
                        SizedBox(width: 16),
                        Flexible(
                          child: Text(
                            _clubName,
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.clip,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    Divider(),
                    const SizedBox(height: 20),

                    // fill the description of the club
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            _clubDescription,
                            style: TextStyle(fontSize: 20),
                            overflow: TextOverflow.clip,
                          ),
                        ),
                      ],
                    ),

                    Divider(),
                    const SizedBox(height: 20),

                    // CO Card
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Column(
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(
                              vertical: 2,
                              horizontal: 10,
                            ),
                            width: MediaQuery.of(context).size.width,
                            decoration: BoxDecoration(
                              color: Color.fromARGB(255, 85, 85, 85),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "Meet your club Oganizer",
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            width: MediaQuery.of(context).size.width,
                            padding: EdgeInsets.symmetric(
                              vertical: 15,
                              horizontal: 20,
                            ),
                            decoration: BoxDecoration(
                              color: Color.fromARGB(255, 133, 34, 98),
                            ),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 25,
                                  backgroundImage:
                                      _studentProfileImageURL != null
                                          ? NetworkImage(
                                            _studentProfileImageURL!,
                                          )
                                          : const AssetImage(
                                                'images/profile/default_profile.png',
                                              )
                                              as ImageProvider,
                                ),
                                const SizedBox(width: 16),
                                Text(
                                  _studentName,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Memeber List TODO: handle if no member in the club
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Column(
                            children: [
                              // Member Lis Header
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
                                      "Members",
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              Expanded(
                                child: SingleChildScrollView(
                                  child: IntrinsicHeight(
                                    child: Column(
                                      children: [
                                        // Need to convert this into a buildcard
                                        ...List.generate(
                                          10,
                                          (i) => Container(
                                            width:
                                                MediaQuery.of(
                                                  context,
                                                ).size.width,
                                            decoration: BoxDecoration(
                                              color:
                                                  i % 2 == 0
                                                      ? Color.fromARGB(
                                                        255,
                                                        153,
                                                        153,
                                                        153,
                                                      )
                                                      : Colors
                                                          .deepPurple
                                                          .shade400,
                                              border: Border(
                                                bottom: BorderSide(
                                                  color: Colors.white,
                                                  width: i == 9 ? 0 : 2,
                                                ),
                                              ),
                                            ),
                                            padding: EdgeInsets.symmetric(
                                              vertical: 2,
                                              horizontal: 20,
                                            ),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  "Name $i",
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                    color: Colors.black,
                                                  ),
                                                ),
                                                const SizedBox(height: 2),
                                                Text(
                                                  "role",
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color: Colors.black,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 40),
                  ],
                ),
              ),
    );
  }
}
