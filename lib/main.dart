import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'auth_gate.dart';
import 'firebase_options.dart';
import 'forgot_password_page.dart';
import 'home_page.dart';
import 'journal_page.dart';
import 'login_page.dart';
import 'registration_page.dart';
import 'weather_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

final _router = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const AuthGate(),
      routes: [
        GoRoute(path: 'login', builder: (context, state) => const LoginPage()),
        GoRoute(
          path: 'registration',
          builder: (context, state) => const RegistrationPage(),
        ),
        GoRoute(
          path: 'forgot-password',
          builder: (context, state) => const ForgotPasswordPage(),
        ),
      ],
    ),
    GoRoute(
      path: '/home',
      builder: (context, state) => const HomePage(),
      routes: [
        GoRoute(
          path: 'journal',
          builder: (context, state) => const JournalPage(),
        ),
        GoRoute(
          path: 'weather',
          builder: (context, state) => const WeatherPage(),
        ),
      ],
    ),
  ],
  redirect: (context, state) {
    final loggedIn = FirebaseAuth.instance.currentUser != null;
    final loggingIn =
        state.matchedLocation == '/login' ||
        state.matchedLocation == '/registration' ||
        state.matchedLocation == '/forgot-password';

    if (!loggedIn) {
      return loggingIn ? null : '/login';
    }

    if (loggingIn) {
      return '/home';
    }

    return null;
  },
);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: _router,
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue),
    );
  }
}
