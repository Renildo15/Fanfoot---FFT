import 'package:fanfoot/core/models/club.dart';
import 'package:fanfoot/core/models/country.dart';
import 'package:fanfoot/core/services/country_service.dart';
import 'package:fanfoot/features/editor/widgets/stars.dart';
import 'package:flutter/material.dart';

class ClubGridViewItem extends StatefulWidget {
  final Club club;

  const ClubGridViewItem({super.key, required this.club});

  @override
  State<ClubGridViewItem> createState() => _ClubGridViewItemState();
}

class _ClubGridViewItemState extends State<ClubGridViewItem> {
  final _countryService = CountryService();
  Country? _country;
  bool _isLoadingCountry = true;

  @override
  void initState() {
    super.initState();
    _loadCountry();
  }

  Future<void> _loadCountry() async {
    try {
      final country = await _countryService.getCountry(widget.club.id!);
      setState(() {
        _country = country;
        _isLoadingCountry = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingCountry = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo do clube
            Flexible(
              flex: 4,
              child: AspectRatio(
                aspectRatio: 1,
                child: Image.asset(widget.club.crestPath!, fit: BoxFit.contain),
              ),
            ),

            const SizedBox(height: 12),

            // Nome do clube
            Flexible(
              flex: 2,
              child: Text(
                widget.club.name.toUpperCase(),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 6),

            // Estrelas centralizadas
            Stars(rating: 5, isCenter: true),

            const SizedBox(height: 6),

            // Bandeira do país
            SizedBox(
              width: 28,
              height: 20,
              child: _isLoadingCountry
                  ? const Center(
                      child: SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    )
                  : (_country != null
                        ? Image.asset(
                            _country!.flag,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) =>
                                const Icon(Icons.flag, size: 18),
                          )
                        : const Icon(Icons.flag, size: 18)),
            ),
          ],
        ),
      ),
    );
  }
}
