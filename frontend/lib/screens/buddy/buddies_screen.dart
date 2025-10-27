import 'package:flutter/material.dart';
import 'package:frontend/providers/swipe_provider.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:swipable_stack/swipable_stack.dart';
import '../../providers/event_provider.dart';
import '../../models/user.dart';
import '../../core/constants.dart';

class BuddiesSwipeScreen extends StatefulWidget {
  const BuddiesSwipeScreen({super.key});

  @override
  State<BuddiesSwipeScreen> createState() => _BuddiesSwipeScreenState();
}

class _BuddiesSwipeScreenState extends State<BuddiesSwipeScreen> {
  final SwipableStackController _controller = SwipableStackController();
  List<User> _buddies = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _fetchBuddies());
  }

  Future<void> _fetchBuddies() async {
    setState(() => _loading = true);
    final provider = context.read<EventProvider>();
    await provider.fetchExploreBuddies();
    setState(() {
      _buddies = List.from(provider.buddies);
      _loading = false;
    });
  }

  Future<void> _onSwipeCompleted(int index, SwipeDirection direction) async {
    if (index >= _buddies.length) return;

    final buddy = _buddies[index];
    final liked = direction == SwipeDirection.right;

    // handle swipe via provider
    final swipeProvider = context.read<SwipeProvider>();
    await swipeProvider.handleSwipe(
      eventId: buddy.sharedEvents?.isNotEmpty == true
          ? buddy.sharedEvents!.first.eventId
          : '',
      targetId: buddy.id!,
      liked: liked,
    );

    final status = swipeProvider.lastStatus;

    // Wait a bit for swipe animation to finish
    await Future.delayed(const Duration(milliseconds: 260));

    if (!mounted) return;

    // ✅ Remove the specific buddy by ID (not by index)
    setState(() {
      _buddies.removeWhere((b) => b.id == buddy.id);
    });

    // show match popup if matched
    if (status == "match" && mounted) {
      await Future.delayed(const Duration(milliseconds: 50));
      if (!mounted) return;

      // ✅ Refresh all matches automatically
      await context.read<SwipeProvider>().refreshMatches();

      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          backgroundColor: const Color.fromARGB(135, 255, 48, 110),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Lottie.asset(
                'assets/animations/Success.json',
                width: 180,
                repeat: true,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 16),
              Text(
                "It’s a match with ${buddy.name}!",
                style: const TextStyle(color: Colors.white, fontSize: 18),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    // optional auto-refresh when empty
    if (_buddies.isEmpty && mounted) {
      await Future.delayed(const Duration(milliseconds: 300));
      _fetchBuddies();
    }
  }

  void _swipeLeft() => _controller.next(swipeDirection: SwipeDirection.left);
  void _swipeRight() => _controller.next(swipeDirection: SwipeDirection.right);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: _loading
            ? _buildLoadingState()
            : RefreshIndicator(
                color: AppColors.accent,
                backgroundColor: Colors.black,
                onRefresh: _fetchBuddies,
                child: _buddies.isEmpty
                    ? ListView(children: [_buildEmptyState()])
                    : _buildSwipeStack(),
              ),
      ),
    );
  }

  Widget _buildLoadingState() =>
      const Center(child: CircularProgressIndicator(color: AppColors.primary));

  Widget _buildEmptyState() => Padding(
    padding: const EdgeInsets.only(top: 200),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(
          Icons.people_outline_rounded,
          size: 80,
          color: Color.fromARGB(179, 255, 0, 0),
        ),
        const SizedBox(height: 16),
        const Text(
          "No buddies found 😢",
          style: TextStyle(
            color: Color.fromARGB(255, 66, 201, 255),
            fontSize: 18,
          ),
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: _fetchBuddies,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.accent,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          child: const Text("Refresh"),
        ),
      ],
    ),
  );

  Widget _buildSwipeStack() {
    return Stack(
      alignment: Alignment.center,
      children: [
        SwipableStack(
          controller: _controller,
          allowVerticalSwipe: false,
          itemCount: _buddies.length, // keeps stack synced
          onSwipeCompleted: _onSwipeCompleted,
          builder: (context, properties) {
            if (properties.index >= _buddies.length) {
              return const SizedBox.shrink();
            }
            final buddy = _buddies[properties.index];
            return AnimatedOpacity(
              duration: const Duration(milliseconds: 200),
              opacity: properties.stackIndex == 0 ? 1 : 0.9,
              child: _BuddyCard(
                buddy: buddy,
                swipeProgress: properties.swipeProgress,
              ),
            );
          },
        ),

        // Buttons
        Positioned(bottom: 40, left: 0, right: 0, child: _buildActionButtons()),
      ],
    );
  }

  Widget _buildActionButtons() => Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      _ActionButton(
        icon: Icons.close_rounded,
        color: Colors.redAccent,
        onTap: _swipeLeft,
      ),
      const SizedBox(width: 25),
      _ActionButton(
        icon: Icons.favorite_rounded,
        color: Colors.greenAccent,
        onTap: _swipeRight,
        size: 70,
      ),
    ],
  );
}

class _BuddyCard extends StatelessWidget {
  final User buddy;
  final double swipeProgress;

  const _BuddyCard({required this.buddy, required this.swipeProgress});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Container(
      width: size.width,
      height: size.height,
      margin: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(
              buddy.avatar ??
                  'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=400&h=600&fit=crop',
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                color: Colors.grey[800],
                child: const Icon(
                  Icons.person,
                  size: 80,
                  color: Colors.white30,
                ),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.4),
                    Colors.black.withOpacity(0.8),
                  ],
                ),
              ),
            ),
            Positioned(
              bottom: 100,
              left: 24,
              right: 24,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    buddy.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.email, color: Colors.white70, size: 16),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          buddy.email,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 15,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (buddy.sharedEvents?.isNotEmpty == true)
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: buddy.sharedEvents!
                          .map((e) => _EventChip(text: e.title))
                          .toList(),
                    )
                  else
                    const Text(
                      "No shared events",
                      style: TextStyle(color: Colors.white54, fontSize: 12),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EventChip extends StatelessWidget {
  final String text;
  const _EventChip({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.deepPurple.withOpacity(0.3),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  final double size;

  const _ActionButton({
    required this.icon,
    required this.color,
    required this.onTap,
    this.size = 60,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      shape: const CircleBorder(),
      elevation: 8,
      shadowColor: color.withOpacity(0.3),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Icon(icon, color: color, size: size * 0.4),
        ),
      ),
    );
  }
}
