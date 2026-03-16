import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/symbol_picker_data.dart';

class CareChip extends StatelessWidget {
  final String label;
  final String emoji;
  final SymbolCategory category;
  final bool small;

  const CareChip({
    super.key,
    required this.label,
    required this.emoji,
    required this.category,
    this.small = false,
  });

  Color _backgroundColor() {
    switch (category) {
      case SymbolCategory.wash:
        return AppColors.washColor.withOpacity(0.12);
      case SymbolCategory.bleach:
        return AppColors.bleachColor.withOpacity(0.15);
      case SymbolCategory.dry:
        return AppColors.dryColor.withOpacity(0.12);
      case SymbolCategory.iron:
        return AppColors.ironColor.withOpacity(0.12);
      case SymbolCategory.dryClean:
        return AppColors.dryCleanColor.withOpacity(0.12);
    }
  }

  Color _borderColor() {
    switch (category) {
      case SymbolCategory.wash:
        return AppColors.washColor.withOpacity(0.3);
      case SymbolCategory.bleach:
        return AppColors.bleachColor.withOpacity(0.3);
      case SymbolCategory.dry:
        return AppColors.dryColor.withOpacity(0.3);
      case SymbolCategory.iron:
        return AppColors.ironColor.withOpacity(0.3);
      case SymbolCategory.dryClean:
        return AppColors.dryCleanColor.withOpacity(0.3);
    }
  }

  Color _textColor() {
    switch (category) {
      case SymbolCategory.wash:
        return AppColors.washColor;
      case SymbolCategory.bleach:
        return const Color(0xFF856404); // dark amber
      case SymbolCategory.dry:
        return AppColors.dryColor;
      case SymbolCategory.iron:
        return AppColors.ironColor;
      case SymbolCategory.dryClean:
        return AppColors.dryCleanColor;
    }
  }

  @override
  Widget build(BuildContext context) {
    final double horizontalPad = small ? 8.0 : 10.0;
    final double verticalPad = small ? 5.0 : 7.0;
    final double emojiSize = small ? 13.0 : 15.0;
    final double textSize = small ? 11.0 : 12.0;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: horizontalPad,
        vertical: verticalPad,
      ),
      decoration: BoxDecoration(
        color: _backgroundColor(),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _borderColor()),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji, style: TextStyle(fontSize: emojiSize)),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              fontSize: textSize,
              fontWeight: FontWeight.w600,
              color: _textColor(),
            ),
          ),
        ],
      ),
    );
  }
}
