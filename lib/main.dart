import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'providers/budget_provider.dart';
import 'screens/dashboard_screen.dart';
import 'screens/onboarding_screen.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarColor: AppTheme.bgDark,
    systemNavigationBarIconBrightness: Brightness.light,
  ));

  final budgetProvider = BudgetProvider();
  await budgetProvider.loadData();

  runApp(
    ChangeNotifierProvider(
      create: (_) => budgetProvider,
      child: const BudgetFlowApp(),
    ),
  );
}

class BudgetFlowApp extends StatelessWidget {
  const BudgetFlowApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BudgetFlow – Expense Tracker',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: Consumer<BudgetProvider>(
        builder: (context, budget, _) {
          // Route first-time users to onboarding
          if (!budget.onboardingComplete) {
            return const OnboardingScreen();
          }
          return const DashboardScreen();
        },
      ),
    );
  }
}
