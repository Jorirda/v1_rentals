import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:v1_rentals/auth/auth_service.dart';
import 'package:v1_rentals/models/user_model.dart';
import 'package:v1_rentals/models/vehicle_model.dart';

class CarDetailsScreen extends StatefulWidget {
  final Vehicle vehicle;

  const CarDetailsScreen(this.vehicle, {Key? key}) : super(key: key);

  @override
  _CarDetailsScreenState createState() => _CarDetailsScreenState();
}

class _CarDetailsScreenState extends State<CarDetailsScreen>
    with SingleTickerProviderStateMixin {
  bool isFavorite = false;
  late TabController tabController;
  late List<Map<String, dynamic>> features;
  CustomUser? vendor;
  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 2, vsync: this);
    fetchVendorInfo();
    features = [
      {
        'title': 'Car Type',
        'icon': Icons.directions_car,
        'subtitle': widget.vehicle.getCarTypeString(),
      },
      {
        'title': 'Seats',
        'icon': Icons.event_seat,
        'subtitle': '${widget.vehicle.seats} seats',
      },
      {
        'title': 'Fuel Type',
        'icon': Icons.local_gas_station,
        'subtitle': widget.vehicle.getFuelTypeString(),
      },
      {
        'title': 'Transmission Type',
        'icon': Icons.settings,
        'subtitle': widget.vehicle.getTransmissionTypeString(),
      },
    ];
  }

  // Method to fetch vendor information
  Future<void> fetchVendorInfo() async {
    try {
      CustomUser? vendorData =
          await AuthService().getUserData(widget.vehicle.vendorId);
      setState(() {
        vendor = vendorData;
      });
    } catch (e) {
      print('Error fetching vendor information: $e');
    }
  }

  // Widget to display vendor information
  Widget buildVendorInfo() {
    if (vendor != null) {
      return Card(
        color: Theme.of(context).colorScheme.primary,
        margin: const EdgeInsets.all(16.0),
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              CircleAvatar(
                radius: 40,
                backgroundColor: Colors.grey,
                child: vendor?.imageURL != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(45),
                        child: Image.network(
                          vendor!.imageURL!,
                          width: 90,
                          height: 90,
                          fit: BoxFit.cover,
                        ),
                      )
                    : Text(
                        vendor?.fullname?[0].toUpperCase() ?? "",
                        style: const TextStyle(fontSize: 18),
                      ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      vendor!.fullname,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      vendor!.businessName ?? 'No Business Name',
                      style: TextStyle(
                        color: Colors.grey[300],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    } else {
      // Show loading indicator or placeholder while fetching vendor information
      return CircularProgressIndicator();
    }
  }

  @override
  void dispose() {
    tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 350.0,
            pinned: true,
            stretch: true,
            automaticallyImplyLeading: false,
            leading: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.5),
                      spreadRadius: 1,
                      blurRadius: 5,
                      offset:
                          Offset(0, 3), // changes the position of the shadow
                    ),
                  ],
                ),
                child: IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: Icon(Icons.arrow_back, color: Colors.white),
                ),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: ClipRRect(
                child: Image.network(
                  widget.vehicle.imageUrl ?? '',
                  fit: BoxFit.cover,
                ),
              ),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.5),
                        spreadRadius: 1,
                        blurRadius: 5,
                        offset:
                            Offset(0, 3), // changes the position of the shadow
                      ),
                    ],
                  ),
                  child: IconButton(
                    onPressed: () {
                      setState(() {
                        isFavorite = !isFavorite;
                      });
                    },
                    icon: isFavorite
                        ? Icon(Icons.favorite, color: Colors.red)
                        : Icon(Icons.favorite_outline, color: Colors.white),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.5),
                        spreadRadius: 1,
                        blurRadius: 5,
                        offset:
                            Offset(0, 3), // changes the position of the shadow
                      ),
                    ],
                  ),
                  child: IconButton(
                    onPressed: () {
                      // Add your action here
                    },
                    icon: Icon(Icons.share, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
          SliverList(
            delegate: SliverChildListDelegate(
              [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '\$${widget.vehicle.pricePerDay}/Day',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 25,
                                color: Colors.red),
                          ),
                          Row(
                            children: [
                              Text(
                                widget.vehicle.rating.toString(),
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 20,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Icon(
                                Icons.star,
                                color: Colors.yellow,
                              ),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(height: 10),
                      Text(
                        widget.vehicle.brand,
                        style: TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        widget.vehicle.overview,
                        maxLines: 3,
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(5),
                  child: TabBar(
                    unselectedLabelColor: Colors.grey,
                    labelColor: Colors.black,
                    indicatorColor: Theme.of(context).colorScheme.primary,
                    indicatorWeight: 2,
                    controller: tabController,
                    tabs: const [
                      Tab(text: 'Features'),
                      Tab(text: 'Reviews'),
                    ],
                  ),
                ),

                SizedBox(
                  height: (features.length / 2).ceil() *
                      150.0, // calculates the height dynamically based on the number of features in your list. Adjust the 120.0 value according to your UI requirements.
                  child: TabBarView(
                    controller: tabController,
                    children: [
                      SingleChildScrollView(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Wrap(
                                spacing: 16.0,
                                runSpacing: 16.0,
                                children: features.map((feature) {
                                  return SizedBox(
                                    width:
                                        MediaQuery.of(context).size.width / 2 -
                                            24,
                                    child: Card(
                                      elevation: 3,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Container(
                                        padding:
                                            EdgeInsets.symmetric(vertical: 15),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              feature['icon'],
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .primary,
                                            ),
                                            SizedBox(height: 8),
                                            Text(
                                              feature['title'],
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            Text(
                                              feature['subtitle'],
                                              style: TextStyle(
                                                color: Colors.grey,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Center(
                        child: Text('Tab 2 Content'),
                      ),
                    ],
                  ),
                ),
                // Card with vendor information
                // Card(
                //   color: Colors.white,
                //   margin: const EdgeInsets.all(16.0),
                //   elevation: 3,
                //   shape: RoundedRectangleBorder(
                //     borderRadius: BorderRadius.circular(10),
                //   ),
                //   child: const Padding(
                //     padding: const EdgeInsets.all(16.0),
                //     child: Row(
                //       children: [
                //         CircleAvatar(
                //           radius: 30,
                //           // backgroundImage: NetworkImage(
                //           //     widget.vehicle.vendorImageUrl ?? ''),
                //         ),
                //         const SizedBox(width: 16),
                //         Expanded(
                //           child: Column(
                //             crossAxisAlignment: CrossAxisAlignment.start,
                //             children: [
                //               Text(
                //                 'Vendor Name',
                //                 style: TextStyle(
                //                   fontWeight: FontWeight.bold,
                //                   fontSize: 16,
                //                 ),
                //               ),
                //               const SizedBox(height: 8),
                //               Text(
                //                 'Vendor Business Name',
                //                 style: TextStyle(
                //                   color: Colors.grey,
                //                 ),
                //               ),
                //             ],
                //           ),
                //         ),
                //       ],
                //     ),
                //   ),
                // ),
                buildVendorInfo(), // Display vendor information widget
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        height: 100, // Adjust height as needed
        color: Colors.white,
        child: Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.5),
                spreadRadius: 1,
                blurRadius: 5,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.storefront),
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const Text(
                    'Store',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  IconButton(
                    onPressed: () {},
                    icon: Icon(
                      Icons.phone,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const Text(
                    'Call',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  IconButton(
                    onPressed: () {},
                    icon: Icon(
                      Icons.chat_outlined,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const Text(
                    'Chat',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              SizedBox(
                width: 30,
              ),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    // Add your booking logic here
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        vertical: 16, horizontal: 32),
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text('Book Now'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
