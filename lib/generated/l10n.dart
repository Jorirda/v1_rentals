// GENERATED CODE - DO NOT MODIFY BY HAND
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'intl/messages_all.dart';

// **************************************************************************
// Generator: Flutter Intl IDE plugin
// Made by Localizely
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, lines_longer_than_80_chars
// ignore_for_file: join_return_with_assignment, prefer_final_in_for_each
// ignore_for_file: avoid_redundant_argument_values, avoid_escaping_inner_quotes

class S {
  S();

  static S? _current;

  static S get current {
    assert(_current != null,
        'No instance of S was loaded. Try to initialize the S delegate before accessing S.current.');
    return _current!;
  }

  static const AppLocalizationDelegate delegate = AppLocalizationDelegate();

  static Future<S> load(Locale locale) {
    final name = (locale.countryCode?.isEmpty ?? false)
        ? locale.languageCode
        : locale.toString();
    final localeName = Intl.canonicalizedLocale(name);
    return initializeMessages(localeName).then((_) {
      Intl.defaultLocale = localeName;
      final instance = S();
      S._current = instance;

      return instance;
    });
  }

  static S of(BuildContext context) {
    final instance = S.maybeOf(context);
    assert(instance != null,
        'No instance of S present in the widget tree. Did you add S.delegate in localizationsDelegates?');
    return instance!;
  }

  static S? maybeOf(BuildContext context) {
    return Localizations.of<S>(context, S);
  }

  /// `V1 Rentals`
  String get title {
    return Intl.message(
      'V1 Rentals',
      name: 'title',
      desc: '',
      args: [],
    );
  }

  /// `Home`
  String get home {
    return Intl.message(
      'Home',
      name: 'home',
      desc: '',
      args: [],
    );
  }

  /// `Favorites`
  String get favorites {
    return Intl.message(
      'Favorites',
      name: 'favorites',
      desc: '',
      args: [],
    );
  }

  /// `Fleet`
  String get fleet {
    return Intl.message(
      'Fleet',
      name: 'fleet',
      desc: '',
      args: [],
    );
  }

  /// `Bookings`
  String get bookings {
    return Intl.message(
      'Bookings',
      name: 'bookings',
      desc: '',
      args: [],
    );
  }

  /// `Account`
  String get account {
    return Intl.message(
      'Account',
      name: 'account',
      desc: '',
      args: [],
    );
  }

  /// `Settings`
  String get settings {
    return Intl.message(
      'Settings',
      name: 'settings',
      desc: '',
      args: [],
    );
  }

  /// `Email`
  String get email {
    return Intl.message(
      'Email',
      name: 'email',
      desc: '',
      args: [],
    );
  }

  /// `Please enter your email`
  String get please_enter_your_email {
    return Intl.message(
      'Please enter your email',
      name: 'please_enter_your_email',
      desc: '',
      args: [],
    );
  }

  /// `Password`
  String get password {
    return Intl.message(
      'Password',
      name: 'password',
      desc: '',
      args: [],
    );
  }

  /// `Please enter your password`
  String get please_enter_your_password {
    return Intl.message(
      'Please enter your password',
      name: 'please_enter_your_password',
      desc: '',
      args: [],
    );
  }

  /// `Login`
  String get login {
    return Intl.message(
      'Login',
      name: 'login',
      desc: '',
      args: [],
    );
  }

  /// `Not a member?`
  String get not_a_member {
    return Intl.message(
      'Not a member?',
      name: 'not_a_member',
      desc: '',
      args: [],
    );
  }

  /// `No favorites found.`
  String get no_favorites_found {
    return Intl.message(
      'No favorites found.',
      name: 'no_favorites_found',
      desc: '',
      args: [],
    );
  }

  /// `Register now`
  String get register_now {
    return Intl.message(
      'Register now',
      name: 'register_now',
      desc: '',
      args: [],
    );
  }

  /// `English`
  String get english {
    return Intl.message(
      'English',
      name: 'english',
      desc: '',
      args: [],
    );
  }

  /// `Chinese`
  String get chinese {
    return Intl.message(
      'Chinese',
      name: 'chinese',
      desc: '',
      args: [],
    );
  }

  /// `Full Name`
  String get full_name {
    return Intl.message(
      'Full Name',
      name: 'full_name',
      desc: '',
      args: [],
    );
  }

  /// `Phone Number`
  String get phone_number {
    return Intl.message(
      'Phone Number',
      name: 'phone_number',
      desc: '',
      args: [],
    );
  }

  /// `Address`
  String get address {
    return Intl.message(
      'Address',
      name: 'address',
      desc: '',
      args: [],
    );
  }

  /// `Date of Birth`
  String get date_of_birth {
    return Intl.message(
      'Date of Birth',
      name: 'date_of_birth',
      desc: '',
      args: [],
    );
  }

  /// `Expiry Date`
  String get expiry_date {
    return Intl.message(
      'Expiry Date',
      name: 'expiry_date',
      desc: '',
      args: [],
    );
  }

  /// `Driver's License Number`
  String get driver_license_number {
    return Intl.message(
      'Driver\'s License Number',
      name: 'driver_license_number',
      desc: '',
      args: [],
    );
  }

  /// `Issuing Country`
  String get issuing_country {
    return Intl.message(
      'Issuing Country',
      name: 'issuing_country',
      desc: '',
      args: [],
    );
  }

