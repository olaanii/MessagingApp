import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'presentation/auth/phone_entry_screen.dart';
import 'presentation/auth/otp_verification_screen.dart';
import 'presentation/auth/create_profile_screen.dart';
import 'presentation/chat/inbox_screen.dart';
import 'presentation/chat/chat_detail_screen.dart';
import 'presentation/chat/group_creation_screen.dart';
import 'presentation/settings/settings_screen.dart';
import 'presentation/theme/app_theme.dart';
import 'presentation/auth/auth_provider.dart';
import 'presentation/chat/chat_provider.dart';
import 'presentation/chat/contacts_screen.dart';

import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

bool _isFirebaseInitialized = false;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Attempt to initialize Firebase with generated options.
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    _isFirebaseInitialized = true;
  } catch (e) {
    debugPrint('Firebase initialization warning: $e');
    // We catch this to allow the app to run even without Firebase configured,
    // though Auth services will fail with more descriptive errors later.
    _isFirebaseInitialized = false;
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ChatProvider()),
      ],
      child: MessagingApp(isFirebaseInitialized: _isFirebaseInitialized),
    ),
  );
}

class MessagingApp extends StatefulWidget {
  final bool isFirebaseInitialized;
  const MessagingApp({super.key, required this.isFirebaseInitialized});

  @override
  State<MessagingApp> createState() => _MessagingAppState();
}

class _MessagingAppState extends State<MessagingApp> {
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    _router = GoRouter(
      initialLocation: '/',
      refreshListenable: authProvider,
      redirect: (context, state) {
        final bool loggedIn = authProvider.isAuthenticated;
        final bool isAuthRoute = state.matchedLocation == '/' || 
                               state.matchedLocation == '/otp' || 
                               state.matchedLocation == '/profile';

        if (!loggedIn && !isAuthRoute) {
          return '/';
        }
        if (loggedIn && state.matchedLocation == '/') {
          return '/inbox';
        }
        return null;
      },
      routes: [
        GoRoute(path: '/', builder: (context, state) => const PhoneEntryScreen()),
        GoRoute(
          path: '/otp',
          builder: (context, state) => const OtpVerificationScreen(),
        ),
        GoRoute(
          path: '/profile',
          builder: (context, state) => const CreateProfileScreen(),
        ),
        GoRoute(path: '/inbox', builder: (context, state) => const InboxScreen()),
        GoRoute(
          path: '/chat/:id',
          builder: (context, state) {
            final id = state.pathParameters['id']!;
            return ChatDetailScreen(chatId: id);
          },
        ),
        GoRoute(
          path: '/settings',
          builder: (context, state) => const SettingsScreen(),
        ),
        GoRoute(
          path: '/contacts',
          builder: (context, state) => const ContactsScreen(),
        ),
        GoRoute(
          path: '/new-group',
          builder: (context, state) => const GroupCreationScreen(),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isFirebaseInitialized && identical(0, 0.0)) {
      // Simple web check
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.cloud_off, size: 64, color: Colors.blue),
                  const SizedBox(height: 16),
                  const Text(
                    'Firebase Config Missing',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Please run "flutterfire configure" to set up your web configurations.',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {},
                    child: const Text('Continue (Services will be disabled)'),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Messaging App',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      routerConfig: _router,
    );
  }
}
