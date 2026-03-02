import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/providers/core_providers.dart';
import '../../../core/theme/app_theme.dart';
import '../../../features/auth/domain/entities/user_entity.dart';
import '../../../features/auth/presentation/pages/login_page.dart';
import '../../../features/dashboard/presentation/pages/dashboard_page.dart';
import '../../../features/transactions/presentation/pages/transactions_page.dart';
import '../../../features/transactions/presentation/pages/add_edit_transaction_page.dart';
import '../../../features/settings/presentation/pages/settings_page.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authStream = ref.watch(authRepositoryProvider).authStateChanges;
  final notifier = _AuthChangeNotifier(authStream);

  return GoRouter(
    initialLocation: '/login',
    refreshListenable: notifier,
    redirect: (context, state) {
      final isLoggedIn = notifier.isLoggedIn;
      final isLoginRoute = state.matchedLocation == '/login';

      if (!isLoggedIn && !isLoginRoute) return '/login';
      if (isLoggedIn && isLoginRoute) return '/dashboard';
      return null;
    },
    routes: [
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

class _AuthChangeNotifier extends ChangeNotifier {
  bool _isLoggedIn = false;

  _AuthChangeNotifier(Stream<UserEntity?> stream) {
    stream.listen((user) {
      _isLoggedIn = user != null;
      notifyListeners();
    });
  }

  bool get isLoggedIn => _isLoggedIn;
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
