import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import '../components/my_alert_dialog.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
//import 'package:uuid/uuid.dart';

class FormPage extends StatefulWidget {
  const FormPage({super.key});

  @override
  State<FormPage> createState() => _FormPageState();
}

class _FormPageState extends State<FormPage> {
  // Key to validate the entire form
  final _formKey = GlobalKey<FormState>();

  final List<String> inputFields = [
    'Όνομα / Name',
    'Επώνυμο / Surname',
    'Ημ. Γέννησης - Date of Birth (mm/dd/yyyy)',
    'ΑΔΤ / ID Number',
    'Οδός / Street',
    'Αριθμός Οδού / Street Number',
    'Πόλη / City',
    'Εθνικότητα / Nationality',
    'Τηλέφωνο / Phone',
    'Email',
  ];

  final List<String> fields = [
    'FIRSTNAME',
    'LASTNAME',
    'DATEOFBIRTH',
    'DOCNUMBER',
    'STREET',
    'STREETNUMBER',
    'CITY',
    'NATIONALITY',
    'TELEPHONE',
    'EMAIL',
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

  // --- NEW: Validator functions for each field type ---
  String? _validateGeneric(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Αυτό το πεδίο είναι υποχρεωτικό.';
    }
    return null;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Παρακαλώ εισάγετε το email σας.';
    }
    final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (!emailRegex.hasMatch(value)) {
      return 'Παρακαλώ εισάγετε ένα έγκυρο email.';
    }
    return null;
  }

  String? _validatePhoneNumber(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Παρακαλώ εισάγετε τον αριθμό τηλεφώνου σας.';
    }
    if (!RegExp(r'^\d{10}$').hasMatch(value)) {
      return 'Παρακαλώ εισάγετε έναν έγκυρο αριθμό.';
    }
    return null;
  }

  String? _validateDateOfBirth(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Παρακαλώ εισάγετε την ημερομηνία γέννησης σας.';
    }
    if (!RegExp(r'^\d{2}/\d{2}/\d{4}$').hasMatch(value)) {
      return 'Παρακαλώ εισάγετε μια έγκυρη ημερομηνία';
    }
    return null;
  }

  // Create a list of validator functions corresponding to the fields
  late final List<String? Function(String?)> _validators = [
    _validateGeneric, // Όνομα
    _validateGeneric, // Επώνυμο
    _validateDateOfBirth, // Ημ/νια Γέννησης
    _validateGeneric, // ΑΔΤ
    _validateGeneric, // Οδός
    _validateGeneric, // Αριθμός Οδού
    _validateGeneric, // Πόλη
    _validateGeneric, // Εθνικότητα
    _validatePhoneNumber, // Τηλέφωνο
    _validateEmail, // Email
  ];

  // Helper method to determine keyboard type
  TextInputType _getKeyboardType(String fieldName) {
    switch (fieldName) {
      case 'EMAIL':
        return TextInputType.emailAddress;
      case 'TELEPHONE':
        return TextInputType.phone;
      case 'STREETNUMBER':
        return TextInputType.number;
      default:
        return TextInputType.text;
    }
  }

  Future<Map<String, dynamic>> loadParameters() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final localFilePath = '${directory.path}/parameters.json';
      final localFile = File(localFilePath);

      if (await localFile.exists()) {
        final jsonString = await localFile.readAsString();
        return jsonDecode(jsonString);
      } else {
        final String jsonString = await rootBundle.loadString(
          'assets/data/parameters.json',
        );
        return jsonDecode(jsonString);
      }
    } catch (e) {
      if (!mounted) return {};
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Σφάλμα κατά την ανάγνωση των παραμέτρων: $e",
            style: const TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.red,
        ),
      );
      return {};
    }
  }

  Future<void> _saveAndSendApiData() async {
    // NEW: Trigger the form's validation
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Παρακαλώ συμπληρώστε σωστά όλα τα πεδία.',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final Map<String, dynamic> customerData = {
      "Name": _controllers[0].text.trim(),
      "Surname": _controllers[1].text.trim(),
      "Full Name":
          '${_controllers[0].text.trim()} ${_controllers[1].text.trim()}',
      "Email": _controllers[9].text.trim(), // DistinctiveTitle
      "Address": _controllers[4].text.trim(),
      "StreetNumber": _controllers[5].text.trim(),
      "City": _controllers[6].text.trim(),
      "IsRetail": "1", // send as string
      "Phone": _controllers[7].text.trim(),
      "DocNumber": _controllers[3].text.trim(),
      "DateofBirth": _controllers[2].text.trim(),
    };

    //"CountryId": "GR",

    // "PostCode": "10434",
    // "Phone": _controllers[5].text.trim(),

    setState(() {
      _isLoading = true;
    });

    await apiTest(customerData);
    //print(jsonEncode(customerData));

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> apiTest(Map<String, dynamic> formData) async {
    final url = Uri.parse(
      'http://${parameters?["ipaddress"]}:${parameters?["port"]}/exesjson/elogin',
    );

    final Map<String, dynamic> requestBody = {
      "apicode": "${parameters?["apicode"]}",
      "applicationname": "Hercules.MyPylonHoReRe",
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
                style: const TextStyle(color: Colors.white),
              ),
              backgroundColor: const Color.fromARGB(255, 226, 141, 56),
            ),
          );
        } else {
          _cookie = jsonDecode(decodedBody['Result'])['cookie'];

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Επιτυχής Σύνδεση',
                style: TextStyle(color: Colors.white),
              ),
              backgroundColor: Colors.green,
            ),
          );

          await postData(formData);
        }
      } else {
        print('Request failed with status: ${response.statusCode}.');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Αποτυχία αιτήματος: ${response.statusCode}',
              style: const TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      print('An error occurred: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Παρουσιάστηκε σφάλμα: $e',
            style: const TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.red,
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
      'http://${parameters?['ipaddress']}:${parameters?['port']}/exesjson/postdata',
    );

    if (_cookie == null) {
      if (!mounted) return;
      _showAlertDialog('Σφάλμα', 'Απαιτείται σύνδεση.', Colors.red);
      return;
    }

    final Map<String, dynamic> requestBody = {
      "cookie": _cookie,
      "apicode": "${parameters?['apicode']}",
      "entitycode": "ImportCustHotel",
      "packagenumber": 1,
      "packagesize": 2000,
      "data": jsonEncode(formData),
    };

    print("COOKIE $_cookie \n\n\n");

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
            Colors.orange,
          );
          print(response.body);
        } else {
          _showAlertDialog(
            'Επιτυχία',
            'Τα δεδομένα στάλθηκαν με επιτυχία.',
            Colors.green,
          );
          print(response.body);
        }
      } else {
        _showAlertDialog(
          'Σφάλμα',
          'Αποτυχία αιτήματος με κωδικό: ${response.statusCode}',
          Colors.red,
        );
      }
    } catch (e) {
      if (!mounted) return;
      _showAlertDialog('Σφάλμα', 'Παρουσιάστηκε σφάλμα: $e', Colors.red);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
  resizeToAvoidBottomInset: true,
  backgroundColor: Colors.white,
  appBar: AppBar(
    title: const Text("Check In", style: TextStyle(color: Colors.black)),
    backgroundColor: Colors.grey[200],
    elevation: 0,
  ),
  body: Stack(
    children: [
      // Background image
      Image.asset(
        'assets/images/background.jpg',
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
      ),

      // Scrollable form
      LayoutBuilder(
        builder: (context, constraints) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SingleChildScrollView(
              // Make room for the bottom button
              padding: EdgeInsets.only(bottom: 100),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight,
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 20),
                      ...inputFields.asMap().entries.map((entry) {
                        int index = entry.key;
                        String fieldName = entry.value;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16.0),
                          child: TextFormField(
                            controller: _controllers[index],
                            style: const TextStyle(color: Colors.black),
                            decoration: InputDecoration(
                              hintText: fieldName,
                              hintStyle: const TextStyle(color: Colors.black54),
                              filled: true,
                              fillColor: Colors.white24,
                              enabledBorder: OutlineInputBorder(
                                borderSide: const BorderSide(color: Colors.black54),
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: const BorderSide(
                                    color: Color.fromARGB(255, 130, 110, 164), width: 2.0),
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              errorBorder: OutlineInputBorder(
                                borderSide: const BorderSide(color: Colors.red, width: 2.0),
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              focusedErrorBorder: OutlineInputBorder(
                                borderSide: const BorderSide(color: Colors.red, width: 2.0),
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                            ),
                            validator: _validators[index],
                            keyboardType: _getKeyboardType(fields[index]),
                          ),
                        );
                      }).toList(),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),

      Positioned(
        left: 30,
        right: 30,
        bottom: 100,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : ElevatedButton(
                onPressed: _saveAndSendApiData,
                style: ElevatedButton.styleFrom(
                  elevation: 20,
                  backgroundColor: Colors.purple[500],
                  padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                child: const Text(
                  "Αποθήκευση",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
      ),
    ],
  ),
);


  }
}
