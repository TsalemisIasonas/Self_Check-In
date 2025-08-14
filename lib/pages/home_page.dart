import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pylon_hotel_self_checkin/pages/form_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Alignment _contentAlignment = const Alignment(-2.0, 0.2);

  final List<TextEditingController> _controllers = [];
  Map<String, dynamic>? parameters;
  String _localFilePath = '';

  @override
  void initState() {
    super.initState();
    _initDataAndControllers();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        _contentAlignment = const Alignment(0.0, 0.2);
      });
    });
  }

  Future<void> _initDataAndControllers() async {
    final directory = await getApplicationDocumentsDirectory();
    _localFilePath = '${directory.path}/parameters.json';

    final localFile = File(_localFilePath);
    if (await localFile.exists()) {
      final jsonString = await localFile.readAsString();
      parameters = jsonDecode(jsonString);
    } else {
      final String jsonString = await rootBundle.loadString(
        'assets/data/parameters.json',
      );
      parameters = jsonDecode(jsonString);
    }

    if (parameters != null) {
      parameters!.forEach((key, value) {
        final controller = TextEditingController(text: value.toString());
        _controllers.add(controller);
      });
    }

    setState(() {});
  }

  Future<void> _saveParameters() async {
    if (parameters == null) return;
    try {
      final Map<String, dynamic> updatedParameters = {};
      final keys = parameters!.keys.toList();

      for (int i = 0; i < keys.length; i++) {
        updatedParameters[keys[i]] = _controllers[i].text;
      }

      final jsonString = json.encode(updatedParameters);

      final localFile = File(_localFilePath);
      await localFile.writeAsString(jsonString);

      setState(() {
        parameters = updatedParameters;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Parameters saved to $_localFilePath')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save parameters: $e')),
        );
      }
    }
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void writeParameters() {
    if (parameters == null) {
      return;
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.grey[300],
          title: const Text(
            "ΠΑΡΑΜΕΤΡΟΙ",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w400),
          ),
          content: SizedBox(
            width: MediaQuery.of(context).size.width * 0.8,
            height: MediaQuery.of(context).size.width * 0.8,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.max,
                children: parameters!.entries.map((entry) {
                  final int index = parameters!.keys.toList().indexOf(entry.key);
                  final String fieldName = entry.key;
            
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: TextField(
                      controller: _controllers[index],
                      style: const TextStyle(color: Colors.black),
                      decoration: InputDecoration(
                        hintText: fieldName,
                        hintStyle: const TextStyle(color: Colors.black54),
                        filled: true,
                        fillColor:
                            Colors.grey[300], // Changed to a more visible color.
                        enabledBorder: OutlineInputBorder(
                          borderSide: const BorderSide(color: Colors.black54),
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
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text(
                "AΚΥΡΟ",
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                _saveParameters();
                Navigator.of(context).pop();
              },
              child: const Text(
                "ΑΠΟΘΗΚΕΥΣΗ",
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Check In", style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.purple[50],
        elevation: 0,
        actions: [
          IconButton(
            onPressed: writeParameters,
            icon: const Icon(Icons.more_vert),
          ),
        ],
      ),
      body: Stack(
        children: [
          Image.asset(
            'assets/images/background.jpg',
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          ),
          AnimatedAlign(
            alignment: _contentAlignment,
            duration: const Duration(milliseconds: 1000),
            child: SafeArea(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const SizedBox(height: 70),
                  const Text(
                    "ΚΑΛΩΣ ΗΡΘΑΤΕ",
                    style: TextStyle(
                      fontSize: 35,
                      fontWeight: FontWeight.w300,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Image.asset(
                    'assets/images/checkin.jpg',
                    fit: BoxFit.cover,
                    width: MediaQuery.of(context).size.width * 0.8,
                    height: MediaQuery.of(context).size.width * 0.8,
                  ),
                  const SizedBox(height: 100),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const FormPage(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple[500],
                      foregroundColor: Colors.white,
                      minimumSize: Size(
                        MediaQuery.of(context).size.width * 0.6,
                        60,
                      ),
                      textStyle: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w400,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      elevation: 20,
                    ),
                    child: const Text("ΣΥΝΕΧΕΙΑ"),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
