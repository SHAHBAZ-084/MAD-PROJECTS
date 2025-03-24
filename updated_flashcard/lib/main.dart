import 'package:flutter/material.dart';

void main() {
  runApp(FlashcardApp());
}

class FlashcardApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flashcard App',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: FlashcardScreen(),
    );
  }
}

class FlashcardScreen extends StatefulWidget {
  @override
  _FlashcardScreenState createState() => _FlashcardScreenState();
}

class _FlashcardScreenState extends State<FlashcardScreen> {
  int currentIndex = 0;
  bool showAnswer = false;
  String selectedCategory = "General Knowledge";

  // Categories with flashcards
  final Map<String, List<Map<String, String>>> flashcardCategories = {
    "General Knowledge": [
      {"question": "What is the capital of France?", "answer": "Paris"},
      {"question": "Who developed the theory of relativity?", "answer": "Albert Einstein"},
      {"question": "Which is the largest ocean on Earth?", "answer": "Pacific Ocean"},
    ],
    "Math": [
      {"question": "What is 5 + 3?", "answer": "8"},
      {"question": "What is the square root of 64?", "answer": "8"},
      {"question": "Solve for x: 2x = 10", "answer": "x = 5"},
    ],
    "Science": [
      {"question": "What planet is known as the Red Planet?", "answer": "Mars"},
      {"question": "What gas do plants absorb from the atmosphere?", "answer": "Carbon Dioxide"},
      {"question": "What is the powerhouse of the cell?", "answer": "Mitochondria"},
    ],
    "Technology": [
      {"question": "Who developed Flutter?", "answer": "Google"},
      {"question": "What does CPU stand for?", "answer": "Central Processing Unit"},
      {"question": "What year was Dart released?", "answer": "2011"},
    ],
  };

  List<Map<String, String>> get flashcards => flashcardCategories[selectedCategory]!;

  void nextFlashcard() {
    setState(() {
      showAnswer = false;
      currentIndex = (currentIndex + 1) % flashcards.length;
    });
  }

  void flipCard() {
    setState(() {
      showAnswer = !showAnswer;
    });
  }

  void changeCategory(String? category) {
    if (category != null) {
      setState(() {
        selectedCategory = category;
        currentIndex = 0; // Reset to the first question
        showAnswer = false; // Show question first
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Flashcard App")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Category Selection Dropdown
            DropdownButton<String>(
              value: selectedCategory,
              onChanged: changeCategory,
              items: flashcardCategories.keys.map((String category) {
                return DropdownMenuItem(
                  value: category,
                  child: Text(category, style: TextStyle(fontSize: 18)),
                );
              }).toList(),
            ),

            SizedBox(height: 20),

            // Flashcard
            GestureDetector(
              onTap: flipCard,
              child: Container(
                width: 300,
                height: 200,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.blueAccent,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 5)],
                ),
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Text(
                    showAnswer
                        ? flashcards[currentIndex]["answer"]!
                        : flashcards[currentIndex]["question"]!,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 22, color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),

            SizedBox(height: 20),

            // Next Flashcard Button
            ElevatedButton.icon(
              onPressed: nextFlashcard,
              icon: Icon(Icons.arrow_forward),
              label: Text("Next Flashcard"),
            ),
          ],
        ),
      ),
    );
  }
}
