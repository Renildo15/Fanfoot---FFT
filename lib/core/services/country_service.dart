import 'package:fanfoot/core/models/country.dart';
import 'package:fanfoot/db/database_helper.dart';

class CountryService {
  static final CountryService _instance = CountryService._internal();

  factory CountryService() {
    return _instance;
  }

  CountryService._internal();

  final dbHelper = DatabaseHelper.instance;

  Future<List<Country>> getAllCountries() async {
    final db = await dbHelper.database;
    final result = await db.query('country', orderBy: 'name ASC');
    return result.map((e) => Country.fromMap(e)).toList();
  }

  Future<int> insertCountry(Country country) async {
    final db = await dbHelper.database;
    return await db.insert('country', country.toMap());
  }

  Future<Country?> getCountry(int countryId) async {
    final db = await dbHelper.database;
    final result = await db.query(
      'country',
      where: 'id = ?',
      whereArgs: [countryId],
    );

    if (result.isNotEmpty) {
      return Country.fromMap(result.first);
    }

    return null;
  }

  Future<int> getCountriesCount() async {
    final db = await dbHelper.database;
    final result = await db.query('country', orderBy: 'name ASC');
    return result.length;
  }
}
