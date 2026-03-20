import 'package:fanfoot/core/enums/kit.dart';
import 'package:fanfoot/core/models/club.dart';
import 'package:fanfoot/core/models/country.dart';
import 'package:fanfoot/core/models/kit.dart';
import 'package:fanfoot/core/services/country_service.dart';
import 'package:fanfoot/core/services/kit_service.dart';
import 'package:fanfoot/features/club/widgets/kit_preview.dart';
import 'package:fanfoot/features/editor/widgets/stars.dart';
import 'package:flutter/material.dart';

class ClubGridViewItem extends StatefulWidget {
  final Club club;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const ClubGridViewItem({
    super.key,
    required this.club,
    this.onEdit,
    this.onDelete,
  });

  @override
  State<ClubGridViewItem> createState() => _ClubGridViewItemState();
}

class _ClubGridViewItemState extends State<ClubGridViewItem> {
  final _countryService = CountryService();
  final _kitService = KitService();
  Country? _country;
  List<Kit> _kits = [];
  bool _isLoadingCountry = true;
  bool _isLoadingKits = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final country = await _countryService.getCountry(widget.club.id!);
      if (mounted)
        setState(() {
          _country = country;
          _isLoadingCountry = false;
        });
    } catch (e) {
      if (mounted) setState(() => _isLoadingCountry = false);
    }

    try {
      final kits = await _kitService.getKitsByClubAndSeason(
        widget.club.id!,
        DateTime.now().year,
      );
      if (mounted)
        setState(() {
          _kits = kits;
          _isLoadingKits = false;
        });
    } catch (e) {
      if (mounted) setState(() => _isLoadingKits = false);
    }
  }

  Kit? _getHomeKit() {
    try {
      return _kits.firstWhere((k) => k.type == KitType.home && k.isDefault);
    } catch (_) {
      try {
        return _kits.firstWhere((k) => k.type == KitType.home);
      } catch (_) {
        return _kits.isNotEmpty ? _kits.first : null;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final homeKit = _getHomeKit();

    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Flexible(
              flex: 3,
              child: AspectRatio(
                aspectRatio: 1,
                child: Image.asset(widget.club.crestPath!, fit: BoxFit.contain),
              ),
            ),
            const SizedBox(height: 8),
            Flexible(
              flex: 2,
              child: Text(
                widget.club.name.toUpperCase(),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Stars(rating: 5, isCenter: true),
            const SizedBox(height: 8),
            if (_isLoadingKits)
              const SizedBox(
                height: 40,
                child: Center(
                  child: SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
              )
            else if (_kits.isNotEmpty && homeKit != null)
              SizedBox(
                height: 40,
                child: KitPreview(
                  primaryColor: homeKit.primaryColor,
                  secondaryColor: homeKit.secondaryColor,
                  pattern: homeKit.pattern,
                  width: 28,
                  height: 40,
                ),
              )
            else
              Icon(Icons.checkroom, size: 24, color: Colors.grey[400]),
            const SizedBox(height: 4),
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
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                InkWell(
                  onTap: widget.onEdit,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.blue.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Icon(Icons.edit, size: 16, color: Colors.blue),
                  ),
                ),
                const SizedBox(width: 4),
                InkWell(
                  onTap: widget.onDelete,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.red.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Icon(
                      Icons.delete,
                      size: 16,
                      color: Colors.red,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
