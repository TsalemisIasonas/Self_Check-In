import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class FormPage extends StatefulWidget {
  const FormPage({super.key});

  @override
  State<FormPage> createState() => _FormPageState();
}

class _FormPageState extends State<FormPage> {
  final List<String> fields = ['Όνομα', 'Επώνυμο','Ημ/νια Γέννησης','ΑΔΤ','Εθνικότητα','Τηλέφωνο','Email'];

  // A list of TextEditingControllers to manage the text in each input field
  final List<TextEditingController> _controllers = [];

  @override
  void initState() {
    super.initState();
    // Initialize a controller for each field in the list
    for (var i = 0; i < fields.length; i++) {
      _controllers.add(TextEditingController());
    }
  }

  @override
  void dispose() {
    // Dispose of the controllers when the widget is removed to free up resources
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  // This function is called when the "Save" button is pressed
  Future<void> _saveAndSendApiData() async {
    // Check if any field is empty
    bool hasEmptyField = false;
    for (var controller in _controllers) {
      if (controller.text.trim().isEmpty) {
        hasEmptyField = true;
        break;
      }
    }

    if (hasEmptyField) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Παρακαλώ συμπληρώστε όλα τα πεδία.'), 
          backgroundColor: Colors.redAccent,
        ),
      );
    } else {

      Map<String, String> data = {};
      for (var i = 0; i < fields.length; i++) {
        data[fields[i]] = _controllers[i].text.trim();
      }

      await apiTest(data);
    }
  }

  // The apiTest function is modified to accept the data map from the form
  Future<void> apiTest(Map<String, String> formData) async {
    final url = Uri.parse('http://localhost:7024/exesjson');

    // Combine form data with your API request body
    final Map<String, dynamic> requestBody = {
      ...formData, // Spread the data from the form
      "apicode": "VEUCAI0TVKJRPJA",
      "applicationname": "Hercules.25.01.12.106022b",
      "databasealias": "test_hotel",
      "username": "demo",
      "password": "demo",
    };

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        print('Response body: ${response.body}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Τα δεδομένα αποθηκεύτηκαν και εστάλησαν: ${response.body}'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        print('Request failed with status: ${response.statusCode}.');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Αποτυχία αιτήματος: ${response.statusCode}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      print('An error occurred: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Παρουσιάστηκε σφάλμα: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "Check In",
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.red[50], // Light red
        elevation: 0,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ...fields.asMap().entries.map((entry) {
                  int index = entry.key;
                  String fieldName = entry.value;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: TextField(
                      controller: _controllers[index],
                      style: const TextStyle(color: Colors.black),
                      decoration: InputDecoration(
                        hintText: fieldName,
                        hintStyle: const TextStyle(color: Colors.grey),
                        filled: true,
                        fillColor: Colors.white,
                        enabledBorder: OutlineInputBorder(
                          borderSide: const BorderSide(color: Colors.black54),
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: const BorderSide(color: Colors.redAccent, width: 2.0),
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                    ),
                  );
                }).toList(),
                // The save and send button
                ElevatedButton(
                  onPressed: _saveAndSendApiData,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                  child: const Text(
                    "Αποθήκευση", // "Save"
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
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
