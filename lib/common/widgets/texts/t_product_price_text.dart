import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TProductPriceText extends StatelessWidget {
  const TProductPriceText({
    super.key,
    this.currencySign = '₦ ',
    required this.price,
    this.isLarge = false,
    this.maxLines = 1,
    this.lineThrough = false,
  });

  final String currencySign, price;
  final int maxLines;
  final bool isLarge;
  final bool lineThrough;

  @override
  Widget build(BuildContext context) {
    final baseStyle = isLarge
        ? Theme.of(context).textTheme.headlineMedium
        : Theme.of(context).textTheme.titleLarge;

    return Text(
      '$currencySign$price',
      maxLines: maxLines,
      overflow: TextOverflow.ellipsis,
      style: GoogleFonts.roboto(
        fontSize: baseStyle?.fontSize,
        fontWeight: baseStyle?.fontWeight,
        color: baseStyle?.color,
        decoration: lineThrough ? TextDecoration.lineThrough : null,
      ),
    );
  }
}