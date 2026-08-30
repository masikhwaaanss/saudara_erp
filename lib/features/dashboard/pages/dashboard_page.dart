import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:saudara_erp/providers/auth_provider.dart';

class DashboardPage extends ConsumerStatefulWidget {
  const DashboardPage({Key? key}) : super(key: key);

  @override
  ConsumerState<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends ConsumerState<DashboardPage> {
  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(currentUserProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              showMenu(
                context: context,
                position: const RelativeRect.fromLTRB(100, 80, 0, 0),
                items: [
                  PopupMenuItem(
                    child: const Text('Profile'),
                    onTap: () {},
                  ),
                  PopupMenuItem(
                    child: const Text('Settings'),
                    onTap: () {},
                  ),
                  const PopupMenuDivider(),
                  PopupMenuItem(
                    child: const Text('Logout'),
                    onTap: () {
                      ref.read(authProvider.notifier).logout();
                      Navigator.of(context).pushReplacementNamed('/login');
                    },
                  ),
                ],
              );
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Selamat datang, ${currentUser?.fullName}!',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            Text(
              'Role: ${currentUser?.role}',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                ref.read(authProvider.notifier).logout();
                Navigator.of(context).pushReplacementNamed('/login');
              },
              child: const Text('Logout'),
            ),
          ],
        ),
      ),
    );
  }
}
