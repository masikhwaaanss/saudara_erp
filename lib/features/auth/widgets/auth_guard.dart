import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:saudara_erp/providers/auth_provider.dart';

class AuthGuard extends ConsumerWidget {
  final Widget child;

  const AuthGuard({required this.child, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoggedIn = ref.watch(isLoggedInProvider);

    if (!isLoggedIn) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return child;
  }
}
