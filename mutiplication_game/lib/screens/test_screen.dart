import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class TestScreen extends StatelessWidget {
  const TestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const FaIcon(FontAwesomeIcons.arrowLeft, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text("Test", style: TextStyle(color: Colors.white)),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Stats Area
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _statBox("0", "Completed", icon: FontAwesomeIcons.checkDouble),
                _statBox("0%", "Accuracy Rate", icon: FontAwesomeIcons.percent),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _statBox("0", "Correct", icon: FontAwesomeIcons.circleCheck, color: Colors.green),
                _statBox("0", "Wrong", icon: FontAwesomeIcons.circleXmark, color: Colors.red),
              ],
            ),
            const SizedBox(height: 32),

            // Complexity Header
            const Text(
              "Choose Test Complexity",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white70,
              ),
            ),
            const SizedBox(height: 24),

            // Level Select
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _levelIcon("Easy", FontAwesomeIcons.baby),
                _levelIcon("Middle", FontAwesomeIcons.userGraduate),
                _levelIcon("Hard", FontAwesomeIcons.brain),
              ],
            ),
            const Spacer(),

            // Start Test Button
            ElevatedButton.icon(
              onPressed: () {
                // TODO: Implement test start logic
              },
              icon: const FaIcon(FontAwesomeIcons.play),
              label: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                child: Text("START TEST", style: TextStyle(fontSize: 18)),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurpleAccent,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                elevation: 6,
                shadowColor: Colors.deepPurpleAccent.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _statBox(String value, String label,
      {required IconData icon, Color color = Colors.deepPurpleAccent}) {
    return Container(
      width: 150,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color, width: 1.5),
      ),
      child: Column(
        children: [
          FaIcon(icon, color: color),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color),
          ),
          Text(
            label,
            style: const TextStyle(fontSize: 14, color: Colors.white70),
          ),
        ],
      ),
    );
  }

  Widget _levelIcon(String label, IconData icon) {
    return Column(
      children: [
        CircleAvatar(
          radius: 32,
          backgroundColor: Colors.deepPurpleAccent.withOpacity(0.15),
          child: FaIcon(icon, size: 28, color: Colors.deepPurpleAccent),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }
}
