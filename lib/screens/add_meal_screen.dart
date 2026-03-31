import 'package:flutter/material.dart';
import '../core/services/meal_service.dart';

class AddMealScreen extends StatefulWidget {
  @override
  State<AddMealScreen> createState() => _AddMealScreenState();
}

class _AddMealScreenState extends State<AddMealScreen> {
  String _selectedMealType = 'Snacks';
  TextEditingController _searchController = TextEditingController();

  Future<void> _submitMeal(String name, String calories) async {
    if (name.isEmpty || calories.isEmpty) return;

    int cal = int.tryParse(calories) ?? 0;

    // Optimistic UI update (optional but smart)
    setState(() {
      _allFoods.add({
        'name': name,
        'serving': 'Custom',
        'calories': cal,
        'category': _selectedMealType,
      });
    });

    try {
      await MealService.addMeal(
        name: name,
        calories: cal,
        category: _selectedMealType,
      );
    } catch (e) {
      print("Error: $e");
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
    return Column(
      children: [
        // Green Header
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
                          style: TextStyle(color: Colors.white70, fontSize: 14),
                        ),
                        SizedBox(height: 8),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '0',
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
                        '2000 left',
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

        Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Add Food Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    _openAddMealSheet(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF5DB075),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add, color: Colors.white),
                      SizedBox(width: 8),
                      Text(
                        'Add Food',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 30),

              // Search & Add Food Section
              Text(
                'Search & Add Food',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 15),

              // Meal Type Tabs
              Row(
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
                    borderSide: BorderSide(color: Color(0xFF5DB075), width: 2),
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                ),
              ),
              SizedBox(height: 20),

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
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMealTypeChip(String label) {
    bool isSelected = _selectedMealType == label;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedMealType = label;
        });
      },
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

  void _openAddMealSheet(BuildContext context) {
    TextEditingController nameController = TextEditingController();
    TextEditingController caloriesController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Container(
            padding: EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Handle bar
                Container(
                  width: 40,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                SizedBox(height: 20),

                Text(
                  "Add Meal",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),

                SizedBox(height: 20),

                // Meal Name
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: "Meal Name",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),

                SizedBox(height: 15),

                // Calories
                TextField(
                  controller: caloriesController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: "Calories",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),

                SizedBox(height: 20),

                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () async {
                      Navigator.pop(context);

                      await _submitMeal(
                        nameController.text,
                        caloriesController.text,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF5DB075),
                    ),
                    child: Text("Add Meal"),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildFoodItem(String name, String serving, int calories) {
    return Container(
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
          Icon(Icons.keyboard_arrow_down, color: Colors.grey.shade400),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
