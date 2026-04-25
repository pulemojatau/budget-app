import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/budget_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/app_widgets.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  static const List<Map<String, String>> _currencies = [
    {'symbol': 'R',  'name': 'South African Rand (ZAR)'},
    {'symbol': '\$', 'name': 'US Dollar (USD)'},
    {'symbol': '€',  'name': 'Euro (EUR)'},
    {'symbol': '£',  'name': 'British Pound (GBP)'},
    {'symbol': 'N\$','name': 'Namibian Dollar (NAD)'},
    {'symbol': 'E',  'name': 'Swazi Lilangeni (SZL)'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgDark,
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: AppTheme.bgDark,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Consumer<BudgetProvider>(
        builder: (context, budget, _) {
          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              // Currency
              _SectionLabel(label: 'Preferences'),
              const SizedBox(height: 10),
              GlassCard(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Text('💱', style: TextStyle(fontSize: 18)),
                        SizedBox(width: 10),
                        Text('Currency Symbol', style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w600, fontSize: 14)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _currencies.map((c) => GestureDetector(
                        onTap: () => budget.setCurrency(c['symbol']!),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: budget.currency == c['symbol'] ? AppTheme.primary.withOpacity(0.2) : AppTheme.surface3,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: budget.currency == c['symbol'] ? AppTheme.primary : const Color(0xFF2A2A4A),
                            ),
                          ),
                          child: Column(
                            children: [
                              Text(
                                c['symbol']!,
                                style: TextStyle(
                                  color: budget.currency == c['symbol'] ? AppTheme.primary : AppTheme.textPrimary,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 16,
                                ),
                              ),
                              Text(
                                c['symbol']!,
                                style: TextStyle(
                                  color: budget.currency == c['symbol'] ? AppTheme.primary.withOpacity(0.7) : AppTheme.textMuted,
                                  fontSize: 9,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )).toList(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              // Data management
              const _SectionLabel(label: 'Data Management'),
              const SizedBox(height: 10),
              GlassCard(
                child: Column(
                  children: [
                    _SettingsTile(
                      icon: '🔄',
                      title: 'Reset Monthly Spending',
                      subtitle: 'Clears all spent amounts, keeps your budget setup',
                      iconBg: AppTheme.warning.withOpacity(0.15),
                      onTap: () async {
                        final confirm = await showConfirmDialog(
                          context,
                          title: 'Reset Monthly Data?',
                          message: 'This will set all category spending back to zero and clear transaction history. Your income, expenses, and budget categories will remain.',
                          confirmLabel: 'Reset',
                          confirmColor: AppTheme.warning,
                        );
                        if (confirm == true && context.mounted) {
                          Provider.of<BudgetProvider>(context, listen: false).resetMonthlyData();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('✅ Monthly data reset successfully')),
                          );
                        }
                      },
                    ),
                    const Divider(height: 1, indent: 16, endIndent: 16),
                    _SettingsTile(
                      icon: '🗑️',
                      title: 'Clear All Data',
                      subtitle: 'Permanently delete everything — cannot be undone',
                      iconBg: AppTheme.danger.withOpacity(0.15),
                      titleColor: AppTheme.danger,
                      onTap: () async {
                        final confirm = await showConfirmDialog(
                          context,
                          title: 'Wipe Everything?',
                          message: 'This will permanently delete all your income, expenses, categories, transactions, and goals. This cannot be undone.',
                          confirmLabel: 'Delete All',
                        );
                        if (confirm == true && context.mounted) {
                          Provider.of<BudgetProvider>(context, listen: false).clearAllData();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('All data cleared')),
                          );
                        }
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // ── Trust layer ──────────────────────────────────────────
              const _SectionLabel(label: 'Privacy & Security'),
              const SizedBox(height: 10),
              GlassCard(
                padding: const EdgeInsets.all(16),
                borderColor: AppTheme.accent.withOpacity(0.2),
                child: Column(
                  children: [
                    _TrustRow(
                      icon: Icons.phone_android_rounded,
                      color: AppTheme.accent,
                      title: 'Stored on your device only',
                      subtitle: 'Your data never leaves your phone',
                    ),
                    const SizedBox(height: 12),
                    _TrustRow(
                      icon: Icons.wifi_off_rounded,
                      color: AppTheme.primary,
                      title: 'Works 100% offline',
                      subtitle: 'No internet connection required',
                    ),
                    const SizedBox(height: 12),
                    _TrustRow(
                      icon: Icons.person_off_rounded,
                      color: AppTheme.accentOrange,
                      title: 'No account required',
                      subtitle: 'No sign-up, no email, no tracking',
                    ),
                    const SizedBox(height: 12),
                    _TrustRow(
                      icon: Icons.visibility_off_rounded,
                      color: AppTheme.accentPink,
                      title: 'Zero data collection',
                      subtitle: 'We collect nothing — ever',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // ── About ────────────────────────────────────────────────
              const _SectionLabel(label: 'About'),
              const SizedBox(height: 10),
              GlassCard(
                child: Column(
                  children: [
                    _SettingsTile(
                      icon: '💜',
                      title: 'BudgetFlow – Expense Tracker',
                      subtitle: 'Version 1.0.0 · Offline-first personal budget app',
                      iconBg: AppTheme.primary.withOpacity(0.15),
                      onTap: () {},
                    ),
                    const Divider(height: 1, indent: 16, endIndent: 16),
                    _SettingsTile(
                      icon: '📄',
                      title: 'Privacy Policy',
                      subtitle: 'No data collected · stored locally only',
                      iconBg: AppTheme.accent.withOpacity(0.15),
                      onTap: () {
                        // Copy privacy policy URL to clipboard
                        Clipboard.setData(const ClipboardData(
                          text: 'https://budgetflow-app.github.io/privacy',
                        ));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Privacy policy URL copied to clipboard'),
                          ),
                        );
                      },
                    ),
                    const Divider(height: 1, indent: 16, endIndent: 16),
                    _SettingsTile(
                      icon: '⭐',
                      title: 'Rate BudgetFlow',
                      subtitle: 'Enjoying the app? Leave a review',
                      iconBg: AppTheme.warning.withOpacity(0.15),
                      onTap: () {},
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // ── Footer ───────────────────────────────────────────────
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.surface3,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Column(
                  children: [
                    Text(
                      'BudgetFlow – Expense Tracker',
                      style: TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Control your money in real time',
                      style: TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Made with 💜 · 100% offline · No tracking · No ads',
                      style: TextStyle(color: AppTheme.textMuted, fontSize: 11),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],
          );
        },
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label.toUpperCase(),
      style: const TextStyle(
        color: AppTheme.textMuted,
        fontSize: 11,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.2,
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final String icon;
  final String title;
  final String subtitle;
  final Color iconBg;
  final Color? titleColor;
  final VoidCallback onTap;

  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.iconBg,
    required this.onTap,
    this.titleColor,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(12)),
        child: Center(child: Text(icon, style: const TextStyle(fontSize: 18))),
      ),
      title: Text(
        title,
        style: TextStyle(
          color: titleColor ?? AppTheme.textPrimary,
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
      ),
      subtitle: Text(subtitle, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
      trailing: const Icon(Icons.chevron_right_rounded, color: AppTheme.textMuted, size: 18),
    );
  }
}

// ── Trust row widget ──────────────────────────────────────────────────────────
class _TrustRow extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;

  const _TrustRow({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: color.withOpacity(0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                subtitle,
                style: const TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
        Icon(Icons.check_circle_rounded, color: color, size: 16),
      ],
    );
  }
}
