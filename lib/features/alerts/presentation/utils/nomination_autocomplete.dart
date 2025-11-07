import 'dart:convert';
import 'package:http/http.dart' as http;

Future<List<String>> getAddressSuggestions(String query) async {
  final url = Uri.parse(
    'https://nominatim.openstreetmap.org/search'
        '?q=$query'
        '&format=json'
        '&addressdetails=1'
        '&limit=5'
        '&viewbox=-47.475,-22.530,-47.330,-22.640'
        '&bounded=1',
  );

  final response = await http.get(url, headers: {
    'User-Agent': 'safeway-app/1.0 (pedibr5@gmail.com)',
  });

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body) as List<dynamic>;
    return data.map((e) => e['display_name'] as String).toList();
  } else {
    return [];
  }
}
