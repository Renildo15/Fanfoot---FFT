import 'package:flutter/material.dart';

class Stars extends StatelessWidget {
  final int rating;
  final bool isCenter;
  const Stars({super.key, required this.rating, required this.isCenter});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: isCenter
          ? MainAxisAlignment.center
          : MainAxisAlignment.start,
      children: List.generate(
        5,
        (index) => Icon(
          index < rating ? Icons.star : Icons.star_border,
          color: Colors.amber,
          size: 24,
        ),
      ),
    );
  }
}
