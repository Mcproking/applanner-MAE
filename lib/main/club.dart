import 'package:applanner/club/club_details.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Club extends StatefulWidget {
  Club({super.key});

  @override
  State<StatefulWidget> createState() => _ClubState();
}

class _ClubState extends State<Club> {
  List<Map<String, dynamic>> _clubsList = [];

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchAllClubs();
  }

  Future<void> _fetchAllClubs() async {
    try {
      final snapshot =
          await FirebaseFirestore.instance.collection('clubs').get();

      final List<Map<String, dynamic>> clubs =
          snapshot.docs.map((doc) {
            final data = doc.data();
            data['id'] = doc.id; // Optionally include document ID
            return data;
          }).toList();

      // You can now use this list to build UI
      setState(() {
        _clubsList = clubs;
        _isLoading = false;
      });
    } catch (e) {
      print("Error fetching clubs: $e");
    }
  }

  Widget _buildClubCard(
    String uid,
    String clubName,
    String clubDescription,
    String? clubIconUrl,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Color.fromARGB(255, 85, 85, 85),
        borderRadius: BorderRadius.circular(5),
      ),
      padding: EdgeInsets.all(10),
      margin: EdgeInsets.fromLTRB(0, 0, 0, 10),
      child: Column(
        children: [
          // Image and club name
          Row(
            children: [
              Image(
                image:
                    clubIconUrl != null
                        ? NetworkImage(clubIconUrl)
                        : AssetImage(''),
                fit: BoxFit.cover,
                width: 64,
                height: 64,
              ),
              SizedBox(width: 16),
              Flexible(
                child: Text(
                  clubName,
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // club descittion
          Row(
            children: [
              Flexible(
                child: Text(
                  clubDescription,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),
          // Button to view more
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ClubDetails(uid: uid),
                    ),
                  );
                },
                child: AnimatedContainer(
                  duration: Duration(milliseconds: 200),
                  padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                  decoration: BoxDecoration(
                    color: Color.fromARGB((255), 134, 53, 214),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Row(
                    children: [
                      const Text("More Info"),
                      const Icon(Icons.arrow_forward),
                    ],
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
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _clubsList.isEmpty
              ? const Center(child: Text("No Club Avaliable"))
              : SingleChildScrollView(
                padding: const EdgeInsets.all(10),
                child: IntrinsicHeight(
                  child: Column(
                    children: [
                      ...List.generate(_clubsList.length, (index) {
                        final club = _clubsList[index];
                        return _buildClubCard(
                          club['id'],
                          club['name'],
                          club['description'],
                          club['clubIcon'],
                        );
                      }),
                      _buildClubCard(
                        'TPapKIw07KxoKTIyMJAL',
                        "what if this club name is too long that it can cause overflow",
                        "descrition goes here nigga",
                        "https://cdn.donmai.us/sample/ae/02/__original_drawn_by_mito_go_go_king__sample-ae024f0c0fa1f620c4ddd9de644b078e.jpg",
                      ),
                    ],
                  ),
                ),
              ),
    );
  }
}
