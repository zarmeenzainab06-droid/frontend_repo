import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/services/trainer_service.dart';
import '../../core/utils/theme.dart';
import '../../core/widgets/trainer_drawer.dart';

class TrainerWorkoutPlanForm extends StatefulWidget {
  const TrainerWorkoutPlanForm({Key? key}) : super(key: key);

  @override
  State<TrainerWorkoutPlanForm> createState() => _TrainerWorkoutPlanFormState();
}

class _TrainerWorkoutPlanFormState extends State<TrainerWorkoutPlanForm> {
  final box = GetStorage();
  bool _isLoading = false;
  bool _isFetching = true;

  List<Map<String, dynamic>> _members = [];
  int? _selectedMemberId;

  final _titleCtrl = TextEditingController();
  final _detailsCtrl = TextEditingController();

  static const String baseUrl = "http://gym.sandbox.pk";

  @override
  void initState() {
    super.initState();
    final args = Get.arguments as Map<String, dynamic>?;
    if (args != null && args['member_id'] != null) {
      _selectedMemberId = args['member_id'];
    }
    _loadMembers();
  }

  Future<void> _loadMembers() async {
    setState(() => _isFetching = true);
    final membersResult = await TrainerService.getMyMembers();
    if (membersResult['success']) {
      _members = List<Map<String, dynamic>>.from(membersResult['members']);
      if (_selectedMemberId == null && _members.isNotEmpty) {
        _selectedMemberId = _members.first['id'];
      }
    }
    setState(() => _isFetching = false);
  }

  Future<void> _submitWorkoutPlan() async {
    if (_selectedMemberId == null) {
      Get.snackbar('Error', 'Please select a member', backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }
    if (_titleCtrl.text.trim().isEmpty || _detailsCtrl.text.trim().isEmpty) {
      Get.snackbar('Error', 'Title and exercise details are required', backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    setState(() => _isLoading = true);
    final token = box.read('token') ?? '';

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/trainer/workout-plans'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'member_id': _selectedMemberId,
          'title': _titleCtrl.text.trim(),
          'details': _detailsCtrl.text.trim(),
        }),
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 201 && data['success'] == true) {
        Get.snackbar('Success', 'Workout Plan assigned successfully!', backgroundColor: Colors.green, colorText: Colors.white);
        Get.back();
      } else {
        Get.snackbar('Error', data['message'] ?? 'Failed to assign workout plan', backgroundColor: Colors.red, colorText: Colors.white);
      }
    } catch (e) {
      Get.snackbar('Error', 'Connection failed: $e', backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _detailsCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const TrainerDrawer(),
      appBar: AppBar(
        title: const Text('Assign Workout Plan'),
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
      ),
      body: _isFetching
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'SELECT MEMBER',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<int>(
                    value: _selectedMemberId,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      filled: true,
                      fillColor: Colors.grey.shade100,
                    ),
                    items: _members.map((m) {
                      return DropdownMenuItem<int>(
                        value: m['id'],
                        child: Text('${m['name']} (${m['email'] ?? ''})'),
                      );
                    }).toList(),
                    onChanged: (val) {
                      setState(() => _selectedMemberId = val);
                    },
                  ),
                  const SizedBox(height: 20),

                  const Text(
                    'PLAN TITLE',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _titleCtrl,
                    decoration: InputDecoration(
                      hintText: 'e.g. 3-Day Hypertrophy Routine',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                  const SizedBox(height: 20),

                  const Text(
                    'EXERCISE ROUTINE DETAILS',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _detailsCtrl,
                    maxLines: 8,
                    decoration: InputDecoration(
                      hintText: 'Day 1: Chest & Triceps\n- Flat Bench Press: 4 sets x 10 reps\n- Incline Dumbbell Press: 3 sets x 12 reps\n- Tricep Pushdowns: 4 sets x 12 reps\n\nDay 2: Back & Biceps\n- Lat Pulldowns: 4 sets x 10 reps...',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                  const SizedBox(height: 30),

                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _submitWorkoutPlan,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primary,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                              'Assign Workout Plan',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
