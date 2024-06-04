import 'package:v1_rentals/generated/l10n.dart';
import 'package:v1_rentals/models/booking_model.dart';
import 'package:v1_rentals/models/user_model.dart';
import 'package:v1_rentals/models/vehicle_model.dart';

extension CarTypeExtension on CarType {
  String getTranslation() {
    switch (this) {
      case CarType.all:
        return S.current.carTypeAll;
      case CarType.suv:
        return S.current.carTypeSuv;
      case CarType.sedan:
        return S.current.carTypeSedan;
      case CarType.truck:
        return S.current.carTypeTruck;
      case CarType.van:
        return S.current.carTypeVan;
      case CarType.electric:
        return S.current.carTypeElectric;
      case CarType.hybrid:
        return S.current.carTypeHybrid;
      case CarType.hatchback:
        return S.current.carTypeHatchback;
      case CarType.sports:
        return S.current.carTypeSports;
      case CarType.luxury:
        return S.current.carTypeLuxury;
      case CarType.convertible:
        return S.current.carTypeConvertible;
      default:
        return '';
    }
  }
}

extension TransmissionTypeExtension on TransmissionType {
  String getTranslation() {
    switch (this) {
      case TransmissionType.automatic:
        return S.current.transmissionAutomatic;
      case TransmissionType.manual:
        return S.current.transmissionManual;
      default:
        return S.current.unknown;
    }
  }
}

extension FuelTypeExtension on FuelType {
  String getTranslation() {
    switch (this) {
      case FuelType.gasoline:
        return S.current.fuelTypeGasoline;
      case FuelType.diesel:
        return S.current.fuelTypeDiesel;
      case FuelType.electric:
        return S.current.fuelTypeElectric;
      case FuelType.hybrid:
        return S.current.fuelTypeHybrid;
      default:
        return S.current.unknown;
    }
  }
}

extension UserTypeExtension on UserType {
  String getTranslation() {
    switch (this) {
      case UserType.client:
        return S.current.userTypeClient;
      case UserType.vendor:
        return S.current.userTypeVendor;
      default:
        return S.current.unknown;
    }
  }
}

extension BookingStatusExtension on BookingStatus {
  String getTranslation() {
    switch (this) {
      case BookingStatus.all:
        return S.current.bookingStatusAll;
      case BookingStatus.completed:
        return S.current.bookingStatusCompleted;
      case BookingStatus.cancelled:
        return S.current.bookingStatusCancelled;
      case BookingStatus.pending:
        return S.current.bookingStatusPending;
      case BookingStatus.inProgress:
        return S.current.bookingStatusInProgress;
      default:
        return S.current.bookingStatusPending;
    }
  }
}

extension BrandExtension on Brand {
  String getTranslation() {
    switch (this) {
      case Brand.suzuki:
        return S.current.brandSuzuki;
      case Brand.ford:
        return S.current.brandFord;
      case Brand.toyota:
        return S.current.brandToyota;
      case Brand.nissan:
        return S.current.brandNissan;
      case Brand.bmw:
        return S.current.brandBMW;
      case Brand.audi:
        return S.current.brandAudi;
      case Brand.honda:
        return S.current.brandHonda;
      case Brand.hyundai:
        return S.current.brandHyundai;
      case Brand.isuzu:
        return S.current.brandIsuzu;
      case Brand.mazda:
        return S.current.brandMazda;
      case Brand.kia:
        return S.current.brandKia;
      default:
        return S.current.unknown;
    }
  }
}
