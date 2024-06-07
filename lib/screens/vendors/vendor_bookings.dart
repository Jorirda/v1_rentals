import 'package:flutter/material.dart';
import 'package:v1_rentals/services/auth_service.dart';
import 'package:v1_rentals/models/booking_model.dart';
import 'package:v1_rentals/models/user_model.dart';
import 'package:v1_rentals/screens/vendors/requests_booking.dart';
import 'package:v1_rentals/screens/vendors/vendor_booking_details.dart';
import 'package:v1_rentals/generated/l10n.dart';

class VendorBookings extends StatefulWidget {
  const VendorBookings({super.key});

  @override
  _VendorBookingsState createState() => _VendorBookingsState();
}

class _VendorBookingsState extends State<VendorBookings>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  Future<Map<String, dynamic>> getVendorInfo(String vendorId) async {
    CustomUser? userData = await AuthService().getUserData(vendorId);
    String businessName = userData.businessName ?? 'Unknown Business';
    String? imageUrl = userData.imageURL;
    return {'businessName': businessName, 'imageUrl': imageUrl};
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(S.of(context).my_bookings),
        actions: [
          TextButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const RequestedBookingsScreen()));
              },
              child: Text(S.of(context).manage_requests))
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: S.of(context).all),
            Tab(text: S.of(context).ongoing),
            Tab(text: S.of(context).completed),
            Tab(text: S.of(context).cancelled),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          buildBookingList(BookingStatus.all),
          buildBookingList(BookingStatus.inProgress),
          buildBookingList(BookingStatus.completed),
          buildBookingList(BookingStatus.cancelled),
        ],
      ),
    );
  }

  Widget buildBookingList(BookingStatus status) {
    return StreamBuilder<List<Booking>>(
      stream: AuthService().getVendorBookingsStream(status),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text(S.of(context).no_bookings_found));
        }
        return ListView.builder(
          itemCount: snapshot.data!.length,
          itemBuilder: (context, index) {
            final booking = snapshot.data![index];
            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        VendorBookingDetailsScreen(booking: booking),
                  ),
                );
              },
              child: Card(
                elevation: 2,
                margin: const EdgeInsets.all(20),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FutureBuilder<Map<String, dynamic>>(
                        future: getVendorInfo(booking.vendorId),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const CircularProgressIndicator();
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
                                      '${booking.status}'
                                          .toString()
                                          .split('.')
                                          .last,
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
                                  style: const TextStyle(color: Colors.grey),
                                ),
                                const SizedBox(
                                  height: 5,
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
                            "${S.of(context).total_price}: ",
                            style: const TextStyle(
                                fontSize: 15, fontWeight: FontWeight.w600),
                          ),
                          Text(
                            '\$${booking.totalPrice.toStringAsFixed(2)}',
                            style: const TextStyle(color: Colors.red, fontSize: 20),
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
