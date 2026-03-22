import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:prm_project/core/l10n/app_localizations.dart';
import 'package:prm_project/core/theme/app_colors.dart';
import 'package:prm_project/core/theme/app_text_styles.dart';
import 'package:prm_project/core/widgets/app_button.dart';
import 'package:prm_project/core/providers/settings_provider.dart';
import 'package:prm_project/features/settings/viewmodels/settings_viewmodel.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool notificationsEnabled = true;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final currentThemeMode = ref.watch(themeModeProvider);

    // ── React to SettingsViewModel state changes ────────────────────────────
    ref.listen<SettingsState>(settingsViewModelProvider, (_, next) {
      if (!mounted) return;

      if (next.cacheCleared) {
        ref.read(settingsViewModelProvider.notifier).resetCacheCleared();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.cacheClearedSuccessfully)),
        );
      }

      if (next.accountDeleted) {
        context.go('/login');
      }

      if (next.errorMessage != null) {
        ref.read(settingsViewModelProvider.notifier).clearError();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.errorMessage!),
            backgroundColor: AppColors.error,
          ),
        );
      }
    });

    final settingsState = ref.watch(settingsViewModelProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settings),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSectionHeader(l10n.accountSettings),
          _buildSettingItem(
            icon: Icons.person_outline,
            title: l10n.personalInformation,
            onTap: () {
              // TODO: Navigate to personal info screen
            },
          ),
          _buildSettingItem(
            icon: Icons.password_outlined,
            title: l10n.changePassword,
            onTap: () => context.push('/change-password', extra: false),
          ),


          const SizedBox(height: 24),
          _buildSectionHeader(l10n.appSettings),

          SwitchListTile(
            value: notificationsEnabled,
            onChanged: (value) => setState(() => notificationsEnabled = value),
            title: Text(l10n.pushNotifications, style: AppTextStyles.body1),
            secondary: const Icon(Icons.notifications_outlined, color: AppColors.primary),
            contentPadding: EdgeInsets.zero,
          ),



          ListTile(
            leading: const Icon(Icons.brightness_4_outlined, color: AppColors.primary),
            title: Text(l10n.themeMode, style: AppTextStyles.body1),
            contentPadding: EdgeInsets.zero,
            trailing: DropdownButton<ThemeMode>(
              value: currentThemeMode,
              underline: const SizedBox(),
              onChanged: (ThemeMode? newValue) {
                if (newValue != null) {
                  ref.read(themeModeProvider.notifier).setThemeMode(newValue);
                }
              },
              items: [
                DropdownMenuItem(value: ThemeMode.system, child: Text(l10n.systemDefault)),
                DropdownMenuItem(value: ThemeMode.light, child: Text(l10n.lightMode)),
                DropdownMenuItem(value: ThemeMode.dark, child: Text(l10n.darkMode)),
              ],
            ),
          ),



          const SizedBox(height: 32),

          // ── Clear Cache Button ─────────────────────────────────────────────
          AppButton(
            text: l10n.clearAppCache,
            onPressed: () => _showClearCacheDialog(l10n),
            backgroundColor: AppColors.lightGrey,
            textColor: AppColors.textPrimary,
            isLoading: settingsState.activeAction == SettingsAction.clearCache,
          ),

          const SizedBox(height: 16),

          // ── Delete Account Button ──────────────────────────────────────────
          AppButton(
            text: l10n.deleteMyAccount,
            onPressed: () => _showDeleteAccountDialog(l10n),
            backgroundColor: AppColors.error.withValues(alpha: 0.1),
            textColor: AppColors.error,
            isLoading: settingsState.activeAction == SettingsAction.deleteAccount,
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        title,
        style: AppTextStyles.headline3.copyWith(color: AppColors.primary),
      ),
    );
  }

  Widget _buildSettingItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    String? subtitle,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary),
      title: Text(title, style: AppTextStyles.body1),
      subtitle: subtitle != null ? Text(subtitle, style: AppTextStyles.body2) : null,
      trailing: const Icon(Icons.chevron_right, color: AppColors.grey),
      contentPadding: EdgeInsets.zero,
      onTap: onTap,
    );
  }

  // ── Dialogs ────────────────────────────────────────────────────────────────

  void _showClearCacheDialog(AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.clearCache),
        content: Text(l10n.clearCacheConfirmation),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop(); // dismiss BEFORE async call
              ref.read(settingsViewModelProvider.notifier).clearCache();
            },
            child: Text(l10n.clear, style: const TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog(AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.deleteAccount),
        content: Text(l10n.deleteAccountConfirmation),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop(); // dismiss BEFORE async call
              ref.read(settingsViewModelProvider.notifier).deleteAccount();
            },
            child: Text(l10n.delete, style: const TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }
}
