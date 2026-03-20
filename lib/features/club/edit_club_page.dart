import 'dart:io';
import 'package:fanfoot/core/models/club.dart';
import 'package:fanfoot/core/enums/club.dart';
import 'package:fanfoot/core/models/country.dart';
import 'package:fanfoot/core/services/club_service.dart';
import 'package:fanfoot/core/services/country_service.dart';
import 'package:fanfoot/features/club/widgets/kit_manager.dart';
import 'package:fanfoot/features/widgets/image_preview.dart';
import 'package:fanfoot/features/widgets/select_country.dart';
import 'package:fanfoot/widgets/color_picker_field.dart';
import 'package:flutter/material.dart';

extension ColorExtension on Color {
  String toHexString() {
    return value.toRadixString(16).padLeft(8, '0').substring(2).toUpperCase();
  }
}

class EditClubPage extends StatefulWidget {
  final Club club;

  const EditClubPage({super.key, required this.club});

  @override
  State<EditClubPage> createState() => _EditClubPageState();
}

class _EditClubPageState extends State<EditClubPage> {
  final _formKey = GlobalKey<FormState>();

  late String _name;
  late String? _shortName;
  late double _reputation;
  late double _budget;
  late double _wageBudget;
  ClubFederation? _federation;
  String? _stadium;
  late Color _primaryColor;
  late Color _secondaryColor;
  int? _countryId;
  int _seasonYear = DateTime.now().year;

  File? _crestFile;

  List<Country> _countries = [];
  bool _isLoadingCountries = true;
  bool _isSaving = false;

  final _clubService = ClubService();
  final _countriesService = CountryService();

  @override
  void initState() {
    super.initState();
    _name = widget.club.name;
    _shortName = widget.club.shortName;
    _reputation = widget.club.reputation.toDouble();
    _budget = widget.club.budget;
    _wageBudget = widget.club.wageBudget;
    _federation = widget.club.federation;
    _stadium = widget.club.stadium;
    _primaryColor = _hexToColor(widget.club.primaryColor ?? 'FF0000');
    _secondaryColor = _hexToColor(widget.club.secondaryColor ?? 'FFFFFF');
    _countryId = widget.club.countryId;
    _loadingCountries();
  }

  Color _hexToColor(String hex) {
    hex = hex.replaceAll('#', '');
    if (hex.length == 6) {
      hex = 'FF$hex';
    }
    return Color(int.parse(hex, radix: 16));
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
      setState(() => _isSaving = true);

      final updatedClub = Club(
        id: widget.club.id,
        name: _name,
        shortName: _shortName,
        reputation: _reputation.toInt(),
        budget: _budget,
        wageBudget: _wageBudget,
        federation: _federation,
        stadium: _stadium,
        primaryColor: _primaryColor.toHexString(),
        secondaryColor: _secondaryColor.toHexString(),
        crestPath: _crestFile?.path ?? widget.club.crestPath,
        countryId: _countryId,
      );

      try {
        await _clubService.updateClub(updatedClub);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Clube atualizado com sucesso!")),
        );
        Navigator.pop(context, true);
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erro ao atualizar o clube: $e")),
        );
      } finally {
        if (mounted) setState(() => _isSaving = false);
      }
    }
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required Color color,
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
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color, size: 24),
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
    required Color color,
  }) {
    final displayValue = formatValue ?? value.toInt().toString();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2)),
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
                  color: color,
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
              activeTrackColor: color,
              inactiveTrackColor: color.withValues(alpha: 0.3),
              thumbColor: color,
              overlayColor: color.withValues(alpha: 0.2),
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
            Text("Editar ${widget.club.name}"),
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
                          setState(() => _crestFile = file);
                        },
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                _buildSectionCard(
                  title: 'Informações Básicas',
                  icon: Icons.info_outline,
                  color: Colors.blue[700]!,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            initialValue: _name,
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
                            initialValue: _shortName,
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
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                _buildSectionCard(
                  title: 'Orçamento e Recursos',
                  icon: Icons.account_balance_wallet,
                  color: Colors.green[700]!,
                  children: [
                    _buildSliderField(
                      label: 'Orçamento',
                      value: _budget,
                      min: 0,
                      max: 5000000,
                      divisions: 100,
                      formatValue: _formatCurrency(_budget),
                      onChanged: (value) => setState(() => _budget = value),
                      color: Colors.green[700]!,
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
                      color: Colors.green[700]!,
                    ),
                  ],
                ),
                _buildSectionCard(
                  title: 'Estatísticas',
                  icon: Icons.star,
                  color: Colors.amber[700]!,
                  children: [
                    _buildSliderField(
                      label: 'Reputação',
                      value: _reputation,
                      min: 0,
                      max: 100,
                      divisions: 100,
                      onChanged: (value) => setState(() => _reputation = value),
                      color: Colors.amber[700]!,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      initialValue: _stadium,
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
                _buildSectionCard(
                  title: 'Localização e Federação',
                  icon: Icons.public,
                  color: Colors.purple[700]!,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<ClubFederation>(
                            value: _federation,
                            decoration: InputDecoration(
                              labelText: 'Federação',
                              prefixIcon: const Icon(Icons.groups),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              filled: true,
                              fillColor: Colors.white,
                            ),
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
                            onChanged: (value) =>
                                setState(() => _countryId = value),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                _buildSectionCard(
                  title: 'Identidade Visual',
                  icon: Icons.palette,
                  color: Colors.red[700]!,
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
                if (widget.club.id != null) ...[
                  _buildSectionCard(
                    title: 'Temporada',
                    icon: Icons.calendar_today,
                    color: Colors.teal[700]!,
                    children: [
                      DropdownButtonFormField<int>(
                        value: _seasonYear,
                        decoration: InputDecoration(
                          labelText: 'Ano da temporada',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        items: List.generate(10, (i) {
                          final year = DateTime.now().year - 2 + i;
                          return DropdownMenuItem(
                            value: year,
                            child: Text(year.toString()),
                          );
                        }),
                        onChanged: (value) {
                          if (value != null)
                            setState(() => _seasonYear = value);
                        },
                      ),
                    ],
                  ),
                  KitManager(
                    clubId: widget.club.id!,
                    seasonYear: _seasonYear,
                    clubName: widget.club.name,
                  ),
                ],
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _isSaving ? null : _saveClub,
                    icon: _isSaving
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.save, size: 24),
                    label: Text(
                      _isSaving ? 'Salvando...' : 'Salvar Alterações',
                      style: const TextStyle(fontSize: 18),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[700],
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
