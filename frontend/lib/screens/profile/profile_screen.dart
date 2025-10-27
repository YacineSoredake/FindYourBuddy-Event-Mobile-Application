import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:frontend/core/constants.dart';
import 'package:frontend/providers/auth_provider.dart';
import 'package:frontend/providers/profile_provider.dart';
import 'package:provider/provider.dart';
import 'package:palette_generator/palette_generator.dart';

class ProfileScreen extends StatefulWidget {
  final String currentUserId;
  final String viewedUserId;
  final bool showAppBar;

  const ProfileScreen({
    super.key,
    required this.currentUserId,
    required this.viewedUserId,
    this.showAppBar = true,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool get isMyProfile => widget.currentUserId == widget.viewedUserId;

  Map<String, dynamic>? userData;
  Map<String, dynamic>? stats;
  List<dynamic>? likedEvents;

  bool loading = true;
  Color? dominantColor;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final profile = Provider.of<ProfileProvider>(context, listen: false);

    try {
      final result = await profile.fetchUserById(widget.viewedUserId);

      if (result != null) {
        userData = result['user'];
        stats = result['stats'];
        likedEvents = result['likedEvents'];
      }
 
      if (userData != null && userData!['avatar'] != null) {
        await _extractAvatarColor(userData!['avatar']);
      }
    } catch (e) {
      debugPrint('Profile load error: $e');
    }

    setState(() => loading = false);
  }

  Future<void> _extractAvatarColor(String imageUrl) async {
    try {
      final PaletteGenerator palette = await PaletteGenerator.fromImageProvider(
        NetworkImage(imageUrl),
        size: const Size(200, 200),
        maximumColorCount: 20,
      );
      dominantColor =
          palette.dominantColor?.color ??
          palette.vibrantColor?.color ??
          palette.mutedColor?.color ??
          AppColors.primary;
    } catch (_) {
      dominantColor = AppColors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: Colors.black)),
      );
    }

    if (userData == null) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          title: const Text(
            "User not found",
            style: TextStyle(color: Colors.black),
          ),
          iconTheme: const IconThemeData(color: Colors.black),
        ),
        body: const Center(child: Text("This user does not exist.")),
      );
    }

    final avatar = userData!['avatar'];
    final name = userData!['name'] ?? "Unknown";
    final fields = (userData!['fields'] as List?) ?? [];
    final bgColor = dominantColor ?? AppColors.primary;

    final postsCount = stats?['eventsPosted'] ?? 0;
    final buddiesCount = stats?['matchedBuddies'] ?? 0;
    final likedCount = stats?['likedEventsCount'] ?? 0;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: widget.showAppBar
          ? AppBar(
              backgroundColor: Colors.white,
              elevation: 0,
              centerTitle: true,
              title: Text(name, style: const TextStyle(color: Colors.black)),
              iconTheme: const IconThemeData(color: Colors.black),
            )
          : null,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🔹 Header Section
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 45,
                    backgroundImage: avatar != null
                        ? NetworkImage(avatar)
                        : null,
                    backgroundColor: bgColor.withOpacity(0.2),
                    child: avatar == null
                        ? Text(
                            name[0].toUpperCase(),
                            style: const TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          )
                        : null,
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _statTile(postsCount.toString(), "Posts"),
                        _statTile(buddiesCount.toString(), "Matches"),
                        _statTile(likedCount.toString(), "Likes"),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // 🔹 Name + Interests
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (fields.isNotEmpty)
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: fields
                          .map(
                            (f) => Chip(
                              label: Text(f),
                              backgroundColor: bgColor.withOpacity(0.15),
                              labelStyle: TextStyle(color: bgColor),
                            ),
                          )
                          .toList(),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // 🔹 Action Buttons
            if (isMyProfile)
              _buttonRow([
                _profileButton("Edit Profile", () {
                  // TODO: Navigate to edit page
                }),
                _profileButton("Share Profile", () {}),
              ])
            else
              _buttonRow([
                _profileButton("Follow", () {}),
                _profileButton("Message", () {
                  Navigator.pushNamed(
                    context,
                    '/chat',
                    arguments: {
                      'userId': widget.currentUserId,
                      'buddyId': widget.viewedUserId,
                      'buddyName': name,
                      'buddyAvatar': avatar,
                    },
                  );
                }),
              ]),

            const Divider(height: 30),

            // 🔹 Liked Events
            if (likedEvents != null && likedEvents!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Liked Events",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            mainAxisSpacing: 10,
                            crossAxisSpacing: 10,
                            childAspectRatio: 1,
                          ),
                      itemCount: likedEvents!.length,
                      itemBuilder: (context, i) {
                        final e = likedEvents![i];
                        final image = e['images']?.isNotEmpty == true
                            ? e['images'][0]
                            : null;
                        return Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            image: image != null
                                ? DecorationImage(
                                    image: NetworkImage(image),
                                    fit: BoxFit.cover,
                                  )
                                : null,
                            color: Colors.grey[200],
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              gradient: LinearGradient(
                                colors: [
                                  Colors.black.withOpacity(0.4),
                                  Colors.transparent,
                                ],
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                              ),
                            ),
                            padding: const EdgeInsets.all(8),
                            alignment: Alignment.bottomLeft,
                            child: Text(
                              e['title'] ?? "",
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              )
            else
              Padding(
                padding: const EdgeInsets.all(32.0),
                child: Center(
                  child: Text(
                    isMyProfile
                        ? "You haven't liked any events yet."
                        : "No liked events to show.",
                    style: const TextStyle(color: Colors.grey),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _statTile(String count, String label) => Column(
    children: [
      Text(
        count,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
      ),
      const SizedBox(height: 4),
      Text(label, style: const TextStyle(fontSize: 13, color: Colors.grey)),
    ],
  );

  Widget _buttonRow(List<Widget> buttons) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16.0),
    child: Row(
      children:
          buttons
              .expand((b) => [Expanded(child: b), const SizedBox(width: 8)])
              .toList()
            ..removeLast(),
    ),
  );

  Widget _profileButton(String label, VoidCallback onPressed) => SizedBox(
    height: 36,
    child: ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: const BorderSide(color: Colors.grey),
        ),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.w500,
        ),
      ),
    ),
  );
}
