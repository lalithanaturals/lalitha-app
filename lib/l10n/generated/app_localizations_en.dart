// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Lalitha Naturals';

  @override
  String get printHomeTitle => 'Lalitha Naturals — Print';

  @override
  String get priceTagTileTitle => 'Price Tag';

  @override
  String get priceTagTileSubtitle => 'MRP, discount, final price';

  @override
  String get estimateTileTitle => 'Estimate';

  @override
  String get estimateTileSubtitle => 'Quick items bill for a customer';

  @override
  String get couponTileTitle => 'Coupon';

  @override
  String get couponTileSubtitle => 'Issue a discount coupon';

  @override
  String get branchLabel => 'Branch';

  @override
  String get staffLabel => 'Staff';

  @override
  String get productLabel => 'Product';

  @override
  String get mrpLabel => 'MRP';

  @override
  String get discountPercentOption => '% Off';

  @override
  String get discountFlatOption => 'Flat Off';

  @override
  String get discountPercentFieldLabel => 'Discount %';

  @override
  String get discountAmountFieldLabel => 'Discount Amount';

  @override
  String finalPriceLabel(String amount) {
    return 'Final Price: $amount';
  }

  @override
  String get saveAndPrint => 'Save & Print';

  @override
  String get priceTagSavedMessage => 'Price tag saved';

  @override
  String get selectBranchAndProductError =>
      'Select a branch and a product first.';

  @override
  String failedToSaveError(String error) {
    return 'Failed to save: $error';
  }

  @override
  String get customerNameLabel => 'Customer Name (optional)';

  @override
  String get customerPhoneLabel => 'Customer Phone (optional)';

  @override
  String get itemsLabel => 'Items';

  @override
  String get addItemLabel => 'Add Item';

  @override
  String get itemLabel => 'Item';

  @override
  String get qtyLabel => 'Qty';

  @override
  String get unitPriceLabel => 'Unit Price';

  @override
  String totalLabel(String amount) {
    return 'Total: $amount';
  }

  @override
  String get estimateSavedMessage => 'Estimate saved';

  @override
  String get selectBranchError => 'Select a branch first.';

  @override
  String get addAtLeastOneItemError => 'Add at least one item.';

  @override
  String get walkInCustomer => 'Walk-in Customer';

  @override
  String get couponTypeLabel => 'Coupon Type';

  @override
  String get discountValueLabel => 'Discount Value';

  @override
  String get issueCouponButton => 'Issue Coupon';

  @override
  String get couponIssuedMessage => 'Coupon issued';

  @override
  String get redeemButton => 'Redeem';

  @override
  String get redeemedLabel => 'Redeemed';

  @override
  String get notRedeemedLabel => 'Not redeemed';

  @override
  String get couponRedeemedMessage => 'Coupon redeemed';

  @override
  String get selectBranchAndTypeError =>
      'Select a branch and enter a coupon type first.';

  @override
  String failedToRedeemError(String error) {
    return 'Failed to redeem: $error';
  }
}
