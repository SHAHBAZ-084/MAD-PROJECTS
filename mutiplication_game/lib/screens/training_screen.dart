import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class TrainingScreen extends StatefulWidget {
  const TrainingScreen({super.key});

  @override
  State<TrainingScreen> createState() => _TrainingScreenState();
}

class _TrainingScreenState extends State<TrainingScreen> {
  String selectedOperator = '×';
  String selectedGame = 'Test';
  double difficulty = 10;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(FontAwesomeIcons.arrowLeft, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text("Select Difficulty", style: TextStyle(color: Colors.white)),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("What would you like to train?",
                style: TextStyle(fontSize: 18, color: Colors.white70)),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              alignment: WrapAlignment.center,
              children: _buildOperatorChips(),
            ),
            const SizedBox(height: 32),
            Text(
              "Difficulty Level: ${difficulty.toInt()} (Max number)",
              style: const TextStyle(fontSize: 16, color: Colors.white70),
            ),
            SliderTheme(
              data: SliderTheme.of(context).copyWith(
                activeTrackColor: Colors.deepPurpleAccent,
                inactiveTrackColor: Colors.deepPurple.withOpacity(0.4),
                thumbColor: Colors.deepPurpleAccent,
                overlayColor: Colors.deepPurpleAccent.withOpacity(0.2),
              ),
              child: Slider(
                value: difficulty,
                min: 1,
                max: 100,
                divisions: 99,
                label: difficulty.toInt().toString(),
                onChanged: (value) {
                  setState(() {
                    difficulty = value;
                  });
                },
              ),
            ),
            const SizedBox(height: 30),
            const Text("Type of Game", style: TextStyle(fontSize: 18, color: Colors.white70)),
            const SizedBox(height: 10),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              alignment: WrapAlignment.center,
              children: _buildGameChips(),
            ),
            const Spacer(),
            Center(
              child: ElevatedButton.icon(
                onPressed: () {
                  // TODO: Launch training game
                },
                icon: const Icon(FontAwesomeIcons.play),
                label: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                  child: Text("START", style: TextStyle(fontSize: 18)),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurpleAccent,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  elevation: 6,
                  shadowColor: Colors.deepPurpleAccent.withOpacity(0.5),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildOperatorChips() {
    final operators = {
      '+': FontAwesomeIcons.plus,
      '-': FontAwesomeIcons.minus,
      '÷': FontAwesomeIcons.divide,
      '×': FontAwesomeIcons.xmark,
    };

    return operators.entries.map((entry) {
      final isSelected = selectedOperator == entry.key;
      return ChoiceChip(
        label: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(entry.value, size: 16, color: isSelected ? Colors.white : Colors.deepPurpleAccent),
            const SizedBox(width: 4),
            Text(
              entry.key,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.deepPurpleAccent,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        selected: isSelected,
        selectedColor: Colors.deepPurpleAccent,
        backgroundColor: Colors.white10,
        onSelected: (_) {
          setState(() {
            selectedOperator = entry.key;
          });
        },
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      );
    }).toList();
  }

  List<Widget> _buildGameChips() {
    final gameTypes = {
      'Test': FontAwesomeIcons.pencil,
      'True / False': FontAwesomeIcons.check,
      'Input': FontAwesomeIcons.keyboard,
    };

    return gameTypes.entries.map((entry) {
      final isSelected = selectedGame == entry.key;
      return ChoiceChip(
        label: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(entry.value, size: 16, color: isSelected ? Colors.white : Colors.deepPurpleAccent),
            const SizedBox(width: 4),
            Text(
              entry.key,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.deepPurpleAccent,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        selected: isSelected,
        selectedColor: Colors.deepPurpleAccent,
        backgroundColor: Colors.white10,
        onSelected: (_) {
          setState(() {
            selectedGame = entry.key;
          });
        },
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      );
    }).toList();
  }
}