  /// `Business Name`
  String get business_name {
    return Intl.message(
      'Business Name',
      name: 'business_name',
      desc: '',
      args: [],
    );
  }

  /// `Business Registration Number`
  String get business_registration_number {
    return Intl.message(
      'Business Registration Number',
      name: 'business_registration_number',
      desc: '',
      args: [],
    );
  }

  /// `Tax Identification Number`
  String get tax_identification_number {
    return Intl.message(
      'Tax Identification Number',
      name: 'tax_identification_number',
      desc: '',
      args: [],
    );
  }

  /// `Create Account`
  String get create_account {
    return Intl.message(
      'Create Account',
      name: 'create_account',
      desc: '',
      args: [],
    );
  }

  /// `Select a user type and register below with your details.`
  String get select_user_type {
    return Intl.message(
      'Select a user type and register below with your details.',
      name: 'select_user_type',
      desc: '',
      args: [],
    );
  }

  /// `Sign Up`
  String get sign_up {
    return Intl.message(
      'Sign Up',
      name: 'sign_up',
      desc: '',
      args: [],
    );
  }

  /// `Client`
  String get client {
    return Intl.message(
      'Client',
      name: 'client',
      desc: '',
      args: [],
    );
  }

  /// `Vendor`
  String get vendor {
    return Intl.message(
      'Vendor',
      name: 'vendor',
      desc: '',
      args: [],
    );
  }

  /// `Already a member?`
  String get already_member {
    return Intl.message(
      'Already a member?',
      name: 'already_member',
      desc: '',
      args: [],
    );
  }

  /// `Add or edit photo or avatar`
  String get add_or_edit_photo {
    return Intl.message(
      'Add or edit photo or avatar',
      name: 'add_or_edit_photo',
      desc: '',
      args: [],
    );
  }

  /// `Save Changes`
  String get save_changes {
    return Intl.message(
      'Save Changes',
      name: 'save_changes',
      desc: '',
      args: [],
    );
  }

  /// `Please enter your {field}`
  String please_enter_your(Object field) {
    return Intl.message(
      'Please enter your $field',
      name: 'please_enter_your',
      desc: '',
      args: [field],
    );
  }

  /// `Account`
  String get account_screen_title {
    return Intl.message(
      'Account',
      name: 'account_screen_title',
      desc: '',
      args: [],
    );
  }

  /// `Edit Account`
  String get edit_account_button {
    return Intl.message(
      'Edit Account',
      name: 'edit_account_button',
      desc: '',
      args: [],
    );
  }

  /// `Something went wrong`
  String get user_data_error {
    return Intl.message(
      'Something went wrong',
      name: 'user_data_error',
      desc: '',
      args: [],
    );
  }

  /// `No Data Found`
  String get user_data_not_found {
    return Intl.message(
      'No Data Found',
      name: 'user_data_not_found',
      desc: '',
      args: [],
    );
  }

  /// `Edit Account`
  String get edit_account {
    return Intl.message(
      'Edit Account',
      name: 'edit_account',
      desc: '',
      args: [],
    );
  }

  /// `Address Book`
  String get address_book {
    return Intl.message(
      'Address Book',
      name: 'address_book',
      desc: '',
      args: [],
    );
  }

  /// `Payment Options`
  String get payment_options {
    return Intl.message(
      'Payment Options',
      name: 'payment_options',
      desc: '',
      args: [],
    );
  }

  /// `Language`
  String get language {
    return Intl.message(
      'Language',
      name: 'language',
      desc: '',
      args: [],
    );
  }

  /// `Select your preferred language`
  String get select_language {
    return Intl.message(
      'Select your preferred language',
      name: 'select_language',
      desc: '',
      args: [],
    );
  }

  /// `Help`
  String get help {
    return Intl.message(
      'Help',
      name: 'help',
      desc: '',
      args: [],
    );
  }

  /// `Logout`
  String get logout {
    return Intl.message(
      'Logout',
      name: 'logout',
      desc: '',
      args: [],
    );
  }

  /// `No User Logged In`
  String get no_user_logged_in {
    return Intl.message(
      'No User Logged In',
      name: 'no_user_logged_in',
      desc: '',
      args: [],
    );
  }

  /// `Something went wrong`
  String get something_went_wrong {
    return Intl.message(
      'Something went wrong',
      name: 'something_went_wrong',
      desc: '',
      args: [],
    );
  }

  /// `No Data Found`
  String get no_data_found {
    return Intl.message(
      'No Data Found',
      name: 'no_data_found',
      desc: '',
      args: [],
    );
  }

  /// `Hello`
  String get hello {
    return Intl.message(
      'Hello',
      name: 'hello',
      desc: '',
      args: [],
    );
  }

  /// `Search for your favorite vehicle`
  String get search_for_favorite_vehicle {
    return Intl.message(
      'Search for your favorite vehicle',
      name: 'search_for_favorite_vehicle',
      desc: '',
      args: [],
    );
  }

  /// `Your location`
  String get your_location {
    return Intl.message(
      'Your location',
      name: 'your_location',
      desc: '',
      args: [],
    );
  }

  /// `Search for vehicles`
  String get search_for_vehicles {
    return Intl.message(
      'Search for vehicles',
      name: 'search_for_vehicles',
      desc: '',
      args: [],
    );
  }

