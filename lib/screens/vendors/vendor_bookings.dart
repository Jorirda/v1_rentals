import 'package:flutter/material.dart';
import 'package:v1_rentals/auth/auth_service.dart';
import 'package:v1_rentals/models/booking_model.dart';
import 'package:v1_rentals/models/user_model.dart';
import 'package:v1_rentals/screens/vendors/requests_booking.dart';
import 'package:v1_rentals/screens/vendors/vendor_booking_details.dart';

class VendorBookings extends StatefulWidget {
  const VendorBookings({Key? key}) : super(key: key);

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
    String businessName = userData?.businessName ?? 'Unknown Business';
    String? imageUrl = userData?.imageURL;
    return {'businessName': businessName, 'imageUrl': imageUrl};
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Bookings'),
        actions: [
          TextButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => RequestedBookingsScreen()));
              },
              child: Text('Manage Requests'))
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'All'),
            Tab(text: 'Ongoing'),
            Tab(text: 'Completed'),
            Tab(text: 'Cancelled'),
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
                                    SizedBox(
                                      width: 5,
                                    ),
                                    Text(
                                      '$businessName',
                                      style: TextStyle(
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
                                SizedBox(height: 10),
                                Container(
                                  height: 200,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    image: DecorationImage(
                                      image: NetworkImage(booking.imageUrl),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              ],
                            );
                          }
                        },
                      ),
                      SizedBox(height: 10),
                      Divider(),
                      SizedBox(height: 10),
                      Row(
                        children: [
                          Text(
                            'Total Price: ',
                            style: TextStyle(
                                fontSize: 15, fontWeight: FontWeight.w600),
                          ),
                          Text(
                            '\$${booking.totalPrice.toStringAsFixed(2)}',
                            style: TextStyle(color: Colors.red, fontSize: 20),
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
