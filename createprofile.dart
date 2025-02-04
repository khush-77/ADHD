import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ADHD_Tracker/utils/color.dart';

class ProfileCreationPage extends StatefulWidget {
  const ProfileCreationPage({Key? key}) : super(key: key);

  @override
  _ProfileCreationPageState createState() => _ProfileCreationPageState();
}

class _ProfileCreationPageState extends State<ProfileCreationPage> {
  int _currentStep = 0;
  File? _profileImage;
  final List<String> _currentMedications = [];
  final List<String> _selectedSymptoms = [];
  final List<String> _selectedStrategies = [];

  final TextEditingController _medicationController = TextEditingController();
  final TextEditingController _customSymptomController = TextEditingController();

  final List<String> _predefinedSymptoms = [
    'Careless mistakes', 'Difficulty focusing', 'Trouble listening',
    'Difficulty following instructions', 'Difficulty organizing', 
    'Avoiding tough mental activities', 'Losing items', 'Distracted by surroundings',
    'Forgetful during daily activities', 'Fidgeting', 'Leaving seat', 'Moving excessively',
    'Trouble doing something quietly', 'Always on the go', 'Talking excessively',
    'Blurting out answers', 'Trouble waiting turn', 'Interrupting'
  ];

  final List<String> _predefinedStrategies = [
    'Psychology', 'Occupational therapist', 'Coaching', 
    'Financial coaching', 'Social Work'
  ];

  @override
  void dispose() {
    _medicationController.dispose();
    _customSymptomController.dispose();
    super.dispose();
  }

  Future<void> _pickProfileImage() async {
    final picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 800,
      maxHeight: 800,
      imageQuality: 85,
    );

    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });
    }
  }

  void _addMedication() {
    final medication = _medicationController.text.trim();
    if (medication.isNotEmpty) {
      setState(() {
        _currentMedications.add(medication);
        _medicationController.clear();
      });
    }
  }

  void _removeMedication(int index) {
    setState(() => _currentMedications.removeAt(index));
  }

  @override
  Widget build(BuildContext context) {
    final double fontScale = MediaQuery.of(context).size.width < 600 ? 1.0 : 1.5;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Complete Your Profile',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 20 * fontScale,
          ),
        ),
        backgroundColor: Colors.white,
      ),
      body: Column(
        children: [
          const SizedBox(height: 8),
          _buildStepIndicators(),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Text(
              _getStepTitle(),
              style: Theme.of(context).textTheme.headlineSmall,
            ),
          ),
          Expanded(child: _buildStepContent()),
          Padding(
            padding: const EdgeInsets.all(22.0),
            child: _buildNavigationButton(fontScale),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildStepIndicators() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(4, (index) {
        return Container(
          width: 10,
          height: 10,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _currentStep == index ? AppTheme.upeiGreen : Colors.grey.shade300,
          ),
        );
      }),
    );
  }

  String _getStepTitle() {
    const titles = ['Profile Photo', 'Current Medications', 'ADHD Symptoms', 'Support Strategies'];
    return titles[_currentStep];
  }

  Widget _buildStepContent() {
    switch (_currentStep) {
      case 0:
        return _buildProfilePhotoStep();
      case 1:
        return _buildCurrentMedicationsStep();
      case 2:
        return _buildADHDSymptomsStep();
      case 3:
        return _buildStrategiesStep();
      default:
        return Container();
    }
  }

  Widget _buildNavigationButton(double fontScale) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          setState(() {
            if (_currentStep < 3) {
              _currentStep++;
            }
          });
        },
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          backgroundColor: AppTheme.upeiRed,
        ),
        child: Text(
          _currentStep == 3 ? 'Submit' : 'Next',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16 * fontScale,
          ),
        ),
      ),
    );
  }

  Widget _buildProfilePhotoStep() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 100,
            backgroundImage: _profileImage != null ? FileImage(_profileImage!) : null,
            child: _profileImage == null ? const Icon(Icons.person, size: 100) : null,
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _pickProfileImage,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.upeiRed,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Pick Profile Photo', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentMedicationsStep() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          TextField(
            controller: _medicationController,
            onSubmitted: (_) => _addMedication(),
            decoration: InputDecoration(
              labelText: 'Enter Current Medication',
              suffixIcon: IconButton(icon: const Icon(Icons.add), onPressed: _addMedication),
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: _currentMedications.isEmpty
                ? const Center(child: Text('No medications added'))
                : ListView.builder(
                    itemCount: _currentMedications.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text(_currentMedications[index]),
                        trailing: IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => _removeMedication(index),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildADHDSymptomsStep() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ListView(
        children: _predefinedSymptoms.map((symptom) {
          return CheckboxListTile(
            title: Text(symptom),
            value: _selectedSymptoms.contains(symptom),
            onChanged: (bool? value) {
              setState(() {
                if (value == true) {
                  _selectedSymptoms.add(symptom);
                } else {
                  _selectedSymptoms.remove(symptom);
                }
              });
            },
          );
        }).toList(),
      ),
    );
  }

  Widget _buildStrategiesStep() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ListView.builder(
        itemCount: _predefinedStrategies.length,
        itemBuilder: (context, index) {
          final strategy = _predefinedStrategies[index];
          return RadioListTile<String>(
            title: Text(strategy),
            value: strategy,
            groupValue: _selectedStrategies.isEmpty ? null : _selectedStrategies.first,
            onChanged: (String? value) {
              setState(() {
                _selectedStrategies.clear();
                if (value != null) {
                  _selectedStrategies.add(value);
                }
              });
            },
          );
        },
      ),
    );
  }
}
