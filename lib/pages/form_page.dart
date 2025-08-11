import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class FormPage extends StatefulWidget {
  const FormPage({super.key});

  @override
  State<FormPage> createState() => _FormPageState();
}

class _FormPageState extends State<FormPage> {
  final List<String> fields = [
    'Όνομα',
    'Επώνυμο',
    'Ημ/νια Γέννησης',
    'ΑΔΤ',
    'Εθνικότητα',
    'Τηλέφωνο',
    'Email',
  ];

  final List<TextEditingController> _controllers = [];

  @override
  void initState() {
    super.initState();
    for (var i = 0; i < fields.length; i++) {
      _controllers.add(TextEditingController());
    }
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

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

      print(data);

      await apiTest(data);
    }
  }

  Future<void> apiTest(Map<String, String> formData) async {
    final url = Uri.parse('http://192.168.90.73:7024/exesjson/elogin');

    final Map<String, dynamic> requestBody = {
      //...formData,
      "apicode": "250KNXMNDIKOCYA",
      "applicationname": "Hercules.MyPylonCommercial",
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
        if (jsonDecode(response.body)['Status'] == 'ERROR') {
          print('Response body: ${response.body}');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Επιτυχής Σύνδεση, Σφάλμα δεδομένων: ${response.body}',
              ),
              backgroundColor: const Color.fromARGB(255, 226, 141, 56),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Τα δεδομένα αποθηκεύτηκαν και εστάλησαν: ${response.body}',
              ),
              backgroundColor: Colors.green,
            ),
          );
        }
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
        title: const Text("Check In", style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.red[50], // Light red
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: 20),
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
                        borderSide: const BorderSide(
                          color: Colors.redAccent,
                          width: 2.0,
                        ),
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                  ),
                );
              }).toList(),
              SizedBox(height: 40),
              ElevatedButton(
                onPressed: _saveAndSendApiData,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 50,
                    vertical: 15,
                  ),
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
    );
  }
}
