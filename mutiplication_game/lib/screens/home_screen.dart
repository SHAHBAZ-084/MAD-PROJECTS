import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'learn_table_screen.dart';
import 'test_screen.dart';
import 'training_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text(
          "Multiplication Table",
          style: TextStyle(color: Colors.white),
        ),
        elevation: 0,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: GridView.count(
          crossAxisCount: 2,
          mainAxisSpacing: 20,
          crossAxisSpacing: 20,
          children: [
            _navCard(
              context,
              icon: FontAwesomeIcons.calculator,
              label: "Learn Table",
              screen: const LearnTableScreen(),
              color: Colors.deepPurpleAccent,
            ),
            _navCard(
              context,
              icon: FontAwesomeIcons.clipboardQuestion,
              label: "Test",
              screen: const TestScreen(),
              color: Colors.blueAccent,
            ),
            _navCard(
              context,
              icon: FontAwesomeIcons.dumbbell,
              label: "Training",
              screen: const TrainingScreen(),
              color: Colors.greenAccent,
            ),
          ],
        ),
      ),
    );
  }

  Widget _navCard(BuildContext context,
      {required IconData icon,
        required String label,
        required Widget screen,
        required Color color}) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => screen),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: color.withOpacity(0.9),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.4),
              blurRadius: 8,
              offset: const Offset(2, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 36, color: Colors.white),
            const SizedBox(height: 12),
            Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            )
          ],
        ),
      ),
    );
  }
}
