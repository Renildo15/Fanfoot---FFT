import 'dart:io';
import 'package:fanfoot/core/models/club.dart';
import 'package:fanfoot/core/enums/club.dart';
import 'package:fanfoot/core/models/country.dart';
import 'package:fanfoot/core/services/club_service.dart';
import 'package:fanfoot/core/services/country_service.dart';
import 'package:fanfoot/features/widgets/image_preview.dart';
import 'package:file_selector/file_selector.dart';
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
    // TODO: implement initState
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
                  Container(color: _primaryColor, width: 50, height: 50),
                  const SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: () => pickColor(context, true),
                    child: Text('Cor primária'),
                  ),
                  const SizedBox(width: 30),
                  Container(color: _secondaryColor, width: 50, height: 50),
                  ElevatedButton(
                    onPressed: () => pickColor(context, false),
                    child: Text('Cor secondaria'),
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
                  Expanded(
                    child: _isLoadingCountries
                        ? const CircularProgressIndicator()
                        : DropdownButtonFormField<int>(
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: 'País',
                            ),
                            value: _countryId,
                            items: _countries
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
                            onChanged: (value) =>
                                setState(() => _countryId = value),
                            validator: (value) =>
                                value == null ? 'Selecione um país' : null,
                          ),
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

  Widget buildColorPickerPrimary() => ColorPicker(
    pickerColor: _primaryColor,
    onColorChanged: (color) => setState(() {
      _primaryColor = color;
    }),
  );

  Widget buildColorPickerSecondary() => ColorPicker(
    pickerColor: _secondaryColor,
    onColorChanged: (color) => setState(() {
      _secondaryColor = color;
    }),
  );
  void pickColor(BuildContext context, bool isPrimary) => showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('Selecione a cor: '),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          isPrimary ? buildColorPickerPrimary() : buildColorPickerSecondary(),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Selecione'),
          ),
        ],
      ),
    ),
  );
}
