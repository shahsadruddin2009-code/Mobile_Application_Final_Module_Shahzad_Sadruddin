// ============================================================================
// MUSCLE POWER - Privacy Settings Screen
// ============================================================================
//
// File: privacy_screen.dart
// Description: GDPR-compliant privacy centre where users can manage consent,
//              export their data, and delete their account.
//
// Sections:
//   1. Consent toggles (analytics, contact)
//   2. Data portability (export as JSON)
//   3. Right to erasure (delete account + all data)
//   4. Retention policy summary (read-only)
// ============================================================================

import 'package:flutter/material.dart';
import '../services/data_lifecycle_service.dart';

class PrivacyScreen extends StatefulWidget {
  const PrivacyScreen({super.key});

  @override
  State<PrivacyScreen> createState() => _PrivacyScreenState();
}

class _PrivacyScreenState extends State<PrivacyScreen> {
  final _lifecycle = DataLifecycleService();
  Map<ConsentCategory, bool> _consents = {};
  bool _loading = true;
  bool _exporting = false;

  @override
  void initState() {
    super.initState();
    _loadConsents();
  }

  Future<void> _loadConsents() async {
    final consents = await _lifecycle.getAllConsents();
    if (mounted) {
      setState(() {
        _consents = consents;
        _loading = false;
      });
    }
  }

  Future<void> _toggleConsent(ConsentCategory category, bool value) async {
    await _lifecycle.setConsent(category, value);
    setState(() => _consents[category] = value);
  }

  Future<void> _exportData() async {
    setState(() => _exporting = true);
    try {
      final json = await _lifecycle.exportUserDataAsJson();
      if (!mounted) return;

      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          backgroundColor: const Color(0xFF1A1A2E),
          title: const Text('Your Data Export',
              style: TextStyle(color: Colors.white)),
          content: SizedBox(
            width: double.maxFinite,
            height: 350,
            child: SingleChildScrollView(
              child: SelectableText(
                json,
                style: const TextStyle(
                    color: Colors.white70, fontSize: 12, fontFamily: 'monospace'),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Export failed: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _exporting = false);
    }
  }

  Future<void> _deleteAccount() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        title: const Text('Delete Account?',
            style: TextStyle(color: Colors.redAccent)),
        content: const Text(
          'This will permanently delete your account and ALL associated data. '
          'This action cannot be undone.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete Everything',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _lifecycle.deleteAllUserData();
      if (mounted) {
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F1A),
      appBar: AppBar(
        title: const Text('Privacy & Data',
            style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ===================== Consent =====================
                  _sectionHeader('Consent Management'),
                  const SizedBox(height: 8),
                  _consentTile(
                    icon: Icons.analytics_outlined,
                    title: 'Analytics & Performance',
                    subtitle:
                        'Help us improve the app by sharing anonymous usage metrics.',
                    category: ConsentCategory.analytics,
                  ),
                  const SizedBox(height: 8),
                  _consentTile(
                    icon: Icons.mail_outline,
                    title: 'Contact Consent',
                    subtitle:
                        'Allow us to follow up on your feedback or support requests.',
                    category: ConsentCategory.contact,
                  ),
                  const SizedBox(height: 8),
                  _infoTile(
                    icon: Icons.lock_outline,
                    title: 'Essential Processing',
                    subtitle:
                        'Account, authentication, and core features. Always on.',
                  ),

                  const SizedBox(height: 28),

                  // ===================== Retention =====================
                  _sectionHeader('Data Retention Policy'),
                  const SizedBox(height: 8),
                  _retentionRow('Workout logs', '24 months'),
                  _retentionRow('Meal / nutrition logs', '12 months'),
                  _retentionRow('Feedback & NPS', '6 months'),
                  _retentionRow('Performance metrics', '90 days'),
                  _retentionRow('Inactive accounts', '18 months'),
                  const SizedBox(height: 4),
                  Text(
                    'Records older than the retention window are automatically deleted.',
                    style: TextStyle(color: Colors.grey[500], fontSize: 12),
                  ),

                  const SizedBox(height: 28),

                  // ===================== Portability =====================
                  _sectionHeader('Data Portability'),
                  const SizedBox(height: 8),
                  _actionCard(
                    icon: Icons.download_outlined,
                    title: 'Export My Data',
                    subtitle:
                        'Download all your personal data in machine-readable JSON format (GDPR Art. 20).',
                    buttonLabel: _exporting ? 'Exporting…' : 'Export',
                    buttonColor: const Color(0xFF00D9FF),
                    onPressed: _exporting ? null : _exportData,
                  ),

                  const SizedBox(height: 28),

                  // ===================== Erasure =====================
                  _sectionHeader('Account Deletion'),
                  const SizedBox(height: 8),
                  _actionCard(
                    icon: Icons.delete_forever_outlined,
                    title: 'Delete Account & Data',
                    subtitle:
                        'Permanently remove your account and all associated data (GDPR Art. 17). This cannot be undone.',
                    buttonLabel: 'Delete Account',
                    buttonColor: Colors.redAccent,
                    onPressed: _deleteAccount,
                  ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
    );
  }

  // ==========================================================================
  // WIDGETS
  // ==========================================================================

  Widget _sectionHeader(String text) => Semantics(
        header: true,
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      );

  Widget _consentTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required ConsentCategory category,
  }) {
    final value = _consents[category] ?? false;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF00D9FF), size: 28),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                Text(subtitle,
                    style: TextStyle(color: Colors.grey[400], fontSize: 12)),
              ],
            ),
          ),
          Semantics(
            label: '$title ${value ? "enabled" : "disabled"}',
            child: Switch(
              value: value,
              activeColor: const Color(0xFF00D9FF),
              onChanged: (v) => _toggleConsent(category, v),
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoTile({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.green, size: 28),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                Text(subtitle,
                    style: TextStyle(color: Colors.grey[400], fontSize: 12)),
              ],
            ),
          ),
          const Icon(Icons.check_circle, color: Colors.green),
        ],
      ),
    );
  }

  Widget _retentionRow(String label, String duration) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(Icons.schedule, color: Colors.grey[500], size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(label, style: TextStyle(color: Colors.grey[300])),
          ),
          Text(duration,
              style: const TextStyle(
                  color: Color(0xFFFF6B35), fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _actionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required String buttonLabel,
    required Color buttonColor,
    VoidCallback? onPressed,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: buttonColor.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: buttonColor, size: 28),
              const SizedBox(width: 12),
              Expanded(
                child: Text(title,
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(subtitle,
              style: TextStyle(color: Colors.grey[400], fontSize: 13)),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: buttonColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: onPressed,
              child: Text(buttonLabel),
            ),
          ),
        ],
      ),
    );
  }
}
