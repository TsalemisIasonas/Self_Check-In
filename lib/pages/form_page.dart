import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import '../components/my_alert_dialog.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class FormPage extends StatefulWidget {
  const FormPage({super.key});

  @override
  State<FormPage> createState() => _FormPageState();
}

class _FormPageState extends State<FormPage> {
  final List<String> inputFields = [
    'Όνομα',
    'Επώνυμο',
    'Ημ/νια Γέννησης',
    'ΑΔΤ',
    'Εθνικότητα',
    'Τηλέφωνο',
    'Email',
  ];

  final List<String> fields = [
    'CNTCFIRSTNAME',
    'CNTCLASTNAME',
    'CNTCBIRTHDATE',
    'CNTCIDENTITYCARDNUMBER',
    'CNTCNATIONALITY',
    'PRIMARYBRANCHPHONE1',
    'PRIMARYBRANCHEMAIL',
  ];

  final List<TextEditingController> _controllers = [];
  String? _cookie;
  Map<String, dynamic>? parameters;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    for (var i = 0; i < inputFields.length; i++) {
      _controllers.add(TextEditingController());
    }
    loadParameters().then((params) {
      setState(() {
        parameters = params;
      });
    });
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<Map<String, dynamic>> loadParameters() async {
    try {
      // Get the path to the application's document directory
      final directory = await getApplicationDocumentsDirectory();
      final localFilePath = '${directory.path}/parameters.json';
      final localFile = File(localFilePath);

      //Check if the local file exists.
      if (await localFile.exists()) {
        //If it exists, read from the local file.
        final jsonString = await localFile.readAsString();
        return jsonDecode(jsonString);
      } else {
        // 4. If the local file doesn't exist, fall back to the asset file.
        final String jsonString = await rootBundle.loadString(
          'assets/data/parameters.json',
        );
        return jsonDecode(jsonString);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Σφάλμα κατά την ανάγνωση των παραμέτρων",
            style: TextStyle(backgroundColor: Colors.red),
          ),
        ),
      );
      return {};
    }
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
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Παρακαλώ συμπληρώστε όλα τα πεδία.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final Map<String, dynamic> formData = {};
    for (var i = 0; i < inputFields.length; i++) {
      formData[fields[i]] = _controllers[i].text.trim();
    }

    // Set loading state
    setState(() {
      _isLoading = true;
    });

    await apiTest(formData);

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> apiTest(Map<String, dynamic> formData) async {
    //print('http://${parameters?["ipaddress"]}:${parameters?["port"]}/exesjson/elogin');
    final url = Uri.parse(
      'http://${parameters?["ipaddress"]}:${parameters?["port"]}/exesjson/elogin',
    );

    final Map<String, dynamic> requestBody = {
      "apicode": "${parameters?["apicode"]}",
      "applicationname": "Hercules.MyPylonCommercial",
      "databasealias": "${parameters?["databasealias"]}",
      "username": "${parameters?["username"]}",
      "password": "${parameters?["password"]}",
    };

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(requestBody),
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        final decodedBody = jsonDecode(response.body);

        if (decodedBody['Status'] == 'ERROR') {
          print('Response body: ${response.body}');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Προέκυψε Σφάλμα μετά τη Σύνδεση: ${decodedBody['Error']}',
              ),
              backgroundColor: const Color.fromARGB(255, 226, 141, 56),
            ),
          );
        } else {
          _cookie = jsonDecode(decodedBody['Result'])['cookie'];

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Επιτυχής Σύνδεση'),
              backgroundColor: Colors.green,
            ),
          );

          await postData(formData);
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
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Παρουσιάστηκε σφάλμα: $e'),
          backgroundColor: Colors.red[200],
        ),
      );
    }
  }

  void _showAlertDialog(String title, String content, Color? color) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return MyAlertDialog(title: title, content: content, color: color);
      },
    );
  }

  Future<void> postData(Map<String, dynamic> formData) async {
    final url = Uri.parse(
      'http://${parameters?['ipaddress']}:${parameters?['port']}}/exesjson/postdata',
    );

    if (_cookie == null) {
      if (!mounted) return;
      _showAlertDialog('Σφάλμα', 'Απαιτείται σύνδεση.', Colors.red);
      return;
    }

    final Map<String, dynamic> requestBody = {
      "cookie": _cookie,
      "apicode": "WDUQ52FIWWOEXUG",
      "entitycode": "GetScript",
      "packagenumber": 1,
      "packagesize": 2000,
      "data": jsonEncode(formData),
    };

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(requestBody),
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        final decodedBody = jsonDecode(response.body);
        if (decodedBody['Status'] == 'ERROR') {
          _showAlertDialog(
            'Σφάλμα',
            'Παρουσιάστηκε σφάλμα κατά την αποστολή:\n ${decodedBody["Error"]}',
            Colors.orange[200],
          );
          print(response.body);
        } else {
          _showAlertDialog(
            'Επιτυχία',
            'Τα δεδομένα στάλθηκαν με επιτυχία.',
            Colors.green[200],
          );
          print(response.body);
        }
      } else {
        _showAlertDialog(
          'Σφάλμα',
          'Αποτυχία αιτήματος με κωδικό: ${response.statusCode}',
          Colors.red[200],
        );
      }
    } catch (e) {
      if (!mounted) return;
      _showAlertDialog('Σφάλμα', 'Παρουσιάστηκε σφάλμα: $e', Colors.red[200]);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Check In", style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.grey[200],
        elevation: 0,
      ),
      body: Stack(
        children: [
          Image.asset(
            'assets/images/background.jpg',
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          ),
          Stack(
            children: [
              _isLoading
                  ? Center(
                      child: SizedBox(
                        width: 100,
                        height: 100,
                        child: const CircularProgressIndicator(strokeWidth: 5),
                      ),
                    )
                  : SizedBox.shrink(),
              Padding(
                padding: const EdgeInsets.all(16),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 20),
                      ...inputFields.asMap().entries.map((entry) {
                        int index = entry.key;
                        String fieldName = entry.value;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16.0),
                          child: TextField(
                            controller: _controllers[index],
                            style: const TextStyle(color: Colors.black),
                            decoration: InputDecoration(
                              hintText: fieldName,
                              hintStyle: const TextStyle(color: Colors.black54),
                              filled: true,
                              fillColor: Colors.white24,
                              enabledBorder: OutlineInputBorder(
                                borderSide: const BorderSide(
                                  color: Colors.black54,
                                ),
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: const BorderSide(
                                  color: Color.fromARGB(255, 130, 110, 164),
                                  width: 2.0,
                                ),
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                      const SizedBox(height: 40),
                      ElevatedButton(
                        onPressed: _saveAndSendApiData,
                        style: ElevatedButton.styleFrom(
                          elevation: 20,
                          backgroundColor: Colors.purple[500],
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
            ],
          ),
        ],
      ),
    );
  }
}
