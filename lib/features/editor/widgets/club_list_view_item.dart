import 'package:fanfoot/core/models/country.dart';
import 'package:fanfoot/core/services/country_service.dart';
import 'package:fanfoot/features/editor/widgets/stars.dart';
import 'package:flutter/material.dart';
import 'package:fanfoot/core/models/club.dart';

class ClubListViewItem extends StatefulWidget {
  final Club club;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const ClubListViewItem({
    super.key,
    required this.club,
    this.onEdit,
    this.onDelete,
  });

  @override
  State<ClubListViewItem> createState() => _ClubListViewItemState();
}

class _ClubListViewItemState extends State<ClubListViewItem> {
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
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            SizedBox(
              height: 90,
              width: 90,
              child: Image.asset(widget.club.crestPath!),
            ),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        widget.club.name.toUpperCase(),
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(width: 10),
                      if (_isLoadingCountry)
                        const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      else if (_country != null)
                        Image.network(
                          _country!.flag,
                          width: 24,
                          height: 24,
                          errorBuilder: (_, __, ___) => const Icon(Icons.flag),
                        ),
                    ],
                  ),
                  Stars(rating: 5, isCenter: false),
                ],
              ),
            ),
            Row(
              children: [
                IconButton(
                  onPressed: () {},
                  icon: Icon(Icons.edit, color: Colors.blue),
                  tooltip: "Editar",
                ),
                IconButton(
                  onPressed: () {},
                  icon: Icon(Icons.delete, color: Colors.red),
                  tooltip: "Editar",
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
