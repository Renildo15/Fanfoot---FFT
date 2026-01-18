import 'dart:io';

import 'package:fanfoot/core/enums/competition.enum.dart';
import 'package:fanfoot/core/models/competition.dart';
import 'package:fanfoot/core/models/country.dart';
import 'package:fanfoot/core/services/competition_service.dart';
import 'package:fanfoot/core/services/country_service.dart';
import 'package:fanfoot/features/widgets/image_preview.dart';
import 'package:fanfoot/features/widgets/select_country.dart';
import 'package:fanfoot/widgets/color_picker_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

class NewCompetitionPage extends StatefulWidget {
  const NewCompetitionPage({super.key});

  @override
  State<NewCompetitionPage> createState() => _NewCompetitionPageState();
}

// TODO: VALIDAÇÕES:QUANDO CRIAR UMA NOVA DIVISÃO DE LIGA, VALIDAR PARA CRIÁ-LA UMA DIVISÃO ABAIXO AUTOMATICAMENTE.
// TODO: EM PAIS CRIAR UMA OPÇÃO "FICTICIO" OU PERMITIR CRIAR UMA NOVA SELEÇÃO(ESSA OPÇÃO SÉRIA MAIS COMPLICADA)
class _NewCompetitionPageState extends State<NewCompetitionPage> {
  final _formKey = GlobalKey<FormState>();

  String _name = "";
  CompetitionType? _type;
  double _maxTeams = 32;
  final int _pointsWin = 3;
  double _level = 0;
  final int _pointsDraw = 1;
  final int _pointsLose = 0;
  final int _gdFirst = 1;
  Color _primaryColor = Colors.red;
  Color _secondaryColor = Colors.blue;
  int? _countryId;

  final List<int> cupTeamOption = [2, 4, 6, 8, 16, 32, 64];
  final List<int> leagueTeamOption = [12, 18, 20, 24];

  Map<int, String> _divisions = {
    1: '1º Divisão',
    2: '2º Divisão',
    3: '3º Divisão',
    4: '4º Divisão',
    5: '5º Divisão',
    6: '6º Divisão',
    7: '7º Divisão',
    8: '8º Divisão',
  };

  int _selectedIndex = 0;

  File? _logoPathFile;

  List<Country> _countries = [];
  final _countriesService = CountryService();
  final _competitionService = CompetitionService();
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

  Future<void> _saveCompetition() async {
    if (_formKey.currentState!.validate() && _type != null) {
      _formKey.currentState!.save();

      final newCompetition = Competition(
        name: _name,
        type: _type!,
        countryId: _countryId,
        gdFirst: _gdFirst,
        level: _level.toInt(),
        logoPath: _logoPathFile?.path,
        maxTeams: _maxTeams.toInt(),
        pointsDraw: _pointsDraw,
        pointsLose: _pointsLose,
        pointsWin: _pointsWin,
        primaryColor: _primaryColor.toHexString(),
        secondaryColor: _secondaryColor.toHexString(),
      );

      try {
        await _competitionService.insertCompetition(newCompetition);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Competição salvo com sucesso!")),
        );
        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erro ao salvar competição: $e")),
        );
      }
    }
  }

  List<int> get teamOption {
    if (_type == CompetitionType.league) {
      return leagueTeamOption;
    }
    return cupTeamOption;
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
                      onChanged: (value) => setState(() {
                        _type = value;
                        if (_type != CompetitionType.cup) {
                          _selectedIndex = 0;
                        }
                        ;
                      }),
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
                        Text(
                          'Qtd de times ${teamOption[_selectedIndex].toStringAsFixed(0)}',
                        ),
                        Slider(
                          value: _selectedIndex.toDouble(),
                          min: 0,
                          max: (teamOption.length - 1).toDouble(),
                          divisions: teamOption.length - 1,
                          label: teamOption[_selectedIndex].toString(),
                          onChanged: (value) => setState(() {
                            _selectedIndex = value.round();
                            _maxTeams = teamOption[_selectedIndex].toDouble();
                          }),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 30),
                  SelectCountry(
                    countries: _countries,
                    countryId: _countryId,
                    isLoadingCountries: _isLoadingCountries,
                    onChanged: (value) {
                      setState(() => _countryId = value);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 30),
              Row(
                children: [
                  ColorPickerField(
                    color: _primaryColor,
                    label: 'Cor primária',
                    onColorChanged: (color) {
                      setState(() => _primaryColor = color);
                    },
                  ),
                  const SizedBox(width: 30),
                  ColorPickerField(
                    color: _secondaryColor,
                    label: 'Cor secundária',
                    onColorChanged: (color) {
                      setState(() => _secondaryColor = color);
                    },
                  ),
                ],
              ),
              if (_type == CompetitionType.league) ...[
                const SizedBox(height: 30),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<int>(
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Divisão',
                        ),
                        value: _level == 0 ? null : _level.toInt(),
                        items: _divisions.entries.map((entry) {
                          return DropdownMenuItem<int>(
                            value: entry.key,
                            child: Text(entry.value),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _level = (value ?? 1).toDouble();
                          });
                        },
                        validator: (value) {
                          if (_type == CompetitionType.league &&
                              value == null) {
                            return 'Selecione a divisão';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
              ],

              const SizedBox(height: 30),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _saveCompetition,
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
