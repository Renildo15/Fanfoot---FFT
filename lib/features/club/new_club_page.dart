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
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Clube salvo com sucesso!")),
        );
        Navigator.pop(context);
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Erro ao salvar o clube: $e")));
      }
    }
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

  Widget _buildSliderField({
    required String label,
    required double value,
    required double min,
    required double max,
    required int divisions,
    required Function(double) onChanged,
    String? formatValue,
  }) {
    final displayValue = formatValue ?? value.toInt().toString();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF2E7D32).withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF2E7D32).withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: const TextStyle(
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
                  displayValue,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: const Color(0xFF2E7D32),
              inactiveTrackColor: const Color(0xFF2E7D32).withOpacity(0.3),
              thumbColor: const Color(0xFF2E7D32),
              overlayColor: const Color(0xFF2E7D32).withOpacity(0.2),
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 12),
            ),
            child: Slider(
              value: value,
              min: min,
              max: max,
              divisions: divisions,
              label: displayValue,
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }

  String _formatCurrency(double value) {
    if (value >= 1000000) {
      return 'R\$${(value / 1000000).toStringAsFixed(1)}M';
    } else if (value >= 1000) {
      return 'R\$${(value / 1000).toStringAsFixed(0)}K';
    }
    return 'R\$${value.toInt()}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.shield, size: 28),
            const SizedBox(width: 12),
            const Text("Novo Clube"),
          ],
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [const Color(0xFFF5F5F5), Colors.grey[100]!],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Preview do emblema
                Center(
                  child: Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: ImagePreview(
                        crestFile: _crestFile,
                        onImageSelected: (file) {
                          setState(() {
                            _crestFile = file;
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
                              labelText: 'Nome do clube',
                              prefixIcon: const Icon(Icons.group),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              filled: true,
                              fillColor: Colors.white,
                            ),
                            onSaved: (newValue) => _name = newValue ?? '',
                            validator: (value) =>
                                (value == null || value.isEmpty)
                                ? 'Obrigatório'
                                : null,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            decoration: InputDecoration(
                              labelText: 'Sigla',
                              prefixIcon: const Icon(Icons.text_fields),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              filled: true,
                              fillColor: Colors.white,
                            ),
                            onSaved: (newValue) => _shortName = newValue,
                            validator: (value) =>
                                (value == null || value.isEmpty)
                                ? 'Obrigatório'
                                : null,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                // Seção: Orçamento e Recursos
                _buildSectionCard(
                  title: 'Orçamento e Recursos',
                  icon: Icons.account_balance_wallet,
                  children: [
                    _buildSliderField(
                      label: 'Orçamento',
                      value: _budget,
                      min: 0,
                      max: 5000000,
                      divisions: 100,
                      formatValue: _formatCurrency(_budget),
                      onChanged: (value) => setState(() => _budget = value),
                    ),
                    const SizedBox(height: 16),
                    _buildSliderField(
                      label: 'Orçamento Salarial',
                      value: _wageBudget,
                      min: 0,
                      max: 1000000,
                      divisions: 100,
                      formatValue: _formatCurrency(_wageBudget),
                      onChanged: (value) => setState(() => _wageBudget = value),
                    ),
                  ],
                ),

                // Seção: Estatísticas
                _buildSectionCard(
                  title: 'Estatísticas',
                  icon: Icons.star,
                  children: [
                    _buildSliderField(
                      label: 'Reputação',
                      value: _reputation,
                      min: 0,
                      max: 100,
                      divisions: 100,
                      onChanged: (value) => setState(() => _reputation = value),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Estádio',
                        prefixIcon: const Icon(Icons.stadium),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      onSaved: (newValue) => _stadium = newValue,
                    ),
                  ],
                ),

                // Seção: Localização e Federação
                _buildSectionCard(
                  title: 'Localização e Federação',
                  icon: Icons.public,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<ClubFederation>(
                            decoration: InputDecoration(
                              labelText: 'Federação',
                              prefixIcon: const Icon(Icons.groups),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              filled: true,
                              fillColor: Colors.white,
                            ),
                            value: _federation,
                            items: ClubFederation.values
                                .map(
                                  (f) => DropdownMenuItem(
                                    value: f,
                                    child: Text(f.name),
                                  ),
                                )
                                .toList(),
                            onChanged: (value) =>
                                setState(() => _federation = value),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: SelectCountry(
                            countries: _countries,
                            countryId: _countryId,
                            isLoadingCountries: _isLoadingCountries,
                            onChanged: (value) {
                              setState(() => _countryId = value);
                            },
                          ),
                        ),
                      ],
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

                const SizedBox(height: 20),

                // Botão de salvar
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _saveClub,
                    icon: const Icon(Icons.save, size: 24),
                    label: const Text(
                      'Salvar Clube',
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
