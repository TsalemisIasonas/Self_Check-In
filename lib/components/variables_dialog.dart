import 'package:flutter/material.dart';

class VariablesDialog extends StatelessWidget {

  final Map<String, dynamic>? parameters;
  final List<TextEditingController> controllers;    
  final Function saveParameters;

  const VariablesDialog({
    super.key,
    required this.parameters,
    required this.controllers,
    required this.saveParameters,
  });

  @override
  Widget build(BuildContext context) {
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
                  controller: controllers[index],
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
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.w400),
          ),
        ),
        TextButton(
          onPressed: () {
            saveParameters();
            Navigator.of(context).pop();
          },
          child: const Text(
            "ΑΠΟΘΗΚΕΥΣΗ",
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.w400),
          ),
        ),
      ],
    );
  }
}
