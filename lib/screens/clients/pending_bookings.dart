import 'package:flutter/material.dart';
import 'package:v1_rentals/services/auth_service.dart';
import 'package:v1_rentals/models/booking_model.dart';
import 'package:v1_rentals/models/user_model.dart';
import 'package:v1_rentals/screens/clients/client_booking_details.dart';
import 'package:v1_rentals/generated/l10n.dart';

class PendingBookingsScreen extends StatelessWidget {
  const PendingBookingsScreen({super.key});

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
        title: Text(S.of(context).pending_request),
      ),
      body: StreamBuilder<List<Booking>>(
        stream:
            AuthService().getCurrentUserBookingsStream(BookingStatus.pending),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
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
                              String imageUrl =
                                  snapshot.data?['imageUrl'] ?? '';
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
                                        booking.getBookingStatusString(),
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .primary),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 10),
                                  Text(
                                    '${booking.createdAt}',
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                  SizedBox(
                                    height: 5,
                                  ),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.arrow_circle_up_sharp,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary,
                                      ),
                                      SizedBox(
                                        width: 5,
                                      ),
                                      Text('${booking.pickupLocation}')
                                    ],
                                  ),
                                  SizedBox(
                                    height: 5,
                                  ),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.arrow_circle_down_sharp,
                                        color: Colors.red,
                                      ),
                                      SizedBox(
                                        width: 5,
                                      ),
                                      Text('${booking.dropoffLocation}')
                                    ],
                                  )
                                  // Container(
                                  //   height: 200,
                                  //   decoration: BoxDecoration(
                                  //     borderRadius: BorderRadius.circular(8),
                                  //     image: DecorationImage(
                                  //       image: NetworkImage(booking.imageUrl),
                                  //       fit: BoxFit.cover,
                                  //     ),
                                  //   ),
                                  // ),
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
                              '${S.of(context).total_price} :',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Spacer(),
                            Text(
                              'USD\$${booking.totalPrice.toStringAsFixed(2)}',
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
      ),
    );
  }
}
