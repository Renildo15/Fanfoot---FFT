import 'package:fanfoot/core/models/country.dart';
import 'package:flutter/material.dart';

class SelectCountry extends StatefulWidget {
  bool? isLoadingCountries = true;
  int? countryId;
  List<Country>? countries;
  SelectCountry({
    super.key,
    this.countries,
    this.countryId,
    this.isLoadingCountries,
  });

  @override
  State<SelectCountry> createState() => _SelectCountryState();
}

class _SelectCountryState extends State<SelectCountry> {
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: widget.isLoadingCountries!
          ? const CircularProgressIndicator()
          : DropdownButtonFormField<int>(
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'País',
              ),
              value: widget.countryId,
              items: widget.countries!
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
              onChanged: (value) => setState(() => widget.countryId = value),
              validator: (value) => value == null ? 'Selecione um país' : null,
            ),
    );
  }
}
