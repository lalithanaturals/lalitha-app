import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_te.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('te'),
  ];

  /// The app's title, shown in the OS task switcher etc. Brand name — not translated.
  ///
  /// In en, this message translates to:
  /// **'Lalitha Naturals'**
  String get appTitle;

  /// AppBar title on the Print module's home screen
  ///
  /// In en, this message translates to:
  /// **'Lalitha Naturals — Print'**
  String get printHomeTitle;

  /// No description provided for @priceTagTileTitle.
  ///
  /// In en, this message translates to:
  /// **'Price Tag'**
  String get priceTagTileTitle;

  /// No description provided for @priceTagTileSubtitle.
  ///
  /// In en, this message translates to:
  /// **'MRP, discount, final price'**
  String get priceTagTileSubtitle;

  /// No description provided for @estimateTileTitle.
  ///
  /// In en, this message translates to:
  /// **'Estimate'**
  String get estimateTileTitle;

  /// No description provided for @estimateTileSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Quick items bill for a customer'**
  String get estimateTileSubtitle;

  /// No description provided for @couponTileTitle.
  ///
  /// In en, this message translates to:
  /// **'Coupon'**
  String get couponTileTitle;

  /// No description provided for @couponTileSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Issue a discount coupon'**
  String get couponTileSubtitle;

  /// No description provided for @branchLabel.
  ///
  /// In en, this message translates to:
  /// **'Branch'**
  String get branchLabel;

  /// No description provided for @staffLabel.
  ///
  /// In en, this message translates to:
  /// **'Staff'**
  String get staffLabel;

  /// No description provided for @productLabel.
  ///
  /// In en, this message translates to:
  /// **'Product'**
  String get productLabel;

  /// No description provided for @mrpLabel.
  ///
  /// In en, this message translates to:
  /// **'MRP'**
  String get mrpLabel;

  /// No description provided for @discountPercentOption.
  ///
  /// In en, this message translates to:
  /// **'% Off'**
  String get discountPercentOption;

  /// No description provided for @discountFlatOption.
  ///
  /// In en, this message translates to:
  /// **'Flat Off'**
  String get discountFlatOption;

  /// No description provided for @discountPercentFieldLabel.
  ///
  /// In en, this message translates to:
  /// **'Discount %'**
  String get discountPercentFieldLabel;

  /// No description provided for @discountAmountFieldLabel.
  ///
  /// In en, this message translates to:
  /// **'Discount Amount'**
  String get discountAmountFieldLabel;

  /// Live-computed final price on the Price Tag screen
  ///
  /// In en, this message translates to:
  /// **'Final Price: {amount}'**
  String finalPriceLabel(String amount);

  /// No description provided for @saveAndPrint.
  ///
  /// In en, this message translates to:
  /// **'Save & Print'**
  String get saveAndPrint;

  /// No description provided for @priceTagSavedMessage.
  ///
  /// In en, this message translates to:
  /// **'Price tag saved'**
  String get priceTagSavedMessage;

  /// No description provided for @selectBranchAndProductError.
  ///
  /// In en, this message translates to:
  /// **'Select a branch and a product first.'**
  String get selectBranchAndProductError;

  /// No description provided for @failedToSaveError.
  ///
  /// In en, this message translates to:
  /// **'Failed to save: {error}'**
  String failedToSaveError(String error);

  /// No description provided for @customerNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Customer Name (optional)'**
  String get customerNameLabel;

  /// No description provided for @customerPhoneLabel.
  ///
  /// In en, this message translates to:
  /// **'Customer Phone (optional)'**
  String get customerPhoneLabel;

  /// No description provided for @itemsLabel.
  ///
  /// In en, this message translates to:
  /// **'Items'**
  String get itemsLabel;

  /// No description provided for @addItemLabel.
  ///
  /// In en, this message translates to:
  /// **'Add Item'**
  String get addItemLabel;

  /// No description provided for @itemLabel.
  ///
  /// In en, this message translates to:
  /// **'Item'**
  String get itemLabel;

  /// No description provided for @qtyLabel.
  ///
  /// In en, this message translates to:
  /// **'Qty'**
  String get qtyLabel;

  /// No description provided for @unitPriceLabel.
  ///
  /// In en, this message translates to:
  /// **'Unit Price'**
  String get unitPriceLabel;

  /// Live-computed running total on the Estimate screen
  ///
  /// In en, this message translates to:
  /// **'Total: {amount}'**
  String totalLabel(String amount);

  /// No description provided for @estimateSavedMessage.
  ///
  /// In en, this message translates to:
  /// **'Estimate saved'**
  String get estimateSavedMessage;

  /// No description provided for @selectBranchError.
  ///
  /// In en, this message translates to:
  /// **'Select a branch first.'**
  String get selectBranchError;

  /// No description provided for @addAtLeastOneItemError.
  ///
  /// In en, this message translates to:
  /// **'Add at least one item.'**
  String get addAtLeastOneItemError;

  /// No description provided for @walkInCustomer.
  ///
  /// In en, this message translates to:
  /// **'Walk-in Customer'**
  String get walkInCustomer;

  /// No description provided for @couponTypeLabel.
  ///
  /// In en, this message translates to:
  /// **'Coupon Type'**
  String get couponTypeLabel;

  /// No description provided for @discountValueLabel.
  ///
  /// In en, this message translates to:
  /// **'Discount Value'**
  String get discountValueLabel;

  /// No description provided for @issueCouponButton.
  ///
  /// In en, this message translates to:
  /// **'Issue Coupon'**
  String get issueCouponButton;

  /// No description provided for @couponIssuedMessage.
  ///
  /// In en, this message translates to:
  /// **'Coupon issued'**
  String get couponIssuedMessage;

  /// No description provided for @redeemButton.
  ///
  /// In en, this message translates to:
  /// **'Redeem'**
  String get redeemButton;

  /// No description provided for @redeemedLabel.
  ///
  /// In en, this message translates to:
  /// **'Redeemed'**
  String get redeemedLabel;

  /// No description provided for @notRedeemedLabel.
  ///
  /// In en, this message translates to:
  /// **'Not redeemed'**
  String get notRedeemedLabel;

  /// No description provided for @couponRedeemedMessage.
  ///
  /// In en, this message translates to:
  /// **'Coupon redeemed'**
  String get couponRedeemedMessage;

  /// No description provided for @selectBranchAndTypeError.
  ///
  /// In en, this message translates to:
  /// **'Select a branch and enter a coupon type first.'**
  String get selectBranchAndTypeError;

  /// No description provided for @failedToRedeemError.
  ///
  /// In en, this message translates to:
  /// **'Failed to redeem: {error}'**
  String failedToRedeemError(String error);

  /// No description provided for @locationCardTileTitle.
  ///
  /// In en, this message translates to:
  /// **'Location Card'**
  String get locationCardTileTitle;

  /// No description provided for @locationCardTileSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Print a branch\'s address'**
  String get locationCardTileSubtitle;

  /// No description provided for @addressLabel.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get addressLabel;

  /// No description provided for @printBothBranchesButton.
  ///
  /// In en, this message translates to:
  /// **'Print Both Branches'**
  String get printBothBranchesButton;

  /// No description provided for @locationCardPrintedMessage.
  ///
  /// In en, this message translates to:
  /// **'Location card printed'**
  String get locationCardPrintedMessage;

  /// No description provided for @failedToPrintError.
  ///
  /// In en, this message translates to:
  /// **'Failed to print: {error}'**
  String failedToPrintError(String error);

  /// No description provided for @visitingCardTileTitle.
  ///
  /// In en, this message translates to:
  /// **'Visiting Card'**
  String get visitingCardTileTitle;

  /// No description provided for @visitingCardTileSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Print the business card'**
  String get visitingCardTileSubtitle;

  /// No description provided for @coreOfferingsLabel.
  ///
  /// In en, this message translates to:
  /// **'Core Offerings'**
  String get coreOfferingsLabel;

  /// No description provided for @phoneLabel.
  ///
  /// In en, this message translates to:
  /// **'Call / WhatsApp'**
  String get phoneLabel;

  /// No description provided for @visitingCardPrintedMessage.
  ///
  /// In en, this message translates to:
  /// **'Visiting card printed'**
  String get visitingCardPrintedMessage;

  /// No description provided for @customTextTileTitle.
  ///
  /// In en, this message translates to:
  /// **'Custom Text'**
  String get customTextTileTitle;

  /// No description provided for @customTextTileSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Print a custom message'**
  String get customTextTileSubtitle;

  /// No description provided for @customTextLabel.
  ///
  /// In en, this message translates to:
  /// **'Text'**
  String get customTextLabel;

  /// No description provided for @alignLeftOption.
  ///
  /// In en, this message translates to:
  /// **'Left'**
  String get alignLeftOption;

  /// No description provided for @alignCenterOption.
  ///
  /// In en, this message translates to:
  /// **'Center'**
  String get alignCenterOption;

  /// No description provided for @alignRightOption.
  ///
  /// In en, this message translates to:
  /// **'Right'**
  String get alignRightOption;

  /// No description provided for @boldLabel.
  ///
  /// In en, this message translates to:
  /// **'Bold'**
  String get boldLabel;

  /// No description provided for @fontSizeLabel.
  ///
  /// In en, this message translates to:
  /// **'Font Size'**
  String get fontSizeLabel;

  /// No description provided for @enterTextError.
  ///
  /// In en, this message translates to:
  /// **'Enter some text first.'**
  String get enterTextError;

  /// No description provided for @customTextPrintedMessage.
  ///
  /// In en, this message translates to:
  /// **'Custom text printed'**
  String get customTextPrintedMessage;

  /// No description provided for @appHomeTitle.
  ///
  /// In en, this message translates to:
  /// **'Lalitha Naturals'**
  String get appHomeTitle;

  /// No description provided for @printModuleTitle.
  ///
  /// In en, this message translates to:
  /// **'Print'**
  String get printModuleTitle;

  /// No description provided for @printModuleSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Price tags, estimates, coupons, cards'**
  String get printModuleSubtitle;

  /// No description provided for @stockModuleTitle.
  ///
  /// In en, this message translates to:
  /// **'Stock'**
  String get stockModuleTitle;

  /// No description provided for @stockModuleSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Inventory & transit sheets between branches'**
  String get stockModuleSubtitle;

  /// No description provided for @stockHomeTitle.
  ///
  /// In en, this message translates to:
  /// **'Lalitha Naturals — Stock'**
  String get stockHomeTitle;

  /// No description provided for @inventoryTileTitle.
  ///
  /// In en, this message translates to:
  /// **'Inventory'**
  String get inventoryTileTitle;

  /// No description provided for @inventoryTileSubtitle.
  ///
  /// In en, this message translates to:
  /// **'View and adjust branch stock counts'**
  String get inventoryTileSubtitle;

  /// No description provided for @transitSheetTileTitle.
  ///
  /// In en, this message translates to:
  /// **'Transit Sheet'**
  String get transitSheetTileTitle;

  /// No description provided for @transitSheetTileSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Dispatch stock between branches'**
  String get transitSheetTileSubtitle;

  /// No description provided for @categoryLabel.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get categoryLabel;

  /// No description provided for @currentStockLabel.
  ///
  /// In en, this message translates to:
  /// **'Current Stock'**
  String get currentStockLabel;

  /// No description provided for @stockUpdatedMessage.
  ///
  /// In en, this message translates to:
  /// **'Stock updated'**
  String get stockUpdatedMessage;

  /// No description provided for @failedToUpdateStockError.
  ///
  /// In en, this message translates to:
  /// **'Failed to update stock: {error}'**
  String failedToUpdateStockError(String error);

  /// No description provided for @fromBranchLabel.
  ///
  /// In en, this message translates to:
  /// **'From Branch'**
  String get fromBranchLabel;

  /// No description provided for @toBranchLabel.
  ///
  /// In en, this message translates to:
  /// **'To Branch'**
  String get toBranchLabel;

  /// No description provided for @dispatchButton.
  ///
  /// In en, this message translates to:
  /// **'Dispatch'**
  String get dispatchButton;

  /// No description provided for @transitSheetDispatchedMessage.
  ///
  /// In en, this message translates to:
  /// **'Transit sheet dispatched'**
  String get transitSheetDispatchedMessage;

  /// No description provided for @selectFromAndToBranchError.
  ///
  /// In en, this message translates to:
  /// **'Select both a from-branch and a to-branch.'**
  String get selectFromAndToBranchError;

  /// No description provided for @fromAndToBranchMustDifferError.
  ///
  /// In en, this message translates to:
  /// **'From-branch and to-branch must be different.'**
  String get fromAndToBranchMustDifferError;

  /// No description provided for @addTransitItemLabel.
  ///
  /// In en, this message translates to:
  /// **'Add Item'**
  String get addTransitItemLabel;

  /// No description provided for @scrapModuleTitle.
  ///
  /// In en, this message translates to:
  /// **'Scrap Exchange'**
  String get scrapModuleTitle;

  /// No description provided for @scrapModuleSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Aluminum & steel exchange calculator'**
  String get scrapModuleSubtitle;

  /// No description provided for @calculatorTitle.
  ///
  /// In en, this message translates to:
  /// **'Exchange Calculator'**
  String get calculatorTitle;

  /// No description provided for @aluminumTabLabel.
  ///
  /// In en, this message translates to:
  /// **'Aluminum (₹{rate}/kg)'**
  String aluminumTabLabel(String rate);

  /// No description provided for @steelTabLabel.
  ///
  /// In en, this message translates to:
  /// **'Steel (₹{rate}/kg)'**
  String steelTabLabel(String rate);

  /// No description provided for @weightKgLabel.
  ///
  /// In en, this message translates to:
  /// **'Weight (kg)'**
  String get weightKgLabel;

  /// No description provided for @addWeightLabel.
  ///
  /// In en, this message translates to:
  /// **'Add Weight'**
  String get addWeightLabel;

  /// No description provided for @handlesLabel.
  ///
  /// In en, this message translates to:
  /// **'Handles'**
  String get handlesLabel;

  /// No description provided for @grossWeightLabel.
  ///
  /// In en, this message translates to:
  /// **'Gross Weight'**
  String get grossWeightLabel;

  /// No description provided for @handlesDeductionLabel.
  ///
  /// In en, this message translates to:
  /// **'Handles Deduction'**
  String get handlesDeductionLabel;

  /// No description provided for @netWeightLabel.
  ///
  /// In en, this message translates to:
  /// **'Net Weight'**
  String get netWeightLabel;

  /// No description provided for @materialCostLabel.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get materialCostLabel;

  /// No description provided for @grandTotalLabel.
  ///
  /// In en, this message translates to:
  /// **'Grand Total: {amount}'**
  String grandTotalLabel(String amount);

  /// No description provided for @getEstimationButton.
  ///
  /// In en, this message translates to:
  /// **'Get Estimation'**
  String get getEstimationButton;

  /// No description provided for @submitOrderButton.
  ///
  /// In en, this message translates to:
  /// **'Submit Order'**
  String get submitOrderButton;

  /// No description provided for @exchangeEstimateSavedMessage.
  ///
  /// In en, this message translates to:
  /// **'Estimate saved'**
  String get exchangeEstimateSavedMessage;

  /// No description provided for @exchangeOrderSavedMessage.
  ///
  /// In en, this message translates to:
  /// **'Order saved'**
  String get exchangeOrderSavedMessage;

  /// No description provided for @denominationModuleTitle.
  ///
  /// In en, this message translates to:
  /// **'Denomination'**
  String get denominationModuleTitle;

  /// No description provided for @denominationModuleSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Daily cash audit register'**
  String get denominationModuleSubtitle;

  /// No description provided for @registerEntryTitle.
  ///
  /// In en, this message translates to:
  /// **'Audit Register'**
  String get registerEntryTitle;

  /// No description provided for @dateLabel.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get dateLabel;

  /// No description provided for @openingBalanceLabel.
  ///
  /// In en, this message translates to:
  /// **'Opening Balance'**
  String get openingBalanceLabel;

  /// No description provided for @closingBalanceLabel.
  ///
  /// In en, this message translates to:
  /// **'Closing Balance'**
  String get closingBalanceLabel;

  /// No description provided for @cashTotalLabel.
  ///
  /// In en, this message translates to:
  /// **'Cash Total'**
  String get cashTotalLabel;

  /// No description provided for @denominationCountsLabel.
  ///
  /// In en, this message translates to:
  /// **'Denomination Counts'**
  String get denominationCountsLabel;

  /// No description provided for @expenseCategoryLabel.
  ///
  /// In en, this message translates to:
  /// **'Expenses'**
  String get expenseCategoryLabel;

  /// No description provided for @ownerBillCategoryLabel.
  ///
  /// In en, this message translates to:
  /// **'Owner Bills'**
  String get ownerBillCategoryLabel;

  /// No description provided for @vendorBillCategoryLabel.
  ///
  /// In en, this message translates to:
  /// **'Vendor Bills'**
  String get vendorBillCategoryLabel;

  /// No description provided for @unbilledCategoryLabel.
  ///
  /// In en, this message translates to:
  /// **'Unbilled Items'**
  String get unbilledCategoryLabel;

  /// No description provided for @lineItemNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get lineItemNameLabel;

  /// No description provided for @lineItemAmountLabel.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get lineItemAmountLabel;

  /// No description provided for @addLineItemLabel.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get addLineItemLabel;

  /// No description provided for @commitButton.
  ///
  /// In en, this message translates to:
  /// **'Commit Register'**
  String get commitButton;

  /// No description provided for @registerCommittedMessage.
  ///
  /// In en, this message translates to:
  /// **'Register committed'**
  String get registerCommittedMessage;

  /// No description provided for @failedToCommitError.
  ///
  /// In en, this message translates to:
  /// **'Failed to commit: {error}'**
  String failedToCommitError(String error);

  /// No description provided for @searchTitle.
  ///
  /// In en, this message translates to:
  /// **'Search Records'**
  String get searchTitle;

  /// No description provided for @searchQueryLabel.
  ///
  /// In en, this message translates to:
  /// **'Name, phone, or ID'**
  String get searchQueryLabel;

  /// No description provided for @searchButton.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get searchButton;

  /// No description provided for @noResultsMessage.
  ///
  /// In en, this message translates to:
  /// **'No results'**
  String get noResultsMessage;

  /// No description provided for @netTotalLabel.
  ///
  /// In en, this message translates to:
  /// **'Net Total'**
  String get netTotalLabel;

  /// No description provided for @statusEstimateLabel.
  ///
  /// In en, this message translates to:
  /// **'Estimate'**
  String get statusEstimateLabel;

  /// No description provided for @statusOrderLabel.
  ///
  /// In en, this message translates to:
  /// **'Order'**
  String get statusOrderLabel;

  /// No description provided for @convertToOrderButton.
  ///
  /// In en, this message translates to:
  /// **'Convert to Order'**
  String get convertToOrderButton;

  /// No description provided for @orderConvertedMessage.
  ///
  /// In en, this message translates to:
  /// **'Converted to order'**
  String get orderConvertedMessage;

  /// No description provided for @failedToConvertError.
  ///
  /// In en, this message translates to:
  /// **'Failed to convert: {error}'**
  String failedToConvertError(String error);

  /// No description provided for @archiveTitle.
  ///
  /// In en, this message translates to:
  /// **'Archive'**
  String get archiveTitle;

  /// No description provided for @archiveTileTitle.
  ///
  /// In en, this message translates to:
  /// **'Archive'**
  String get archiveTileTitle;

  /// No description provided for @archiveTileSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Browse past registers for a branch'**
  String get archiveTileSubtitle;

  /// No description provided for @noRegistersMessage.
  ///
  /// In en, this message translates to:
  /// **'No registers found for this branch'**
  String get noRegistersMessage;

  /// No description provided for @statusDraftLabel.
  ///
  /// In en, this message translates to:
  /// **'Draft'**
  String get statusDraftLabel;

  /// No description provided for @statusCommittedLabel.
  ///
  /// In en, this message translates to:
  /// **'Committed'**
  String get statusCommittedLabel;

  /// No description provided for @viewLineItemsLabel.
  ///
  /// In en, this message translates to:
  /// **'View Line Items'**
  String get viewLineItemsLabel;

  /// No description provided for @noLineItemsMessage.
  ///
  /// In en, this message translates to:
  /// **'No line items'**
  String get noLineItemsMessage;

  /// No description provided for @dashboardTileTitle.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get dashboardTileTitle;

  /// No description provided for @dashboardTileSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Cash & category totals for a branch'**
  String get dashboardTileSubtitle;

  /// No description provided for @dashboardTitle.
  ///
  /// In en, this message translates to:
  /// **'Business Intelligence Dashboard'**
  String get dashboardTitle;

  /// No description provided for @registerCountLabel.
  ///
  /// In en, this message translates to:
  /// **'Registers'**
  String get registerCountLabel;

  /// No description provided for @totalCashLabel.
  ///
  /// In en, this message translates to:
  /// **'Total Cash Counted'**
  String get totalCashLabel;

  /// No description provided for @categoryBreakdownLabel.
  ///
  /// In en, this message translates to:
  /// **'Category Breakdown'**
  String get categoryBreakdownLabel;

  /// No description provided for @receiptTitle.
  ///
  /// In en, this message translates to:
  /// **'Receipt'**
  String get receiptTitle;

  /// No description provided for @viewReceiptButton.
  ///
  /// In en, this message translates to:
  /// **'View Receipt'**
  String get viewReceiptButton;

  /// No description provided for @displayIdLabel.
  ///
  /// In en, this message translates to:
  /// **'ID'**
  String get displayIdLabel;

  /// No description provided for @customerLabel.
  ///
  /// In en, this message translates to:
  /// **'Customer'**
  String get customerLabel;

  /// No description provided for @weightEntriesLabel.
  ///
  /// In en, this message translates to:
  /// **'Weight Entries (kg)'**
  String get weightEntriesLabel;

  /// No description provided for @loginTitle.
  ///
  /// In en, this message translates to:
  /// **'Staff Login'**
  String get loginTitle;

  /// No description provided for @pinLabel.
  ///
  /// In en, this message translates to:
  /// **'4-Digit PIN'**
  String get pinLabel;

  /// No description provided for @loginButton.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get loginButton;

  /// No description provided for @selectStaffError.
  ///
  /// In en, this message translates to:
  /// **'Select your name first.'**
  String get selectStaffError;

  /// No description provided for @invalidPinError.
  ///
  /// In en, this message translates to:
  /// **'Incorrect PIN. Please try again.'**
  String get invalidPinError;

  /// No description provided for @logoutButton.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logoutButton;

  /// Shown on the suite home screen's AppBar
  ///
  /// In en, this message translates to:
  /// **'Logged in as {name}'**
  String loggedInAsLabel(String name);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'te'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'te':
      return AppLocalizationsTe();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
