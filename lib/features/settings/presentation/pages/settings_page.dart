import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../auth/presentation/providers/auth_notifier.dart';
import '../providers/settings_provider.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final themeMode = ref.watch(themeModeProvider);
    final currency = ref.watch(currencyProvider);
    final theme = Theme.of(context);
    final colors = theme.extension<AppColors>()!;

    return Scaffold(
      backgroundColor: colors.bg,
      appBar: AppBar(title: const Text('Settings'), centerTitle: false),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        children: [
          // ─── Profile Header ──────────────────────────────────────
          if (user != null)
            Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 32,
                    backgroundColor: colors.accentSoft,
                    backgroundImage: user.photoUrl != null
                        ? NetworkImage(user.photoUrl!)
                        : null,
                    child: user.photoUrl == null
                        ? Text(
                            user.displayName[0],
                            style: TextStyle(
                              color: colors.accent,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        : null,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user.displayName,
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        Text(user.email, style: theme.textTheme.labelMedium),
                      ],
                    ),
                  ),
                ],
              ),
            ),

          const SizedBox(height: 8),

          // ─── Account Section ─────────────────────────────────────
          _SectionHeader(title: 'Account', colors: colors),
          _SettingsTile(
            icon: Icons.account_balance_wallet_outlined,
            title: 'Linked Accounts',
            subtitle: 'Manage your banks and UPI IDs',
            colors: colors,
            onTap: () {
              // TODO: Implement account management
            },
          ),
          _SettingsTile(
            icon: Icons.notifications_none_rounded,
            title: 'Permissions',
            subtitle: 'Notification & SMS listener status',
            colors: colors,
            onTap: () {
              // TODO: Open app settings or permission handler
            },
          ),

          // ─── Preferences Section ──────────────────────────────────
          const SizedBox(height: 24),
          _SectionHeader(title: 'Preferences', colors: colors),
          _SettingsTile(
            icon: Icons.dark_mode_outlined,
            title: 'Appearance',
            subtitle: themeMode == ThemeMode.light ? 'Light Mode' : 'Dark Mode',
            trailing: Switch(
              value: themeMode == ThemeMode.dark,
              onChanged: (_) => ref.read(themeModeProvider.notifier).toggle(),
              activeTrackColor: colors.accentSoft,
              activeColor: colors.accent,
            ),
            colors: colors,
          ),
          _SettingsTile(
            icon: Icons.payments_outlined,
            title: 'Currency',
            subtitle: currency,
            colors: colors,
            onTap: () {
              // TODO: Show currency picker
            },
          ),

          // ─── App Section ──────────────────────────────────────────
          const SizedBox(height: 24),
          _SectionHeader(title: 'App', colors: colors),
          _SettingsTile(
            icon: Icons.info_outline_rounded,
            title: 'About SpendSense',
            subtitle: 'Version 1.0.0',
            colors: colors,
            onTap: () {},
          ),
          _SettingsTile(
            icon: Icons.logout_rounded,
            title: 'Sign Out',
            subtitle: 'Log out of your account',
            titleColor: colors.red,
            iconColor: colors.red,
            showChevron: false,
            colors: colors,
            onTap: () => _showSignOutDialog(context, ref),
          ),

          const SizedBox(height: 48),
        ],
      ),
    );
  }

  void _showSignOutDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out of SpendSense?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ref.read(authNotifierProvider.notifier).signOut();
            },
            child: const Text('Sign Out', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final AppColors colors;

  const _SectionHeader({required this.title, required this.colors});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
      child: Text(
        title.toUpperCase(),
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
          fontWeight: FontWeight.w800,
          color: colors.textDim,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final Color? titleColor;
  final Color? iconColor;
  final bool showChevron;
  final AppColors colors;

  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.trailing,
    this.onTap,
    this.titleColor,
    this.iconColor,
    this.showChevron = true,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: colors.surface2,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor ?? colors.textSub, size: 22),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontSize: 15,
                      color: titleColor,
                    ),
                  ),
                  Text(subtitle, style: theme.textTheme.labelMedium),
                ],
              ),
            ),
            if (trailing != null)
              trailing!
            else if (showChevron)
              Icon(
                Icons.chevron_right_rounded,
                color: colors.textDim,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }
}
