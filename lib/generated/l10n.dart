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

  /// `Pick-up Location`
  String get pick_up_location {
    return Intl.message(
      'Pick-up Location',
      name: 'pick_up_location',
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
