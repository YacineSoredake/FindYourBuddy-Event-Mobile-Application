import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:frontend/core/constants.dart';
import 'package:frontend/providers/auth_provider.dart';
import 'package:frontend/screens/buddy/allbuddies_screen.dart';
import 'package:frontend/screens/buddy/buddies_screen.dart';
import 'package:frontend/screens/event/add_event_screen.dart';
import 'package:frontend/screens/home_screen.dart';
import 'package:frontend/screens/profile/profile_screen.dart';
import 'package:provider/provider.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<String> _titles = const [
    "Discover",
    "Buddies",
    "Add Event",
    "Matches",
    "Profile",
  ];

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;

    if (user == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final List<Widget> pages = [
      const HomeScreen(),
      const BuddiesSwipeScreen(),
      const AddEventScreen(),
      const BuddiesList(),
      ProfileScreen(
        currentUserId: user.id!,
        viewedUserId: user.id!,
        showAppBar: false, // disables AppBar for embedded version
      ),
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // --- Top Navigation Bar ---
            ClipRRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  color: Colors.white.withOpacity(0.08),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _titles[_currentIndex],
                        style: const TextStyle(
                          color: AppColors.secondary,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.3,
                        ),
                      ),

                      // --- Action Buttons ---
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(
                              Icons.search_rounded,
                              color: AppColors.secondary,
                            ),
                            onPressed: () {
                              // TODO: Add search logic
                            },
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.notifications_none_rounded,
                              color: AppColors.secondary,
                            ),
                            onPressed: () {
                              // TODO: Add notifications logic
                            },
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.logout_rounded,
                              color: AppColors.secondary,
                            ),
                            onPressed: () {
                              authProvider.logout(context);
                            },
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            onPressed: () {},
                            icon: CircleAvatar(
                              radius: 18,
                              backgroundColor: Colors.grey[200],
                              backgroundImage: user.avatar != null
                                  ? NetworkImage(user.avatar!)
                                  : null,
                              child: user.avatar == null
                                  ? SvgPicture.asset(
                                      'assets/avatar-svgrepo-com.svg',
                                      width: 28,
                                      height: 28,
                                    )
                                  : null,
                            ),
                            tooltip: 'Profile',
                            splashRadius: 22,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // --- Page Content ---
            Expanded(
              child: IndexedStack(index: _currentIndex, children: pages),
            ),
          ],
        ),
      ),

      // --- Bottom Navigation Bar ---
      bottomNavigationBar: Container(
        margin: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 12,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: NavigationBar(
          height: 65,
          backgroundColor: Colors.transparent,
          surfaceTintColor: Colors.transparent,
          indicatorColor: AppColors.accent.withOpacity(0.3),
          selectedIndex: _currentIndex,
          onDestinationSelected: (index) {
            setState(() => _currentIndex = index);
          },
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.explore_outlined),
              selectedIcon: Icon(Icons.explore),
              label: 'Explore',
            ),
            NavigationDestination(
              icon: Icon(Icons.people_outline),
              selectedIcon: Icon(Icons.people),
              label: 'Buddies',
            ),
            NavigationDestination(
              icon: Icon(Icons.add_circle_outline),
              selectedIcon: Icon(Icons.add_circle),
              label: 'Add',
            ),
            NavigationDestination(
              icon: Icon(Icons.face_outlined),
              selectedIcon: Icon(Icons.face),
              label: 'Matches',
            ),
            NavigationDestination(
              icon: Icon(Icons.person_outline),
              selectedIcon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}
