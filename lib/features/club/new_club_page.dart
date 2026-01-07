import 'dart:io';
import 'package:fanfoot/core/models/club.dart';
import 'package:fanfoot/core/enums/club.dart';
import 'package:fanfoot/core/models/country.dart';
import 'package:fanfoot/core/services/club_service.dart';
import 'package:fanfoot/core/services/country_service.dart';
import 'package:fanfoot/features/widgets/image_preview.dart';
import 'package:fanfoot/features/widgets/select_country.dart';
import 'package:fanfoot/widgets/color_picker_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

class NewClubPage extends StatefulWidget {
  const NewClubPage({super.key});

  @override
  State<NewClubPage> createState() => _NewClubPageState();
}

class _NewClubPageState extends State<NewClubPage> {
  final _formKey = GlobalKey<FormState>();

  String _name = '';
  String? _shortName;
  double _reputation = 0;
  double _budget = 0.0;
  double _wageBudget = 0.0;
  ClubFederation? _federation;
  String? _stadium;
  Color _primaryColor = Colors.red;
  Color _secondaryColor = Colors.blue;
  int? _countryId;

  File? _crestFile;

  List<Country> _countries = [];
  bool _isLoadingCountries = true;

  final _clubService = ClubService();
  final _countriesService = CountryService();
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

  Future<void> _saveClub() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final newClub = Club(
        name: _name,
        shortName: _shortName,
        reputation: _reputation.toInt(),
        budget: _budget,
        wageBudget: _wageBudget,
        federation: _federation,
        stadium: _stadium,
        primaryColor: _primaryColor.toHexString(),
        secondaryColor: _secondaryColor.toHexString(),
        crestPath: _crestFile?.path,
        countryId: _countryId,
      );

      try {
        await _clubService.insertClub(newClub);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Clube salvo com sucesso!")),
        );
        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Erro ao salvar o clube: $e")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Novo clube")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // === PREVIEW DA IMAGEM + BOTÃO ===
              ImagePreview(crestFile: _crestFile),

              const SizedBox(height: 30),

              // === NOME E SIGLA ===
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Nome do clube',
                      ),
                      onSaved: (newValue) => _name = newValue ?? '',
                      validator: (value) => (value == null || value.isEmpty)
                          ? 'Obrigatório'
                          : null,
                    ),
                  ),
                  const SizedBox(width: 30),
                  Expanded(
                    child: TextFormField(
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Sigla',
                      ),
                      onSaved: (newValue) => _shortName = newValue,
                      validator: (value) => (value == null || value.isEmpty)
                          ? 'Obrigatório'
                          : null,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 30),

              // === SLIDERS ===
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Orçamento: R\$${_budget.toStringAsFixed(0)}'),
                        Slider(
                          value: _budget,
                          min: 0,
                          max: 5000000,
                          divisions: 100,
                          label: _budget.toInt().toString(),
                          onChanged: (value) => setState(() => _budget = value),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 30),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Reputação: ${_reputation.toInt()}'),
                        Slider(
                          value: _reputation,
                          min: 0,
                          max: 100,
                          divisions: 100,
                          label: _reputation.toInt().toString(),
                          onChanged: (value) =>
                              setState(() => _reputation = value),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Orçamento Salarial: R\$${_wageBudget.toStringAsFixed(0)}',
                        ),
                        Slider(
                          value: _wageBudget,
                          min: 0,
                          max: 1000000,
                          divisions: 100,
                          label: _wageBudget.toInt().toString(),
                          onChanged: (value) =>
                              setState(() => _wageBudget = value),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: TextFormField(
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Estádio',
                      ),
                      onSaved: (newValue) => _stadium = newValue,
                    ),
                  ),

                  const SizedBox(height: 30),
                ],
              ),
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
              const SizedBox(height: 30),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<ClubFederation>(
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Federação',
                      ),
                      value: _federation,
                      items: ClubFederation.values
                          .map(
                            (f) =>
                                DropdownMenuItem(value: f, child: Text(f.name)),
                          )
                          .toList(),
                      onChanged: (value) => setState(() => _federation = value),
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

              // === CORES ===

              // === BOTÃO DE SALVAR ===
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _saveClub,
                  label: const Text('Salvar Clube'),
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
