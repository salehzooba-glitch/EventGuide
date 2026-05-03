import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/event_model.dart';
import '../../providers/event_provider.dart';
import '../../providers/user_provider.dart';
import '../../core/constants.dart';
import '../../core/utils.dart';
import '../../services/location_service.dart';
import '../booking/booking_screen.dart';

class EventDetailScreen extends StatelessWidget {
  final EventModel event;

  const EventDetailScreen({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // App Bar with Image
          SliverAppBar(
            expandedHeight: 250,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: event.imageUrl != null
                  ? Image.network(
                      event.imageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          // ignore: deprecated_member_use
                          color: AppColors.primaryBlue.withOpacity(0.3),
                          child: const Center(
                            child: Icon(
                              Icons.event,
                              size: 80,
                              color: Colors.white,
                            ),
                          ),
                        );
                      },
                    )
                  : Container(
                      // ignore: deprecated_member_use
                      color: AppColors.primaryBlue.withOpacity(0.3),
                      child: const Center(
                        child: Icon(Icons.event, size: 80, color: Colors.white),
                      ),
                    ),
            ),
            actions: [
              Consumer<UserProvider>(
                builder: (context, userProvider, child) {
                  final isSaved =
                      userProvider.user?.savedEvents.contains(event.id) ??
                      false;
                  return IconButton(
                    icon: Icon(
                      isSaved ? Icons.favorite : Icons.favorite_border,
                      color: isSaved ? Colors.red : Colors.white,
                    ),
                    onPressed: () {
                      final eventProvider = Provider.of<EventProvider>(
                        context,
                        listen: false,
                      );
                      if (isSaved) {
                        eventProvider.unsaveEvent(event.id);
                      } else {
                        eventProvider.saveEvent(event.id);
                      }
                    },
                  );
                },
              ),
            ],
          ),

          // Event Details
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category & Status
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          // ignore: deprecated_member_use
                          color: AppColors.primaryBlue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          event.category
                              .toString()
                              .split('.')
                              .last
                              .toUpperCase(),
                          style: const TextStyle(
                            color: AppColors.primaryBlue,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      if (event.isVerified)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            // ignore: deprecated_member_use
                            color: AppColors.success.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.verified,
                                size: 14,
                                color: AppColors.success,
                              ),
                              SizedBox(width: 4),
                              Text(
                                'Verified',
                                style: TextStyle(
                                  color: AppColors.success,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        )
                      else
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            // ignore: deprecated_member_use
                            color: AppColors.warning.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.warning_amber_rounded,
                                size: 14,
                                color: AppColors.warning,
                              ),
                              SizedBox(width: 4),
                              Text(
                                'Unverified',
                                style: TextStyle(
                                  color: AppColors.warning,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Title
                  Text(
                    event.title,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Organizer
                  Text(
                    'By ${event.organizerName}',
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 24),

                  _buildInfoRow(
                    icon: Icons.calendar_today,
                    title: 'Date & Time',
                    subtitle: DateFormat(
                      'EEEE, MMMM d, y • h:mm a',
                    ).format(event.dateTime),
                  ),
                  if (event.distance != null) ...[
                    const SizedBox(height: 16),
                    _buildInfoRow(
                      icon: Icons.navigation,
                      title: 'Distance from you',
                      subtitle: event.formattedDistance,
                      trailing: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          // ignore: deprecated_member_use
                          color: AppColors.primaryBlue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          event.distance! < 5
                              ? 'Very close!'
                              : event.distance! < 15
                              ? 'Nearby'
                              : 'Drive needed',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.primaryBlue,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),

                  // Location
                  _buildInfoRow(
                    icon: Icons.location_on,
                    title: event.venueName,
                    subtitle: event.venueAddress,
                    trailing: IconButton(
                      icon: const Icon(
                        Icons.directions,
                        color: AppColors.primaryBlue,
                      ),
                      onPressed: () {
                        final locationService = LocationService();
                        locationService.openGoogleMapsNavigation(
                          destinationLat: event.latitude,
                          destinationLng: event.longitude,
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Attendees
                  _buildInfoRow(
                    icon: Icons.people,
                    title: '${event.attendeesCount} people going',
                    subtitle:
                        '${event.availableSeats} seats remaining of ${event.capacity}',
                  ),
                  const SizedBox(height: 16),

                  // Price
                  _buildInfoRow(
                    icon: Icons.local_offer,
                    title: 'Ticket Price',
                    subtitle: NumberUtils.formatPrice(event.ticketPrice),
                  ),
                  const SizedBox(height: 24),

                  // Description
                  const Text(
                    'About this event',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    event.description,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Rating
                  if (event.totalRatings > 0) ...[
                    Row(
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 20),
                        const SizedBox(width: 4),
                        Text(
                          event.averageRating.toStringAsFixed(1),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '(${event.totalRatings} reviews)',
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                  ],
                ],
              ),
            ),
          ),
          // Extra space for button
          const SliverToBoxAdapter(child: SizedBox(height: 80)),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              // ignore: deprecated_member_use
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 10,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: Row(
            children: [
              // Price
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Price',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    Text(
                      NumberUtils.formatPrice(event.ticketPrice),
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryBlue,
                      ),
                    ),
                  ],
                ),
              ),
              // Book Button
              SizedBox(
                width: 180,
                height: 50,
                child: ElevatedButton(
                  onPressed: event.isSoldOut
                      ? null
                      : () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => BookingScreen(event: event),
                            ),
                          );
                        },
                  child: Text(
                    event.isSoldOut ? 'Sold Out' : AppStrings.bookNow,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String title,
    required String subtitle,
    Widget? trailing,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            // ignore: deprecated_member_use
            color: AppColors.primaryBlue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: AppColors.primaryBlue, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        if (trailing != null) trailing,
      ],
    );
  }
}
