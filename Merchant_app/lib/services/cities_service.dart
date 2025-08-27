import 'dart:convert';
import 'package:http/http.dart' as http;

class CitiesService {
  static const String _baseUrl = 'https://countriesnow.space/api/v0.1/countries';
  
  // Cache for cities to avoid repeated API calls
  static Map<String, List<String>> _citiesCache = {};
  
  // Get all countries and their cities
  static Future<Map<String, List<String>>> getAllCities() async {
    if (_citiesCache.isNotEmpty) {
      return _citiesCache;
    }
    
    try {
      final response = await http.get(Uri.parse(_baseUrl));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['error'] == false && data['data'] != null) {
          final countries = data['data'] as List;
          
          for (var country in countries) {
            final countryName = country['country'] as String;
            final cities = List<String>.from(country['cities'] ?? []);
            _citiesCache[countryName] = cities;
          }
          
          return _citiesCache;
        }
      }
      
      // Fallback to popular cities if API fails
      return _getFallbackCities();
    } catch (e) {
      // Return fallback cities if network request fails
      return _getFallbackCities();
    }
  }
  
  // Get cities for a specific country
  static Future<List<String>> getCitiesForCountry(String country) async {
    final allCities = await getAllCities();
    return allCities[country] ?? [];
  }
  
  // Get all available countries
  static Future<List<String>> getCountries() async {
    final allCities = await getAllCities();
    return allCities.keys.toList();
  }
  
  // Fallback cities for popular countries
  static Map<String, List<String>> _getFallbackCities() {
    return {
      'India': [
        'Mumbai', 'Delhi', 'Bangalore', 'Hyderabad', 'Chennai', 'Kolkata',
        'Pune', 'Ahmedabad', 'Jaipur', 'Surat', 'Lucknow', 'Kanpur',
        'Nagpur', 'Indore', 'Thane', 'Bhopal', 'Visakhapatnam', 'Pimpri-Chinchwad',
        'Patna', 'Vadodara', 'Ghaziabad', 'Ludhiana', 'Agra', 'Nashik',
        'Faridabad', 'Meerut', 'Rajkot', 'Kalyan-Dombivali', 'Vasai-Virar',
        'Varanasi', 'Srinagar', 'Aurangabad', 'Dhanbad', 'Amritsar',
        'Allahabad', 'Ranchi', 'Howrah', 'Coimbatore', 'Jabalpur',
        'Gwalior', 'Vijayawada', 'Jodhpur', 'Madurai', 'Raipur',
        'Kota', 'Guwahati', 'Chandigarh', 'Solapur', 'Tiruchirappalli',
        'Bareilly', 'Moradabad', 'Mysore', 'Tiruppur', 'Gurgaon',
        'Aligarh', 'Jalandhar', 'Bhubaneswar', 'Salem', 'Warangal',
        'Guntur', 'Bhiwandi', 'Saharanpur', 'Gorakhpur', 'Bikaner',
        'Amravati', 'Noida', 'Jamshedpur', 'Bhilai', 'Cuttack',
        'Firozabad', 'Kochi', 'Nellore', 'Bhavnagar', 'Dehradun',
        'Durgapur', 'Asansol', 'Rourkela', 'Nanded', 'Kolhapur',
        'Ajmer', 'Akola', 'Gulbarga', 'Jamnagar', 'Ujjain',
        'Loni', 'Siliguri', 'Jhansi', 'Ulhasnagar', 'Jammu',
        'Mangalore', 'Erode', 'Belgaum', 'Ambattur', 'Tirunelveli',
        'Malegaon', 'Gaya', 'Jalgaon', 'Udaipur', 'Maheshtala',
        'Tirupur', 'Davanagere', 'Kozhikode', 'Akola', 'Kurnool',
        'Rajpur Sonarpur', 'Bokaro', 'South Dumdum', 'Bellary',
        'Patiala', 'Gopalpur', 'Agartala', 'Bhagalpur', 'Muzaffarnagar',
        'Bhatpara', 'Panihati', 'Latur', 'Dhule', 'Rohtak',
        'Korba', 'Bhilwara', 'Brahmapur', 'Muzaffarpur', 'Ahmednagar',
        'Mathura', 'Kollam', 'Avadi', 'Kadapa', 'Anantapur',
        'Tiruchengode', 'Bharatpur', 'Panipat', 'Bhatinda', 'Bijapur',
        'Bardhaman', 'Bhiwani', 'Sirsa', 'Kaithal', 'Pudukkottai',
        'Srikakulam', 'Rewa', 'Unnao', 'Hugli-Chinsurah', 'Raigarh',
        'Chhindwara', 'Daman', 'Panaji', 'Kohima', 'Port Blair'
      ],
      'United States': [
        'New York', 'Los Angeles', 'Chicago', 'Houston', 'Phoenix',
        'Philadelphia', 'San Antonio', 'San Diego', 'Dallas', 'San Jose',
        'Austin', 'Jacksonville', 'Fort Worth', 'Columbus', 'Charlotte',
        'San Francisco', 'Indianapolis', 'Seattle', 'Denver', 'Washington',
        'Boston', 'El Paso', 'Nashville', 'Detroit', 'Oklahoma City',
        'Portland', 'Las Vegas', 'Memphis', 'Louisville', 'Baltimore',
        'Milwaukee', 'Albuquerque', 'Tucson', 'Fresno', 'Sacramento',
        'Mesa', 'Kansas City', 'Atlanta', 'Long Beach', 'Colorado Springs',
        'Raleigh', 'Miami', 'Virginia Beach', 'Omaha', 'Oakland',
        'Minneapolis', 'Tulsa', 'Arlington', 'Tampa', 'New Orleans',
        'Wichita', 'Cleveland', 'Bakersfield', 'Aurora', 'Anaheim',
        'Honolulu', 'Santa Ana', 'Corpus Christi', 'Riverside', 'Lexington',
        'Stockton', 'Henderson', 'Saint Paul', 'St. Louis', 'Cincinnati',
        'Pittsburgh', 'Anchorage', 'Anchorage', 'Plano', 'Orlando',
        'Irvine', 'Newark', 'Durham', 'Chula Vista', 'Toledo',
        'Fort Wayne', 'St. Petersburg', 'Laredo', 'Jersey City', 'Chandler',
        'Madison', 'Lubbock', 'Scottsdale', 'Reno', 'Buffalo',
        'Gilbert', 'Glendale', 'North Las Vegas', 'Fremont', 'Cleveland',
        'Chesapeake', 'Birmingham', 'Portland', 'Orlando', 'St. Louis',
        'Laredo', 'Durham', 'Lubbock', 'Laredo', 'Lubbock'
      ],
      'United Kingdom': [
        'London', 'Birmingham', 'Manchester', 'Glasgow', 'Liverpool',
        'Leeds', 'Sheffield', 'Edinburgh', 'Bristol', 'Cardiff',
        'Belfast', 'Leicester', 'Bradford', 'Coventry', 'Nottingham',
        'Kingston upon Hull', 'Newcastle upon Tyne', 'Stoke-on-Trent',
        'Derby', 'Portsmouth', 'Brighton and Hove', 'Plymouth', 'Wolverhampton',
        'Southampton', 'Swansea', 'Salford', 'Oxford', 'Cambridge',
        'York', 'Bath', 'Canterbury', 'Exeter', 'Gloucester',
        'Worcester', 'Chester', 'Durham', 'Lincoln', 'Hereford',
        'Carlisle', 'Ripon', 'Truro', 'Bangor', 'St. Davids'
      ],
      'Canada': [
        'Toronto', 'Montreal', 'Vancouver', 'Calgary', 'Edmonton',
        'Ottawa', 'Winnipeg', 'Quebec City', 'Hamilton', 'Kitchener',
        'London', 'Victoria', 'Halifax', 'Oshawa', 'Windsor',
        'Saskatoon', 'Regina', 'St. John\'s', 'Kelowna', 'Barrie',
        'Sherbrooke', 'Guelph', 'Kingston', 'Moncton', 'Thunder Bay',
        'Saint John', 'Peterborough', 'Sault Ste. Marie', 'Sudbury',
        'Trois-Rivieres', 'Saint-Georges', 'Saguenay', 'Drummondville',
        'Saint-Jerome', 'Granby', 'Saint-Hyacinthe', 'Joliette',
        'Saint-Eustache', 'Val-d\'Or', 'Rouyn-Noranda', 'Bathurst',
        'Miramichi', 'Edmundston', 'Campbellton', 'Bathurst'
      ],
      'Australia': [
        'Sydney', 'Melbourne', 'Brisbane', 'Perth', 'Adelaide',
        'Gold Coast', 'Newcastle', 'Canberra', 'Sunshine Coast', 'Wollongong',
        'Hobart', 'Geelong', 'Townsville', 'Cairns', 'Toowoomba',
        'Darwin', 'Ballarat', 'Bendigo', 'Albury-Wodonga', 'Launceston',
        'Mackay', 'Rockhampton', 'Bunbury', 'Coffs Harbour', 'Bundaberg',
        'Hervey Bay', 'Gladstone', 'Townsville', 'Cairns', 'Toowoomba',
        'Darwin', 'Ballarat', 'Bendigo', 'Albury-Wodonga', 'Launceston',
        'Mackay', 'Rockhampton', 'Bunbury', 'Coffs Harbour', 'Bundaberg',
        'Hervey Bay', 'Gladstone', 'Townsville', 'Cairns', 'Toowoomba'
      ]
    };
  }
  
  // Search cities by name
  static Future<List<String>> searchCities(String query) async {
    final allCities = await getAllCities();
    final allCitiesList = <String>[];
    
    allCities.values.forEach((cities) {
      allCitiesList.addAll(cities);
    });
    
    if (query.isEmpty) {
      return allCitiesList.take(100).toList(); // Return first 100 cities
    }
    
    return allCitiesList
        .where((city) => city.toLowerCase().contains(query.toLowerCase()))
        .take(50)
        .toList();
  }
}
