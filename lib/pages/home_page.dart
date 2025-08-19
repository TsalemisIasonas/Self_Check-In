import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pylon_hotel_self_checkin/components/variables_dialog.dart';
import 'package:pylon_hotel_self_checkin/pages/form_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Alignment _contentAlignment = Alignment(-20.0, 0.2);

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

  bool _checkEssentialKeys(Map<String, dynamic>? params) {
    List _essentialKeys = [
      'apicode',
      'ipaddress',
      'port',
      'databasealias',
      'username',
      'password',
    ];
    if (params == null) return false;
    return _essentialKeys.every(
      (key) =>
          params.containsKey(key) &&
          params[key] is String &&
          params[key].isNotEmpty,
    );
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

    Future.delayed(const Duration(seconds: 1), () {
      if (!_checkEssentialKeys(parameters)) writeParameters();
    });

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
        print(_localFilePath);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save parameters: $e')),
        );
      }
    }
    //_initDataAndControllers();
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
        return VariablesDialog(
          parameters: parameters!,
          controllers: _controllers,
          saveParameters: _saveParameters,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // This is a crucial property for handling the keyboard
      resizeToAvoidBottomInset: true,
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
          SingleChildScrollView(
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
                  AnimatedAlign(
                    alignment: _contentAlignment,
                    duration: const Duration(milliseconds: 1000),
                    child: Image.asset(
                      'assets/images/checkin.jpg',
                      fit: BoxFit.cover,
                      width: MediaQuery.of(context).size.width * 0.8,
                      height: MediaQuery.of(context).size.width * 0.8,
                    ),
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
