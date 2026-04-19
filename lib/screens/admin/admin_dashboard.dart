import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../core/services/admin_service.dart';

class AdminDashboard extends StatefulWidget {
  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  final box = GetStorage();
  bool _isLoading = false;

  int totalFoods = 0;
  int diabeticSafe = 0;
  int bpSafe = 0;
  List<Map<String, dynamic>> foodList = [];

  TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadFoods();
  }

  Future<void> _loadFoods() async {
    setState(() => _isLoading = true);

    final result = await AdminService.getAllFoods();

    if (result['success']) {
      setState(() {
        foodList = List<Map<String, dynamic>>.from(result['foods']);
        totalFoods = foodList.length;
        diabeticSafe = foodList.where((f) => f['is_diabetic_safe'] == 1).length;
        bpSafe = foodList.where((f) => f['is_bp_safe'] == 1).length;
        _isLoading = false;
      });
    } else {
      setState(() => _isLoading = false);
      Get.snackbar('Error', result['message']);
    }
  }

  Future<void> _deleteFood(int foodId) async {
    final result = await AdminService.deleteFood(foodId);

    if (result['success']) {
      Get.snackbar(
        'Success',
        'Food deleted successfully',
        backgroundColor: Colors.green.shade100,
      );
      _loadFoods();
    } else {
      Get.snackbar('Error', result['message']);
    }
  }

  List<Map<String, dynamic>> get _filteredFoods {
    String query = _searchController.text.toLowerCase();
    if (query.isEmpty) {
      return foodList;
    }
    return foodList
        .where((food) => food['name'].toLowerCase().contains(query))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final user = box.read('user');
    final adminName = user != null ? user['name'] : 'Admin';

    return Scaffold(
      backgroundColor: Color(0xFFF5F5F5),
      body: SafeArea(
        child: Column(
          children: [
            // Purple Header
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF7C3AED), Color(0xFF9333EA)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      IconButton(
                        onPressed: () => Get.back(),
                        icon: Icon(Icons.arrow_back, color: Colors.white),
                      ),
                      SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Admin Dashboard',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Manage food database',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 25),

                  // Stats Cards
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          '$totalFoods',
                          'Total Foods',
                          Icons.restaurant_menu,
                        ),
                      ),
                      SizedBox(width: 15),
                      Expanded(
                        child: _buildStatCard(
                          '$diabeticSafe',
                          'Diabetic Safe',
                          Icons.favorite,
                        ),
                      ),
                      SizedBox(width: 15),
                      Expanded(
                        child: _buildStatCard(
                          '$bpSafe',
                          'BP Safe',
                          Icons.favorite_border,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            SizedBox(height: 20),

            // Add New Food Button
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () => _showAddFoodDialog(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF7C3AED),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add, color: Colors.white),
                      SizedBox(width: 10),
                      Text(
                        'Add New Food',
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
            ),

            SizedBox(height: 20),

            // Search Bar
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: TextField(
                controller: _searchController,
                onChanged: (value) => setState(() {}),
                decoration: InputDecoration(
                  hintText: 'Search foods...',
                  prefixIcon: Icon(Icons.search, color: Colors.grey),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                ),
              ),
            ),

            SizedBox(height: 20),

            // Food List
            Expanded(
              child: _isLoading
                  ? Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF7C3AED),
                      ),
                    )
                  : _filteredFoods.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.restaurant_menu,
                            size: 60,
                            color: Colors.grey.shade300,
                          ),
                          SizedBox(height: 15),
                          Text(
                            'No foods found',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      itemCount: _filteredFoods.length,
                      itemBuilder: (context, index) {
                        return _buildFoodCard(_filteredFoods[index]);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String value, String label, IconData icon) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.white, size: 24),
          SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(color: Colors.white70, fontSize: 12),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildFoodCard(Map<String, dynamic> food) {
    bool isDiabeticSafe = food['is_diabetic_safe'] == 1;
    bool isBpSafe = food['is_bp_safe'] == 1;

    return Container(
      margin: EdgeInsets.only(bottom: 15),
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
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  food['name'],
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 6),
                Text(
                  '${food['portion']}',
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                ),
                SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: [
                    if (isDiabeticSafe)
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Color(0xFF5DB075).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.check_circle,
                              size: 14,
                              color: Color(0xFF5DB075),
                            ),
                            SizedBox(width: 4),
                            Text(
                              'Diabetic Safe',
                              style: TextStyle(
                                fontSize: 11,
                                color: Color(0xFF5DB075),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    if (isBpSafe)
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade100,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.check_circle,
                              size: 14,
                              color: Colors.blue.shade700,
                            ),
                            SizedBox(width: 4),
                            Text(
                              'BP Safe',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.blue.shade700,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${food['calories']} kcal',
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xFFFF9966),
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 10),
              Row(
                children: [
                  IconButton(
                    onPressed: () => _showEditFoodDialog(food),
                    icon: Icon(
                      Icons.edit_outlined,
                      color: Colors.blue.shade600,
                    ),
                    padding: EdgeInsets.zero,
                    constraints: BoxConstraints(),
                  ),
                  SizedBox(width: 15),
                  IconButton(
                    onPressed: () =>
                        _showDeleteConfirmation(food['id'], food['name']),
                    icon: Icon(
                      Icons.delete_outline,
                      color: Colors.red.shade600,
                    ),
                    padding: EdgeInsets.zero,
                    constraints: BoxConstraints(),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showAddFoodDialog() {
    TextEditingController nameController = TextEditingController();
    TextEditingController caloriesController = TextEditingController();
    TextEditingController portionController = TextEditingController();
    bool isDiabeticSafe = false;
    bool isBpSafe = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text('Add New Food Item'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: 'Food Name *',
                    hintText: 'e.g. Chicken Biryani',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                SizedBox(height: 15),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: caloriesController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Calories *',
                          hintText: '250',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: portionController,
                        decoration: InputDecoration(
                          labelText: 'Portion *',
                          hintText: '1 plate',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 15),
                Text(
                  'Health Safety',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
                CheckboxListTile(
                  title: Text('Safe for Diabetic patients'),
                  value: isDiabeticSafe,
                  onChanged: (value) {
                    setDialogState(() => isDiabeticSafe = value!);
                  },
                  activeColor: Color(0xFF5DB075),
                  contentPadding: EdgeInsets.zero,
                ),
                CheckboxListTile(
                  title: Text('Safe for BP patients'),
                  value: isBpSafe,
                  onChanged: (value) {
                    setDialogState(() => isBpSafe = value!);
                  },
                  activeColor: Color(0xFF5DB075),
                  contentPadding: EdgeInsets.zero,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: Text('Cancel', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () async {
                if (nameController.text.isEmpty ||
                    caloriesController.text.isEmpty ||
                    portionController.text.isEmpty) {
                  Get.snackbar('Error', 'Please fill all required fields');
                  return;
                }

                Get.back();

                final result = await AdminService.addFood(
                  name: nameController.text,
                  calories: int.parse(caloriesController.text),
                  portion: portionController.text,
                  isDiabeticSafe: isDiabeticSafe,
                  isBpSafe: isBpSafe,
                );

                if (result['success']) {
                  Get.snackbar(
                    'Success',
                    'Food added successfully',
                    backgroundColor: Colors.green.shade100,
                  );
                  _loadFoods();
                } else {
                  Get.snackbar('Error', result['message']);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF7C3AED),
              ),
              child: Text('Add Food'),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditFoodDialog(Map<String, dynamic> food) {
    TextEditingController nameController = TextEditingController(
      text: food['name'],
    );
    TextEditingController caloriesController = TextEditingController(
      text: food['calories'].toString(),
    );
    TextEditingController portionController = TextEditingController(
      text: food['portion'],
    );
    bool isDiabeticSafe = food['is_diabetic_safe'] == 1;
    bool isBpSafe = food['is_bp_safe'] == 1;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text('Edit Food Item'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: 'Food Name *',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                SizedBox(height: 15),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: caloriesController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Calories *',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: portionController,
                        decoration: InputDecoration(
                          labelText: 'Portion *',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 15),
                Text(
                  'Health Safety',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
                CheckboxListTile(
                  title: Text('Safe for Diabetic patients'),
                  value: isDiabeticSafe,
                  onChanged: (value) {
                    setDialogState(() => isDiabeticSafe = value!);
                  },
                  activeColor: Color(0xFF5DB075),
                  contentPadding: EdgeInsets.zero,
                ),
                CheckboxListTile(
                  title: Text('Safe for BP patients'),
                  value: isBpSafe,
                  onChanged: (value) {
                    setDialogState(() => isBpSafe = value!);
                  },
                  activeColor: Color(0xFF5DB075),
                  contentPadding: EdgeInsets.zero,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: Text('Cancel', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () async {
                Get.back();

                final result = await AdminService.updateFood(
                  foodId: food['id'],
                  name: nameController.text,
                  calories: int.parse(caloriesController.text),
                  portion: portionController.text,
                  isDiabeticSafe: isDiabeticSafe,
                  isBpSafe: isBpSafe,
                );

                if (result['success']) {
                  Get.snackbar(
                    'Success',
                    'Food updated successfully',
                    backgroundColor: Colors.green.shade100,
                  );
                  _loadFoods();
                } else {
                  Get.snackbar('Error', result['message']);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF7C3AED),
              ),
              child: Text('Update'),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmation(int foodId, String foodName) {
    Get.defaultDialog(
      title: 'Delete Food',
      middleText: 'Are you sure you want to delete "$foodName"?',
      textConfirm: 'Delete',
      textCancel: 'Cancel',
      confirmTextColor: Colors.white,
      buttonColor: Colors.red,
      onConfirm: () {
        Get.back();
        _deleteFood(foodId);
      },
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
