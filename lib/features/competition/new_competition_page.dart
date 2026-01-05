import 'dart:io';

import 'package:fanfoot/core/enums/competition.enum.dart';
import 'package:fanfoot/core/models/country.dart';
import 'package:fanfoot/core/services/country_service.dart';
import 'package:fanfoot/features/widgets/image_preview.dart';
import 'package:fanfoot/features/widgets/select_country.dart';
import 'package:flutter/material.dart';

class NewCompetitionPage extends StatefulWidget {
  const NewCompetitionPage({super.key});

  @override
  State<NewCompetitionPage> createState() => _NewCompetitionPageState();
}

class _NewCompetitionPageState extends State<NewCompetitionPage> {
  final _formKey = GlobalKey<FormState>();

  String _name = "";
  CompetitionType? _type;
  double _maxTeams = 32;
  int _pointsWin = 3;
  int _pointsDraw = 1;
  int _pointsLose = 0;
  int _gdFirst = 1;
  Color _primaryColor = Colors.red;
  Color _secondaryColor = Colors.blue;
  int? _countryId;

  File? _logoPathFile;

  List<Country> _countries = [];
  final _countriesService = CountryService();
  bool _isLoadingCountries = true;

  @override
  void initState() {
    super.initState();
    _loadingCountries();
  }

  Future<void> _loadingCountries() async {
    final countries = await _countriesService.getAllCountries();

    setState(() {
      _countries = countries;
      _isLoadingCountries = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Nova competição")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              ImagePreview(crestFile: _logoPathFile),
              const SizedBox(height: 30),

              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Nome da competição',
                      ),
                      onSaved: (newValue) => _name = newValue ?? '',
                      validator: (value) => (value == null || value.isEmpty)
                          ? 'Obrigatório'
                          : null,
                    ),
                  ),
                  const SizedBox(width: 30),
                  Expanded(
                    child: DropdownButtonFormField<CompetitionType>(
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Tipo da competição',
                      ),
                      value: _type,
                      items: CompetitionType.values
                          .map(
                            (f) => DropdownMenuItem(
                              value: f,
                              child: Text(f.value),
                            ),
                          )
                          .toList(),
                      onChanged: (value) => setState(() => _type = value),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 30),

              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Qtd de times ${_maxTeams.toStringAsFixed(0)}'),
                        Slider(
                          value: _maxTeams,
                          min: 0,
                          max: 64,
                          divisions: 100,
                          label: _maxTeams.toInt().toString(),
                          onChanged: (value) =>
                              setState(() => _maxTeams = value),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 30),
                  SelectCountry(
                    countries: _countries,
                    countryId: _countryId,
                    isLoadingCountries: _isLoadingCountries,
                  ),
                ],
              ),
              // const SizedBox(height: 30),
              //  Row(
              //   children: [
              //     Container(color: _primaryColor, width: 50, height: 50),
              //     const SizedBox(height: 30),
              //     ElevatedButton(
              //       onPressed: () => pickColor(context, true),
              //       child: Text('Cor primária'),
              //     ),
              //     const SizedBox(width: 30),
              //     Container(color: _secondaryColor, width: 50, height: 50),
              //     ElevatedButton(
              //       onPressed: () => pickColor(context, false),
              //       child: Text('Cor secondaria'),
              //     ),
              //   ],
              // ),
              const SizedBox(height: 30),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => {},
                  label: const Text('Salvar competição'),
                  icon: const Icon(Icons.save),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    textStyle: const TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
