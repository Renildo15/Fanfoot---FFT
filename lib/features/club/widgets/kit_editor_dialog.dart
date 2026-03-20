import 'package:fanfoot/core/enums/kit.dart';
import 'package:fanfoot/core/models/kit.dart';
import 'package:fanfoot/features/club/widgets/kit_preview.dart';
import 'package:fanfoot/widgets/color_picker_field.dart';
import 'package:flutter/material.dart';

class KitEditorDialog extends StatefulWidget {
  final int clubId;
  final int seasonYear;
  final Kit? existingKit;

  const KitEditorDialog({
    super.key,
    required this.clubId,
    required this.seasonYear,
    this.existingKit,
  });

  @override
  State<KitEditorDialog> createState() => _KitEditorDialogState();
}

class _KitEditorDialogState extends State<KitEditorDialog> {
  KitType _type = KitType.home;
  String _primaryColor = 'FF0000';
  String _secondaryColor = 'FFFFFF';
  String _patternColor = '000000';
  KitPattern _pattern = KitPattern.solid;
  int? _playerNumber;
  bool _isDefault = false;

  bool get isEditing => widget.existingKit != null;

  @override
  void initState() {
    super.initState();
    if (widget.existingKit != null) {
      final kit = widget.existingKit!;
      _type = kit.type;
      _primaryColor = kit.primaryColor;
      _secondaryColor = kit.secondaryColor;
      _patternColor = kit.patternColor ?? '000000';
      _pattern = kit.pattern;
      _playerNumber = kit.playerNumber;
      _isDefault = kit.isDefault;
    }
  }

  Color _hexToColor(String hex) {
    hex = hex.replaceAll('#', '');
    if (hex.length == 6) hex = 'FF$hex';
    return Color(int.parse(hex, radix: 16));
  }

  String _colorToHex(Color color) {
    return color.value
        .toRadixString(16)
        .padLeft(8, '0')
        .substring(2)
        .toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: 600,
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.checkroom, color: Colors.blue[700], size: 28),
                  const SizedBox(width: 12),
                  Text(
                    isEditing ? 'Editar Uniforme' : 'Criar Uniforme',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    KitPreviewWithLabel(
                      primaryColor: _primaryColor,
                      secondaryColor: _secondaryColor,
                      pattern: _pattern,
                      playerNumber: _playerNumber,
                      width: 100,
                      height: 130,
                      label: 'FRENTE',
                    ),
                    const SizedBox(width: 20),
                    KitPreviewWithLabel(
                      primaryColor: _primaryColor,
                      secondaryColor: _secondaryColor,
                      pattern: _pattern,
                      playerNumber: _playerNumber,
                      width: 100,
                      height: 130,
                      label: 'TRÁS',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Tipo:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: KitType.values.map((type) {
                  return ChoiceChip(
                    label: Text(_getKitTypeName(type)),
                    selected: _type == type,
                    onSelected: (selected) {
                      if (selected) setState(() => _type = type);
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ColorPickerField(
                      color: _hexToColor(_primaryColor),
                      label: 'Cor Primária',
                      onColorChanged: (color) =>
                          setState(() => _primaryColor = _colorToHex(color)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ColorPickerField(
                      color: _hexToColor(_secondaryColor),
                      label: 'Cor Secundária',
                      onColorChanged: (color) =>
                          setState(() => _secondaryColor = _colorToHex(color)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                'Padrão:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: KitPattern.values.map((pattern) {
                  return ChoiceChip(
                    label: Text(_getPatternName(pattern)),
                    selected: _pattern == pattern,
                    onSelected: (selected) {
                      if (selected) setState(() => _pattern = pattern);
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Número na camisa',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
                keyboardType: TextInputType.number,
                controller: TextEditingController(
                  text: _playerNumber?.toString() ?? '',
                ),
                onChanged: (value) => _playerNumber = int.tryParse(value),
              ),
              const SizedBox(height: 12),
              CheckboxListTile(
                title: const Text('Uniforme padrão'),
                value: _isDefault,
                onChanged: (value) =>
                    setState(() => _isDefault = value ?? false),
                contentPadding: EdgeInsets.zero,
                dense: true,
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancelar'),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    onPressed: () {
                      final kit = Kit(
                        id: widget.existingKit?.id,
                        clubId: widget.clubId,
                        seasonYear: widget.seasonYear,
                        type: _type,
                        primaryColor: _primaryColor,
                        secondaryColor: _secondaryColor,
                        patternColor: _patternColor,
                        pattern: _pattern,
                        playerNumber: _playerNumber,
                        isDefault: _isDefault,
                      );
                      Navigator.pop(context, kit);
                    },
                    icon: const Icon(Icons.save),
                    label: Text(isEditing ? 'Atualizar' : 'Salvar'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[700],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getKitTypeName(KitType type) {
    switch (type) {
      case KitType.home:
        return 'Casa';
      case KitType.away:
        return 'Visitante';
      case KitType.third:
        return 'Terceiro';
      case KitType.goalkeeper:
        return 'Goleiro';
    }
  }

  String _getPatternName(KitPattern pattern) {
    switch (pattern) {
      case KitPattern.solid:
        return 'Sólido';
      case KitPattern.verticalStripes:
        return 'Listras V';
      case KitPattern.horizontalStripes:
        return 'Listras H';
      case KitPattern.diagonalStripes:
        return 'Diagonal';
      case KitPattern.quartered:
        return 'Quadrantes';
      case KitPattern.halves:
        return 'Metades';
      case KitPattern.gradient:
        return 'Gradiente';
    }
  }
}
