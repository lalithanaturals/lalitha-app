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

  @override
  String get locationCardTileTitle => 'Location Card';

  @override
  String get locationCardTileSubtitle => 'Print a branch\'s address';

  @override
  String get addressLabel => 'Address';

  @override
  String get printBothBranchesButton => 'Print Both Branches';

  @override
  String get locationCardPrintedMessage => 'Location card printed';

  @override
  String failedToPrintError(String error) {
    return 'Failed to print: $error';
  }

  @override
  String get visitingCardTileTitle => 'Visiting Card';

  @override
  String get visitingCardTileSubtitle => 'Print the business card';

  @override
  String get coreOfferingsLabel => 'Core Offerings';

  @override
  String get phoneLabel => 'Call / WhatsApp';

  @override
  String get visitingCardPrintedMessage => 'Visiting card printed';

  @override
  String get customTextTileTitle => 'Custom Text';

  @override
  String get customTextTileSubtitle => 'Print a custom message';

  @override
  String get customTextLabel => 'Text';

  @override
  String get alignLeftOption => 'Left';

  @override
  String get alignCenterOption => 'Center';

  @override
  String get alignRightOption => 'Right';

  @override
  String get boldLabel => 'Bold';

  @override
  String get fontSizeLabel => 'Font Size';

  @override
  String get enterTextError => 'Enter some text first.';

  @override
  String get customTextPrintedMessage => 'Custom text printed';

  @override
  String get appHomeTitle => 'Lalitha Naturals';

  @override
  String get printModuleTitle => 'Print';

  @override
  String get printModuleSubtitle => 'Price tags, estimates, coupons, cards';

  @override
  String get stockModuleTitle => 'Stock';

  @override
  String get stockModuleSubtitle =>
      'Inventory & transit sheets between branches';

  @override
  String get stockHomeTitle => 'Lalitha Naturals — Stock';

  @override
  String get inventoryTileTitle => 'Inventory';

  @override
  String get inventoryTileSubtitle => 'View and adjust branch stock counts';

  @override
  String get transitSheetTileTitle => 'Transit Sheet';

  @override
  String get transitSheetTileSubtitle => 'Dispatch stock between branches';

  @override
  String get categoryLabel => 'Category';

  @override
  String get currentStockLabel => 'Current Stock';

  @override
  String get stockUpdatedMessage => 'Stock updated';

  @override
  String failedToUpdateStockError(String error) {
    return 'Failed to update stock: $error';
  }

  @override
  String get fromBranchLabel => 'From Branch';

  @override
  String get toBranchLabel => 'To Branch';

  @override
  String get dispatchButton => 'Dispatch';

  @override
  String get transitSheetDispatchedMessage => 'Transit sheet dispatched';

  @override
  String get selectFromAndToBranchError =>
      'Select both a from-branch and a to-branch.';

  @override
  String get fromAndToBranchMustDifferError =>
      'From-branch and to-branch must be different.';

  @override
  String get addTransitItemLabel => 'Add Item';

  @override
  String get scrapModuleTitle => 'Scrap Exchange';

  @override
  String get scrapModuleSubtitle => 'Aluminum & steel exchange calculator';

  @override
  String get calculatorTitle => 'Exchange Calculator';

  @override
  String aluminumTabLabel(String rate) {
    return 'Aluminum (₹$rate/kg)';
  }

  @override
  String steelTabLabel(String rate) {
    return 'Steel (₹$rate/kg)';
  }

  @override
  String get weightKgLabel => 'Weight (kg)';

  @override
  String get addWeightLabel => 'Add Weight';

  @override
  String get handlesLabel => 'Handles';

  @override
  String get grossWeightLabel => 'Gross Weight';

  @override
  String get handlesDeductionLabel => 'Handles Deduction';

  @override
  String get netWeightLabel => 'Net Weight';

  @override
  String get materialCostLabel => 'Amount';

  @override
  String grandTotalLabel(String amount) {
    return 'Grand Total: $amount';
  }

  @override
  String get getEstimationButton => 'Get Estimation';

  @override
  String get submitOrderButton => 'Submit Order';

  @override
  String get exchangeEstimateSavedMessage => 'Estimate saved';

  @override
  String get exchangeOrderSavedMessage => 'Order saved';

  @override
  String get denominationModuleTitle => 'Denomination';

  @override
  String get denominationModuleSubtitle => 'Daily cash audit register';

  @override
  String get registerEntryTitle => 'Audit Register';

  @override
  String get dateLabel => 'Date';

  @override
  String get openingBalanceLabel => 'Opening Balance';

  @override
  String get closingBalanceLabel => 'Closing Balance';

  @override
  String get cashTotalLabel => 'Cash Total';

  @override
  String get denominationCountsLabel => 'Denomination Counts';

  @override
  String get expenseCategoryLabel => 'Expenses';

  @override
  String get ownerBillCategoryLabel => 'Owner Bills';

  @override
  String get vendorBillCategoryLabel => 'Vendor Bills';

  @override
  String get unbilledCategoryLabel => 'Unbilled Items';

  @override
  String get lineItemNameLabel => 'Name';

  @override
  String get lineItemAmountLabel => 'Amount';

  @override
  String get addLineItemLabel => 'Add';

  @override
  String get commitButton => 'Commit Register';

  @override
  String get registerCommittedMessage => 'Register committed';

  @override
  String failedToCommitError(String error) {
    return 'Failed to commit: $error';
  }

  @override
  String get searchTitle => 'Search Records';

  @override
  String get searchQueryLabel => 'Name, phone, or ID';

  @override
  String get searchButton => 'Search';

  @override
  String get noResultsMessage => 'No results';

  @override
  String get netTotalLabel => 'Net Total';

  @override
  String get statusEstimateLabel => 'Estimate';

  @override
  String get statusOrderLabel => 'Order';

  @override
  String get convertToOrderButton => 'Convert to Order';

  @override
  String get orderConvertedMessage => 'Converted to order';

  @override
  String failedToConvertError(String error) {
    return 'Failed to convert: $error';
  }
}
