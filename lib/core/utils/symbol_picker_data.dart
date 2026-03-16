import '../models/garment.dart';

enum SymbolCategory {
  wash,
  bleach,
  dry,
  iron,
  dryClean,
}

extension SymbolCategoryExtension on SymbolCategory {
  String get displayName {
    switch (this) {
      case SymbolCategory.wash:
        return 'Washing';
      case SymbolCategory.bleach:
        return 'Bleaching';
      case SymbolCategory.dry:
        return 'Drying';
      case SymbolCategory.iron:
        return 'Ironing';
      case SymbolCategory.dryClean:
        return 'Dry Cleaning';
    }
  }

  String get emoji {
    switch (this) {
      case SymbolCategory.wash:
        return '🧺';
      case SymbolCategory.bleach:
        return '🧪';
      case SymbolCategory.dry:
        return '💨';
      case SymbolCategory.iron:
        return '🔥';
      case SymbolCategory.dryClean:
        return '🔵';
    }
  }
}

class CareSymbol {
  final String id;
  final String name;
  final String description;
  final String emoji;
  final SymbolCategory category;
  final WashMethod? washMethod;
  final int? temperature;
  final IronLevel? ironLevel;
  final BleachType? bleachType;
  final DryMethod? dryMethod;
  final SpinSpeed? spinSpeed;

  const CareSymbol({
    required this.id,
    required this.name,
    required this.description,
    required this.emoji,
    required this.category,
    this.washMethod,
    this.temperature,
    this.ironLevel,
    this.bleachType,
    this.dryMethod,
    this.spinSpeed,
  });
}

class SymbolPickerData {
  SymbolPickerData._();