  /// `Search for locations`
  String get search_for_locations {
    return Intl.message(
      'Search for locations',
      name: 'search_for_locations',
      desc: '',
      args: [],
    );
  }

  /// `Set pick-up and drop-off as the same location`
  String get set_pickup_drop_off {
    return Intl.message(
      'Set pick-up and drop-off as the same location',
      name: 'set_pickup_drop_off',
      desc: '',
      args: [],
    );
  }

  /// `Locations`
  String get locations {
    return Intl.message(
      'Locations',
      name: 'locations',
      desc: '',
      args: [],
    );
  }

  /// `Confirm your selection`
  String get confirm_your_selection {
    return Intl.message(
      'Confirm your selection',
      name: 'confirm_your_selection',
      desc: '',
      args: [],
    );
  }

  /// `Recommended Brands`
  String get recommended_brands {
    return Intl.message(
      'Recommended Brands',
      name: 'recommended_brands',
      desc: '',
      args: [],
    );
  }

  /// `View All`
  String get view_all {
    return Intl.message(
      'View All',
      name: 'view_all',
      desc: '',
      args: [],
    );
  }

  /// `All Vehicles in Collection`
  String get all_vehicles_in_collection {
    return Intl.message(
      'All Vehicles in Collection',
      name: 'all_vehicles_in_collection',
      desc: '',
      args: [],
    );
  }

  /// `My Bookings`
  String get my_bookings {
    return Intl.message(
      'My Bookings',
      name: 'my_bookings',
      desc: '',
      args: [],
    );
  }

  /// `All`
  String get all {
    return Intl.message(
      'All',
      name: 'all',
      desc: '',
      args: [],
    );
  }

  /// `Ongoing`
  String get ongoing {
    return Intl.message(
      'Ongoing',
      name: 'ongoing',
      desc: '',
      args: [],
    );
  }

  /// `Completed`
  String get completed {
    return Intl.message(
      'Completed',
      name: 'completed',
      desc: '',
      args: [],
    );
  }

  /// `Cancelled`
  String get cancelled {
    return Intl.message(
      'Cancelled',
      name: 'cancelled',
      desc: '',
      args: [],
    );
  }

  /// `Decline`
  String get decline {
    return Intl.message(
      'Decline',
      name: 'decline',
      desc: '',
      args: [],
    );
  }

  /// `Total Price`
  String get total_price {
    return Intl.message(
      'Total Price',
      name: 'total_price',
      desc: '',
      args: [],
    );
  }

  /// `Manage Pending Requests`
  String get manage_pending_requests {
    return Intl.message(
      'Manage Pending Requests',
      name: 'manage_pending_requests',
      desc: '',
      args: [],
    );
  }

  /// `Manage Requests`
  String get manage_requests {
    return Intl.message(
      'Manage Requests',
      name: 'manage_requests',
      desc: '',
      args: [],
    );
  }

  /// `No bookings found.`
  String get no_bookings_found {
    return Intl.message(
      'No bookings found.',
      name: 'no_bookings_found',
      desc: '',
      args: [],
    );
  }

  /// `Booking ID`
  String get booking_id {
    return Intl.message(
      'Booking ID',
      name: 'booking_id',
      desc: '',
      args: [],
    );
  }

  /// `Rental Vehicle`
  String get rental_vehicle {
    return Intl.message(
      'Rental Vehicle',
      name: 'rental_vehicle',
      desc: '',
      args: [],
    );
  }

  /// `Renter`
  String get renter {
    return Intl.message(
      'Renter',
      name: 'renter',
      desc: '',
      args: [],
    );
  }

  /// `Rental Details`
  String get rental_details {
    return Intl.message(
      'Rental Details',
      name: 'rental_details',
      desc: '',
      args: [],
    );
  }

  /// `Pick-up`
  String get pick_up {
    return Intl.message(
      'Pick-up',
      name: 'pick_up',
      desc: '',
      args: [],
    );
  }

  /// `Drop-off`
  String get drop_off {
    return Intl.message(
      'Drop-off',
      name: 'drop_off',
      desc: '',
      args: [],
    );
  }

  /// `Pick-up Time`
  String get pickup_time {
    return Intl.message(
      'Pick-up Time',
      name: 'pickup_time',
      desc: '',
      args: [],
    );
  }

  /// `Pick-up Date`
  String get pickup_date {
    return Intl.message(
      'Pick-up Date',
      name: 'pickup_date',
      desc: '',
      args: [],
    );
  }

  /// `Drop-off Time`
  String get dropoff_time {
    return Intl.message(
      'Drop-off Time',
      name: 'dropoff_time',
      desc: '',
      args: [],
    );
  }

  /// `Drop-off Date`
  String get dropoff_date {
    return Intl.message(
      'Drop-off Date',
      name: 'dropoff_date',
      desc: '',
      args: [],
    );
  }

  /// `Pick-up Location`
  String get pick_up_location {
    return Intl.message(
      'Pick-up Location',
      name: 'pick_up_location',
      desc: '',
      args: [],
    );
  }

  /// `Set Pickup Location`
  String get set_pickup_location {
    return Intl.message(
      'Set Pickup Location',
      name: 'set_pickup_location',
      desc: '',
      args: [],
    );
  }

  /// `Drop-off Location`
  String get drop_off_location {
    return Intl.message(
      'Drop-off Location',
      name: 'drop_off_location',
      desc: '',
      args: [],
    );
  }

