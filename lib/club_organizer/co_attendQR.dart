import 'package:applanner/club_organizer/co_backend.dart';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class ClubOrgQRCode extends StatefulWidget {
  late String uid;
  late String name;
  ClubOrgQRCode({super.key, required this.uid, required this.name});

  @override
  State<StatefulWidget> createState() => _ClubOrgQRCodeState();
}

class _ClubOrgQRCodeState extends State<ClubOrgQRCode> {
  late String _uid;
  late String _name;

  final OrganizerService _clubOrgService = OrganizerService();

  @override
  void initState() {
    super.initState();
    _uid = widget.uid;
    _name = widget.name;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Attendance Code")),
      body: Container(
        padding: EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: SizedBox(
            width: MediaQuery.of(context).size.width,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(_name, style: TextStyle(fontSize: 28)),
                const SizedBox(height: 16),
                Container(
                  decoration: BoxDecoration(color: Colors.white),
                  child: QrImageView(
                    data: _uid,
                    version: QrVersions.auto,
                    size: 200,
                    gapless: false,
                  ),
                ),

                const SizedBox(height: 32),
                GestureDetector(
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        duration: Duration(milliseconds: 1500),
                        backgroundColor: Colors.redAccent.shade200,
                        content: Row(
                          children: [
                            // Text
                            Expanded(
                              child: const Text(
                                "Ending Event?",
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),

                            // Button
                            GestureDetector(
                              onTap: () async {
                                bool? isCompleted;
                                ScaffoldMessenger.of(
                                  context,
                                ).hideCurrentSnackBar();

                                isCompleted = await _clubOrgService
                                    .completeEvent(_uid);

                                if (isCompleted == null) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text("Internal Error"),
                                      backgroundColor:
                                          Colors.redAccent.shade200,
                                    ),
                                  );
                                } else {
                                  Navigator.pop(context, true);
                                }
                              },
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                  vertical: 5,
                                  horizontal: 10,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.redAccent.shade100,
                                  borderRadius: BorderRadius.circular(10),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black,
                                      offset: Offset(0, 2),
                                      blurRadius: 5,
                                      blurStyle: BlurStyle.inner,
                                    ),
                                  ],
                                ),
                                child: Text(
                                  "Complete",
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
                      ),
                    );
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.greenAccent.shade200,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 15, horizontal: 15),
                    child: Row(
                      children: [
                        Icon(Icons.flag, color: Colors.black),
                        const SizedBox(width: 12),
                        Text(
                          "Event Complete",
                          style: TextStyle(color: Colors.black),
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
    );
  }
}
