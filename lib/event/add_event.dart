import 'package:applanner/club_organizer/co_backend.dart';
import 'package:applanner/others/dropdownConst.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AddEvent extends StatefulWidget {
  final DocumentReference clubRef;

  const AddEvent({super.key, required, required this.clubRef});

  @override
  State<StatefulWidget> createState() => _AddEventState();
}

class _AddEventState extends State<AddEvent> {
  late DocumentReference _clubRef; // pass-in from parent

  final TextEditingController _eventNameController = TextEditingController();
  final TextEditingController _eventDetailsController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _startTimeController = TextEditingController();
  final TextEditingController _endTimeController = TextEditingController();
  final TextEditingController _locationCodeController = TextEditingController();
  final TextEditingController _catagoryCodeController = TextEditingController();

  late TimeOfDay _timeStart;
  late TimeOfDay _timeEnd;
  late DateTime _datePicked;

  final _formKey = GlobalKey<FormState>();

  static final _dropdownLocation = dropdownConst.dropdownLocation;
  static final _dropdownCatagory = dropdownConst.dropdownCatagory;

  final OrganizerService _clubOrgService = OrganizerService();

  @override
  void initState() {
    super.initState();
    _clubRef = widget.clubRef;
    _datePicked = DateTime.now();
    _timeEnd = _timeStart = TimeOfDay.now();
  }

  void _initDateAndTime() {
    _startTimeController.text = _timeStart.format(context);
    _endTimeController.text = _timeEnd.format(context);
    _dateController.text = _datePicked.toString().split(' ')[0];
  }