  /// `Set Dropoff Location`
  String get set_dropoff_location {
    return Intl.message(
      'Set Dropoff Location',
      name: 'set_dropoff_location',
      desc: '',
      args: [],
    );
  }

  /// `Reserve`
  String get reserve {
    return Intl.message(
      'Reserve',
      name: 'reserve',
      desc: '',
      args: [],
    );
  }

  /// `Payment`
  String get payment {
    return Intl.message(
      'Payment',
      name: 'payment',
      desc: '',
      args: [],
    );
  }

  /// `Summary`
  String get summary {
    return Intl.message(
      'Summary',
      name: 'summary',
      desc: '',
      args: [],
    );
  }

  /// `Next`
  String get next {
    return Intl.message(
      'Next',
      name: 'next',
      desc: '',
      args: [],
    );
  }

  /// `Back`
  String get back {
    return Intl.message(
      'Back',
      name: 'back',
      desc: '',
      args: [],
    );
  }

  /// `Your credit and debit cards`
  String get your_credit_debit {
    return Intl.message(
      'Your credit and debit cards',
      name: 'your_credit_debit',
      desc: '',
      args: [],
    );
  }

  /// `Your Fleet`
  String get your_fleet {
    return Intl.message(
      'Your Fleet',
      name: 'your_fleet',
      desc: '',
      args: [],
    );
  }

  /// `Choose a payment method`
  String get choose_payment_method {
    return Intl.message(
      'Choose a payment method',
      name: 'choose_payment_method',
      desc: '',
      args: [],
    );
  }

  /// `ending in`
  String get ending_in {
    return Intl.message(
      'ending in',
      name: 'ending_in',
      desc: '',
      args: [],
    );
  }

  /// `Card Holder`
  String get card_holder {
    return Intl.message(
      'Card Holder',
      name: 'card_holder',
      desc: '',
      args: [],
    );
  }

  /// `Rental Supplier`
  String get rental_supplier {
    return Intl.message(
      'Rental Supplier',
      name: 'rental_supplier',
      desc: '',
      args: [],
    );
  }

  /// `Other payment methods`
  String get other_payment_method {
    return Intl.message(
      'Other payment methods',
      name: 'other_payment_method',
      desc: '',
      args: [],
    );
  }

  /// `Book Your Vehicle`
  String get book_your_vehicle {
    return Intl.message(
      'Book Your Vehicle',
      name: 'book_your_vehicle',
      desc: '',
      args: [],
    );
  }

  /// `Enter pick-up location`
  String get enter_pickup_location {
    return Intl.message(
      'Enter pick-up location',
      name: 'enter_pickup_location',
      desc: '',
      args: [],
    );
  }

  /// `Enter drop-off location`
  String get enter_dropoff_location {
    return Intl.message(
      'Enter drop-off location',
      name: 'enter_dropoff_location',
      desc: '',
      args: [],
    );
  }

  /// `My Location`
  String get my_location {
    return Intl.message(
      'My Location',
      name: 'my_location',
      desc: '',
      args: [],
    );
  }

  /// `History`
  String get history {
    return Intl.message(
      'History',
      name: 'history',
      desc: '',
      args: [],
    );
  }

  /// `Current Location Address`
  String get current_location_address {
    return Intl.message(
      'Current Location Address',
      name: 'current_location_address',
      desc: '',
      args: [],
    );
  }

  /// `Popular Locations`
  String get popular_locations {
    return Intl.message(
      'Popular Locations',
      name: 'popular_locations',
      desc: '',
      args: [],
    );
  }

  /// `Set Address`
  String get set_address {
    return Intl.message(
      'Set Address',
      name: 'set_address',
      desc: '',
      args: [],
    );
  }

  /// `Confirm Pickup Location`
  String get confirm_pickup_location {
    return Intl.message(
      'Confirm Pickup Location',
      name: 'confirm_pickup_location',
      desc: '',
      args: [],
    );
  }

  /// `Confirm Dropoff Location`
  String get confirm_dropoff_location {
    return Intl.message(
      'Confirm Dropoff Location',
      name: 'confirm_dropoff_location',
      desc: '',
      args: [],
    );
  }

  /// `Clear`
  String get clear {
    return Intl.message(
      'Clear',
      name: 'clear',
      desc: '',
      args: [],
    );
  }

  /// `Transaction Details`
  String get transaction_details {
    return Intl.message(
      'Transaction Details',
      name: 'transaction_details',
      desc: '',
      args: [],
    );
  }

  /// `Payment Method`
  String get payment_method {
    return Intl.message(
      'Payment Method',
      name: 'payment_method',
      desc: '',
      args: [],
    );
  }

  /// `Booking Time`
  String get booking_time {
    return Intl.message(
      'Booking Time',
      name: 'booking_time',
      desc: '',
      args: [],
    );
  }

  /// `Booking Details`
  String get booking_details {
    return Intl.message(
      'Booking Details',
      name: 'booking_details',
      desc: '',
      args: [],
    );
  }

  /// `Amount Information`
  String get amount_information {
    return Intl.message(
      'Amount Information',
      name: 'amount_information',
      desc: '',
      args: [],
    );
  }

  /// `Total Rental Price`
  String get total_rental_price {
    return Intl.message(
      'Total Rental Price',
      name: 'total_rental_price',
      desc: '',
      args: [],
    );
  }

