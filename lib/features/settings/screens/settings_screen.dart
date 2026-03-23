import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/core/mixins/toast_mixin.dart';
import 'package:flutter_app/features/settings/services/notification_preferences_service.dart';
import 'package:flutter_app/routes/app_routes.dart';
import 'package:flutter_app/shared/themes/app_theme.dart';

/// Settings Screen
///
/// Sections:
///   Account      — change password, KYC, logout all devices, delete account
///   Notifications — master toggle + per-type toggles (persisted via SharedPrefs)
///   Preferences  — language, clear cache
///   Help         — FAQ, contact, rate the app
///   About        — version, terms, privacy policy, licenses
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> with ToastMixin {
  final _prefsService = NotificationPreferencesService();
  NotificationPrefs _prefs = const NotificationPrefs(
    push: true,
    bids: true,
    appointments: true,
    messages: true,
  );
  bool _prefsLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadPrefs();
  }

  Future<void> _loadPrefs() async {
    final loaded = await _prefsService.load();
    if (mounted) setState(() { _prefs = loaded; _prefsLoaded = true; });
  }

  Future<void> _updatePrefs(NotificationPrefs updated) async {
    setState(() => _prefs = updated);
    await _prefsService.save(updated);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'settings.title'.tr(),
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 20,
          ),
        ),
        leading: IconButton(
          key: const Key('settings_back_btn'),
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _prefsLoaded
          ? ListView(
              padding: const EdgeInsets.symmetric(vertical: 12),
              children: [
                // ─── Account ──────────────────────────────────────────────
                _SectionHeader(title: 'settings.account'.tr()),
                _SettingsTile(
                  key: const Key('settings_change_password'),
                  icon: Icons.lock_outline_rounded,
                  iconColor: Colors.indigo,
                  title: 'settings.change_password'.tr(),
                  subtitle: 'settings.change_password_sub'.tr(),
                  onTap: () => Navigator.pushNamed(context, AppRoutes.forgotPassword),
                ),
                _SettingsTile(
                  key: const Key('settings_kyc'),
                  icon: Icons.verified_user_outlined,
                  iconColor: Colors.teal,
                  title: 'kyc.title'.tr(),
                  subtitle: 'profile.kyc_coming_soon'.tr(),
                  onTap: () => showSuccessToast('settings.feature_coming_soon'.tr()),
                ),
                _SettingsTile(
                  key: const Key('settings_logout_all_devices'),
                  icon: Icons.devices_outlined,
                  iconColor: Colors.deepOrange,
                  title: 'settings.logout_all_devices'.tr(),
                  subtitle: 'settings.logout_all_devices_sub'.tr(),
                  onTap: _handleLogoutAllDevices,
                ),
                _DangerTile(
                  key: const Key('settings_delete_account'),
                  icon: Icons.delete_forever_outlined,
                  title: 'settings.delete_account'.tr(),
                  subtitle: 'settings.delete_account_sub'.tr(),
                  onTap: _handleDeleteAccount,
                ),

                const SizedBox(height: 8),

                // ─── Notifications ────────────────────────────────────────
                _SectionHeader(title: 'settings.notifications'.tr()),
                _SettingsToggle(
                  key: const Key('settings_toggle_push'),
                  icon: Icons.notifications_outlined,
                  iconColor: Colors.orange,
                  title: 'settings.push_notifications'.tr(),
                  subtitle: 'settings.push_notifications_sub'.tr(),
                  value: _prefs.push,
                  onChanged: (val) => _updatePrefs(
                    _prefs.copyWith(
                      push: val,
                      bids: val ? _prefs.bids : false,
                      appointments: val ? _prefs.appointments : false,
                      messages: val ? _prefs.messages : false,
                    ),
                  ),
                ),
                _SettingsToggle(
                  key: const Key('settings_toggle_bids'),
                  icon: Icons.gavel_outlined,
                  iconColor: Colors.deepPurple,
                  title: 'settings.notification_bids'.tr(),
                  subtitle: null,
                  value: _prefs.bids && _prefs.push,
                  onChanged: _prefs.push
                      ? (val) => _updatePrefs(_prefs.copyWith(bids: val))
                      : null,
                ),
                _SettingsToggle(
                  key: const Key('settings_toggle_appointments'),
                  icon: Icons.calendar_today_outlined,
                  iconColor: Colors.blue,
                  title: 'settings.notification_appointments'.tr(),
                  subtitle: null,
                  value: _prefs.appointments && _prefs.push,
                  onChanged: _prefs.push
                      ? (val) => _updatePrefs(_prefs.copyWith(appointments: val))
                      : null,
                ),
                _SettingsToggle(
                  key: const Key('settings_toggle_messages'),
                  icon: Icons.chat_bubble_outline_rounded,
                  iconColor: Colors.green,
                  title: 'settings.notification_messages'.tr(),
                  subtitle: null,
                  value: _prefs.messages && _prefs.push,
                  onChanged: _prefs.push
                      ? (val) => _updatePrefs(_prefs.copyWith(messages: val))
                      : null,
                ),

                const SizedBox(height: 8),

                // ─── App Preferences ──────────────────────────────────────
                _SectionHeader(title: 'settings.app'.tr()),
                _SettingsTile(
                  key: const Key('settings_language'),
                  icon: Icons.language_rounded,
                  iconColor: Colors.teal,
                  title: 'profile.language'.tr(),
                  subtitle: 'settings.language_sub'.tr(),
                  onTap: () => Navigator.pushNamed(context, AppRoutes.languageSelection),
                ),
                _SettingsTile(
                  key: const Key('settings_clear_cache'),
                  icon: Icons.cleaning_services_outlined,
                  iconColor: Colors.blueGrey,
                  title: 'settings.clear_cache'.tr(),
                  subtitle: 'settings.clear_cache_sub'.tr(),
                  onTap: _handleClearCache,
                ),

                const SizedBox(height: 8),

                // ─── Help & Support ───────────────────────────────────────
                _SectionHeader(title: 'settings.help'.tr()),
                _SettingsTile(
                  key: const Key('settings_faq'),
                  icon: Icons.help_outline_rounded,
                  iconColor: Colors.blue,
                  title: 'settings.faq'.tr(),
                  subtitle: 'settings.faq_sub'.tr(),
                  onTap: () => _showFaqSheet(context),
                ),
                _SettingsTile(
                  key: const Key('settings_contact'),
                  icon: Icons.support_agent_rounded,
                  iconColor: Colors.green,
                  title: 'settings.contact'.tr(),
                  subtitle: 'settings.contact_sub'.tr(),
                  onTap: () => _showContactSheet(context),
                ),
                _SettingsTile(
                  key: const Key('settings_rate'),
                  icon: Icons.star_rounded,
                  iconColor: Colors.amber[700]!,
                  title: 'settings.rate'.tr(),
                  subtitle: 'settings.rate_sub'.tr(),
                  onTap: () => showSuccessToast('settings.feature_coming_soon'.tr()),
                ),

                const SizedBox(height: 8),

                // ─── About ────────────────────────────────────────────────
                _SectionHeader(title: 'settings.about'.tr()),
                _SettingsTile(
                  key: const Key('settings_version'),
                  icon: Icons.info_outline_rounded,
                  iconColor: Colors.grey,
                  title: 'settings.version'.tr(),
                  subtitle: '1.0.0 (Build 1)',
                  onTap: null,
                  trailing: const SizedBox.shrink(),
                ),
                _SettingsTile(
                  key: const Key('settings_terms'),
                  icon: Icons.description_outlined,
                  iconColor: Colors.blueGrey,
                  title: 'settings.terms'.tr(),
                  subtitle: null,
                  onTap: () => showSuccessToast('settings.feature_coming_soon'.tr()),
                ),
                _SettingsTile(
                  key: const Key('settings_privacy'),
                  icon: Icons.privacy_tip_outlined,
                  iconColor: Colors.blueGrey,
                  title: 'settings.privacy'.tr(),
                  subtitle: null,
                  onTap: () => showSuccessToast('settings.feature_coming_soon'.tr()),
                ),
                _SettingsTile(
                  key: const Key('settings_licenses'),
                  icon: Icons.copyright_outlined,
                  iconColor: Colors.grey,
                  title: 'settings.licenses'.tr(),
                  subtitle: null,
                  onTap: () => showLicensePage(context: context, applicationName: 'FarmerApp'),
                ),

                const SizedBox(height: 32),
              ],
            )
          : const Center(child: CircularProgressIndicator()),
    );
  }

  // ─── Handlers ──────────────────────────────────────────────────────────────

  void _handleClearCache() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('settings.clear_cache'.tr()),
        content: Text('settings.clear_cache_confirm'.tr()),
        actions: [
          TextButton(
            key: const Key('clear_cache_cancel_btn'),
            onPressed: () => Navigator.pop(ctx),
            child: Text('common.cancel'.tr()),
          ),
          TextButton(
            key: const Key('clear_cache_confirm_btn'),
            onPressed: () {
              Navigator.pop(ctx);
              showSuccessToast('settings.cache_cleared'.tr());
            },
            child: Text(
              'common.confirm'.tr(),
              style: const TextStyle(color: AppTheme.primaryColor),
            ),
          ),
        ],
      ),
    );
  }

  void _handleLogoutAllDevices() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('settings.logout_all_devices'.tr()),
        content: Text('settings.logout_all_devices_confirm'.tr()),
        actions: [
          TextButton(
            key: const Key('logout_all_cancel_btn'),
            onPressed: () => Navigator.pop(ctx),
            child: Text('common.cancel'.tr()),
          ),
          TextButton(
            key: const Key('logout_all_confirm_btn'),
            onPressed: () {
              Navigator.pop(ctx);
              showSuccessToast('settings.feature_coming_soon'.tr());
            },
            child: Text(
              'common.confirm'.tr(),
              style: const TextStyle(color: AppTheme.errorColor),
            ),
          ),
        ],
      ),
    );
  }

  void _handleDeleteAccount() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: AppTheme.errorColor, size: 22),
            const SizedBox(width: 8),
            Text('settings.delete_account'.tr()),
          ],
        ),
        content: Text('settings.delete_account_confirm'.tr()),
        actions: [
          TextButton(
            key: const Key('delete_account_cancel_btn'),
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'common.cancel'.tr(),
              style: const TextStyle(color: AppTheme.textSecondary),
            ),
          ),
          ElevatedButton(
            key: const Key('delete_account_confirm_btn'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              showSuccessToast('settings.feature_coming_soon'.tr());
            },
            child: Text('settings.delete_account'.tr()),
          ),
        ],
      ),
    );
  }

  void _showFaqSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _FaqSheet(),
    );
  }

  void _showContactSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _ContactSheet(),
    );
  }
}

