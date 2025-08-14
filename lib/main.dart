import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'services/auth_service.dart';
import 'services/user_service.dart';
import 'services/theme_service.dart';
import 'services/cleanup_service.dart';
import 'services/profile_picture_service.dart';
import 'widgets/responsive_navigation.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/auth/forgot_password_screen.dart';
import 'screens/settings/edit_profile_screen.dart';
import 'screens/settings/change_password_screen.dart';

import 'theme/app_theme.dart';
import 'package:firebase_auth/firebase_auth.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('Firebase initialized successfully');
  } catch (e) {
    print('Firebase initialization failed: $e');
    // Firebase initialization failed
  }

  // Test Firebase connection
  try {
    FirebaseAuth.instance;
    print('Firebase Auth connection successful');
  } catch (e) {
    print('Firebase Auth connection test failed: $e');
    // Firebase connection test failed
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // Global key for ScaffoldMessenger to ensure alerts work everywhere
  static final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserService()),
        ChangeNotifierProvider(create: (context) {
          final authService = AuthService(context.read<UserService>());
          authService.initialize();
          return authService;
        }),
        ChangeNotifierProvider(create: (_) => ThemeService()),
        ChangeNotifierProvider(
          create: (context) {
            final profilePictureService = ProfilePictureService();
            // Initialize the profile picture service when the app starts
            WidgetsBinding.instance.addPostFrameCallback((_) {
              final authService = context.read<AuthService>();
              if (authService.currentUser != null) {
                profilePictureService.initialize(authService.currentUser!.id);
              }
            });
            return profilePictureService;
          },
        ),
        ChangeNotifierProxyProvider<AuthService, CleanupService>(
          create: (context) => CleanupService(
            context.read<AuthService>(),
            context.read<UserService>(),
          ),
          update: (context, authService, previous) =>
              previous ??
              CleanupService(
                authService,
                context.read<UserService>(),
              ),
        ),
      ],
      child: Consumer<ThemeService>(
        builder: (context, themeService, child) {
          return MaterialApp(
            title: 'HR Knives Inventory Management',
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeService.themeMode,
            scaffoldMessengerKey: _scaffoldMessengerKey,
            home: const AuthCheckScreen(),
            routes: {
              '/login': (context) => const LoginScreen(),
              '/register': (context) => const RegisterScreen(),
              '/forgot-password': (context) => const ForgotPasswordScreen(),
              '/home': (context) => const ResponsiveNavigation(),
              '/edit-profile': (context) => EditProfileScreen(),
              '/change-password': (context) => const ChangePasswordScreen(),
            },
            onGenerateRoute: (settings) {
              // Handle custom routes
              if (settings.name == '/force-login') {
                return MaterialPageRoute(
                  builder: (context) => const LoginScreen(),
                  settings: settings,
                );
              }
              return null;
            },
            debugShowCheckedModeBanner: false,
          );
        },
      ),
    );
  }
}

class AuthCheckScreen extends StatefulWidget {
  const AuthCheckScreen({super.key});

  @override
  State<AuthCheckScreen> createState() => _AuthCheckScreenState();
}

class _AuthCheckScreenState extends State<AuthCheckScreen> {
  @override
  void initState() {
    super.initState();
    // Start the cleanup service when the app initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final cleanupService = context.read<CleanupService>();
      cleanupService.startCleanupService();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthService>(
      builder: (context, authService, child) {
        // Listen to auth state changes to detect sign out
        final currentUser = authService.currentUser;
        final isLoading = authService.isLoading;

        // Show loading indicator while checking auth state
        if (isLoading) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (currentUser != null) {
          return const ResponsiveNavigation();
        }

        // No user or error - show login immediately
        return const LoginScreen();
      },
    );
  }
}
