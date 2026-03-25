import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'providers/providers.dart';
import 'screens/auth/sign_in_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/home/family_shell.dart';
import 'screens/member/member_list_screen.dart';
import 'screens/member/member_detail_screen.dart';
import 'screens/member/member_form_screen.dart';
import 'screens/member/link_members_screen.dart';
import 'screens/member/import_screen.dart';
import 'screens/ar/ar_scan_screen.dart';
import 'screens/ar/ar_portrait_screen.dart';
import 'screens/claim/claim_screen.dart';
import 'screens/frame/frame_screen.dart';

final routerProviderWithInitial =
    Provider.family<GoRouter, String>((ref, initialLocation) {
  return _buildRouter(ref, initialLocation: initialLocation);
});

final routerProvider = Provider<GoRouter>((ref) {
  return _buildRouter(ref);
});

GoRouter _buildRouter(Ref ref, {String? initialLocation}) {
  final authNotifier = ValueNotifier<bool>(false);

  ref.listen(currentUserProvider, (_, next) {
    authNotifier.value = next != null;
  });

  return GoRouter(
    initialLocation: initialLocation ?? '/home',
    refreshListenable: authNotifier,
    redirect: (context, state) {
      final isSignedIn = ref.read(currentUserProvider) != null;
      final loc = state.matchedLocation;
      final isOnAuth = loc == '/sign-in';
      final isOnClaim = loc == '/claim';

      if (!isSignedIn && !isOnAuth) return '/sign-in';
      if (isSignedIn && isOnAuth) return isOnClaim ? null : '/home';
      return null;
    },
    routes: [
      GoRoute(
        path: '/sign-in',
        builder: (_, __) => const SignInScreen(),
      ),
      GoRoute(
        path: '/claim',
        builder: (_, state) => ClaimScreen(
          token: state.uri.queryParameters['t'] ?? '',
          type: state.uri.queryParameters['type'],
        ),
      ),
      ShellRoute(
        builder: (context, state, child) => HomeScreen(child: child),
        routes: [
          GoRoute(
            path: '/home',
            builder: (_, __) => const FamilyShell(),
          ),
          GoRoute(
            path: '/members/new',
            builder: (_, __) => const MemberFormScreen(),
          ),
          GoRoute(
            path: '/members/import',
            builder: (_, __) => const ImportScreen(),
          ),
          GoRoute(
            path: '/members/link',
            builder: (_, state) => LinkMembersScreen(
              prefillSourceId: state.uri.queryParameters['source'],
            ),
          ),
          GoRoute(
            path: '/members/:id',
            builder: (_, state) =>
                MemberDetailScreen(memberId: state.pathParameters['id']!),
          ),
          GoRoute(
            path: '/members/:id/edit',
            builder: (_, state) =>
                MemberFormScreen(memberId: state.pathParameters['id']),
          ),
          GoRoute(
            path: '/ar',
            builder: (_, __) => const ArScanScreen(),
          ),
          GoRoute(
            path: '/ar/portrait/:memberId',
            builder: (_, state) =>
                ArPortraitScreen(memberId: state.pathParameters['memberId']!),
          ),
          GoRoute(
            path: '/frame',
            builder: (_, __) => const FrameScreen(),
          ),
        ],
      ),
    ],
  );
}
