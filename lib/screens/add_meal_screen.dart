import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/services/meal_service.dart';

class AddMealScreen extends StatefulWidget {
  @override
  State<AddMealScreen> createState() => _AddMealScreenState();
}

class _AddMealScreenState extends State<AddMealScreen> {
  String _selectedMealType = 'Snacks';
  TextEditingController _searchController = TextEditingController();

  List<Map<String, dynamic>> _todayMeals = [];
  int _totalCalories = 0;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadTodayMeals();
  }

  Future<void> _loadTodayMeals() async {
    setState(() => _isLoading = true);

    final result = await MealService.getTodayMeals();

    if (result['success']) {
      setState(() {
        _todayMeals = List<Map<String, dynamic>>.from(result['meals']);
        _totalCalories = result['total_calories'];
        _isLoading = false;
      });
    } else {
      setState(() => _isLoading = false);
      Get.snackbar('Error', result['message']);
    }
  }

  Future<void> _addMeal(String name, int calories, String serving) async {
    final result = await MealService.addMeal(
      foodName: name,
      calories: calories,
      mealType: _selectedMealType,
      servingSize: serving,
    );

    if (result['success']) {
      Get.snackbar(
        'Success',
        'Meal added successfully!',
        backgroundColor: Colors.green.shade100,
      );
      _loadTodayMeals(); // Refresh the list
    } else {
      Get.snackbar('Error', result['message']);
    }
  }

  Future<void> _deleteMeal(int mealId) async {
    final result = await MealService.deleteMeal(mealId);

    if (result['success']) {
      Get.snackbar(
        'Success',
        'Meal deleted successfully!',
        backgroundColor: Colors.green.shade100,
      );
      _loadTodayMeals(); // Refresh the list
    } else {
      Get.snackbar('Error', result['message']);
    }
  }

  // Hardcoded Pakistani foods database
  final List<Map<String, dynamic>> _allFoods = [
    {
      'name': 'Roti (whole wheat)',
      'serving': '1 piece',
      'calories': 75,
      'category': 'Breakfast',
    },
    {
      'name': 'White rice',
      'serving': '1 cup',
      'calories': 200,
      'category': 'Lunch',
    },
    {
      'name': 'Brown rice',
      'serving': '1 cup',
      'calories': 215,
      'category': 'Lunch',
    },
    {
      'name': 'Daal (lentils)',
      'serving': '1 cup',
      'calories': 200,
      'category': 'Lunch',
    },
    {
      'name': 'Chicken karahi',
      'serving': '1 serving',
      'calories': 350,
      'category': 'Dinner',
    },
    {
      'name': 'Chicken biryani',
      'serving': '1 plate',
      'calories': 550,
      'category': 'Lunch',
    },
    {
      'name': 'Aloo gosht',
      'serving': '1 serving',
      'calories': 400,
      'category': 'Dinner',
    },
    {
      'name': 'Nihari',
      'serving': '1 bowl',
      'calories': 450,
      'category': 'Breakfast',
    },
    {
      'name': 'Haleem',
      'serving': '1 bowl',
      'calories': 380,
      'category': 'Dinner',
    },
    {
      'name': 'Chapli kabab',
      'serving': '2 pieces',
      'calories': 320,
      'category': 'Snacks',
    },
    {
      'name': 'Samosa',
      'serving': '2 pieces',
      'calories': 280,
      'category': 'Snacks',
    },
    {
      'name': 'Pakora',
      'serving': '5 pieces',
      'calories': 200,
      'category': 'Snacks',
    },
    {
      'name': 'Paratha',
      'serving': '1 piece',
      'calories': 250,
      'category': 'Breakfast',
    },
    {
      'name': 'Omelette',
      'serving': '2 eggs',
      'calories': 180,
      'category': 'Breakfast',
    },
    {
      'name': 'Lassi',
      'serving': '1 glass',
      'calories': 150,
      'category': 'Snacks',
    },
    {'name': 'Chai', 'serving': '1 cup', 'calories': 50, 'category': 'Snacks'},
    {
      'name': 'Mixed vegetable',
      'serving': '1 cup',
      'calories': 120,
      'category': 'Dinner',
    },
    {
      'name': 'Fruit chaat',
      'serving': '1 bowl',
      'calories': 100,
      'category': 'Snacks',
    },
    {
      'name': 'Apple',
      'serving': '1 medium',
      'calories': 95,
      'category': 'Snacks',
    },
    {
      'name': 'Banana',
      'serving': '1 medium',
      'calories': 105,
      'category': 'Snacks',
    },
    {
      'name': 'Orange',
      'serving': '1 medium',
      'calories': 62,
      'category': 'Snacks',
    },
    {
      'name': 'Grilled fish',
      'serving': '1 fillet',
      'calories': 180,
      'category': 'Dinner',
    },
    {
      'name': 'Boiled egg',
      'serving': '1 egg',
      'calories': 70,
      'category': 'Breakfast',
    },
    {
      'name': 'Green tea',
      'serving': '1 cup',
      'calories': 2,
      'category': 'Snacks',
    },
    {
      'name': 'Cucumber raita',
      'serving': '1 bowl',
      'calories': 80,
      'category': 'Snacks',
    },
    {
      'name': 'Roasted chickpeas',
      'serving': '1/4 cup',
      'calories': 120,
      'category': 'Snacks',
    },
    {
      'name': 'Handful of almonds',
      'serving': '10 pieces',
      'calories': 160,
      'category': 'Snacks',
    },
  ];

  List<Map<String, dynamic>> get _filteredFoods {
    String query = _searchController.text.toLowerCase();
    if (query.isEmpty) {
      return _allFoods;
    }
    return _allFoods
        .where((food) => food['name'].toLowerCase().contains(query))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Green Header (Fixed)
          Container(
            width: double.infinity,
            padding: EdgeInsets.fromLTRB(20, 50, 20, 20),
            decoration: BoxDecoration(
              color: Color(0xFF5DB075),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Icon(Icons.arrow_back, color: Colors.white),
                    SizedBox(width: 15),
                    Text(
                      'Track Calories',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Text(
                  'Monitor your daily intake',
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
                SizedBox(height: 20),

                // Today's Intake Card
                Container(
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Today's Intake",
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                          SizedBox(height: 8),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                '$_totalCalories',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 36,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                ' / 2000',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 18,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '${2000 - _totalCalories} left',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Scrollable Content (Fixed)
          Expanded(
            child: _isLoading
                ? Center(
                    child: CircularProgressIndicator(color: Color(0xFF5DB075)),
                  )
                : ListView(
                    padding: EdgeInsets.all(20),
                    children: [
                      // Today's Meals List
                      if (_todayMeals.isNotEmpty) ...[
                        Text(
                          "Today's Meals",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 15),
                        ..._todayMeals
                            .map((meal) => _buildLoggedMealItem(meal))
                            .toList(),
                        SizedBox(height: 30),
                      ],

                      // Search & Add Food Section
                      Text(
                        'Search & Add Food',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 15),

                      // Meal Type Tabs
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            _buildMealTypeChip('Breakfast'),
                            SizedBox(width: 10),
                            _buildMealTypeChip('Lunch'),
                            SizedBox(width: 10),
                            _buildMealTypeChip('Dinner'),
                            SizedBox(width: 10),
                            _buildMealTypeChip('Snacks'),
                          ],
                        ),
                      ),
                      SizedBox(height: 20),

                      // Search Bar
                      TextField(
                        controller: _searchController,
                        onChanged: (value) => setState(() {}),
                        decoration: InputDecoration(
                          hintText: 'Search Pakistani foods...',
                          prefixIcon: Icon(Icons.search, color: Colors.grey),
                          filled: true,
                          fillColor: Color(0xFFF5F5F5),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: BorderSide(color: Color(0xFF5DB075)),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: BorderSide(
                              color: Color(0xFF5DB075).withOpacity(0.3),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: BorderSide(
                              color: Color(0xFF5DB075),
                              width: 2,
                            ),
                          ),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 16,
                          ),
                        ),
                      ),
                      SizedBox(height: 10),

                      // Can't find food? Add custom button
                      Center(
                        child: TextButton.icon(
                          onPressed: () => _showAddCustomFoodDialog(),
                          icon: Icon(
                            Icons.add_circle_outline,
                            color: Color(0xFF5DB075),
                          ),
                          label: Text(
                            "Can't find your food? Add custom",
                            style: TextStyle(color: Color(0xFF5DB075)),
                          ),
                        ),
                      ),
                      SizedBox(height: 10),

                      // Food List
                      ..._filteredFoods
                          .map(
                            (food) => _buildFoodItem(
                              food['name'],
                              food['serving'],
                              food['calories'],
                            ),
                          )
                          .toList(),

                      // No meals message
                      if (_filteredFoods.isEmpty)
                        Center(
                          child: Column(
                            children: [
                              SizedBox(height: 40),
                              Icon(
                                Icons.search_off,
                                size: 60,
                                color: Colors.grey.shade300,
                              ),
                              SizedBox(height: 15),
                              Text(
                                'No food found',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ),

                      SizedBox(height: 20),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildMealTypeChip(String label) {
    bool isSelected = _selectedMealType == label;
    return GestureDetector(
      onTap: () => setState(() => _selectedMealType = label),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? Color(0xFF5DB075) : Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey.shade700,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildFoodItem(String name, String serving, int calories) {
    return GestureDetector(
      onTap: () => _addMeal(name, calories, serving),
      child: Container(
        margin: EdgeInsets.only(bottom: 12),
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Color(0xFFF8F8F8),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  SizedBox(height: 4),
                  Text(
                    serving,
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
            Text(
              '$calories kcal',
              style: TextStyle(
                fontSize: 15,
                color: Color(0xFFFF9966),
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(width: 10),
            Icon(Icons.add_circle, color: Color(0xFF5DB075)),
          ],
        ),
      ),
    );
  }

  Widget _buildLoggedMealItem(Map<String, dynamic> meal) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Color(0xFF5DB075).withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Color(0xFF5DB075).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.restaurant, color: Color(0xFF5DB075)),
          ),
          SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  meal['food_name'],
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                SizedBox(height: 4),
                Text(
                  '${meal['meal_type']} • ${meal['serving_size']}',
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
          Text(
            '${meal['calories']} kcal',
            style: TextStyle(
              fontSize: 15,
              color: Color(0xFF5DB075),
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(width: 10),
          IconButton(
            onPressed: () => _showDeleteConfirmation(meal['id']),
            icon: Icon(Icons.delete_outline, color: Colors.red.shade400),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(int mealId) {
    Get.defaultDialog(
      title: 'Delete Meal',
      middleText: 'Are you sure you want to delete this meal?',
      textConfirm: 'Delete',
      textCancel: 'Cancel',
      confirmTextColor: Colors.white,
      buttonColor: Colors.red,
      onConfirm: () {
        Get.back();
        _deleteMeal(mealId);
      },
    );
  }

  void _showAddCustomFoodDialog() {
    TextEditingController nameController = TextEditingController();
    TextEditingController caloriesController = TextEditingController();
    TextEditingController servingController = TextEditingController();

    Get.defaultDialog(
      title: 'Add Custom Food',
      content: Padding(
        padding: EdgeInsets.symmetric(horizontal: 10),
        child: Column(
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: 'Food Name',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            SizedBox(height: 15),
            TextField(
              controller: servingController,
              decoration: InputDecoration(
                labelText: 'Serving Size (e.g., 1 plate)',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            SizedBox(height: 15),
            TextField(
              controller: caloriesController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Calories',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ],
        ),
      ),
      textConfirm: 'Add',
      textCancel: 'Cancel',
      confirmTextColor: Colors.white,
      buttonColor: Color(0xFF5DB075),
      onConfirm: () {
        if (nameController.text.isNotEmpty &&
            caloriesController.text.isNotEmpty) {
          Get.back();
          _addMeal(
            nameController.text,
            int.parse(caloriesController.text),
            servingController.text.isEmpty ? 'Custom' : servingController.text,
          );
        }
      },
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
