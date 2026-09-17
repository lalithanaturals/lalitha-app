// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Telugu (`te`).
class AppLocalizationsTe extends AppLocalizations {
  AppLocalizationsTe([String locale = 'te']) : super(locale);

  @override
  String get appTitle => 'Lalitha Naturals';

  @override
  String get printHomeTitle => 'లలిత నేచురల్స్ — ప్రింట్';

  @override
  String get priceTagTileTitle => 'ధర ట్యాగ్';

  @override
  String get priceTagTileSubtitle => 'MRP, డిస్కౌంట్, తుది ధర';

  @override
  String get estimateTileTitle => 'అంచనా';

  @override
  String get estimateTileSubtitle => 'కస్టమర్ కోసం త్వరిత వస్తువుల బిల్లు';

  @override
  String get couponTileTitle => 'కూపన్';

  @override
  String get couponTileSubtitle => 'డిస్కౌంట్ కూపన్ జారీ చేయండి';

  @override
  String get branchLabel => 'బ్రాంచ్';

  @override
  String get staffLabel => 'సిబ్బంది';

  @override
  String get productLabel => 'ఉత్పత్తి';

  @override
  String get mrpLabel => 'MRP';

  @override
  String get discountPercentOption => '% తగ్గింపు';

  @override
  String get discountFlatOption => 'ఫ్లాట్ తగ్గింపు';

  @override
  String get discountPercentFieldLabel => 'డిస్కౌంట్ %';

  @override
  String get discountAmountFieldLabel => 'డిస్కౌంట్ మొత్తం';

  @override
  String finalPriceLabel(String amount) {
    return 'తుది ధర: $amount';
  }

  @override
  String get saveAndPrint => 'సేవ్ & ప్రింట్';

  @override
  String get priceTagSavedMessage => 'ధర ట్యాగ్ సేవ్ చేయబడింది';

  @override
  String get selectBranchAndProductError =>
      'ముందుగా బ్రాంచ్ మరియు ఉత్పత్తిని ఎంచుకోండి.';

  @override
  String failedToSaveError(String error) {
    return 'సేవ్ చేయడంలో విఫలమైంది: $error';
  }

  @override
  String get customerNameLabel => 'కస్టమర్ పేరు (ఐచ్ఛికం)';

  @override
  String get customerPhoneLabel => 'కస్టమర్ ఫోన్ (ఐచ్ఛికం)';

  @override
  String get itemsLabel => 'వస్తువులు';

  @override
  String get addItemLabel => 'వస్తువు జోడించండి';

  @override
  String get itemLabel => 'వస్తువు';

  @override
  String get qtyLabel => 'పరిమాణం';

  @override
  String get unitPriceLabel => 'యూనిట్ ధర';

  @override
  String totalLabel(String amount) {
    return 'మొత్తం: $amount';
  }

  @override
  String get estimateSavedMessage => 'అంచనా సేవ్ చేయబడింది';

  @override
  String get selectBranchError => 'ముందుగా బ్రాంచ్ ఎంచుకోండి.';

  @override
  String get addAtLeastOneItemError => 'కనీసం ఒక వస్తువును జోడించండి.';

  @override
  String get walkInCustomer => 'వాక్-ఇన్ కస్టమర్';

  @override
  String get couponTypeLabel => 'కూపన్ రకం';

  @override
  String get discountValueLabel => 'డిస్కౌంట్ విలువ';

  @override
  String get issueCouponButton => 'కూపన్ జారీ చేయండి';

  @override
  String get couponIssuedMessage => 'కూపన్ జారీ చేయబడింది';

  @override
  String get redeemButton => 'రీడీమ్ చేయండి';

  @override
  String get redeemedLabel => 'రీడీమ్ చేయబడింది';

  @override
  String get notRedeemedLabel => 'రీడీమ్ చేయలేదు';

  @override
  String get couponRedeemedMessage => 'కూపన్ రీడీమ్ చేయబడింది';

  @override
  String get selectBranchAndTypeError =>
      'ముందుగా బ్రాంచ్ ఎంచుకుని కూపన్ రకాన్ని నమోదు చేయండి.';

  @override
  String failedToRedeemError(String error) {
    return 'రీడీమ్ చేయడంలో విఫలమైంది: $error';
  }

  @override
  String get locationCardTileTitle => 'లొకేషన్ కార్డ్';

  @override
  String get locationCardTileSubtitle => 'బ్రాంచ్ చిరునామాను ప్రింట్ చేయండి';

  @override
  String get addressLabel => 'చిరునామా';

  @override
  String get printBothBranchesButton => 'రెండు బ్రాంచ్‌లను ప్రింట్ చేయండి';

  @override
  String get locationCardPrintedMessage => 'లొకేషన్ కార్డ్ ప్రింట్ చేయబడింది';

  @override
  String failedToPrintError(String error) {
    return 'ప్రింట్ చేయడంలో విఫలమైంది: $error';
  }

  @override
  String get visitingCardTileTitle => 'విజిటింగ్ కార్డ్';

  @override
  String get visitingCardTileSubtitle => 'బిజినెస్ కార్డ్ ప్రింట్ చేయండి';

  @override
  String get coreOfferingsLabel => 'ప్రధాన ఉత్పత్తులు';

  @override
  String get phoneLabel => 'కాల్ / వాట్సాప్';

  @override
  String get visitingCardPrintedMessage => 'విజిటింగ్ కార్డ్ ప్రింట్ చేయబడింది';
}
