import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../providers/auth_notifier.dart';

class LoginPage extends ConsumerWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authNotifierProvider);
    final theme = Theme.of(context);
    final colors = theme.extension<AppColors>()!;
    final size = MediaQuery.sizeOf(context);

    // Navigate away on authentication
    ref.listen(authNotifierProvider, (_, next) {
      next.whenData((state) {
        if (state is AuthAuthenticated) {
          context.go('/dashboard');
        }
      });
    });

    return Scaffold(
      backgroundColor: colors.bg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: size.height * 0.08),

              // ── Brand Logo ──────────────────────────────────────────
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: colors.accent,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: colors.accent.withValues(alpha: 0.15),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.account_balance_wallet_rounded,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(height: 32),

              // ── Headline ──────────────────────────────────────────
              Text('SpendSense', style: theme.textTheme.displayLarge),
              const SizedBox(height: 12),
              Text(
                'Financial clarity starts here. Automatic expense tracking powered by intelligence.',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: colors.textSub,
                  height: 1.5,
                ),
              ),

              const Spacer(),

              // ── Error Message ─────────────────────────────────────
              authState.whenData((state) {
                    if (state is AuthError) {
                      return Container(
                        margin: const EdgeInsets.only(bottom: 20),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: colors.redSoft,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: colors.red.withValues(alpha: 0.2),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.error_outline,
                              color: colors.red,
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                state.message,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: colors.red,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  }).value ??
                  const SizedBox.shrink(),

              // ── Google Sign-In Button ─────────────────────────────
              _PrimaryActionButton(
                isLoading: authState.isLoading,
                label: 'Continue with Google',
                iconPath: 'assets/icons/google.svg',
                onTap: () =>
                    ref.read(authNotifierProvider.notifier).signInWithGoogle(),
              ),
              const SizedBox(height: 24),

              // ── Privacy Footer ────────────────────────────────────
              Center(
                child: Text(
                  'End-to-end encrypted. We only process transaction notifications.',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: colors.textDim,
                  ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

class _PrimaryActionButton extends StatelessWidget {
  final bool isLoading;
  final String label;
  final String iconPath;
  final VoidCallback onTap;

  const _PrimaryActionButton({
    required this.isLoading,
    required this.label,
    required this.iconPath,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;

    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: isLoading ? null : onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: colors.accent,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Using Icon as fallback for SVG if file not present yet
                  const Icon(
                    Icons.login_rounded,
                    size: 20,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.2,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
