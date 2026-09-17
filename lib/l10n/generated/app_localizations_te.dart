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

  @override
  String get customTextTileTitle => 'కస్టమ్ టెక్స్ట్';

  @override
  String get customTextTileSubtitle => 'కస్టమ్ సందేశాన్ని ప్రింట్ చేయండి';

  @override
  String get customTextLabel => 'టెక్స్ట్';

  @override
  String get alignLeftOption => 'ఎడమ';

  @override
  String get alignCenterOption => 'మధ్య';

  @override
  String get alignRightOption => 'కుడి';

  @override
  String get boldLabel => 'బోల్డ్';

  @override
  String get fontSizeLabel => 'ఫాంట్ పరిమాణం';

  @override
  String get enterTextError => 'ముందుగా కొంత టెక్స్ట్ నమోదు చేయండి.';

  @override
  String get customTextPrintedMessage => 'కస్టమ్ టెక్స్ట్ ప్రింట్ చేయబడింది';

  @override
  String get appHomeTitle => 'Lalitha Naturals';

  @override
  String get printModuleTitle => 'ప్రింట్';

  @override
  String get printModuleSubtitle => 'ధర ట్యాగ్‌లు, అంచనాలు, కూపన్లు, కార్డులు';

  @override
  String get stockModuleTitle => 'స్టాక్';

  @override
  String get stockModuleSubtitle =>
      'బ్రాంచ్‌ల మధ్య ఇన్వెంటరీ & ట్రాన్సిట్ షీట్‌లు';

  @override
  String get stockHomeTitle => 'లలిత నేచురల్స్ — స్టాక్';

  @override
  String get inventoryTileTitle => 'ఇన్వెంటరీ';

  @override
  String get inventoryTileSubtitle =>
      'బ్రాంచ్ స్టాక్ లెక్కలను చూడండి మరియు సవరించండి';

  @override
  String get transitSheetTileTitle => 'ట్రాన్సిట్ షీట్';

  @override
  String get transitSheetTileSubtitle => 'బ్రాంచ్‌ల మధ్య స్టాక్‌ను పంపండి';

  @override
  String get categoryLabel => 'వర్గం';

  @override
  String get currentStockLabel => 'ప్రస్తుత స్టాక్';

  @override
  String get stockUpdatedMessage => 'స్టాక్ నవీకరించబడింది';

  @override
  String failedToUpdateStockError(String error) {
    return 'స్టాక్ నవీకరించడంలో విఫలమైంది: $error';
  }

  @override
  String get fromBranchLabel => 'నుండి బ్రాంచ్';

  @override
  String get toBranchLabel => 'కు బ్రాంచ్';

  @override
  String get dispatchButton => 'పంపించు';

  @override
  String get transitSheetDispatchedMessage => 'ట్రాన్సిట్ షీట్ పంపబడింది';

  @override
  String get selectFromAndToBranchError =>
      'నుండి-బ్రాంచ్ మరియు కు-బ్రాంచ్ రెండింటినీ ఎంచుకోండి.';

  @override
  String get fromAndToBranchMustDifferError =>
      'నుండి-బ్రాంచ్ మరియు కు-బ్రాంచ్ వేర్వేరుగా ఉండాలి.';

  @override
  String get addTransitItemLabel => 'వస్తువు జోడించండి';

  @override
  String get scrapModuleTitle => 'స్క్రాప్ ఎక్స్ఛేంజ్';

  @override
  String get scrapModuleSubtitle =>
      'అల్యూమినియం & స్టీల్ ఎక్స్ఛేంజ్ కాలిక్యులేటర్';

  @override
  String get calculatorTitle => 'ఎక్స్ఛేంజ్ కాలిక్యులేటర్';

  @override
  String aluminumTabLabel(String rate) {
    return 'అల్యూమినియం (₹$rate/కేజీ)';
  }

  @override
  String steelTabLabel(String rate) {
    return 'స్టీల్ (₹$rate/కేజీ)';
  }

  @override
  String get weightKgLabel => 'బరువు (కేజీ)';

  @override
  String get addWeightLabel => 'బరువు జోడించండి';

  @override
  String get handlesLabel => 'హ్యాండిల్స్';

  @override
  String get grossWeightLabel => 'మొత్తం బరువు';

  @override
  String get handlesDeductionLabel => 'హ్యాండిల్స్ తగ్గింపు';

  @override
  String get netWeightLabel => 'నికర బరువు';

  @override
  String get materialCostLabel => 'మొత్తం';

  @override
  String grandTotalLabel(String amount) {
    return 'గ్రాండ్ టోటల్: $amount';
  }

  @override
  String get getEstimationButton => 'అంచనా పొందండి';

  @override
  String get submitOrderButton => 'ఆర్డర్ సమర్పించండి';

  @override
  String get exchangeEstimateSavedMessage => 'అంచనా సేవ్ చేయబడింది';

  @override
  String get exchangeOrderSavedMessage => 'ఆర్డర్ సేవ్ చేయబడింది';

  @override
  String get denominationModuleTitle => 'డినామినేషన్';

  @override
  String get denominationModuleSubtitle => 'రోజువారీ నగదు ఆడిట్ రిజిస్టర్';

  @override
  String get registerEntryTitle => 'ఆడిట్ రిజిస్టర్';

  @override
  String get dateLabel => 'తేదీ';

  @override
  String get openingBalanceLabel => 'ప్రారంభ నిల్వ';

  @override
  String get closingBalanceLabel => 'ముగింపు నిల్వ';

  @override
  String get cashTotalLabel => 'నగదు మొత్తం';

  @override
  String get denominationCountsLabel => 'నోట్ల లెక్క';

  @override
  String get expenseCategoryLabel => 'ఖర్చులు';

  @override
  String get ownerBillCategoryLabel => 'యజమాని బిల్లులు';

  @override
  String get vendorBillCategoryLabel => 'వెండార్ బిల్లులు';

  @override
  String get unbilledCategoryLabel => 'బిల్లు లేని వస్తువులు';

  @override
  String get lineItemNameLabel => 'పేరు';

  @override
  String get lineItemAmountLabel => 'మొత్తం';

  @override
  String get addLineItemLabel => 'జోడించండి';

  @override
  String get commitButton => 'రిజిస్టర్ కమిట్ చేయండి';

  @override
  String get registerCommittedMessage => 'రిజిస్టర్ కమిట్ చేయబడింది';

  @override
  String failedToCommitError(String error) {
    return 'కమిట్ చేయడంలో విఫలమైంది: $error';
  }

  @override
  String get searchTitle => 'రికార్డులను శోధించండి';

  @override
  String get searchQueryLabel => 'పేరు, ఫోన్, లేదా ID';

  @override
  String get searchButton => 'శోధించండి';

  @override
  String get noResultsMessage => 'ఫలితాలు లేవు';

  @override
  String get netTotalLabel => 'నికర మొత్తం';

  @override
  String get statusEstimateLabel => 'అంచనా';

  @override
  String get statusOrderLabel => 'ఆర్డర్';

  @override
  String get convertToOrderButton => 'ఆర్డర్‌గా మార్చండి';

  @override
  String get orderConvertedMessage => 'ఆర్డర్‌గా మార్చబడింది';

  @override
  String failedToConvertError(String error) {
    return 'మార్చడంలో విఫలమైంది: $error';
  }

  @override
  String get archiveTitle => 'ఆర్కైవ్';

  @override
  String get archiveTileTitle => 'ఆర్కైవ్';

  @override
  String get archiveTileSubtitle =>
      'బ్రాంచ్ కోసం గత రిజిస్టర్లను బ్రౌజ్ చేయండి';

  @override
  String get noRegistersMessage => 'ఈ బ్రాంచ్ కోసం రిజిస్టర్లు కనుగొనబడలేదు';

  @override
  String get statusDraftLabel => 'డ్రాఫ్ట్';

  @override
  String get statusCommittedLabel => 'కమిట్ చేయబడింది';

  @override
  String get viewLineItemsLabel => 'లైన్ ఐటెమ్‌లను చూడండి';

  @override
  String get noLineItemsMessage => 'లైన్ ఐటెమ్‌లు లేవు';

  @override
  String get dashboardTileTitle => 'డాష్‌బోర్డ్';

  @override
  String get dashboardTileSubtitle => 'బ్రాంచ్ కోసం నగదు & వర్గం మొత్తాలు';

  @override
  String get dashboardTitle => 'బిజినెస్ ఇంటెలిజెన్స్ డాష్‌బోర్డ్';

  @override
  String get registerCountLabel => 'రిజిస్టర్లు';

  @override
  String get totalCashLabel => 'మొత్తం లెక్కించిన నగదు';

  @override
  String get categoryBreakdownLabel => 'వర్గం వారీ వివరాలు';

  @override
  String get receiptTitle => 'రసీదు';

  @override
  String get viewReceiptButton => 'రసీదు చూడండి';

  @override
  String get displayIdLabel => 'ID';

  @override
  String get customerLabel => 'కస్టమర్';

  @override
  String get weightEntriesLabel => 'బరువు నమోదులు (కేజీ)';
}
