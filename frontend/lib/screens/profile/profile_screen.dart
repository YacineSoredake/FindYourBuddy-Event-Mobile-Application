import 'package:flutter/material.dart';
import 'package:frontend/core/constants.dart';
import 'package:frontend/providers/auth_provider.dart';
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
  Map<String, dynamic>? viewedUser;
  bool loading = true;
  Color? dominantColor;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);

    if (isMyProfile) {
      viewedUser = auth.user?.toJson();
    } else {
      final buddy = await auth.fetchUserById(widget.viewedUserId);
      viewedUser = buddy?.toJson();
    }

    // Extract color from avatar
    if (viewedUser != null && viewedUser!['avatar'] != null) {
      await _extractAvatarColor(viewedUser!['avatar']);
    }

    setState(() => loading = false);
  }

  Future<void> _extractAvatarColor(String imageUrl) async {
    try {
      final PaletteGenerator paletteGenerator =
          await PaletteGenerator.fromImageProvider(
        NetworkImage(imageUrl),
        size: const Size(200, 200),
        maximumColorCount: 20,
      );

      setState(() {
        dominantColor = paletteGenerator.dominantColor?.color ??
            paletteGenerator.vibrantColor?.color ??
            paletteGenerator.mutedColor?.color ??
            AppColors.primary;
      });
    } catch (e) {
      setState(() {
        dominantColor = AppColors.primary;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: CircularProgressIndicator(
            color: Colors.black,
            strokeWidth: 2,
          ),
        ),
      );
    }

    if (viewedUser == null) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.person_off_outlined, size: 80, color: Colors.grey[400]),
              const SizedBox(height: 16),
              Text(
                'User not found',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      );
    }

    final avatar = viewedUser!['avatar'];
    final name = viewedUser!['name'] ?? 'Unknown User';
    final bio = viewedUser!['bio'];
    final fields = viewedUser!['fields'] as List<String>?;
    final bgColor = dominantColor ?? AppColors.primary;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: widget.showAppBar
          ? AppBar(
              backgroundColor: Colors.white,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black),
                onPressed: () => Navigator.pop(context),
              ),
              title: Text(
                name,
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              actions: [
                if (isMyProfile)
                  IconButton(
                    icon: const Icon(Icons.menu, color: Colors.black),
                    onPressed: () {
                      // TODO: Show menu
                    },
                  ),
              ],
            )
          : null,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Header Section
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Avatar and Stats Row
                  Row(
                    children: [
                      // Avatar
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: avatar == null
                              ? LinearGradient(
                                  colors: [
                                    bgColor,
                                    bgColor.withOpacity(0.7),
                                  ],
                                )
                              : null,
                        ),
                        child: CircleAvatar(
                          radius: 40,
                          backgroundColor: Colors.grey[300],
                          backgroundImage: avatar != null
                              ? NetworkImage(avatar)
                              : null,
                          child: avatar == null
                              ? Text(
                                  name[0].toUpperCase(),
                                  style: const TextStyle(
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                )
                              : null,
                        ),
                      ),
                      const SizedBox(width: 30),
                      // Stats
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildStatColumn('0', 'Posts'),
                            _buildStatColumn('0', 'Followers'),
                            _buildStatColumn('0', 'Following'),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Name
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                  // Bio
                  if (bio != null && bio.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      bio,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black,
                      ),
                    ),
                  ],
                  // Fields/Interests
                  if (fields != null && fields.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: fields
                          .map((field) => Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: bgColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                    color: bgColor.withOpacity(0.3),
                                    width: 1,
                                  ),
                                ),
                                child: Text(
                                  field,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: bgColor,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ))
                          .toList(),
                    ),
                  ],
                  const SizedBox(height: 16),
                  // Action Buttons
                  if (isMyProfile)
                    Row(
                      children: [
                        Expanded(
                          child: _instagramButton(
                            label: 'Edit Profile',
                            onPressed: () {
                              // TODO: Edit profile
                            },
                            isPrimary: false,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _instagramButton(
                            label: 'Share Profile',
                            onPressed: () {
                              // TODO: Share profile
                            },
                            isPrimary: false,
                          ),
                        ),
                      ],
                    )
                  else
                    Row(
                      children: [
                        Expanded(
                          flex: 5,
                          child: _instagramButton(
                            label: 'Follow',
                            onPressed: () {
                              // TODO: Follow user
                            },
                            isPrimary: true,
                            color: bgColor,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          flex: 5,
                          child: _instagramButton(
                            label: 'Message',
                            onPressed: () {
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
                            },
                            isPrimary: false,
                          ),
                        ),
                        const SizedBox(width: 8),
                        _iconButton(
                          icon: Icons.person_add_outlined,
                          onPressed: () {
                            // TODO: More actions
                          },
                        ),
                      ],
                    ),
                ],
              ),
            ),
            // Divider
            const Divider(height: 1, thickness: 0.5),
            // Tabs
            Container(
              height: 50,
              child: Row(
                children: [
                  Expanded(
                    child: _tabButton(
                      icon: Icons.grid_on_outlined,
                      isSelected: true,
                    ),
                  ),
                  Expanded(
                    child: _tabButton(
                      icon: Icons.person_pin_outlined,
                      isSelected: false,
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, thickness: 0.5),
            // Grid of posts (empty state)
            Container(
              padding: const EdgeInsets.all(40),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.black, width: 2),
                      ),
                      child: const Icon(
                        Icons.camera_alt_outlined,
                        size: 60,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      isMyProfile ? 'Share Photos' : 'No Posts Yet',
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w300,
                        color: Colors.black,
                      ),
                    ),
                    if (isMyProfile) ...[
                      const SizedBox(height: 12),
                      Text(
                        'When you share photos, they\'ll appear on your profile.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatColumn(String count, String label) {
    return Column(
      children: [
        Text(
          count,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            color: Colors.black,
          ),
        ),
      ],
    );
  }

  Widget _instagramButton({
    required String label,
    required VoidCallback onPressed,
    required bool isPrimary,
    Color? color,
  }) {
    return SizedBox(
      height: 32,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: isPrimary ? (color ?? Colors.blue) : Colors.white,
          foregroundColor: isPrimary ? Colors.white : Colors.black,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: isPrimary
                ? BorderSide.none
                : BorderSide(color: Colors.grey[300]!, width: 1),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _iconButton({
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      height: 32,
      width: 32,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: BorderSide(color: Colors.grey[300]!, width: 1),
          ),
          padding: EdgeInsets.zero,
        ),
        child: Icon(icon, size: 18),
      ),
    );
  }

  Widget _tabButton({
    required IconData icon,
    required bool isSelected,
  }) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: isSelected ? Colors.black : Colors.transparent,
            width: 1,
          ),
        ),
      ),
      child: Icon(
        icon,
        color: isSelected ? Colors.black : Colors.grey[400],
        size: 24,
      ),
    );
  }
}