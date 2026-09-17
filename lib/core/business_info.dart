/// Static business info used by the Visiting Card screen (brand tagline,
/// offerings, phone, website). Hardcoded here for now, mirroring the
/// original Print app — same tech debt the master plan flags in §1
/// ("hardcoded business data"). A future pass should move this into the
/// `settings` collection so it's admin-editable without a rebuild.
class BusinessInfo {
  const BusinessInfo._();

  static const tagline = 'Feel the earth';
  static const coreOfferings = [
    'Organic Food Products & Spices',
    'Cold-Pressed Oils & Ghee',
    'Millet Groceries & Snacks',
  ];
  static const phone = '9676287766';
  static const website = 'www.lalithanaturals.com';
}