// ─── FAQ Bottom Sheet ──────────────────────────────────────────────────────────

class _FaqSheet extends StatelessWidget {
  const _FaqSheet();

  @override
  Widget build(BuildContext context) {
    final faqs = [
      ('settings.faq_q1'.tr(), 'settings.faq_a1'.tr()),
      ('settings.faq_q2'.tr(), 'settings.faq_a2'.tr()),
      ('settings.faq_q3'.tr(), 'settings.faq_a3'.tr()),
      ('settings.faq_q4'.tr(), 'settings.faq_a4'.tr()),
      ('settings.faq_q5'.tr(), 'settings.faq_a5'.tr()),
    ];

    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      maxChildSize: 0.95,
      minChildSize: 0.4,
      builder: (_, controller) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Row(
                children: [
                  const Icon(Icons.help_outline_rounded, color: AppTheme.primaryColor),
                  const SizedBox(width: 10),
                  Text(
                    'settings.faq'.tr(),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: ListView.builder(
                controller: controller,
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: faqs.length,
                itemBuilder: (context, i) => _FaqTile(
                  question: faqs[i].$1,
                  answer: faqs[i].$2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FaqTile extends StatefulWidget {
  final String question;
  final String answer;

  const _FaqTile({required this.question, required this.answer});

  @override
  State<_FaqTile> createState() => _FaqTileState();
}

class _FaqTileState extends State<_FaqTile> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: _expanded
            ? AppTheme.primaryColor.withValues(alpha: 0.04)
            : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _expanded
              ? AppTheme.primaryColor.withValues(alpha: 0.2)
              : Colors.grey.shade200,
        ),
      ),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        title: Text(
          widget.question,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: _expanded ? AppTheme.primaryColor : AppTheme.textPrimary,
          ),
        ),
        iconColor: AppTheme.primaryColor,
        collapsedIconColor: AppTheme.textSecondary,
        onExpansionChanged: (v) => setState(() => _expanded = v),
        children: [
          Text(
            widget.answer,
            style: const TextStyle(
              fontSize: 13,
              color: AppTheme.textSecondary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Contact Sheet ─────────────────────────────────────────────────────────────

class _ContactSheet extends StatelessWidget {
  const _ContactSheet();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).padding.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 8),
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Row(
              children: [
                const Icon(Icons.support_agent_rounded, color: AppTheme.primaryColor),
                const SizedBox(width: 10),
                Text(
                  'settings.contact'.tr(),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          const SizedBox(height: 16),
          _ContactOption(
            icon: Icons.email_outlined,
            iconColor: Colors.blue,
            label: 'settings.contact_email'.tr(),
            value: 'support@farmerapp.in',
          ),
          _ContactOption(
            icon: Icons.phone_outlined,
            iconColor: Colors.green,
            label: 'settings.contact_phone'.tr(),
            value: '+91 1800-XXX-XXXX',
          ),
          _ContactOption(
            icon: Icons.access_time_outlined,
            iconColor: Colors.orange,
            label: 'settings.contact_hours'.tr(),
            value: 'Mon–Sat, 9 AM – 6 PM IST',
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _ContactOption extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;

  const _ContactOption({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppTheme.textSecondary,
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Section header ────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: AppTheme.textSecondary,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}

// ─── Settings tile ─────────────────────────────────────────────────────────────

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String? subtitle;
  final VoidCallback? onTap;
  final Widget? trailing;

  const _SettingsTile({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
        leading: Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: iconColor, size: 20),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
          ),
        ),
        subtitle: subtitle != null
            ? Text(
                subtitle!,
                style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
              )
            : null,
        trailing: trailing ??
            (onTap != null
                ? Icon(Icons.chevron_right_rounded, color: Colors.grey[400], size: 20)
                : null),
        onTap: onTap,
      ),
    );
  }
}

// ─── Danger tile ───────────────────────────────────────────────────────────────

class _DangerTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback? onTap;

  const _DangerTile({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      decoration: BoxDecoration(
        color: AppTheme.errorColor.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.errorColor.withValues(alpha: 0.15),
          width: 0.8,
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
        leading: Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: AppTheme.errorColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: AppTheme.errorColor, size: 20),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppTheme.errorColor,
          ),
        ),
        subtitle: subtitle != null
            ? Text(
                subtitle!,
                style: TextStyle(
                  fontSize: 12,
                  color: AppTheme.errorColor.withValues(alpha: 0.7),
                ),
              )
            : null,
        trailing: Icon(
          Icons.chevron_right_rounded,
          color: AppTheme.errorColor.withValues(alpha: 0.5),
          size: 20,
        ),
        onTap: onTap,
      ),
    );
  }
}

// ─── Settings toggle ───────────────────────────────────────────────────────────

class _SettingsToggle extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool>? onChanged;

  const _SettingsToggle({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final disabled = onChanged == null;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
        leading: Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: (disabled ? Colors.grey : iconColor).withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            color: disabled ? Colors.grey : iconColor,
            size: 20,
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: disabled ? AppTheme.textSecondary : AppTheme.textPrimary,
          ),
        ),
        subtitle: subtitle != null
            ? Text(
                subtitle!,
                style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
              )
            : null,
        trailing: Switch.adaptive(
          value: value,
          onChanged: onChanged,
          activeColor: AppTheme.primaryColor,
        ),
      ),
    );
  }
}
