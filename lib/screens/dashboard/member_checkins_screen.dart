import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:get_storage/get_storage.dart';
import '../../core/utils/theme.dart';
import '../../core/utils/formatters.dart';

class MemberCheckInsScreen extends StatefulWidget {
  const MemberCheckInsScreen({super.key});

  @override
  State<MemberCheckInsScreen> createState() => _MemberCheckInsScreenState();
}

class _MemberCheckInsScreenState extends State<MemberCheckInsScreen> {
  List<dynamic> _checkIns = [];
  bool _isLoading = true;
  final box = GetStorage();

  String _getToken() => box.read('token') ?? '';

  @override
  void initState() {
    super.initState();
    _loadCheckIns();
  }

  Future<void> _loadCheckIns() async {
    setState(() => _isLoading = true);
    try {
      final response = await http.get(
        Uri.parse('http://gym.sandbox.pk/api/members/my-check-ins'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${_getToken()}',
        },
      );
      final data = jsonDecode(response.body);
      if (data['success'] == true) {
        setState(() {
          _checkIns = data['checkIns'] ?? [];
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  // Groups check-ins under date headers ("Today", "Yesterday", "Jul 30, 2026")
  List<Widget> _buildGroupedList() {
    final List<Widget> widgets = [];
    String? lastHeader;

    for (final entry in _checkIns) {
      final dt = parseServerTimestamp(entry['check_in_time']?.toString());
      if (dt == null) continue;

      final header = formatDateHeader(dt);
      if (header != lastHeader) {
        if (lastHeader != null) widgets.add(const SizedBox(height: 8));
        widgets.add(
          Padding(
            padding: const EdgeInsets.only(bottom: 8, top: 4),
            child: Text(
              header,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: AppTheme.textSecondary,
              ),
            ),
          ),
        );
        lastHeader = header;
      }

      widgets.add(
        Card(
          margin: const EdgeInsets.only(bottom: 10),
          child: ListTile(
            leading: const Icon(Icons.check_circle, color: AppTheme.active),
            title: Text(formatTime12h(dt)),
          ),
        ),
      );
    }

    return widgets;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
        title: const Text('My Check-ins'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadCheckIns),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _checkIns.isEmpty
          ? const Center(child: Text('No check-ins yet'))
          : ListView(
              padding: const EdgeInsets.all(16),
              children: _buildGroupedList(),
            ),
    );
  }
}
