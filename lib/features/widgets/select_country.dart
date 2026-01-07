import 'package:fanfoot/core/models/country.dart';
import 'package:flutter/material.dart';

class SelectCountry extends StatelessWidget {
  final bool isLoadingCountries;
  final int? countryId;
  final List<Country> countries;
  final ValueChanged<int?> onChanged;

  const SelectCountry({
    super.key,
    required this.countries,
    required this.countryId,
    required this.isLoadingCountries,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: isLoadingCountries
          ? const CircularProgressIndicator()
          : DropdownButtonFormField<int>(
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'País',
              ),
              value: countryId,
              items: countries
                  .map(
                    (country) => DropdownMenuItem<int>(
                      value: country.id,
                      child: Row(
                        children: [
                          if (country.flag.isNotEmpty)
                            Image.network(
                              country.flag,
                              width: 24,
                              height: 16,
                              fit: BoxFit.cover,
                            ),
                          const SizedBox(width: 8),
                          Text(country.name),
                        ],
                      ),
                    ),
                  )
                  .toList(),
              onChanged: onChanged,
              validator: (value) => value == null ? 'Selecione um país' : null,
            ),
    );
  }
}
