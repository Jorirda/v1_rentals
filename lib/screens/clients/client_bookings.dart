import 'package:flutter/material.dart';
import 'package:v1_rentals/services/auth_service.dart';
import 'package:v1_rentals/models/booking_model.dart';
import 'package:v1_rentals/models/user_model.dart';
import 'package:v1_rentals/screens/clients/client_booking_details.dart';
import 'package:v1_rentals/screens/clients/pending_bookings.dart';

import 'package:v1_rentals/generated/l10n.dart';
import 'package:v1_rentals/widgets/shimmer_widget.dart';

class ClientBookings extends StatelessWidget {
  const ClientBookings({Key? key});

  Future<Map<String, dynamic>> getVendorInfo(String vendorId) async {
    CustomUser? userData = await AuthService().getUserData(vendorId);
    String businessName = userData.businessName ?? 'Unknown Business';
    String? imageUrl = userData.imageURL;
    return {'businessName': businessName, 'imageUrl': imageUrl};
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 5, // Number of tabs
      child: Scaffold(
        appBar: AppBar(
          title: Text(S.of(context).my_bookings), // Translate title
          actions: [
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PendingBookingsScreen(),
                  ),
                );
              },
              child: Text(S
                  .of(context)
                  .manage_pending_requests), // Translate button text
            )
          ],
          bottom: TabBar(
            isScrollable: true,
            tabs: [
              Tab(text: S.of(context).all), // Translate tab texts
              Tab(text: S.of(context).accepted),
              Tab(text: S.of(context).ongoing),
              Tab(text: S.of(context).completed),
              Tab(text: S.of(context).cancelled),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            buildBookingList(BookingStatus.all),
            buildBookingList(BookingStatus.accepted), // Pass locale provider
            buildBookingList(
              BookingStatus.inProgress,
            ),
            buildBookingList(
              BookingStatus.completed,
            ),
            buildBookingList(
              BookingStatus.cancelled,
            ),
          ],
        ),
      ),
    );
  }

  Widget buildBookingList(BookingStatus status) {
    return StreamBuilder<List<Booking>>(
      stream: AuthService().getCurrentUserBookingsStream(status),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: ShimmerWidget());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(
              child: Text(S
                  .of(context)
                  .no_bookings_found)); // Translate no bookings found message
        }
        return ListView.builder(
          itemCount: snapshot.data!.length,
          itemBuilder: (context, index) {
            final booking = snapshot.data![snapshot.data!.length - 1 - index];
            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        ClientBookingDetailsScreen(booking: booking),
                  ),
                );
              },
              child: Card(
                elevation: 2,
                margin: EdgeInsets.all(20),
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FutureBuilder<Map<String, dynamic>>(
                        future: getVendorInfo(booking.vendorId),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return CircularProgressIndicator();
                          } else if (snapshot.hasError) {
                            return Text('Error: ${snapshot.error}');
                          } else {
                            String businessName =
                                snapshot.data?['businessName'] ?? '';
                            String imageUrl = snapshot.data?['imageUrl'] ?? '';
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    CircleAvatar(
                                      radius: 20,
                                      backgroundColor: Colors.grey,
                                      backgroundImage: imageUrl != null
                                          ? NetworkImage(imageUrl)
                                          : null,
                                    ),
                                    const SizedBox(
                                      width: 5,
                                    ),
                                    Text(
                                      businessName,
                                      style: const TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w600),
                                    ),
                                    const Spacer(),
                                    Text(
                                      booking.getBookingStatusString(),
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .primary),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  '${booking.createdAt}',
                                  style: TextStyle(color: Colors.grey),
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.arrow_circle_up_sharp,
                                      color:
                                          Theme.of(context).colorScheme.primary,
                                    ),
                                    const SizedBox(
                                      width: 5,
                                    ),
                                    Text(booking.pickupLocation)
                                  ],
                                ),
                                const SizedBox(
                                  height: 5,
                                ),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.arrow_circle_down_sharp,
                                      color: Colors.red,
                                    ),
                                    const SizedBox(
                                      width: 5,
                                    ),
                                    Text(booking.dropoffLocation)
                                  ],
                                )
                              ],
                            );
                          }
                        },
                      ),
                      const SizedBox(height: 10),
                      const Divider(),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Text(
                            "${S.of(context).total_price}: ", // Translate total price label
                            style: const TextStyle(
                                fontSize: 20, fontWeight: FontWeight.w600),
                          ),
                          Spacer(),
                          Text(
                            'USD\$${booking.totalPrice.toStringAsFixed(2)}',
                            style: const TextStyle(
                                color: Colors.red, fontSize: 20),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
