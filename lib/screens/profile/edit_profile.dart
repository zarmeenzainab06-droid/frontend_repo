import 'package:flutter/material.dart';
import '../../core/utils/theme.dart';

class EditProfileScreen extends StatefulWidget {
  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController     = TextEditingController();
  final _emailController    = TextEditingController();
  final _passwordController = TextEditingController();
  final _ageController      = TextEditingController();
  final _weightController   = TextEditingController();
  final _heightController   = TextEditingController();

  String? _selectedGender;
  bool _isDiabetic      = false;
  bool _hasBP           = false;
  bool _obscurePassword = true;

  final List<String> _genderOptions = ['male', 'female'];

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _ageController.dispose();
    _weightController.dispose();
    _heightController.dispose();
    super.dispose();
  }

  InputDecoration _fieldDecor(String label, IconData icon, {Widget? suffixIcon}) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: AppTheme.textGrey, size: 18),
      suffixIcon: suffixIcon,
      // inherits filled, fillColor, borders from AppTheme.inputDecorationTheme
    );
  }

  Widget _sectionLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, top: 4),
      child: Row(
        children: [
          Container(
            width: 3, height: 14,
            decoration: BoxDecoration(
              color: AppTheme.primary,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            text.toUpperCase(),
            style: const TextStyle(
              color: AppTheme.textGrey,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _healthToggle({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    required IconData icon,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      decoration: BoxDecoration(
        color: value ? AppTheme.primary.withOpacity(0.08) : AppTheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: value ? AppTheme.primary : AppTheme.border,
          width: value ? 1.5 : 1,
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Container(
          width: 38, height: 38,
          decoration: BoxDecoration(
            color: value ? AppTheme.primary : AppTheme.border,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: Colors.white, size: 18),
        ),
        title: Text(
          title,
          style: TextStyle(
            color: AppTheme.textDark,
            fontSize: 14,
            fontWeight: value ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
        subtitle: Text(subtitle,
            style: const TextStyle(color: AppTheme.textGrey, fontSize: 12)),
        trailing: Switch(
          value: value,
          onChanged: onChanged,
          // uses AppTheme.switchTheme automatically
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // scaffoldBackgroundColor comes from AppTheme
      body: CustomScrollView(
        slivers: [
          // ── App Bar ────────────────────────────────────────────────────────
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            elevation: 0,
            // backgroundColor & foregroundColor from AppTheme.appBarTheme
            leading: IconButton(
              icon: Container(
                width: 36, height: 36,
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppTheme.border),
                ),
                child: const Icon(Icons.arrow_back_ios_new_rounded,
                    size: 15, color: AppTheme.textDark),
              ),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 16),
                child: TextButton(
                  onPressed: () {},
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text('Save',
                      style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              collapseMode: CollapseMode.pin,
              background: Stack(
                children: [
                  // Soft green radial glow
                  Positioned(
                    top: -40, right: -40,
                    child: Container(
                      width: 200, height: 200,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(colors: [
                          AppTheme.primary.withOpacity(0.18),
                          Colors.transparent,
                        ]),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                        top: 90, left: 20, right: 20, bottom: 16),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Stack(
                          children: [
                            Container(
                              width: 72, height: 72,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [AppTheme.primary, AppTheme.accent],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: AppTheme.border, width: 2),
                              ),
                              child: const Icon(Icons.person_rounded,
                                  color: Colors.white, size: 36),
                            ),
                            Positioned(
                              bottom: 0, right: 0,
                              child: Container(
                                width: 22, height: 22,
                                decoration: BoxDecoration(
                                  color: AppTheme.primaryDark,
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                      color: AppTheme.background, width: 2),
                                ),
                                child: const Icon(Icons.edit_rounded,
                                    size: 11, color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 16),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text('Edit Profile',
                                style: TextStyle(
                                    color: AppTheme.textDark,
                                    fontSize: 22,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: -0.5)),
                            SizedBox(height: 2),
                            Text('Update your personal info',
                                style: TextStyle(
                                    color: AppTheme.textGrey, fontSize: 13)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Form Body ──────────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Personal Info ─────────────────────────────────────────
                    _sectionLabel('Personal Info'),
                    TextFormField(
                      controller: _nameController,
                      decoration: _fieldDecor('Full Name', Icons.badge_outlined),
                      validator: (v) =>
                          v == null || v.isEmpty ? 'Name is required' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration:
                          _fieldDecor('Email Address', Icons.email_outlined),
                      validator: (v) => v == null || !v.contains('@')
                          ? 'Enter a valid email'
                          : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      decoration: _fieldDecor(
                        'Password',
                        Icons.lock_outline_rounded,
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            color: AppTheme.textGrey,
                            size: 18,
                          ),
                          onPressed: () => setState(
                              () => _obscurePassword = !_obscurePassword),
                        ),
                      ),
                    ),

                    const SizedBox(height: 28),

                    // ── Body Metrics ──────────────────────────────────────────
                    _sectionLabel('Body Metrics'),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _ageController,
                            keyboardType: TextInputType.number,
                            decoration: _fieldDecor('Age', Icons.cake_outlined),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: _selectedGender,
                            dropdownColor: AppTheme.surface,
                            decoration:
                                _fieldDecor('Gender', Icons.wc_rounded),
                            items: _genderOptions
                                .map((g) => DropdownMenuItem(
                                      value: g,
                                      child: Text(
                                          g[0].toUpperCase() + g.substring(1)),
                                    ))
                                .toList(),
                            onChanged: (v) =>
                                setState(() => _selectedGender = v),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _weightController,
                            keyboardType: const TextInputType.numberWithOptions(
                                decimal: true),
                            decoration: _fieldDecor(
                                'Weight (kg)', Icons.monitor_weight_outlined),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            controller: _heightController,
                            keyboardType: const TextInputType.numberWithOptions(
                                decimal: true),
                            decoration:
                                _fieldDecor('Height (cm)', Icons.height_rounded),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 28),

                    // ── Health Conditions ─────────────────────────────────────
                    _sectionLabel('Health Conditions'),
                    _healthToggle(
                      title: 'Diabetic',
                      subtitle: 'I have diabetes',
                      value: _isDiabetic,
                      icon: Icons.bloodtype_outlined,
                      onChanged: (v) => setState(() => _isDiabetic = v),
                    ),
                    const SizedBox(height: 10),
                    _healthToggle(
                      title: 'High Blood Pressure',
                      subtitle: 'I have hypertension (BP)',
                      value: _hasBP,
                      icon: Icons.favorite_outline_rounded,
                      onChanged: (v) => setState(() => _hasBP = v),
                    ),

                    const SizedBox(height: 36),

                    // ── Save Button ───────────────────────────────────────────
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [AppTheme.primary, AppTheme.accent],
                          ),
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.primary.withOpacity(0.35),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: ElevatedButton(
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              // handle save
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primary,
                            shadowColor: AppTheme.primary,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14)),
                          ),
                          child: const Text(
                            'Save Changes',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}