import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/providers/core_providers.dart';
import '../../../core/theme/app_theme.dart';
import '../../../features/auth/presentation/pages/login_page.dart';
import '../../../features/dashboard/presentation/pages/dashboard_page.dart';
import '../../../features/transactions/presentation/pages/transactions_page.dart';
import '../../../features/transactions/presentation/pages/add_edit_transaction_page.dart';
import '../../../features/settings/presentation/pages/settings_page.dart';
import '../../../features/onboarding/presentation/pages/onboarding_page.dart';
import '../../../features/onboarding/presentation/pages/splash_screen.dart';
import '../../../features/onboarding/presentation/providers/onboarding_provider.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final notifier = _RouterNotifier(ref);

  return GoRouter(
    initialLocation: '/splash',
    refreshListenable: notifier,
    redirect: (context, state) {
      final isLoggedIn = notifier.isLoggedIn;
      final onboardingCompleted = notifier.onboardingCompleted;

      final isSplashRoute = state.matchedLocation == '/splash';
      final isOnboardingRoute = state.matchedLocation == '/onboarding';
      final isLoginRoute = state.matchedLocation == '/login';

      // 1. If we are on Splash, let it handle its own delay and manual navigation
      if (isSplashRoute) return null;

      // 2. If onboarding not completed, go to onboarding (unless already there)
      if (!onboardingCompleted) {
        return isOnboardingRoute ? null : '/onboarding';
      }

      // 3. Auth redirects
      if (!isLoggedIn && !isLoginRoute && !isOnboardingRoute) return '/login';
      if (isLoggedIn && (isLoginRoute || isOnboardingRoute)) {
        return '/dashboard';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/splash',
        name: 'splash',
        builder: (ctx, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        name: 'onboarding',
        builder: (ctx, state) => const OnboardingPage(),
      ),
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (ctx, state) => const LoginPage(),
      ),
      ShellRoute(
        builder: (ctx, state, child) => MainShell(child: child),
        routes: [
          GoRoute(
            path: '/dashboard',
            name: 'dashboard',
            builder: (ctx, state) => const DashboardPage(),
          ),
          GoRoute(
            path: '/transactions',
            name: 'transactions',
            builder: (ctx, state) => const TransactionsPage(),
          ),
          GoRoute(
            path: '/transactions/add',
            name: 'add-transaction',
            builder: (ctx, state) => const AddEditTransactionPage(),
          ),
          GoRoute(
            path: '/transactions/edit/:id',
            name: 'edit-transaction',
            builder: (ctx, state) => AddEditTransactionPage(
              transactionId: state.pathParameters['id'],
            ),
          ),
          GoRoute(
            path: '/settings',
            name: 'settings',
            builder: (ctx, state) => const SettingsPage(),
          ),
        ],
      ),
    ],
  );
});

class _RouterNotifier extends ChangeNotifier {
  final Ref _ref;
  bool _isLoggedIn = false;
  bool _onboardingCompleted = false;

  _RouterNotifier(this._ref) {
    // Listen to onboarding changes
    _ref.listen<bool>(onboardingProvider, (prev, next) {
      if (_onboardingCompleted != next) {
        _onboardingCompleted = next;
        notifyListeners();
      }
    });

    // Listen to auth changes via stream
    _ref.read(authRepositoryProvider).authStateChanges.listen((user) {
      final loggedIn = user != null;
      if (_isLoggedIn != loggedIn) {
        _isLoggedIn = loggedIn;
        notifyListeners();
      }
    });

    // Initialize
    _onboardingCompleted = _ref.read(onboardingProvider);
  }

  bool get isLoggedIn => _isLoggedIn;
  bool get onboardingCompleted => _onboardingCompleted;
}

class MainShell extends StatelessWidget {
  final Widget child;
  const MainShell({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.extension<AppColors>()!;
    final state = GoRouterState.of(context);

    // Calculate index from path
    int selectedIndex = 0;
    if (state.matchedLocation.startsWith('/transactions')) {
      selectedIndex = 1;
    } else if (state.matchedLocation.startsWith('/settings')) {
      selectedIndex = 2;
    }

    return Scaffold(
      body: child,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: colors.border)),
        ),
        child: NavigationBar(
          selectedIndex: selectedIndex,
          onDestinationSelected: (i) {
            final tabs = ['/dashboard', '/transactions', '/settings'];
            context.go(tabs[i]);
          },
          backgroundColor: colors.surface,
          elevation: 0,
          indicatorColor: colors.accentSoft,
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          height: 64,
          destinations: [
            NavigationDestination(
              icon: Icon(Icons.dashboard_outlined, color: colors.textDim),
              selectedIcon: Icon(Icons.dashboard_rounded, color: colors.accent),
              label: 'Dashboard',
            ),
            NavigationDestination(
              icon: Icon(Icons.receipt_long_outlined, color: colors.textDim),
              selectedIcon: Icon(
                Icons.receipt_long_rounded,
                color: colors.accent,
              ),
              label: 'Transactions',
            ),
            NavigationDestination(
              icon: Icon(Icons.settings_outlined, color: colors.textDim),
              selectedIcon: Icon(Icons.settings_rounded, color: colors.accent),
              label: 'Settings',
            ),
          ],
        ),
      ),
    );
  }
}
