class LocationUtils {
  static const Map<String, List<String>> countryLocations = {
    'NG': [
      'Lagos, Nigeria',
      'Abuja, Nigeria', 
      'Port Harcourt, Nigeria',
      'Kano, Nigeria',
      'Ibadan, Nigeria',
      'Benin City, Nigeria',
      'Kaduna, Nigeria',
      'Jos, Nigeria',
      'Ilorin, Nigeria',
      'Abeokuta, Nigeria',
      'Enugu, Nigeria',
      'Aba, Nigeria',
      'Maiduguri, Nigeria',
      'Zaria, Nigeria',
      'Bauchi, Nigeria',
    ],
    'US': [
      'New York, NY',
      'Los Angeles, CA',
      'Chicago, IL',
      'Houston, TX',
      'Phoenix, AZ',
      'Philadelphia, PA',
      'San Antonio, TX',
      'San Diego, CA',
      'Dallas, TX',
      'San Jose, CA',
      'Austin, TX',
      'Jacksonville, FL',
      'Fort Worth, TX',
      'Columbus, OH',
      'Charlotte, NC',
    ],
    'CA': [
      'Toronto, ON',
      'Montreal, QC',
      'Vancouver, BC',
      'Calgary, AB',
      'Edmonton, AB',
      'Ottawa, ON',
      'Winnipeg, MB',
      'Quebec City, QC',
      'Hamilton, ON',
      'Kitchener, ON',
      'London, ON',
      'Victoria, BC',
      'Halifax, NS',
      'Oshawa, ON',
      'Windsor, ON',
    ],
    'MT': [
      'Valletta, Malta',
      'Birkirkara, Malta',
      'Mosta, Malta',
      'Qormi, Malta',
      'Zabbar, Malta',
      'Sliema, Malta',
      'Hamrun, Malta',
      'Naxxar, Malta',
      'Marsaskala, Malta',
      'Rabat, Malta',
      'St. Julian\'s, Malta',
      'Paola, Malta',
      'Zejtun, Malta',
      'Fgura, Malta',
      'Zebbug, Malta',
    ],
  };

  static List<String> getLocationSuggestions(String countryCode) {
    return countryLocations[countryCode] ?? countryLocations['NG']!;
  }

  static String getCountryFromCode(String countryCode) {
    switch (countryCode) {
      case '+234':
        return 'NG';
      case '+1':
        return 'US'; // Default to US for +1, could be enhanced to detect CA
      case '+356':
        return 'MT';
      default:
        return 'NG';
    }
  }
}
