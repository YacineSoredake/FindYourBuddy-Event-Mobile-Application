import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:frontend/core/constants.dart';
import 'package:frontend/firebase_options.dart';
import 'package:frontend/providers/chat_provider.dart';
import 'package:frontend/providers/event_provider.dart';
import 'package:frontend/providers/profile_provider.dart';
import 'package:frontend/providers/swipe_provider.dart';
import 'package:frontend/screens/chat/chat_screen.dart';
import 'package:frontend/screens/event/add_event_screen.dart';
import 'package:frontend/screens/profile/profile_screen.dart';
import 'package:frontend/screens/splash_screen.dart';
import 'package:frontend/main_screen.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'screens/auth/register/register_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => EventProvider()),
        ChangeNotifierProvider(create: (_) => SwipeProvider()),
        ChangeNotifierProvider(create: (_) => ProfileProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Event Buddy',
      theme: ThemeData(
        primaryColor: AppColors.secondary,
        scaffoldBackgroundColor: AppColors.background,
        inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(),
        ),
      ),

      initialRoute: "/splash",
      routes: {
        "/splash": (context) => const SplashScreen(),
        "/login": (context) => const LoginScreen(),
        "/register": (context) => const RegisterFlowScreen(),
        "/home": (context) => const HomeScreen(),
        "/addEvent": (context) => const AddEventScreen(),
        "/main": (context) => const MainScreen(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/chat') {
          final args = settings.arguments as Map<String, dynamic>;
          return MaterialPageRoute(
            builder: (context) => ChangeNotifierProvider(
              create: (_) => ChatProvider(
                userId: args['userId'],
                buddyId: args['buddyId'],
              ),
              child: ChatScreen(
                userId: args['userId'],
                buddyId: args['buddyId'],
                buddyName: args['buddyName'],
                buddyAvatar: args['buddyAvatar'],
              ),
            ),
          );
        }
        if (settings.name == '/profile') {
          final args = settings.arguments as Map<String, dynamic>;
          return MaterialPageRoute(
            builder: (context) => ProfileScreen(
              currentUserId: args['currentUserId'],
              viewedUserId: args['viewedUserId'],
            ),
          );
        }
        return null;
      },
    );
  }
}
