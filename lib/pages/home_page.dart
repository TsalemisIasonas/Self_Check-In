import 'package:flutter/material.dart';
import 'form_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // We use a double? so we can represent a state where the height
  // hasn't been set yet (null), which is better than 0.0.
  double? _containerHeight;

  @override
  void initState() {
    super.initState();
    // Use `WidgetsBinding.instance.addPostFrameCallback` for a more reliable
    // way to get screen size after the first frame has been built.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        _containerHeight = MediaQuery.of(context).size.height;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Align(
        alignment: Alignment.bottomCenter,
        child: AnimatedContainer(
          // Check for null and set height to 0.0 if not yet initialized.
          height: _containerHeight ?? 0.0,
          duration: const Duration(milliseconds: 900),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Flexible spacer to push the content down
                const Spacer(flex: 3), 
                
                // Using a regular Icon and a Spacer for flexible spacing
                const Icon(
                  Icons.check_circle_outline,
                  size: 100,
                  color: Colors.redAccent,
                ),

                // Another flexible spacer to push the button up
                const Spacer(flex: 2),

                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const FormPage(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    foregroundColor: Colors.white,
                    minimumSize: Size(
                        MediaQuery.of(context).size.width * 0.2, 60),
                    textStyle: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w400,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                    elevation: 5,
                  ),
                  child: const Text("ΣΥΝΕΧΕΙΑ"),
                ),

                // Add a small spacer at the bottom for a little padding
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
