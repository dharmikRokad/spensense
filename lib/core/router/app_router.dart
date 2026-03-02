import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/providers/core_providers.dart';
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

/// Bottom-nav shell that wraps all authenticated routes
class MainShell extends StatefulWidget {
  final Widget child;
  const MainShell({super.key, required this.child});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _selectedIndex = 0;

  final _tabs = const ['/dashboard', '/transactions', '/settings'];

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      body: widget.child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (i) {
          setState(() => _selectedIndex = i);
          context.go(_tabs[i]);
        },
        backgroundColor: colorScheme.surface,
        indicatorColor: colorScheme.primary.withValues(alpha: 0.15),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: Icon(Icons.receipt_long_outlined),
            selectedIcon: Icon(Icons.receipt_long),
            label: 'Transactions',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
