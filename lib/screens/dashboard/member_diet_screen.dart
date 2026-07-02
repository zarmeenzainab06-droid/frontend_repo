import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:get_storage/get_storage.dart';
import '../../core/utils/theme.dart';

class MemberDietScreen extends StatefulWidget {
  const MemberDietScreen({super.key});

  @override
  State<MemberDietScreen> createState() => _MemberDietScreenState();
}

class _MemberDietScreenState extends State<MemberDietScreen> {
  Map<String, dynamic>? _dietPlan;
  List<dynamic> _remarks = [];
  bool _isLoading = true;
  final box = GetStorage();
  final _remarkController = TextEditingController();
  bool _submittingRemark = false;

  String _getToken() => box.read('token') ?? '';

  @override
  void initState() {
    super.initState();
    _loadDietPlan();
  }

  Future<void> _loadDietPlan() async {
    try {
      final response = await http.get(
        Uri.parse('http://localhost:3000/api/diet/my-plan'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${_getToken()}',
        },
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _dietPlan = data['diet_plan'];
          _isLoading = false;
        });
        if (_dietPlan != null) {
          _loadRemarks(_dietPlan!['id'].toString());
        }
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadRemarks(String dietPlanId) async {
    try {
      final response = await http.get(
        Uri.parse('http://localhost:3000/api/diet/remarks/$dietPlanId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${_getToken()}',
        },
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() => _remarks = data['remarks']);
      }
    } catch (e) {
      print('Remarks error: $e');
    }
  }

  Future<void> _submitRemark() async {
    if (_remarkController.text.isEmpty) return;

    setState(() => _submittingRemark = true);

    try {
      final response = await http.post(
        Uri.parse('http://localhost:3000/api/diet/remark'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${_getToken()}',
        },
        body: jsonEncode({
          'diet_plan_id': _dietPlan!['id'],
          'remark': _remarkController.text,
        }),
      );

      if (response.statusCode == 200) {
        _remarkController.clear();
        _loadRemarks(_dietPlan!['id'].toString());
        Get.snackbar(
          'Success',
          'Remark add ho gaya!',
          backgroundColor: AppTheme.activeLight,
          colorText: AppTheme.active,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      print('Remark error: $e');
    }

    setState(() => _submittingRemark = false);
  }

  // Parse meal items from text
  List<String> _parseMeal(String? meal) {
    if (meal == null || meal.isEmpty) return [];
    return meal.split('\n').where((e) => e.trim().isNotEmpty).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
        title: const Text('My Diet Plan'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadDietPlan),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppTheme.primary),
            )
          : _dietPlan == null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.restaurant_outlined,
                    size: 60,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Koi diet plan assign nahi hua',
                    style: TextStyle(color: Colors.grey, fontSize: 16),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Apne trainer se contact karo',
                    style: TextStyle(color: Colors.grey, fontSize: 13),
                  ),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Active Diet Plan header
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1B4332),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.green.withOpacity(0.3),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Text(
                                'Active Diet Plan',
                                style: TextStyle(
                                  color: Colors.greenAccent,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _dietPlan!['title'] ?? '',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Trainer info
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [AppTheme.cardShadow],
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryLight,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.person,
                            color: AppTheme.primary,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Assigned by',
                              style: TextStyle(
                                fontSize: 11,
                                color: AppTheme.textSecondary,
                              ),
                            ),
                            Text(
                              _dietPlan!['trainer_name'] ?? 'Trainer',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            const Text(
                              'Assigned on',
                              style: TextStyle(
                                fontSize: 11,
                                color: AppTheme.textSecondary,
                              ),
                            ),
                            Text(
                              _dietPlan!['assignment_date']
                                      ?.toString()
                                      .substring(0, 10) ??
                                  'N/A',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Meal sections
                  _buildMealSection(
                    '🍳',
                    'Breakfast',
                    Colors.orange[100]!,
                    Colors.orange,
                    _parseMeal(_dietPlan!['breakfast']),
                  ),
                  const SizedBox(height: 12),
                  _buildMealSection(
                    '☀️',
                    'Lunch',
                    Colors.yellow[100]!,
                    Colors.amber,
                    _parseMeal(_dietPlan!['lunch']),
                  ),
                  const SizedBox(height: 12),
                  _buildMealSection(
                    '🌙',
                    'Dinner',
                    Colors.blue[100]!,
                    Colors.blue,
                    _parseMeal(_dietPlan!['dinner']),
                  ),
                  const SizedBox(height: 12),
                  _buildMealSection(
                    '🥤',
                    'Snacks & Supplements',
                    Colors.green[100]!,
                    Colors.green,
                    _parseMeal(_dietPlan!['snacks']),
                  ),

                  const SizedBox(height: 16),

                  // Member Remarks section
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [AppTheme.cardShadow],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(
                              Icons.comment_outlined,
                              color: AppTheme.primary,
                              size: 18,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'My Remarks',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // Add remark field
                        TextField(
                          controller: _remarkController,
                          maxLines: 3,
                          decoration: InputDecoration(
                            hintText: 'Apna feedback ya question likho...',
                            hintStyle: const TextStyle(
                              color: AppTheme.textHint,
                            ),
                            filled: true,
                            fillColor: const Color(0xFFF5F5F5),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: AppTheme.primary,
                                width: 1.5,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          width: double.infinity,
                          height: 44,
                          child: ElevatedButton(
                            onPressed: _submittingRemark ? null : _submitRemark,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: _submittingRemark
                                ? const CircularProgressIndicator(
                                    color: Colors.white,
                                  )
                                : const Text(
                                    'Submit Remark',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                          ),
                        ),

                        // Previous remarks
                        if (_remarks.isNotEmpty) ...[
                          const SizedBox(height: 16),
                          const Divider(),
                          const SizedBox(height: 8),
                          ..._remarks.map(
                            (r) => Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppTheme.primaryLight,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    r['remark'] ?? '',
                                    style: const TextStyle(fontSize: 13),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    r['created_at']?.toString().substring(
                                          0,
                                          10,
                                        ) ??
                                        '',
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: AppTheme.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Back button
                  SizedBox(
                    width: double.infinity,
                    height: 44,
                    child: OutlinedButton.icon(
                      onPressed: () => Get.back(),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppTheme.primary),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      icon: const Icon(
                        Icons.arrow_back,
                        color: AppTheme.primary,
                      ),
                      label: const Text(
                        'Back to Dashboard',
                        style: TextStyle(color: AppTheme.primary),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  // Meal section widget
  Widget _buildMealSection(
    String emoji,
    String title,
    Color bgColor,
    Color borderColor,
    List<String> items,
  ) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [AppTheme.cardShadow],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Meal header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Text(emoji, style: const TextStyle(fontSize: 18)),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: borderColor,
                  ),
                ),
              ],
            ),
          ),
          // Meal items
          Padding(
            padding: const EdgeInsets.all(16),
            child: items.isEmpty
                ? const Text(
                    'No items',
                    style: TextStyle(color: AppTheme.textSecondary),
                  )
                : Column(
                    children: items
                        .map(
                          (item) => Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(
                                  Icons.check_circle,
                                  color: Colors.green,
                                  size: 16,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    item,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: AppTheme.textPrimary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                        .toList(),
                  ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _remarkController.dispose();
    super.dispose();
  }
}
