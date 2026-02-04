class AppStrings {
  static Map<String, Map<String, String>> localizedValues = {
    'en': {
      'welcome': 'Welcome to oblns',
      'book_ride': 'Book a Ride',
      'searching': 'Searching for Driver...',
      'sos': 'Emergency SOS',
      'chat': 'Chat',
      'wallet': 'My Wallet',
    },
    'ar': {
      'welcome': 'مرحباً بك في oblns',
      'book_ride': 'احجز رحلة',
      'searching': 'جاري البحث عن سائق...',
      'sos': 'طوارئ SOS',
      'chat': 'دردشة',
      'wallet': 'محفظتي',
    },
  };

  static String get(String key, String lang) {
    return localizedValues[lang]?[key] ?? key;
  }
}
