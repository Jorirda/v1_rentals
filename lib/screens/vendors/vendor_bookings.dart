import 'package:flutter/material.dart';
import 'package:v1_rentals/auth/auth_service.dart';
import 'package:v1_rentals/models/booking_model.dart';

class VendorBookings extends StatelessWidget {
  const VendorBookings({Key? key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4, // Number of tabs
      child: Scaffold(
        appBar: AppBar(
          title: Text('My Bookings'),
          bottom: TabBar(
            tabs: [
              Tab(text: 'All'),
              Tab(text: 'Completed'),
              Tab(text: 'Requested'),
              Tab(text: 'Cancelled'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            buildBookingList(BookingStatus.all),
            buildBookingList(BookingStatus.completed),
            buildBookingList(BookingStatus.pending),
            buildBookingList(BookingStatus.cancelled),
          ],
        ),
      ),
    );
  }

  Widget buildBookingList(BookingStatus status) {
    return StreamBuilder<List<Booking>>(
      stream: AuthService().getVendorBookingsStream(status),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text('No bookings found.'));
        }
        return ListView.builder(
          itemCount: snapshot.data!.length,
          itemBuilder: (context, index) {
            final booking = snapshot.data![index];
            return GestureDetector(
              onTap: () {
                // Navigate to a new page to display booking details
                // Navigator.push(
                //   context,
                //   MaterialPageRoute(
                //     builder: (context) => BookingDetailsPage(booking: booking),
                //   ),
                // );
              },
              child: ListTile(
                title: Text('Booking ID: ${booking.id}'),
                subtitle: Text('Vehicle ID: ${booking.vehicleId}'),
                // Add more details here as needed
              ),
            );
          },
        );
      },
    );
  }
}
