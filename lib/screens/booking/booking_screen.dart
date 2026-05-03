import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/event_model.dart';
import '../../providers/booking_provider.dart';
import '../../providers/user_provider.dart';
import '../../widgets/loading_widgets.dart';
import '../../core/constants.dart';
import '../../core/utils.dart';
import 'booking_confirmation_screen.dart';

class BookingScreen extends StatefulWidget {
  final EventModel event;

  const BookingScreen({super.key, required this.event});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  int _quantity = 1;
  bool _agreeToTerms = false;
  String? _selectedPaymentMethod;

  final List<String> _paymentMethods = [
    'Cash at Event',
    'Credit Card',
    'Mada',
    'Apple Pay',
  ];

  @override
  Widget build(BuildContext context) {
    final totalPrice = widget.event.ticketPrice * _quantity;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Book Tickets'),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Consumer<BookingProvider>(
        builder: (context, bookingProvider, child) {
          if (bookingProvider.isLoading) {
            return const LoadingIndicator(
              message: 'Processing your booking...',
            );
          }

          return CustomScrollView(
            slivers: [
              // Event Summary
              SliverToBoxAdapter(
                child: Container(
                  padding: const EdgeInsets.all(20),
                  color: Colors.white,
                  child: Row(
                    children: [
                      // Event Image
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: widget.event.imageUrl != null
                            ? Image.network(
                                widget.event.imageUrl!,
                                width: 80,
                                height: 80,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    width: 80,
                                    height: 80,
                                    color: Colors.grey[200],
                                    child: const Icon(
                                      Icons.event,
                                      color: Colors.grey,
                                    ),
                                  );
                                },
                              )
                            : Container(
                                width: 80,
                                height: 80,
                                color: Colors.grey[200],
                                child: const Icon(
                                  Icons.event,
                                  color: Colors.grey,
                                ),
                              ),
                      ),
                      const SizedBox(width: 16),
                      // Event Details
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.event.title,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(
                                  Icons.calendar_today,
                                  size: 14,
                                  color: Colors.grey,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  DateFormat(
                                    'MMM d, y • h:mm a',
                                  ).format(widget.event.dateTime),
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(
                                  Icons.location_on,
                                  size: 14,
                                  color: Colors.grey,
                                ),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    widget.event.venueName,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Quantity Selector
              SliverToBoxAdapter(
                child: Container(
                  margin: const EdgeInsets.all(20),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        // ignore: deprecated_member_use
                        color: Colors.grey.withOpacity(0.1),
                        spreadRadius: 1,
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Number of Tickets',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Decrease button
                          Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey[300]!),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: IconButton(
                              icon: const Icon(Icons.remove),
                              onPressed: _quantity > 1
                                  ? () {
                                      setState(() {
                                        _quantity--;
                                      });
                                    }
                                  : null,
                              color: _quantity > 1
                                  ? AppColors.primaryBlue
                                  : Colors.grey,
                            ),
                          ),

                          // Quantity
                          Text(
                            _quantity.toString(),
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),

                          // Increase button
                          Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey[300]!),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: IconButton(
                              icon: const Icon(Icons.add),
                              onPressed: _quantity < widget.event.availableSeats
                                  ? () {
                                      setState(() {
                                        _quantity++;
                                      });
                                    }
                                  : null,
                              color: _quantity < widget.event.availableSeats
                                  ? AppColors.primaryBlue
                                  : Colors.grey,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Available: ${widget.event.availableSeats} tickets',
                        style: TextStyle(
                          fontSize: 12,
                          color: widget.event.availableSeats < 10
                              ? Colors.orange
                              : Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Price Breakdown
              SliverToBoxAdapter(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        // ignore: deprecated_member_use
                        color: Colors.grey.withOpacity(0.1),
                        spreadRadius: 1,
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Price Details',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Ticket Price (x$_quantity)',
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                            ),
                          ),
                          Text(
                            NumberUtils.formatPrice(
                              widget.event.ticketPrice * _quantity,
                            ),
                            style: const TextStyle(
                              fontWeight: FontWeight.w500,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Divider(),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Total',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          Text(
                            NumberUtils.formatPrice(totalPrice),
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryBlue,
                            ),
                          ),
                        ],
                      ),
                      if (widget.event.ticketPrice == 0) ...[
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            // ignore: deprecated_member_use
                            color: AppColors.success.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Row(
                            children: [
                              Icon(
                                Icons.info,
                                color: AppColors.success,
                                size: 16,
                              ),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'This is a free event. No payment required.',
                                  style: TextStyle(
                                    color: AppColors.success,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              // Payment Method (for paid events)
              if (widget.event.ticketPrice > 0)
                SliverToBoxAdapter(
                  child: Container(
                    margin: const EdgeInsets.all(20),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          // ignore: deprecated_member_use
                          color: Colors.grey.withOpacity(0.1),
                          spreadRadius: 1,
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Payment Method',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ..._paymentMethods.map((method) {
                          return RadioListTile<String>(
                            title: Text(method),
                            value: method,
                            // ignore: deprecated_member_use
                            groupValue: _selectedPaymentMethod,
                            // ignore: deprecated_member_use
                            onChanged: (value) {
                              setState(() {
                                _selectedPaymentMethod = value;
                              });
                            },
                            activeColor: AppColors.primaryBlue,
                            contentPadding: EdgeInsets.zero,
                          );
                        }),
                      ],
                    ),
                  ),
                ),

              // Terms and Conditions
              SliverToBoxAdapter(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      Checkbox(
                        value: _agreeToTerms,
                        onChanged: (value) {
                          setState(() {
                            _agreeToTerms = value ?? false;
                          });
                        },
                        activeColor: AppColors.primaryBlue,
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _agreeToTerms = !_agreeToTerms;
                            });
                          },
                          child: RichText(
                            text: const TextSpan(
                              text: 'I agree to the ',
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 12,
                              ),
                              children: [
                                TextSpan(
                                  text: 'Terms of Service',
                                  style: TextStyle(
                                    color: AppColors.primaryBlue,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                TextSpan(
                                  text: ' and ',
                                  style: TextStyle(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                                TextSpan(
                                  text: 'Cancellation Policy',
                                  style: TextStyle(
                                    color: AppColors.primaryBlue,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          );
        },
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
          child: Consumer<BookingProvider>(
            builder: (context, bookingProvider, child) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Confirm Button
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: _canProceed(bookingProvider)
                          ? () => _confirmBooking(bookingProvider)
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryBlue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: bookingProvider.isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : Text(
                              widget.event.ticketPrice == 0
                                  ? 'Confirm Booking'
                                  : 'Pay ${NumberUtils.formatPrice(totalPrice)}',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'You won\'t be charged yet',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  bool _canProceed(BookingProvider provider) {
    if (provider.isLoading) return false;
    if (!_agreeToTerms) return false;
    if (widget.event.ticketPrice > 0 && _selectedPaymentMethod == null) {
      return false;
    }
    return true;
  }

  Future<void> _confirmBooking(BookingProvider bookingProvider) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    if (userProvider.user == null) return;

    final success = await bookingProvider.bookTickets(
      eventId: widget.event.id,
      userName: userProvider.user!.fullName,
      eventTitle: widget.event.title,
      eventDate: widget.event.dateTime,
      eventImage: widget.event.imageUrl,
      quantity: _quantity,
    );

    if (success && mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => BookingConfirmationScreen(
            event: widget.event,
            quantity: _quantity,
            totalPrice: widget.event.ticketPrice * _quantity,
          ),
        ),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(bookingProvider.error ?? 'Booking failed'),
          backgroundColor: AppColors.error,
        ),
      );
      bookingProvider.clearError();
    }
  }
}