  /// `Other services`
  String get other_services {
    return Intl.message(
      'Other services',
      name: 'other_services',
      desc: '',
      args: [],
    );
  }

  /// `Cancel`
  String get cancel {
    return Intl.message(
      'Cancel',
      name: 'cancel',
      desc: '',
      args: [],
    );
  }

  /// `Confirm`
  String get confirm {
    return Intl.message(
      'Confirm',
      name: 'confirm',
      desc: '',
      args: [],
    );
  }

  /// `Edit`
  String get edit {
    return Intl.message(
      'Edit',
      name: 'edit',
      desc: '',
      args: [],
    );
  }

  /// `Pending Requests`
  String get pending_request {
    return Intl.message(
      'Pending Requests',
      name: 'pending_request',
      desc: '',
      args: [],
    );
  }

  /// `All`
  String get carTypeAll {
    return Intl.message(
      'All',
      name: 'carTypeAll',
      desc: '',
      args: [],
    );
  }

  /// `SUV`
  String get carTypeSuv {
    return Intl.message(
      'SUV',
      name: 'carTypeSuv',
      desc: '',
      args: [],
    );
  }

  /// `Sedan`
  String get carTypeSedan {
    return Intl.message(
      'Sedan',
      name: 'carTypeSedan',
      desc: '',
      args: [],
    );
  }

  /// `Truck`
  String get carTypeTruck {
    return Intl.message(
      'Truck',
      name: 'carTypeTruck',
      desc: '',
      args: [],
    );
  }

  /// `Van`
  String get carTypeVan {
    return Intl.message(
      'Van',
      name: 'carTypeVan',
      desc: '',
      args: [],
    );
  }

  /// `Electric`
  String get carTypeElectric {
    return Intl.message(
      'Electric',
      name: 'carTypeElectric',
      desc: '',
      args: [],
    );
  }

  /// `Hybrid`
  String get carTypeHybrid {
    return Intl.message(
      'Hybrid',
      name: 'carTypeHybrid',
      desc: '',
      args: [],
    );
  }

  /// `Hatchback`
  String get carTypeHatchback {
    return Intl.message(
      'Hatchback',
      name: 'carTypeHatchback',
      desc: '',
      args: [],
    );
  }

  /// `Sports`
  String get carTypeSports {
    return Intl.message(
      'Sports',
      name: 'carTypeSports',
      desc: '',
      args: [],
    );
  }

  /// `Luxury`
  String get carTypeLuxury {
    return Intl.message(
      'Luxury',
      name: 'carTypeLuxury',
      desc: '',
      args: [],
    );
  }

  /// `Convertible`
  String get carTypeConvertible {
    return Intl.message(
      'Convertible',
      name: 'carTypeConvertible',
      desc: '',
      args: [],
    );
  }

  /// `Automatic`
  String get transmissionAutomatic {
    return Intl.message(
      'Automatic',
      name: 'transmissionAutomatic',
      desc: '',
      args: [],
    );
  }

  /// `Manual`
  String get transmissionManual {
    return Intl.message(
      'Manual',
      name: 'transmissionManual',
      desc: '',
      args: [],
    );
  }

  /// `Gasoline`
  String get fuelTypeGasoline {
    return Intl.message(
      'Gasoline',
      name: 'fuelTypeGasoline',
      desc: '',
      args: [],
    );
  }

  /// `Diesel`
  String get fuelTypeDiesel {
    return Intl.message(
      'Diesel',
      name: 'fuelTypeDiesel',
      desc: '',
      args: [],
    );
  }

  /// `Electric`
  String get fuelTypeElectric {
    return Intl.message(
      'Electric',
      name: 'fuelTypeElectric',
      desc: '',
      args: [],
    );
  }

  /// `Hybrid`
  String get fuelTypeHybrid {
    return Intl.message(
      'Hybrid',
      name: 'fuelTypeHybrid',
      desc: '',
      args: [],
    );
  }

  /// `Client`
  String get userTypeClient {
    return Intl.message(
      'Client',
      name: 'userTypeClient',
      desc: '',
      args: [],
    );
  }

  /// `Vendor`
  String get userTypeVendor {
    return Intl.message(
      'Vendor',
      name: 'userTypeVendor',
      desc: '',
      args: [],
    );
  }

  /// `All`
  String get bookingStatusAll {
    return Intl.message(
      'All',
      name: 'bookingStatusAll',
      desc: '',
      args: [],
    );
  }

  /// `Completed`
  String get bookingStatusCompleted {
    return Intl.message(
      'Completed',
      name: 'bookingStatusCompleted',
      desc: '',
      args: [],
    );
  }

  /// `Cancelled`
  String get bookingStatusCancelled {
    return Intl.message(
      'Cancelled',
      name: 'bookingStatusCancelled',
      desc: '',
      args: [],
    );
  }

  /// `Pending`
  String get bookingStatusPending {
    return Intl.message(
      'Pending',
      name: 'bookingStatusPending',
      desc: '',
      args: [],
    );
  }

  /// `In Progress`
  String get bookingStatusInProgress {
    return Intl.message(
      'In Progress',
      name: 'bookingStatusInProgress',
      desc: '',
      args: [],
    );
  }

  /// `Booking Accepted`
  String get booking_accepted {
    return Intl.message(
      'Booking Accepted',
      name: 'booking_accepted',
      desc: '',
      args: [],
    );
  }

