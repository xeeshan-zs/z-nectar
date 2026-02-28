import 'package:flutter/material.dart';
import 'package:grocery_app/core/theme/app_colors.dart';
import 'package:grocery_app/core/constants/app_constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class NotificationsSettingsScreen extends StatefulWidget {
  const NotificationsSettingsScreen({super.key});

  @override
  State<NotificationsSettingsScreen> createState() =>
      _NotificationsSettingsScreenState();
}

class _NotificationsSettingsScreenState
    extends State<NotificationsSettingsScreen> {
  bool _pushEnabled = true;
  bool _emailEnabled = false;
  bool _smsPromoEnabled = true;
  bool _orderUpdatesEnabled = true;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('preferences')
          .doc('notifications')
          .get();
      if (doc.exists && mounted) {
        final data = doc.data()!;
        setState(() {
          _pushEnabled = data['push'] ?? true;
          _orderUpdatesEnabled = data['orderUpdates'] ?? true;
          _emailEnabled = data['email'] ?? false;
          _smsPromoEnabled = data['smsPromo'] ?? true;
        });
      }
    }
  }

  Future<void> _savePreference(String key, bool value) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('preferences')
          .doc('notifications')
          .set({key: value}, SetOptions(merge: true));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: AppColors.darkText, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Notifications',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.darkText,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(
            vertical: 20, horizontal: AppConstants.horizontalPadding),
        children: [
          _buildToggle(
            'Push Notifications',
            'Receive alerts on your device',
            _pushEnabled,
            (val) {
              setState(() => _pushEnabled = val);
              _savePreference('push', val);
            },
          ),
          const Divider(),
          _buildToggle(
            'Order Updates',
            'Get notified about your order status',
            _orderUpdatesEnabled,
            (val) {
              setState(() => _orderUpdatesEnabled = val);
              _savePreference('orderUpdates', val);
            },
          ),
          const Divider(),
          _buildToggle(
            'Email Alerts',
            'Receive newsletters and offers via email',
            _emailEnabled,
            (val) {
              setState(() => _emailEnabled = val);
              _savePreference('email', val);
            },
          ),
          const Divider(),
          _buildToggle(
            'SMS Promotional',
            'Get exclusive discount codes via SMS',
            _smsPromoEnabled,
            (val) {
              setState(() => _smsPromoEnabled = val);
              _savePreference('smsPromo', val);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildToggle(
      String title, String subtitle, bool value, Function(bool) onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.darkText,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.greyText,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: AppColors.white,
            activeTrackColor: AppColors.primaryGreen,
            inactiveThumbColor: AppColors.white,
            inactiveTrackColor: AppColors.lightGrey,
          ),
        ],
      ),
    );
  }
}