  static List<CareSymbol> get allSymbols => [
    // ── Washing ──────────────────────────────────────────────────────────────
    const CareSymbol(
      id: 'wash_30',
      name: 'Machine Wash 30°C',
      description: 'Machine wash at a maximum temperature of 30°C (cold).',
      emoji: '🧺',
      category: SymbolCategory.wash,
      washMethod: WashMethod.machineWashCold,
      temperature: 30,
    ),
    const CareSymbol(
      id: 'wash_30_gentle',
      name: 'Machine Wash 30°C Gentle',
      description: 'Machine wash at 30°C on gentle/delicate cycle.',
      emoji: '🧺',
      category: SymbolCategory.wash,
      washMethod: WashMethod.machineWashCold,
      temperature: 30,
      spinSpeed: SpinSpeed.gentle,
    ),
    const CareSymbol(
      id: 'wash_40',
      name: 'Machine Wash 40°C',
      description: 'Machine wash at a maximum temperature of 40°C (warm).',
      emoji: '🧺',
      category: SymbolCategory.wash,
      washMethod: WashMethod.machineWashWarm,
      temperature: 40,
    ),
    const CareSymbol(
      id: 'wash_40_gentle',
      name: 'Machine Wash 40°C Gentle',
      description: 'Machine wash at 40°C on gentle/delicate cycle.',
      emoji: '🧺',
      category: SymbolCategory.wash,
      washMethod: WashMethod.machineWashWarm,
      temperature: 40,
      spinSpeed: SpinSpeed.gentle,
    ),
    const CareSymbol(
      id: 'wash_60',
      name: 'Machine Wash 60°C',
      description: 'Machine wash at a maximum temperature of 60°C (hot).',
      emoji: '🧺',
      category: SymbolCategory.wash,
      washMethod: WashMethod.machineWashHot,
      temperature: 60,
    ),
    const CareSymbol(
      id: 'wash_95',
      name: 'Machine Wash 95°C',
      description: 'Machine wash at up to 95°C for sanitation.',
      emoji: '🧺',
      category: SymbolCategory.wash,
      washMethod: WashMethod.machineWashHot,
      temperature: 95,
    ),
    const CareSymbol(
      id: 'wash_hand',
      name: 'Hand Wash',
      description: 'Hand wash only in cool water with gentle detergent.',
      emoji: '🖐️',
      category: SymbolCategory.wash,
      washMethod: WashMethod.handWash,
      temperature: 30,
    ),
    const CareSymbol(
      id: 'wash_no',
      name: 'Do Not Wash',
      description: 'Do not wash with water.',
      emoji: '🚫',
      category: SymbolCategory.wash,
      washMethod: WashMethod.doNotWash,
    ),
    const CareSymbol(
      id: 'spin_no',
      name: 'Do Not Spin',
      description: 'Remove from machine without spinning.',
      emoji: '🚫',
      category: SymbolCategory.wash,
      spinSpeed: SpinSpeed.noSpin,
    ),

    // ── Bleaching ────────────────────────────────────────────────────────────
    const CareSymbol(
      id: 'bleach_any',
      name: 'Bleach Allowed',
      description: 'Any type of bleach may be used when necessary.',
      emoji: '🧪',
      category: SymbolCategory.bleach,
      bleachType: BleachType.anyBleach,
    ),
    const CareSymbol(
      id: 'bleach_nonchlorine',
      name: 'Non-Chlorine Bleach Only',
      description: 'Only non-chlorine (oxygen-based) bleach may be used.',
      emoji: '⚗️',
      category: SymbolCategory.bleach,
      bleachType: BleachType.nonChlorineOnly,
    ),
    const CareSymbol(
      id: 'bleach_no',
      name: 'Do Not Bleach',
      description: 'Do not use any type of bleach on this garment.',
      emoji: '🚫',
      category: SymbolCategory.bleach,
      bleachType: BleachType.noBleach,
    ),

    // ── Drying ───────────────────────────────────────────────────────────────
    const CareSymbol(
      id: 'dry_tumble_low',
      name: 'Tumble Dry Low Heat',
      description: 'Tumble dry using low heat setting only.',
      emoji: '🌀',
      category: SymbolCategory.dry,
      dryMethod: DryMethod.tumbleDryLow,
    ),
    const CareSymbol(
      id: 'dry_tumble_medium',
      name: 'Tumble Dry Medium Heat',
      description: 'Tumble dry using medium heat setting.',
      emoji: '🌀',
      category: SymbolCategory.dry,
      dryMethod: DryMethod.tumbleDryMedium,
    ),
    const CareSymbol(
      id: 'dry_tumble_high',
      name: 'Tumble Dry High Heat',
      description: 'Tumble dry using high heat setting.',
      emoji: '🌀',
      category: SymbolCategory.dry,
      dryMethod: DryMethod.tumbleDryHigh,
    ),
    const CareSymbol(
      id: 'dry_tumble_no_heat',
      name: 'Tumble Dry No Heat',
      description: 'Tumble dry on air-only cycle with no heat.',
      emoji: '🌀',
      category: SymbolCategory.dry,
      dryMethod: DryMethod.tumbleDryLow,
    ),
    const CareSymbol(
      id: 'dry_tumble_no',
      name: 'Do Not Tumble Dry',
      description: 'Do not use a tumble dryer.',
      emoji: '🚫',
      category: SymbolCategory.dry,
      dryMethod: DryMethod.doNotTumbleDry,
    ),
    const CareSymbol(
      id: 'dry_line',
      name: 'Line Dry',
      description: 'Hang on a line or hanger to air dry.',
      emoji: '🪢',
      category: SymbolCategory.dry,
      dryMethod: DryMethod.lineDry,
    ),
    const CareSymbol(
      id: 'dry_line_shade',
      name: 'Line Dry in Shade',
      description: 'Hang to dry away from direct sunlight.',
      emoji: '🌥️',
      category: SymbolCategory.dry,
      dryMethod: DryMethod.lineDry,
    ),
    const CareSymbol(
      id: 'dry_flat',
      name: 'Dry Flat',
      description: 'Lay flat on a clean surface to dry and maintain shape.',
      emoji: '📐',
      category: SymbolCategory.dry,
      dryMethod: DryMethod.dryFlat,
    ),
    const CareSymbol(
      id: 'dry_drip',
      name: 'Drip Dry',
      description: 'Hang while wet and allow to drip dry naturally.',
      emoji: '💧',
      category: SymbolCategory.dry,
      dryMethod: DryMethod.dripDry,
    ),
    const CareSymbol(
      id: 'dry_shade',
      name: 'Dry in Shade',
      description: 'Dry away from direct sunlight to prevent fading.',
      emoji: '🌤️',
      category: SymbolCategory.dry,
      dryMethod: DryMethod.lineDry,
    ),

    // ── Ironing ──────────────────────────────────────────────────────────────
    const CareSymbol(
      id: 'iron_low',
      name: 'Iron Low Heat (110°C)',
      description: 'Iron at low temperature, maximum 110°C. Suitable for synthetics.',
      emoji: '🔥',
      category: SymbolCategory.iron,
      ironLevel: IronLevel.low,
      temperature: 110,
    ),
    const CareSymbol(
      id: 'iron_medium',
      name: 'Iron Medium Heat (150°C)',
      description: 'Iron at medium temperature, maximum 150°C. Suitable for wool.',
      emoji: '🔥',
      category: SymbolCategory.iron,
      ironLevel: IronLevel.medium,
      temperature: 150,
    ),
    const CareSymbol(
      id: 'iron_high',
      name: 'Iron High Heat (200°C)',
      description: 'Iron at high temperature, maximum 200°C. Suitable for cotton and linen.',
      emoji: '🔥',
      category: SymbolCategory.iron,
      ironLevel: IronLevel.high,
      temperature: 200,
    ),
    const CareSymbol(
      id: 'iron_steam_ok',
      name: 'Steam Ironing OK',
      description: 'Steam ironing is permitted.',
      emoji: '💨',
      category: SymbolCategory.iron,
      ironLevel: IronLevel.steamOk,
    ),
    const CareSymbol(
      id: 'iron_steam_no',
      name: 'Do Not Steam',
      description: 'Iron without steam — steam can damage this fabric.',
      emoji: '💨',
      category: SymbolCategory.iron,
      ironLevel: IronLevel.medium,
    ),
    const CareSymbol(
      id: 'iron_no',
      name: 'Do Not Iron',
      description: 'Do not apply heat from an iron.',
      emoji: '🚫',
      category: SymbolCategory.iron,
      ironLevel: IronLevel.noIron,
    ),

    // ── Dry Cleaning ─────────────────────────────────────────────────────────
    const CareSymbol(
      id: 'dryclean_any',
      name: 'Dry Clean',
      description: 'Dry clean with any suitable solvent.',
      emoji: '🔵',
      category: SymbolCategory.dryClean,
      washMethod: WashMethod.dryCleanOnly,
    ),
    const CareSymbol(
      id: 'dryclean_gentle',
      name: 'Dry Clean — Gentle Treatment',
      description: 'Dry clean with gentle treatment. Inform cleaner of delicacy.',
      emoji: '🔵',
      category: SymbolCategory.dryClean,
      washMethod: WashMethod.dryCleanOnly,
    ),
    const CareSymbol(
      id: 'dryclean_no',
      name: 'Do Not Dry Clean',
      description: 'Do not dry clean this garment.',
      emoji: '🚫',
      category: SymbolCategory.dryClean,
    ),
  ];

  static Map<SymbolCategory, List<CareSymbol>> get symbolsByCategory {
    final map = <SymbolCategory, List<CareSymbol>>{};
    for (final category in SymbolCategory.values) {
      map[category] = allSymbols.where((s) => s.category == category).toList();
    }
    return map;
  }

  static CareSymbol? findById(String id) {
    try {
      return allSymbols.firstWhere((s) => s.id == id);
    } catch (_) {
      return null;
    }
  }
}
