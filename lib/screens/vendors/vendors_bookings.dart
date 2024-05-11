import 'package:flutter/material.dart';

class VendorMyBookings extends StatefulWidget {
  const VendorMyBookings({Key? key}) : super(key: key);

  @override
  _VendorMyBookingsState createState() => _VendorMyBookingsState();
}

class _VendorMyBookingsState extends State<VendorMyBookings>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Bookings'),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'All'),
            Tab(text: 'Completed'),
            Tab(text: 'Cancelled'),
            Tab(text: 'Requests'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // All bookings
          _buildBookingsList('All Bookings'),
          // Completed bookings
          _buildBookingsList('Completed Bookings'),
          // Cancelled bookings
          _buildBookingsList('Cancelled Bookings'),
          // Booking requests
          _buildBookingsList('Booking Requests'),
        ],
      ),
    );
  }

  Widget _buildBookingsList(String title) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            title,
            style: TextStyle(fontSize: 24),
          ),
          // Add widgets to display vendor's bookings based on the title
        ],
      ),
    );
  }
}