  Future<DateTime> _selectDate() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      firstDate: DateTime.now(),
      initialDate: _datePicked,
      lastDate: DateTime(DateTime.now().year + 1),
    );

    return pickedDate ?? DateTime.now();
  }

  Future<TimeOfDay> _selectTime(TimeOfDay time) async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: time,
    );

    return pickedTime ?? TimeOfDay.now();
  }

  @override
  Widget build(BuildContext context) {
    _initDateAndTime();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Event'),
        backgroundColor: Color.fromARGB(255, 51, 51, 51),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(15),
        child: IntrinsicHeight(
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const Text(
                  "Create A New Event",
                  style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),

                // Divider for Event Details
                Row(
                  children: [
                    Expanded(child: Divider()),
                    const Text("Event Details"),
                    Expanded(child: Divider()),
                  ],
                ),
                const SizedBox(height: 20),

                // Input for Event Name
                TextFormField(
                  controller: _eventNameController,
                  decoration: InputDecoration(
                    labelText: "Event Name *",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    suffixIcon: IconButton(
                      onPressed: () {
                        // print("Show snack bar");
                      },
                      icon: Icon(Icons.priority_high),
                    ),
                  ),

                  validator: (v) {
                    if (v == null || v.isEmpty) {
                      return 'Please enter Event Name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Input for Event Details
                TextFormField(
                  controller: _eventDetailsController,
                  decoration: InputDecoration(
                    labelText: "Description",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    suffixIcon: IconButton(
                      onPressed: () {},
                      icon: Icon(Icons.priority_high),
                    ),
                  ),

                  validator: (v) {
                    if (v == null || v.isEmpty) {
                      return 'Please Fill the Event Details';
                    }
                    return null;
                  },
                  minLines: 1,
                  maxLines: 3,
                ),
                const SizedBox(height: 20),

                // Dropdown for catagory
                DropdownButtonFormField(
                  decoration: InputDecoration(
                    labelText: "Catagory",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  items: List.generate(_dropdownCatagory.length, (index) {
                    final catagory = _dropdownCatagory[index];
                    return DropdownMenuItem(
                      value: catagory['Code'],
                      child: Row(
                        children: [
                          Icon(catagory['Icons']),
                          const SizedBox(width: 8),
                          Text(catagory['Catagory']),
                        ],
                      ),
                    );
                  }),
                  onChanged: (selectedItem) {
                    _catagoryCodeController.text = selectedItem.toString();
                    // print(selectedItem);
                  },
                  validator: (value) {
                    if (value == null || value.toString().isEmpty) {
                      return 'Please select a category';
                    }
                    return null;
                  },
                ),
                // Divider
                Row(
                  children: [
                    Expanded(child: Divider()),
                    const Text("Event Time"),
                    Expanded(child: Divider()),
                  ],
                ),
                const SizedBox(height: 12),
                // Date Picker
                TextFormField(
                  controller: _dateController,
                  readOnly: true,
                  showCursor: false,
                  decoration: InputDecoration(
                    labelText: "Event Date *",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    suffixIcon: IconButton(
                      onPressed: () async {
                        DateTime selectedDate = await _selectDate();
                        setState(() {
                          _datePicked = selectedDate;
                          _dateController.text =
                              _datePicked.toString().split(' ')[0];
                        });
                      },
                      icon: Icon(Icons.calendar_month_outlined),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Time Picker
                Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Start Time
                        Expanded(
                          child: TextFormField(
                            controller: _startTimeController,
                            readOnly: true,
                            showCursor: false,
                            decoration: InputDecoration(
                              labelText: "Start Time",
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              suffixIcon: IconButton(
                                onPressed: () async {
                                  TimeOfDay pickedTime = await _selectTime(
                                    _timeStart,
                                  );
                                  _timeStart = pickedTime;
                                  _startTimeController.text = _timeStart.format(
                                    context,
                                  );
                                },
                                icon: Icon(Icons.priority_high),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),

                        // End time
                        Expanded(
                          child: TextFormField(
                            controller: _endTimeController,
                            readOnly: true,
                            showCursor: false,
                            decoration: InputDecoration(
                              labelText: "End Time",
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              suffixIcon: IconButton(
                                onPressed: () async {
                                  TimeOfDay pickedTime = await _selectTime(
                                    _timeEnd,
                                  );
                                  _timeEnd = pickedTime;
                                  _endTimeController.text = _timeEnd.format(
                                    context,
                                  );
                                },
                                icon: Icon(Icons.priority_high),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                // Divider
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(child: Divider()),
                    const Text("Event Location"),
                    Expanded(child: Divider()),
                  ],
                ),
                const SizedBox(height: 12),

                // Dropdown for location
                DropdownButtonFormField(
                  decoration: InputDecoration(
                    labelText: "Location",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  items: List.generate(_dropdownLocation.length, (index) {
                    final location = _dropdownLocation[index];
                    return DropdownMenuItem(
                      value: location['Code'],
                      child: Text(location['Name'] ?? 'Error occor'),
                    );
                  }),
                  onChanged: (selectedItem) {
                    _locationCodeController.text = (selectedItem)!;
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select a location';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // upload image (maybe change the data in firebase instead)
                // add image button
                GestureDetector(
                  onTap: () {},
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                    decoration: BoxDecoration(
                      color: Color.fromARGB(255, 135, 53, 214),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.arrow_upward),
                        const SizedBox(width: 8),
                        Text("Upload Image", style: TextStyle(fontSize: 16)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 5),
                Divider(),
                const SizedBox(height: 5),

                // Create Event
                GestureDetector(
                  onTap: () async {
                    if (_formKey.currentState!.validate()) {
                      User? user = FirebaseAuth.instance.currentUser;

                      if (user != null) {
                        bool iscomplete = await _clubOrgService.createEvent(
                          _eventNameController.text.trim(),
                          _eventDetailsController.text.trim(),
                          _catagoryCodeController.text.trim(),
                          _dateController.text.trim(),
                          _startTimeController.text.trim(),
                          _endTimeController.text.trim(),
                          _locationCodeController.text.trim(),
                          _clubRef,
                        );

                        if (iscomplete) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                "Event Created. Awaiting for approval.",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              backgroundColor: Colors.green,
                            ),
                          );

                          Navigator.pop(context);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                "Internal Error Occor",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      }
                    }
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                    decoration: BoxDecoration(
                      color: Color.fromARGB(255, 35, 175, 11),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.add, color: Colors.black),
                        const SizedBox(width: 8),
                        Text(
                          "Create Event",
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
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
    );
  }
}
