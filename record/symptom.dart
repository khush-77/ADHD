import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mindle/models/database_helper.dart';
import 'package:mindle/models/goals.dart';
import 'package:mindle/ui/home/record/medication.dart';

class SymptomLogging extends StatefulWidget {
  const SymptomLogging({super.key});

  @override
  State<SymptomLogging> createState() => _SymptomLoggingState();
}

class _SymptomLoggingState extends State<SymptomLogging> {
  DateTime? _startDate;
  DateTime? _endDate;

  String? selectedFrequency;
  String? _selectedFrequency;

  final ScrollController _scrollController = ScrollController();
  final TextEditingController _notesController = TextEditingController();

  Timer? _debounce;
  final Map<String, bool> symptomSelection = {
    'Impulsivity': false,
    'Irritability': false,
    'Inattention': false,
  };

  final _frequencyOptions = [
    'Morning',
    'Mid Day',
    'Afternoon',
    'Evening',
    'Night',
    'Mid Night',
  ];
  int _selectedFrequencyIndex = 0;
  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final DateTime today = DateTime.now();
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: isStartDate ? (_startDate ?? today) : (_endDate ?? today),
      firstDate: today,
      lastDate: DateTime(today.year + 10),
    );

    if (pickedDate != null) {
      setState(() {
        if (isStartDate) {
          _startDate = pickedDate;
        } else {
          _endDate = pickedDate;
        }
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScrollStopped);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScrollStopped);
    _debounce?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  void _saveGoal() async {
    if (_startDate == null || selectedFrequency == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill all required fields')),
      );
      return;
    }

    final goal = Goal(
      name: 'Your Goal Name', // Replace with actual input
      frequency: selectedFrequency!,
      startDate: _startDate!,
      notes: _notesController.text,
    );

    await DatabaseHelper.instance.insertGoal(goal);
    Navigator.pop(context);
  }

  void _onScrollStopped() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    _debounce = Timer(const Duration(milliseconds: 100), () {
      final offset = _scrollController.offset;
      final itemHeight = 56.0;
      final index = (offset / itemHeight).round();

      setState(() {
        _selectedFrequencyIndex = index;
      });
    });
  }

  void _selectFrequency(int index) {
    setState(() {
      _selectedFrequencyIndex = index;

      // Ensure the list scrolls to the selected frequency
      _scrollController.animateTo(
        index * 56.0, // 56.0 is the height of each item
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final fontScale = size.width / 375.0;
    final softPurple = const Color(0xFF8D5BFF);
    final grey = const Color(0xFFF5F5F5);
    final darkPurple = const Color(0xFF2D2642);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        centerTitle: true,
        title: Text(
          'Log Symptoms',
          style: GoogleFonts.lato(
            textStyle: TextStyle(
              fontFamily: 'GoogleSans',
              fontSize: 20 * fontScale,
              fontWeight: FontWeight.bold,
              color: darkPurple,
              letterSpacing: -0.5,
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const SizedBox(width: 4),
                Text(
                  'Symptoms',
                  style: GoogleFonts.lato(
                    textStyle: TextStyle(
                      fontFamily: 'GoogleSans',
                      fontSize: 16 * fontScale,
                      fontWeight: FontWeight.bold,
                      color: darkPurple,
                      letterSpacing: -0.5,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Column(
              children: symptomSelection.keys.map((symptom) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      symptom,
                      style: GoogleFonts.lato(
                        textStyle: const TextStyle(
                          fontSize: 14,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    Checkbox(
                      value: symptomSelection[symptom],
                      onChanged: (bool? value) {
                        setState(() {
                          symptomSelection[symptom] = value ?? false;
                        });
                      },
                    ),
                  ],
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            Text(
              'Severity',
              style: GoogleFonts.lato(
                textStyle: TextStyle(
                  fontFamily: 'GoogleSans',
                  fontSize: 16 * fontScale,
                  fontWeight: FontWeight.bold,
                  color: darkPurple,
                  letterSpacing: -0.5,
                ),
              ),
            ),
            const SizedBox(height: 10),
            Flex(direction: Axis.vertical, children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _FrequencyButton(
                    label: 'Not at all',
                    isSelected: selectedFrequency == 'Not at all',
                    onPressed: () {
                      setState(() {
                        selectedFrequency = 'Not at all';
                      });
                    },
                  ),
                  SizedBox(
                    width: 4,
                  ),
                  _FrequencyButton(
                    label: 'Mild',
                    isSelected: selectedFrequency == 'Mild',
                    onPressed: () {
                      setState(() {
                        selectedFrequency = 'Mild';
                      });
                    },
                  ),
                  SizedBox(
                    width: 4,
                  ),
                  _FrequencyButton(
                    label: 'Moderate',
                    isSelected: selectedFrequency == 'Moderate',
                    onPressed: () {
                      setState(() {
                        selectedFrequency = 'Moderate';
                      });
                    },
                  ),
                  SizedBox(
                    width: 4,
                  ),
                  _FrequencyButton(
                    label: 'Severe',
                    isSelected: selectedFrequency == 'Severe',
                    onPressed: () {
                      setState(() {
                        selectedFrequency = 'Severe';
                      });
                    },
                  ),
                ],
              ),
            ]),
            const SizedBox(height: 20),
            Text(
              'Time of day',
              style: GoogleFonts.lato(
                textStyle: TextStyle(
                  fontFamily: 'GoogleSans',
                  fontSize: 16 * fontScale,
                  fontWeight: FontWeight.bold,
                  color: darkPurple,
                  letterSpacing: -0.5,
                ),
              ),
            ),
            SizedBox(height: 10),
            SizedBox(
              height: 120,
              child: ListView.builder(
                controller: _scrollController,
                physics: const BouncingScrollPhysics(),
                itemCount: _frequencyOptions.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () => _selectFrequency(index),
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      alignment: Alignment.center,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: _selectedFrequencyIndex == index
                            ? Color(0xFFF5F5F5) // Grey color
                            : Colors.white,
                        borderRadius: BorderRadius.circular(25),
                        border: _selectedFrequencyIndex == index
                            ? Border.all(
                                color: Color(0xFFF5F5F5),
                                width: 1.5,
                              )
                            : null,
                      ),
                      child: Text(
                        _frequencyOptions[index],
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Notes',
              style: GoogleFonts.lato(
                textStyle: TextStyle(
                  fontFamily: 'GoogleSans',
                  fontSize: 16 * fontScale,
                  fontWeight: FontWeight.bold,
                  color: darkPurple,
                  letterSpacing: -0.5,
                ),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _notesController,
              maxLines: 5,
              decoration: InputDecoration(
                hintText: 'Add a note',
                fillColor: Colors.grey[200],
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => MedicationLoggingPage()));
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: softPurple,
                minimumSize: Size(double.infinity, size.height * 0.07),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              child: Text(
                'Next',
                style: TextStyle(
                  fontSize: 18 * fontScale,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FrequencyButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onPressed;

  const _FrequencyButton({
    required this.label,
    required this.isSelected,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          backgroundColor: isSelected ? Colors.blue[50] : Colors.white,
          side: BorderSide(
            color: isSelected ? Colors.blue : Colors.grey[400]!,
            width: 1.5,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(vertical: 12),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.blue : Colors.black,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