  /// `Booking Completed`
  String get booking_completed {
    return Intl.message(
      'Booking Completed',
      name: 'booking_completed',
      desc: '',
      args: [],
    );
  }

  /// `Booking Declined`
  String get booking_declined {
    return Intl.message(
      'Booking Declined',
      name: 'booking_declined',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to decline this booking?`
  String get confirm_decline_booking {
    return Intl.message(
      'Are you sure you want to decline this booking?',
      name: 'confirm_decline_booking',
      desc: '',
      args: [],
    );
  }

  /// `Error processing booking`
  String get error_processing_booking {
    return Intl.message(
      'Error processing booking',
      name: 'error_processing_booking',
      desc: '',
      args: [],
    );
  }

  /// `Error declining booking`
  String get error_declining_booking {
    return Intl.message(
      'Error declining booking',
      name: 'error_declining_booking',
      desc: '',
      args: [],
    );
  }

  /// `Error fetching bookings`
  String get error_fetching_bookings {
    return Intl.message(
      'Error fetching bookings',
      name: 'error_fetching_bookings',
      desc: '',
      args: [],
    );
  }

  /// `Unknown`
  String get unknown {
    return Intl.message(
      'Unknown',
      name: 'unknown',
      desc: '',
      args: [],
    );
  }

  /// `Type`
  String get type {
    return Intl.message(
      'Type',
      name: 'type',
      desc: '',
      args: [],
    );
  }

  /// `Seats`
  String get seats {
    return Intl.message(
      'Seats',
      name: 'seats',
      desc: '',
      args: [],
    );
  }

  /// `Fuel`
  String get fuel {
    return Intl.message(
      'Fuel',
      name: 'fuel',
      desc: '',
      args: [],
    );
  }

  /// `Transmission`
  String get transmission {
    return Intl.message(
      'Transmission',
      name: 'transmission',
      desc: '',
      args: [],
    );
  }

  /// `No Business Name`
  String get no_business_name {
    return Intl.message(
      'No Business Name',
      name: 'no_business_name',
      desc: '',
      args: [],
    );
  }

  /// `Reviews`
  String get reviews {
    return Intl.message(
      'Reviews',
      name: 'reviews',
      desc: '',
      args: [],
    );
  }

  /// `Store`
  String get store {
    return Intl.message(
      'Store',
      name: 'store',
      desc: '',
      args: [],
    );
  }

  /// `Call`
  String get call {
    return Intl.message(
      'Call',
      name: 'call',
      desc: '',
      args: [],
    );
  }

  /// `Chat`
  String get chat {
    return Intl.message(
      'Chat',
      name: 'chat',
      desc: '',
      args: [],
    );
  }

  /// `Book Now`
  String get book_now {
    return Intl.message(
      'Book Now',
      name: 'book_now',
      desc: '',
      args: [],
    );
  }

  /// `Payment Overview`
  String get payment_overview {
    return Intl.message(
      'Payment Overview',
      name: 'payment_overview',
      desc: '',
      args: [],
    );
  }

  /// `Add Credit/Debit Card`
  String get add_credit_debit {
    return Intl.message(
      'Add Credit/Debit Card',
      name: 'add_credit_debit',
      desc: '',
      args: [],
    );
  }

  /// `Add Payment Card`
  String get add_payment_card {
    return Intl.message(
      'Add Payment Card',
      name: 'add_payment_card',
      desc: '',
      args: [],
    );
  }

  /// `Add Card`
  String get add_card {
    return Intl.message(
      'Add Card',
      name: 'add_card',
      desc: '',
      args: [],
    );
  }

  /// `No cards found.`
  String get no_card_found {
    return Intl.message(
      'No cards found.',
      name: 'no_card_found',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to remove this card?`
  String get confirm_remove {
    return Intl.message(
      'Are you sure you want to remove this card?',
      name: 'confirm_remove',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to save changes to this card?`
  String get confirm_card_changes {
    return Intl.message(
      'Are you sure you want to save changes to this card?',
      name: 'confirm_card_changes',
      desc: '',
      args: [],
    );
  }

  /// `Remove`
  String get remove {
    return Intl.message(
      'Remove',
      name: 'remove',
      desc: '',
      args: [],
    );
  }

  /// `Delete`
  String get delete {
    return Intl.message(
      'Delete',
      name: 'delete',
      desc: '',
      args: [],
    );
  }

  /// `Accept`
  String get accept {
    return Intl.message(
      'Accept',
      name: 'accept',
      desc: '',
      args: [],
    );
  }

  /// `Complete`
  String get complete {
    return Intl.message(
      'Complete',
      name: 'complete',
      desc: '',
      args: [],
    );
  }

  /// `Update Card Information`
  String get update_card_information {
    return Intl.message(
      'Update Card Information',
      name: 'update_card_information',
      desc: '',
      args: [],
    );
  }

  /// `Edit Payment Card`
  String get edit_payment_card {
    return Intl.message(
      'Edit Payment Card',
      name: 'edit_payment_card',
      desc: '',
      args: [],
    );
  }

  /// `Suzuki`
  String get brandSuzuki {
    return Intl.message(
      'Suzuki',
      name: 'brandSuzuki',
      desc: '',
      args: [],
    );
  }

  /// `Ford`
  String get brandFord {
    return Intl.message(
      'Ford',
      name: 'brandFord',
      desc: '',
      args: [],
    );
  }

  /// `Toyota`
  String get brandToyota {
    return Intl.message(
      'Toyota',
      name: 'brandToyota',
      desc: '',
      args: [],
    );
  }

  /// `Nissan`
  String get brandNissan {
    return Intl.message(
      'Nissan',
      name: 'brandNissan',
      desc: '',
      args: [],
    );
  }

  /// `BMW`
  String get brandBMW {
    return Intl.message(
      'BMW',
      name: 'brandBMW',
      desc: '',
      args: [],
    );
  }

  /// `Audi`
  String get brandAudi {
    return Intl.message(
      'Audi',
      name: 'brandAudi',
      desc: '',
      args: [],
    );
  }

  /// `Honda`
  String get brandHonda {
    return Intl.message(
      'Honda',
      name: 'brandHonda',
      desc: '',
      args: [],
    );
  }

  /// `Hyundai`
  String get brandHyundai {
    return Intl.message(
      'Hyundai',
      name: 'brandHyundai',
      desc: '',
      args: [],
    );
  }

  /// `Isuzu`
  String get brandIsuzu {
    return Intl.message(
      'Isuzu',
      name: 'brandIsuzu',
      desc: '',
      args: [],
    );
  }

  /// `Mazda`
  String get brandMazda {
    return Intl.message(
      'Mazda',
      name: 'brandMazda',
      desc: '',
      args: [],
    );
  }

  /// `Kia`
  String get brandKia {
    return Intl.message(
      'Kia',
      name: 'brandKia',
      desc: '',
      args: [],
    );
  }

  /// `Categories`
  String get categories {
    return Intl.message(
      'Categories',
      name: 'categories',
      desc: '',
      args: [],
    );
  }

  /// `All Brands`
  String get all_brands {
    return Intl.message(
      'All Brands',
      name: 'all_brands',
      desc: '',
      args: [],
    );
  }

  /// `Error loading vehicles.`
  String get error_loading_vehicles {
    return Intl.message(
      'Error loading vehicles.',
      name: 'error_loading_vehicles',
      desc: '',
      args: [],
    );
  }

  /// `No vehicles found.`
  String get no_vehicles_found {
    return Intl.message(
      'No vehicles found.',
      name: 'no_vehicles_found',
      desc: '',
      args: [],
    );
  }

  /// `Vehicle Details`
  String get vehicle_details {
    return Intl.message(
      'Vehicle Details',
      name: 'vehicle_details',
      desc: '',
      args: [],
    );
  }

  /// `Overview`
  String get overview {
    return Intl.message(
      'Overview',
      name: 'overview',
      desc: '',
      args: [],
    );
  }

  /// `Day`
  String get day {
    return Intl.message(
      'Day',
      name: 'day',
      desc: '',
      args: [],
    );
  }

  /// `Follow`
  String get follow {
    return Intl.message(
      'Follow',
      name: 'follow',
      desc: '',
      args: [],
    );
  }

  /// `Brand`
  String get brand {
    return Intl.message(
      'Brand',
      name: 'brand',
      desc: '',
      args: [],
    );
  }

  /// `Price Per Day`
  String get price_per_day {
    return Intl.message(
      'Price Per Day',
      name: 'price_per_day',
      desc: '',
      args: [],
    );
  }

  /// `Color`
  String get color {
    return Intl.message(
      'Color',
      name: 'color',
      desc: '',
      args: [],
    );
  }

  /// `Model Year`
  String get model_year {
    return Intl.message(
      'Model Year',
      name: 'model_year',
      desc: '',
      args: [],
    );
  }

  /// `Notifications`
  String get notifications {
    return Intl.message(
      'Notifications',
      name: 'notifications',
      desc: '',
      args: [],
    );
  }

  /// `Notification deleted.`
  String get notification_deleted {
    return Intl.message(
      'Notification deleted.',
      name: 'notification_deleted',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to delete this notification?`
  String get confirm_delete_notification {
    return Intl.message(
      'Are you sure you want to delete this notification?',
      name: 'confirm_delete_notification',
      desc: '',
      args: [],
    );
  }

  /// `Mark as read`
  String get mark_as_read {
    return Intl.message(
      'Mark as read',
      name: 'mark_as_read',
      desc: '',
      args: [],
    );
  }

  /// `Vehicle`
  String get vehicle {
    return Intl.message(
      'Vehicle',
      name: 'vehicle',
      desc: '',
      args: [],
    );
  }

  /// `Add Vehicle`
  String get add_vehicle {
    return Intl.message(
      'Add Vehicle',
      name: 'add_vehicle',
      desc: '',
      args: [],
    );
  }

  /// `Car Type`
  String get car_type {
    return Intl.message(
      'Car Type',
      name: 'car_type',
      desc: '',
      args: [],
    );
  }

  /// `Add Image`
  String get add_image {
    return Intl.message(
      'Add Image',
      name: 'add_image',
      desc: '',
      args: [],
    );
  }

  /// `Submit`
  String get submit {
    return Intl.message(
      'Submit',
      name: 'submit',
      desc: '',
      args: [],
    );
  }

  /// `Take Photo`
  String get take_photo {
    return Intl.message(
      'Take Photo',
      name: 'take_photo',
      desc: '',
      args: [],
    );
  }

  /// `Change image`
  String get change_image {
    return Intl.message(
      'Change image',
      name: 'change_image',
      desc: '',
      args: [],
    );
  }

  /// `Update vehicle`
  String get update_vehicle {
    return Intl.message(
      'Update vehicle',
      name: 'update_vehicle',
      desc: '',
      args: [],
    );
  }

  /// `Choose from gallery`
  String get choose_from_gallery {
    return Intl.message(
      'Choose from gallery',
      name: 'choose_from_gallery',
      desc: '',
      args: [],
    );
  }

  /// `Edit vehicle`
  String get edit_vehicle {
    return Intl.message(
      'Edit vehicle',
      name: 'edit_vehicle',
      desc: '',
      args: [],
    );
  }

  /// `Today`
  String get today {
    return Intl.message(
      'Today',
      name: 'today',
      desc: '',
      args: [],
    );
  }

  /// `Just now`
  String get just_now {
    return Intl.message(
      'Just now',
      name: 'just_now',
      desc: '',
      args: [],
    );
  }

  /// `minutes ago`
  String get minutes_ago {
    return Intl.message(
      'minutes ago',
      name: 'minutes_ago',
      desc: '',
      args: [],
    );
  }

  /// `hours ago`
  String get hours_ago {
    return Intl.message(
      'hours ago',
      name: 'hours_ago',
      desc: '',
      args: [],
    );
  }

  /// `month ago`
  String get month_ago {
    return Intl.message(
      'month ago',
      name: 'month_ago',
      desc: '',
      args: [],
    );
  }

  /// `months ago`
  String get months_ago {
    return Intl.message(
      'months ago',
      name: 'months_ago',
      desc: '',
      args: [],
    );
  }

  /// `days ago`
  String get days_ago {
    return Intl.message(
      'days ago',
      name: 'days_ago',
      desc: '',
      args: [],
    );
  }

  /// `New`
  String get new_title {
    return Intl.message(
      'New',
      name: 'new_title',
      desc: '',
      args: [],
    );
  }

  /// `Last 7 Days`
  String get last_7_days {
    return Intl.message(
      'Last 7 Days',
      name: 'last_7_days',
      desc: '',
      args: [],
    );
  }

  /// `Last 30 Days`
  String get last_30_days {
    return Intl.message(
      'Last 30 Days',
      name: 'last_30_days',
      desc: '',
      args: [],
    );
  }

  /// `Brand (if not in list)`
  String get brand_alt {
    return Intl.message(
      'Brand (if not in list)',
      name: 'brand_alt',
      desc: '',
      args: [],
    );
  }

  /// `Model`
  String get model {
    return Intl.message(
      'Model',
      name: 'model',
      desc: '',
      args: [],
    );
  }

  /// `Please enter the model of the car`
  String get enter_model {
    return Intl.message(
      'Please enter the model of the car',
      name: 'enter_model',
      desc: '',
      args: [],
    );
  }

  /// `Please enter the model year`
  String get enter_model_year {
    return Intl.message(
      'Please enter the model year',
      name: 'enter_model_year',
      desc: '',
      args: [],
    );
  }

  /// `Please enter the number of seats`
  String get enter_num_seats {
    return Intl.message(
      'Please enter the number of seats',
      name: 'enter_num_seats',
      desc: '',
      args: [],
    );
  }

  /// `Please enter the price per day`
  String get enter_price_per_day {
    return Intl.message(
      'Please enter the price per day',
      name: 'enter_price_per_day',
      desc: '',
      args: [],
    );
  }

  /// `Please select a brand`
  String get please_select_brand {
    return Intl.message(
      'Please select a brand',
      name: 'please_select_brand',
      desc: '',
      args: [],
    );
  }

  /// `Please enter the color`
  String get enter_color {
    return Intl.message(
      'Please enter the color',
      name: 'enter_color',
      desc: '',
      args: [],
    );
  }

  /// `Please enter an overview`
  String get enter_overview {
    return Intl.message(
      'Please enter an overview',
      name: 'enter_overview',
      desc: '',
      args: [],
    );
  }

  /// `Popular Vehicles`
  String get popular_vehicles {
    return Intl.message(
      'Popular Vehicles',
      name: 'popular_vehicles',
      desc: '',
      args: [],
    );
  }

  /// `Vehicles For You`
  String get vehicles_for_you {
    return Intl.message(
      'Vehicles For You',
      name: 'vehicles_for_you',
      desc: '',
      args: [],
    );
  }

  /// `Vehicles Near You`
  String get vehicles_near_you {
    return Intl.message(
      'Vehicles Near You',
      name: 'vehicles_near_you',
      desc: '',
      args: [],
    );
  }

  /// `Features`
  String get features {
    return Intl.message(
      'Features',
      name: 'features',
      desc: '',
      args: [],
    );
  }
}

class AppLocalizationDelegate extends LocalizationsDelegate<S> {
  const AppLocalizationDelegate();

  List<Locale> get supportedLocales {
    return const <Locale>[
      Locale.fromSubtags(languageCode: 'en'),
      Locale.fromSubtags(languageCode: 'zh'),
    ];
  }

  @override
  bool isSupported(Locale locale) => _isSupported(locale);
  @override
  Future<S> load(Locale locale) => S.load(locale);
  @override
  bool shouldReload(AppLocalizationDelegate old) => false;

  bool _isSupported(Locale locale) {
    for (var supportedLocale in supportedLocales) {
      if (supportedLocale.languageCode == locale.languageCode) {
        return true;
      }
    }
    return false;
  }
}
