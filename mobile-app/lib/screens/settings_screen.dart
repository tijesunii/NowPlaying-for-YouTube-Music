import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _trackingUrlController = TextEditingController();
  final _remoteUrlController = TextEditingController();
  final _secretController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _trackingUrlController.text = prefs.getString('trackingApiUrl') ?? '';
      _remoteUrlController.text = prefs.getString('remoteApiUrl') ?? '';
      _secretController.text = prefs.getString('secretToken') ?? '';
    });
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('trackingApiUrl', _trackingUrlController.text.trim());
    await prefs.setString('remoteApiUrl', _remoteUrlController.text.trim());
    await prefs.setString('secretToken', _secretController.text.trim());

    if (mounted) {
      HapticFeedback.mediumImpact();
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF030303),
      appBar: AppBar(
        backgroundColor: const Color(0xFF030303),
        elevation: 0,
        title: const Text('Settings', style: TextStyle(fontWeight: FontWeight.w600)),
        centerTitle: true,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            _buildTextField(
              label: 'Tracking API Endpoint',
              controller: _trackingUrlController,
              hint: 'https://domain.com/api/now-playing.php',
            ),
            const SizedBox(height: 20),
            _buildTextField(
              label: 'Remote API Endpoint',
              controller: _remoteUrlController,
              hint: 'https://domain.com/api/remote.php',
            ),
            const SizedBox(height: 20),
            _buildTextField(
              label: 'Secret Token',
              controller: _secretController,
              hint: 'Required for authentication',
              obscureText: true,
            ),
            const SizedBox(height: 40),
            CupertinoButton(
              color: const Color(0xFFFF0000),
              borderRadius: BorderRadius.circular(14),
              onPressed: _saveSettings,
              child: const Text('Save Configuration', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    String? hint,
    bool obscureText = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: TextStyle(
            color: Colors.white.withOpacity(0.5),
            fontSize: 12,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFF1C1C1E),
            borderRadius: BorderRadius.circular(12),
          ),
          child: TextField(
            controller: controller,
            obscureText: obscureText,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(color: Colors.white.withOpacity(0.2)),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            ),
          ),
        ),
      ],
    );
  }
}
