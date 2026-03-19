import 'package:flutter/material.dart';

class NewGamePage extends StatefulWidget {
  const NewGamePage({super.key});

  @override
  State<NewGamePage> createState() => _NewGamePageState();
}

class _NewGamePageState extends State<NewGamePage> {
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();

  int _selectedSeason = 2024;
  String? _selectedCountry;
  String? _selectedCompetition;
  String? _selectedClub;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
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
    required int value,
    required int min,
    required int max,
    required Function(int) onChanged,
  }) {
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
                  value.toString(),
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
              value: value.toDouble(),
              min: min.toDouble(),
              max: max.toDouble(),
              divisions: max - min,
              label: value.toString(),
              onChanged: (newValue) => onChanged(newValue.toInt()),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectField({
    required String label,
    required String? value,
    required IconData icon,
    required List<String> options,
    required Function(String?) onChanged,
    bool isLoading = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF2E7D32).withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF2E7D32).withOpacity(0.2)),
      ),
      child: DropdownButtonFormField<String>(
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          border: InputBorder.none,
          filled: true,
          fillColor: Colors.transparent,
        ),
        value: value,
        items: isLoading
            ? [
                const DropdownMenuItem<String>(
                  value: null,
                  child: Text('Carregando...'),
                ),
              ]
            : [
                const DropdownMenuItem<String>(
                  value: null,
                  child: Text('Selecione...'),
                ),
                ...options.map(
                  (option) => DropdownMenuItem<String>(
                    value: option,
                    child: Text(option),
                  ),
                ),
              ],
        onChanged: isLoading ? null : onChanged,
        style: const TextStyle(fontSize: 16, color: Color(0xFF212121)),
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
            const Icon(Icons.play_circle_outline, size: 28),
            const SizedBox(width: 12),
            const Text("Novo Jogo"),
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header com ilustração
              Center(
                child: Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        const Color(0xFF2E7D32),
                        const Color(0xFF388E3C),
                        const Color(0xFF4CAF50),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.sports_soccer,
                          size: 60,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Criar Novo Save',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Configure seu novo mundo de futebol',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // Seção: Informações do Save
              _buildSectionCard(
                title: 'Informações do Save',
                icon: Icons.info_outline,
                children: [
                  TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: 'Nome do Save *',
                      hintText: 'Ex: Meu Primeiro Jogo',
                      prefixIcon: const Icon(Icons.label),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _descriptionController,
                    decoration: InputDecoration(
                      labelText: 'Descrição (opcional)',
                      hintText: 'Ex: Jogo com Flamengo no Brasileirão',
                      prefixIcon: const Icon(Icons.description),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    maxLines: 3,
                  ),
                ],
              ),

              // Seção: Temporada Inicial
              _buildSectionCard(
                title: 'Temporada Inicial',
                icon: Icons.calendar_today,
                children: [
                  _buildSliderField(
                    label: 'Ano da Temporada',
                    value: _selectedSeason,
                    min: 2020,
                    max: 2030,
                    onChanged: (value) {
                      setState(() {
                        _selectedSeason = value;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F5E9),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xFF2E7D32).withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.info_outline,
                          color: Color(0xFF2E7D32),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'O jogo começará na temporada $_selectedSeason',
                            style: const TextStyle(
                              color: Color(0xFF1B5E20),
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              // Seção: Configurações do Mundo
              _buildSectionCard(
                title: 'Configurações do Mundo',
                icon: Icons.public,
                children: [
                  _buildSelectField(
                    label: 'País',
                    value: _selectedCountry,
                    icon: Icons.flag,
                    options: const [
                      'Brasil',
                      'Argentina',
                      'Inglaterra',
                      'Espanha',
                      'Itália',
                      'Alemanha',
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedCountry = value;
                        if (value == null) {
                          _selectedCompetition = null;
                          _selectedClub = null;
                        }
                      });
                    },
                  ),
                  if (_selectedCountry != null) ...[
                    const SizedBox(height: 16),
                    _buildSelectField(
                      label: 'Competição',
                      value: _selectedCompetition,
                      icon: Icons.emoji_events,
                      options: _selectedCountry == 'Brasil'
                          ? const [
                              'Brasileirão Série A',
                              'Brasileirão Série B',
                              'Copa do Brasil',
                            ]
                          : const ['Liga Principal', 'Segunda Divisão'],
                      onChanged: (value) {
                        setState(() {
                          _selectedCompetition = value;
                          if (value == null) {
                            _selectedClub = null;
                          }
                        });
                      },
                    ),
                  ],
                  if (_selectedCompetition != null) ...[
                    const SizedBox(height: 16),
                    _buildSelectField(
                      label: 'Clube para Gerenciar',
                      value: _selectedClub,
                      icon: Icons.shield,
                      options: const [
                        'Flamengo',
                        'Palmeiras',
                        'São Paulo',
                        'Corinthians',
                        'Fluminense',
                        'Santos',
                      ],
                      onChanged: (value) {
                        setState(() {
                          _selectedClub = value;
                        });
                      },
                    ),
                  ],
                ],
              ),

              const SizedBox(height: 20),

              // Botão de Iniciar Jogo
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pushReplacementNamed(context, '/game');
                  },
                  icon: const Icon(Icons.play_arrow, size: 28),
                  label: const Text(
                    'Iniciar Jogo',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2E7D32),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 4,
                  ),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
