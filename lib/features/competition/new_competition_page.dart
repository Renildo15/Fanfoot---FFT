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
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Competição salva com sucesso!")),
        );
        Navigator.pop(context);
      } catch (e) {
        if (!mounted) return;
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

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2E7D32).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: const Color(0xFF2E7D32), size: 24),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF212121),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            ...children,
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.emoji_events, size: 28),
            const SizedBox(width: 12),
            const Text("Nova Competição"),
          ],
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFFF5F5F5),
              Colors.grey[100]!,
            ],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Preview do logo
                Center(
                  child: Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: ImagePreview(
                        crestFile: _logoPathFile,
                        onImageSelected: (file) {
                          setState(() {
                            _logoPathFile = file;
                          });
                        },
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Seção: Informações Básicas
                _buildSectionCard(
                  title: 'Informações Básicas',
                  icon: Icons.info_outline,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            decoration: InputDecoration(
                              labelText: 'Nome da competição',
                              prefixIcon: const Icon(Icons.title),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              filled: true,
                              fillColor: Colors.white,
                            ),
                            onSaved: (newValue) => _name = newValue ?? '',
                            validator: (value) => (value == null || value.isEmpty)
                                ? 'Obrigatório'
                                : null,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: DropdownButtonFormField<CompetitionType>(
                            decoration: InputDecoration(
                              labelText: 'Tipo da competição',
                              prefixIcon: const Icon(Icons.category),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              filled: true,
                              fillColor: Colors.white,
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
                            }),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                // Seção: Configurações
                _buildSectionCard(
                  title: 'Configurações',
                  icon: Icons.settings,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2E7D32).withOpacity(0.05),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFF2E7D32).withOpacity(0.2),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Quantidade de Times',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF2E7D32),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  teamOption[_selectedIndex].toString(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          SliderTheme(
                            data: SliderTheme.of(context).copyWith(
                              activeTrackColor: const Color(0xFF2E7D32),
                              inactiveTrackColor:
                                  const Color(0xFF2E7D32).withOpacity(0.3),
                              thumbColor: const Color(0xFF2E7D32),
                              overlayColor:
                                  const Color(0xFF2E7D32).withOpacity(0.2),
                              thumbShape: const RoundSliderThumbShape(
                                enabledThumbRadius: 12,
                              ),
                            ),
                            child: Slider(
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
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
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

                // Seção: Cores
                _buildSectionCard(
                  title: 'Identidade Visual',
                  icon: Icons.palette,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: ColorPickerField(
                            color: _primaryColor,
                            label: 'Cor primária',
                            onColorChanged: (color) {
                              setState(() => _primaryColor = color);
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ColorPickerField(
                            color: _secondaryColor,
                            label: 'Cor secundária',
                            onColorChanged: (color) {
                              setState(() => _secondaryColor = color);
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                // Seção: Divisão (apenas para ligas)
                if (_type == CompetitionType.league) ...[
                  _buildSectionCard(
                    title: 'Divisão',
                    icon: Icons.layers,
                    children: [
                      DropdownButtonFormField<int>(
                        decoration: InputDecoration(
                          labelText: 'Nível da divisão',
                          prefixIcon: const Icon(Icons.stairs),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Colors.white,
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
                          if (_type == CompetitionType.league && value == null) {
                            return 'Selecione a divisão';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ],

                const SizedBox(height: 20),

                // Botão de salvar
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _saveCompetition,
                    icon: const Icon(Icons.save, size: 24),
                    label: const Text(
                      'Salvar Competição',
                      style: TextStyle(fontSize: 18),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2E7D32),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 3,
                    ),
                  ),
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
