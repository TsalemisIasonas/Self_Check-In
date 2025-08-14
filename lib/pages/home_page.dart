import 'package:flutter/material.dart';
import 'form_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // This variable will control the alignment, starting from off-screen to the left.
  // The value of -2.0 ensures it is completely out of view.
  Alignment _contentAlignment = const Alignment(-2.0, 0.2);

  @override
  void initState() {
    super.initState();
    // Use a post-frame callback to trigger the animation after the widget
    // has been built for the first time.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        // We set the alignment to the final position to trigger the slide-in animation.
        _contentAlignment = const Alignment(0.0, 0.2);
      });
    });
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
          // We use an AnimatedAlign widget. It animates its alignment
          // from the old value to the new one over a duration.
          AnimatedAlign(
            alignment: _contentAlignment,
            duration: const Duration(milliseconds: 1000),
            child: SafeArea(
              child: Column(

                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const SizedBox(height: 100,),
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
                  const SizedBox(height: 40),
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
