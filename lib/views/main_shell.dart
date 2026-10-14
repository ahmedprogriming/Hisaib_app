import 'package:flutter/material.dart';
import 'package:management_debts_app/core/theme/app_colors.dart';

import 'package:management_debts_app/views/customers/customers_view.dart';
import 'package:management_debts_app/views/home/home_view.dart';
import 'package:management_debts_app/views/reports/reports_view.dart';
import 'package:management_debts_app/views/settings/setting_page.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _selectedIndex = 0;

  static const _screens = [
    HomePage(),
    CustomersPage(),
    ReportsPage(),
    SettingPage(),
  ];

  static const _destinations = [
    (
      icon: Icons.home_outlined,
      selectedIcon: Icons.home_rounded,
      label: 'الرئيسية',
    ),
    (
      icon: Icons.people_outline,
      selectedIcon: Icons.people_rounded,
      label: 'العملاء',
    ),
    (
      icon: Icons.bar_chart_outlined,
      selectedIcon: Icons.bar_chart_rounded,
      label: 'التقارير',
    ),
    (
      icon: Icons.settings_outlined,
      selectedIcon: Icons.settings_rounded,
      label: 'الإعدادات',
    ),
  ];

  @override
  void initState() {
    super.initState();
    // بدء مراقبة المزامنة بمجرد دخول التاجر للتطبيق
    WidgetsBinding.instance.addPostFrameCallback((_) {});
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: IndexedStack(index: _selectedIndex, children: _screens),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          boxShadow: [
            BoxShadow(
              color: AppColors.textSecondary.withValues(alpha: 0.08),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),

        child: SafeArea(
          child: ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            child: NavigationBarTheme(
              data: NavigationBarThemeData(
                backgroundColor: AppColors.surface,
                indicatorColor: AppColors.primary.withValues(alpha: 0.12),
                indicatorShape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                labelTextStyle: WidgetStateProperty.resolveWith((states) {
                  if (states.contains(WidgetState.selected)) {
                    return const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    );
                  }
                  return const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary,
                  );
                }),
              ),
              child: NavigationBar(
                selectedIndex: _selectedIndex,
                onDestinationSelected: (i) =>
                    setState(() => _selectedIndex = i),
                backgroundColor: Colors.transparent,
                elevation: 0,
                height: 70,
                labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
                destinations: _destinations
                    .map(
                      (d) => NavigationDestination(
                        icon: Icon(d.icon, color: AppColors.textSecondary),
                        selectedIcon: Icon(
                          d.selectedIcon,
                          color: AppColors.primary,
                        ),
                        label: d.label,
                      ),
                    )
                    .toList(),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
