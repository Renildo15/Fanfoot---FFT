import 'dart:convert';
import 'package:fanfoot/core/models/country.dart';
import 'package:fanfoot/core/services/country_service.dart';
import 'package:http/http.dart' as http;

Future<List<Country>> fetchCountries() async {
  final url = Uri.parse(
    'https://restcountries.com/v3.1/all?fields=flags,cca2,name',
  );
  final response = await http.get(url);

  if (response.statusCode != 200) {
    throw Exception('Falha ao buscar países: ${response.statusCode}');
  }

  final List<dynamic> data = jsonDecode(response.body);

  return data.map<Country>((c) {
    return Country(
      code: c['cca2'].toString().toLowerCase(),
      name: c['name']['common'],
      flag: c['flags']['png'],
    );
  }).toList();
}

Future<void> syncCountries() async {
  final countriesCount = await CountryService().getCountriesCount();
  final countries = await fetchCountries();

  if (countriesCount == 0) {
    for (var country in countries) {
      await CountryService().insertCountry(country);
      print('${country.name} adicionado!');
    }
  } else {
    print('Já existe países no banco: $countriesCount');
  }
}
