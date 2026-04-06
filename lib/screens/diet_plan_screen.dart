import 'package:flutter/material.dart';

class DietPlanScreen extends StatefulWidget {
  @override
  State<DietPlanScreen> createState() => _DietPlanScreenState();
}

class _DietPlanScreenState extends State<DietPlanScreen> {
  String _selectedTab = 'Daily Plan';

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
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
                      'Your Diet Plan',
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
                  'Personalized for your health',
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
                SizedBox(height: 20),

                // Tab Selector
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () =>
                            setState(() => _selectedTab = 'Daily Plan'),
                        child: Container(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: _selectedTab == 'Daily Plan'
                                ? Colors.white
                                : Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'Daily Plan',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: _selectedTab == 'Daily Plan'
                                  ? Color(0xFF5DB075)
                                  : Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: GestureDetector(
                        onTap: () =>
                            setState(() => _selectedTab = 'Weekly Overview'),
                        child: Container(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: _selectedTab == 'Weekly Overview'
                                ? Colors.white
                                : Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'Weekly Overview',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: _selectedTab == 'Weekly Overview'
                                  ? Color(0xFF5DB075)
                                  : Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Calorie Summary Cards
                Row(
                  children: [
                    Expanded(
                      child: _buildSummaryCard(
                        'Total Daily Plan',
                        '1665',
                        'Calories',
                      ),
                    ),
                    SizedBox(width: 15),
                    Expanded(
                      child: _buildSummaryCard('Your Goal', '2000', 'Calories'),
                    ),
                  ],
                ),
                SizedBox(height: 20),

                // Health Recommendations
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Color(0xFFF0F8F4),
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(
                      color: Color(0xFF5DB075).withOpacity(0.3),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Health Recommendations',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 10),
                      _buildRecommendation(
                        '• Limit rice and refined carbohydrates',
                      ),
                      _buildRecommendation('• Focus on fiber-rich foods'),
                      _buildRecommendation('• Monitor sugar levels regularly'),
                    ],
                  ),
                ),
                SizedBox(height: 25),

                _buildMealSection('🌅 Breakfast (8:00 AM)', [
                  {'name': 'Whole wheat roti (2)', 'calories': 150},
                  {'name': 'Boiled egg', 'calories': 70},
                  {'name': 'Green tea', 'calories': 2},
                ]),
                SizedBox(height: 20),

                _buildMealSection('☕ Mid-Morning Snack (11:00 AM)', [
                  {'name': 'Apple', 'calories': 95},
                  {'name': 'Handful of almonds', 'calories': 160},
                ]),
                SizedBox(height: 20),

                _buildMealSection('🍛 Lunch (1:30 PM)', [
                  {'name': 'Brown rice (1 cup)', 'calories': 215},
                  {
                    'name': 'Aloo gosht (portion)',
                    'calories': 215,
                    'warning': true,
                  },
                  {'name': 'Chicken karahi', 'calories': 280},
                  {'name': 'Mixed vegetable salad', 'calories': 60},
                ]),
                SizedBox(height: 20),

                _buildMealSection('🥤 Evening Snack (5:00 PM)', [
                  {'name': 'Cucumber raita', 'calories': 80},
                  {'name': 'Roasted chickpeas', 'calories': 120},
                ]),
                SizedBox(height: 20),

                _buildMealSection('🍽️ Dinner (8:00 PM)', [
                  {'name': 'Grilled fish', 'calories': 180},
                  {'name': 'Daal (lentils)', 'calories': 200},
                  {'name': 'Spinach salad', 'calories': 60},
                ]),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(String title, String value, String unit) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
          ),
          SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Color(0xFF5DB075),
            ),
          ),
          Text(
            unit,
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendation(String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: 6),
      child: Text(
        text,
        style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
      ),
    );
  }

  Widget _buildMealSection(String mealTime, List<Map<String, dynamic>> foods) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.access_time, size: 18, color: Color(0xFF5DB075)),
            SizedBox(width: 8),
            Text(
              mealTime,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        SizedBox(height: 12),
        ...foods
            .map(
              (food) => _buildFoodItem(
                food['name'],
                food['calories'],
                warning: food['warning'] ?? false,
              ),
            )
            .toList(),
      ],
    );
  }

  Widget _buildFoodItem(String name, int calories, {bool warning = false}) {
    return Container(
      margin: EdgeInsets.only(bottom: 8),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: warning ? Colors.red.shade50 : Color(0xFFF8F8F8),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: warning ? Colors.red.shade200 : Colors.grey.shade200,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              name,
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ),
          if (warning)
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              margin: EdgeInsets.only(right: 10),
              decoration: BoxDecoration(
                color: Colors.red.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'High Sugar',
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.red.shade700,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          Text(
            '$calories kcal',
            style: TextStyle(
              fontSize: 13,
              color: Color(0xFFFF9966),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
