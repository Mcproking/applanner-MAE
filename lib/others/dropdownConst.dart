import 'package:flutter/material.dart';

class dropdownConst {
  static final List<Map<String, String>> dropdownLocation = [
    {"Name": "Atrium 1", "Code": "A1-L7"},
    {"Name": "Atrium 2", "Code": "A2-L6"},
    {"Name": "Atrium 3", "Code": "A3-L5"},
    {"Name": "Atrium 4", "Code": "A4-L4"},
  ];

  static final List<Map<String, dynamic>> dropdownCatagory = [
    {"Catagory": "Sports", "Code": "Sports", "Icons": Icons.sports_basketball},
    {"Catagory": "E-Sports", "Code": "Esport", "Icons": Icons.sports_esports},
  ];

  String? getName(List<Map<String, dynamic>> list, String inputName) {
    for (var item in list) {
      final name = item['name'];
      if (inputName == name) {
        return name;
      }
    }
    return null;
  }
}
