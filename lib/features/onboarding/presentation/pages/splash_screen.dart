import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../providers/onboarding_provider.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToNext();
  }

  Future<void> _navigateToNext() async {
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;

    final onboardingCompleted = ref.read(onboardingProvider);
    if (!onboardingCompleted) {
      context.go('/onboarding');
    } else {
      // GoRouter redirect logic will handle auth state from here
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;

    return Scaffold(
      backgroundColor: colors.surface,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: colors.accentSoft,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                Icons.account_balance_wallet_rounded,
                size: 40,
                color: colors.accent,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'SpendSense',
              style: Theme.of(context).textTheme.displayLarge?.copyWith(
                fontSize: 32,
                color: colors.text,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Smart. Secure. Seamless.',
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: colors.textSub,
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
