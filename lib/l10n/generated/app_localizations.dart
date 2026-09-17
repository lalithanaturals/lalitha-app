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
