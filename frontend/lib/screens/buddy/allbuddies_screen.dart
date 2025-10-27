import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:frontend/providers/swipe_provider.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:frontend/providers/auth_provider.dart';

class BuddiesList extends StatefulWidget {
  const BuddiesList({super.key});

  @override
  State<BuddiesList> createState() => _BuddiesListState();
}

class _BuddiesListState extends State<BuddiesList> {
  Future<void> _refreshBuddies() async {
    await context.read<SwipeProvider>().fetchMatchedBuddies();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _refreshBuddies());
  }

  @override
  Widget build(BuildContext context) {
    final swipeProvider = context.watch<SwipeProvider>();
    final isLoading = swipeProvider.loading;
    final buddies = swipeProvider.matches;
    final error = swipeProvider.errorMessage;
    final currentUserId = context.read<AuthProvider>().user!.id;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Builder(
          builder: (_) {
            if (isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (error != null) {
              return Center(
                child: Text(
                  error,
                  style: const TextStyle(color: Colors.red, fontSize: 16),
                ),
              );
            }

            if (buddies.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "No matches ?",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                    Lottie.asset(
                      'assets/animations/laughCat.json',
                      width: 180,
                      repeat: true,
                      fit: BoxFit.contain,
                    ),
                  ],
                ),
              );
            }

            return RefreshIndicator(
              color: Colors.blueAccent,
              backgroundColor: Colors.white,
              onRefresh: _refreshBuddies,
              child: ListView.builder(
                physics: const AlwaysScrollableScrollPhysics(),
                itemCount: buddies.length,
                itemBuilder: (context, index) {
                  final buddy = buddies[index];
                  final matchedUser = buddy.getMatchedUser(currentUserId);

                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFEEF2F3), Color(0xFFD9E4EC)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.15),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(12),
                      leading: CircleAvatar(
                        radius: 30,
                        backgroundImage: matchedUser?.avatar != null
                            ? NetworkImage(matchedUser!.avatar!)
                            : const AssetImage(
                                    'assets/images/default_avatar.png',
                                  )
                                  as ImageProvider,
                      ),
                      title: Text(
                        matchedUser?.name ?? 'Unknown User',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      subtitle: Text(
                        matchedUser?.email ?? '',
                        style: const TextStyle(color: Colors.black54),
                      ),
                      trailing: const Icon(
                        Icons.message_rounded,
                        color: Color.fromARGB(255, 81, 62, 255),
                      ),
                      onTap: () {
                        log('Tapped buddy: ${matchedUser?.name}');
                        Navigator.pushNamed(
                          context,
                          '/chat',
                          arguments: {
                            'userId': currentUserId,
                            'buddyId': buddy.id,
                            'buddyName': matchedUser!.name,
                            'buddyAvatar': matchedUser.avatar,
                          },
                        );
                      },
                    ),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}
