import 'package:flutter/material.dart';
import '../../../core/constants/colors.dart';

class ShlokaMatchScreen extends StatefulWidget {
  const ShlokaMatchScreen({super.key});

  @override
  State<ShlokaMatchScreen> createState() => _ShlokaMatchScreenState();
}

class _ShlokaMatchScreenState extends State<ShlokaMatchScreen> {
  final Map<String, String> shlokas = {
    'कर्मण्येवाधिकारस्ते': 'Focus on your actions, not results',
    'योगस्थः कुरु कर्माणि': 'Be steady in yoga while acting',
    'न हि ज्ञानेन सदृशम्': 'Nothing is purer than knowledge',
  };

  String? matchedShloka;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Shloka Match'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text(
              'Drag the meaning to the correct shloka',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),

            Expanded(
              child: Row(
                children: [
                  Expanded(child: _buildShlokaColumn()),
                  const SizedBox(width: 12),
                  Expanded(child: _buildMeaningColumn()),
                ],
              ),
            ),

            if (matchedShloka != null)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text(
                  'Correct! 🎉',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.saffron,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// LEFT COLUMN — DROP TARGETS
  Widget _buildShlokaColumn() {
    return Column(
      children: shlokas.keys.map((shloka) {
        return DragTarget<String>(
          onAccept: (meaning) {
            if (shlokas[shloka] == meaning) {
              setState(() {
                matchedShloka = shloka;
              });
            }
          },
          builder: (context, candidateData, rejectedData) {
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: matchedShloka == shloka
                    ? AppColors.saffron.withOpacity(0.2)
                    : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.saffron,
                ),
              ),
              child: Text(
                shloka,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            );
          },
        );
      }).toList(),
    );
  }

  /// RIGHT COLUMN — DRAGGABLE MEANINGS
  Widget _buildMeaningColumn() {
    return Column(
      children: shlokas.values.map((meaning) {
        return Draggable<String>(
          data: meaning,
          feedback: _dragCard(meaning, dragging: true),
          childWhenDragging: _dragCard(meaning, disabled: true),
          child: _dragCard(meaning),
        );
      }).toList(),
    );
  }

  Widget _dragCard(String text,
      {bool dragging = false, bool disabled = false}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: disabled
            ? Colors.grey.shade200
            : dragging
                ? AppColors.gold
                : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          if (!disabled)
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
        ],
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 14),
      ),
    );
  }
}