import 'package:flutter/material.dart';
import 'package:frontend/core/constants.dart';
import 'package:provider/provider.dart';
import '../providers/event_provider.dart';
import 'package:like_button/like_button.dart';
import '../models/event.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<EventProvider>().fetchEvents();
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final eventProvider = context.watch<EventProvider>();

    final isLoading = eventProvider.loading;
    final hasError = eventProvider.error != null;
    final isEmpty = !isLoading && !hasError && eventProvider.events.isEmpty;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: () async {
          await eventProvider.fetchEvents(forceRefresh: true);
        },
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 350),
          child: isLoading
              ? const _LoadingShimmer()
              : hasError
              ? _ErrorView(error: eventProvider.error!)
              : isEmpty
              ? const _EmptyView()
              : _EventList(events: eventProvider.events),
        ),
      ),
    );
  }
}

class _EventList extends StatelessWidget {
  final List<Event> events;

  const _EventList({required this.events});

  @override
  Widget build(BuildContext context) {
    final eventProvider = context.read<EventProvider>();

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: events.length,
      itemBuilder: (context, index) {
        final event = events[index];
        final isInterested = event.isInterested;

        return GestureDetector(
          onTap: () {
           
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 16),
            height: 200,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Stack(
              children: [
                // Event image
                ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: event.images != null && event.images!.isNotEmpty
                      ? Image.network(
                          event.images!.first,
                          height: 200,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) =>
                              Container(color: Colors.grey[300]),
                        )
                      : Container(
                          color: Colors.grey[300],
                          child: const Icon(Icons.event, size: 60),
                        ),
                ),

                // Gradient overlay
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.6),
                        Colors.black.withOpacity(0.9),
                      ],
                    ),
                  ),
                ),

                //  Event Info
                Positioned(
                  bottom: 16,
                  left: 16,
                  right: 16,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        event.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          height: 1.2,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${event.category} ${event.createdBy?.name != null ? "• by ${event.createdBy!.name}" : ""}',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.calendar_today,
                                size: 14,
                                color: Colors.white70,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                event.date.toLocal().toString().split(' ')[0],
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                          LikeButton(
                            isLiked: isInterested,
                            likeCount: null,
                            onTap: (isLiked) async {
                              isLiked
                                  ? await eventProvider.unmarkInterest(event.id)
                                  : await eventProvider.markInterest(event.id);
                              return !isLiked;
                            },
                            likeBuilder: (bool isLiked) {
                              return Icon(
                                Icons.favorite,
                                color: isLiked ? Colors.red : Colors.grey,
                                size: 30,
                              );
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _EmptyView extends StatelessWidget {
  const _EmptyView();

  @override
  Widget build(BuildContext context) {
    return Center(
      key: const ValueKey('empty'),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.event_busy,
            color: AppColors.primary.withOpacity(0.6),
            size: 80,
          ),
          const SizedBox(height: 10),
          const Text(
            "No events available right now.",
            style: TextStyle(fontSize: 16, color: Colors.black54),
          ),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String error;
  const _ErrorView({required this.error});

  @override
  Widget build(BuildContext context) {
    return Center(
      key: const ValueKey('error'),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: Colors.redAccent, size: 70),
          const SizedBox(height: 12),
          Text(
            error,
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.secondary, fontSize: 15),
          ),
          const SizedBox(height: 10),
          ElevatedButton.icon(
            onPressed: () => context.read<EventProvider>().fetchEvents(),
            icon: const Icon(Icons.refresh),
            label: const Text("Retry"),
          ),
        ],
      ),
    );
  }
}

class _LoadingShimmer extends StatelessWidget {
  const _LoadingShimmer();

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      key: const ValueKey('loading'),
      padding: const EdgeInsets.all(16),
      itemCount: 5,
      itemBuilder: (_, __) {
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          height: 200,
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(18),
          ),
        );
      },
    );
  }
}
