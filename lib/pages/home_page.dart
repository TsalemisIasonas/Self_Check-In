import 'package:flutter/material.dart';
import 'form_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // We'll use this variable to animate the height of the container.
  // It should be initialized to 0.0 to start the animation from the bottom.
  double _containerHeight = 0.0;

  @override
  void initState() {
    super.initState();
    // Use Future.delayed to change the height after the initial build.
    // This allows the animation to happen after the widget is first rendered.
    // The duration of 100 milliseconds gives a slight delay before the animation starts.
    Future.delayed(const Duration(milliseconds: 100), () {
      setState(() {
        // We set the height to the full screen height to animate the container
        // rising from the bottom to the top.
        _containerHeight = MediaQuery.of(context).size.height;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Align(
        alignment: Alignment.bottomCenter, // Align the container to the bottom
        child: AnimatedContainer(
          // The container will animate its height from 0.0 to the full screen height.
          height: _containerHeight,
          duration: const Duration(milliseconds: 900),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Icon is styled with your primary colors
                const Icon(
                  Icons.check_circle_rounded,
                  size: 100,
                  color: Colors.redAccent,
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.4),
                TextButton(
                  onPressed: () {
                    // Navigate to the FormPage
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const FormPage(),
                      ),
                    );
                  },
                  child: const Text(
                    "ΣΥΝΕΧΕΙΑ", // CONTINUE
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
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
