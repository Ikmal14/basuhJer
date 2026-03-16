import '../models/garment.dart';
import '../models/care_profile.dart';

class CareTextParser {
  CareTextParser._();

  static CareProfile parseTagText(String text) {
    final normalizedText = text.toLowerCase().trim();

    final washMethod = _parseWashMethod(normalizedText);
    final temperature = _parseTemperature(normalizedText);
    final ironLevel = _parseIronLevel(normalizedText);
    final bleachType = _parseBleachType(normalizedText);
    final dryMethod = _parseDryMethod(normalizedText);
    final spinSpeed = _parseSpinSpeed(normalizedText);
    final fabricComposition = _parseFabricComposition(normalizedText);

    final doList = _generateDoList(
      washMethod: washMethod,
      temperature: temperature,
      ironLevel: ironLevel,
      bleachType: bleachType,
      dryMethod: dryMethod,
      spinSpeed: spinSpeed,
      fabrics: fabricComposition,
    );

    final dontList = _generateDontList(
      washMethod: washMethod,
      ironLevel: ironLevel,
      bleachType: bleachType,
      dryMethod: dryMethod,
      spinSpeed: spinSpeed,
    );

    final chemicalsAllowed = _generateChemicalsAllowed(bleachType: bleachType, washMethod: washMethod);
    final chemicalsNotAllowed = _generateChemicalsNotAllowed(bleachType: bleachType, washMethod: washMethod);

    return CareProfile(
      washMethod: washMethod,
      maxTemperature: temperature,
      ironLevel: ironLevel,
      bleachType: bleachType,
      dryMethod: dryMethod,
      spinSpeed: spinSpeed,
      doList: doList,
      dontList: dontList,
      chemicalsAllowed: chemicalsAllowed,
      chemicalsNotAllowed: chemicalsNotAllowed,
      fabricComposition: fabricComposition,
      selectedSymbolIds: const [],
      rawTagText: text,
    );
  }

  static WashMethod _parseWashMethod(String text) {
    // Check dry clean first (highest priority)
    if (_matchesAny(text, [
      'dry clean only',
      'dry-clean only',
      'dryclean only',
      r'dry clean$',
      'professional clean',
      'professionally clean',
    ])) {
      return WashMethod.dryCleanOnly;
    }

    // Do not wash
    if (_matchesAny(text, [
      'do not wash',
      'do not machine wash',
      'no wash',
      r'wash\s*:\s*no',
    ])) {
      return WashMethod.doNotWash;
    }

    // Hand wash
    if (_matchesAny(text, [
      'hand wash only',
      'hand wash',
      'hand-wash',
      'handwash',
      'wash by hand',
      'gentle hand',
    ])) {
      return WashMethod.handWash;
    }

    // Machine wash — detect temperature to determine cold/warm/hot
    final temp = _parseTemperature(text);

    if (_matchesAny(text, [
      'machine wash',
      'machine-wash',
      'machine washable',
      'washable',
      'tumble wash',
      r'\d+\s*°?\s*[cf]',
    ])) {
      if (temp != null) {
        if (temp <= 30) return WashMethod.machineWashCold;
        if (temp <= 45) return WashMethod.machineWashWarm;
        return WashMethod.machineWashHot;
      }

      if (_matchesAny(text, ['cold', 'cool', r'30\s*°?c', r'30\s*°?f'])) {
        return WashMethod.machineWashCold;
      }
      if (_matchesAny(text, ['warm', r'40\s*°?c'])) {
        return WashMethod.machineWashWarm;
      }
      if (_matchesAny(text, ['hot', r'60\s*°?c', r'95\s*°?c'])) {
        return WashMethod.machineWashHot;
      }
      return WashMethod.machineWashCold; // default to cold if not specified
    }

    // Temperature alone implies machine wash
    if (temp != null) {
      if (temp <= 30) return WashMethod.machineWashCold;
      if (temp <= 45) return WashMethod.machineWashWarm;
      return WashMethod.machineWashHot;
    }

    return WashMethod.unknown;
  }

  static int? _parseTemperature(String text) {
    // Match patterns like "30°C", "40 °C", "40C", "40°", "30 degrees"
    final celsiusPattern = RegExp(r'(\d+)\s*°?\s*c(?:\b|elsius)', caseSensitive: false);
    final degreePattern = RegExp(r'(\d+)\s*°(?:\s|$)', caseSensitive: false);
    final degreesPattern = RegExp(r'(\d+)\s*degrees', caseSensitive: false);
    final fahrenheitPattern = RegExp(r'(\d+)\s*°?\s*f(?:\b|ahrenheit)', caseSensitive: false);

    // Try Celsius first
    var match = celsiusPattern.firstMatch(text);
    if (match != null) {
      return int.tryParse(match.group(1)!);
    }

    match = degreePattern.firstMatch(text);
    if (match != null) {
      return int.tryParse(match.group(1)!);
    }

    match = degreesPattern.firstMatch(text);
    if (match != null) {
      return int.tryParse(match.group(1)!);
    }

    // Fahrenheit — convert to Celsius
    match = fahrenheitPattern.firstMatch(text);
    if (match != null) {
      final f = int.tryParse(match.group(1)!);
      if (f != null) {
        return ((f - 32) * 5 / 9).round();
      }
    }

    // Common temperature words
    if (_matchesAny(text, [r'\bcold\b', r'\bcool\b'])) return 30;
    if (_matchesAny(text, [r'\bwarm\b'])) return 40;
    if (_matchesAny(text, [r'\bhot\b'])) return 60;

    return null;
  }

  static IronLevel _parseIronLevel(String text) {
    // Do not iron
    if (_matchesAny(text, [
      'do not iron',
      'do not use iron',
      'no iron',
      'no ironing',
      'iron no',
      'cannot be ironed',
    ])) {
      return IronLevel.noIron;
    }

    // Steam iron check
    if (_matchesAny(text, ['steam iron', 'steam ok', 'steam press', 'can steam'])) {
      return IronLevel.steamOk;
    }

    // Check for iron temperature in °C
    final ironTempPattern = RegExp(
      r'iron\s+(?:at\s+)?(\d+)\s*°?\s*c',
      caseSensitive: false,
    );
    final ironTempMatch = ironTempPattern.firstMatch(text);
    if (ironTempMatch != null) {
      final temp = int.tryParse(ironTempMatch.group(1)!);
      if (temp != null) {
        if (temp <= 110) return IronLevel.low;
        if (temp <= 150) return IronLevel.medium;
        return IronLevel.high;
      }
    }

    // Dot notation: one dot = low, two dots = medium, three dots = high
    if (text.contains('•••') || text.contains('...') || _matchesAny(text, [r'iron\s+high', r'high\s+heat\s+iron'])) {
      return IronLevel.high;
    }
    if (text.contains('••') || _matchesAny(text, [r'iron\s+medium', r'medium\s+heat\s+iron', r'warm\s+iron'])) {
      return IronLevel.medium;
    }
    if (text.contains('•') || _matchesAny(text, [r'iron\s+low', r'low\s+heat\s+iron', r'cool\s+iron'])) {
      return IronLevel.low;
    }

    // Temperature-based detection
    if (_matchesAny(text, [r'iron\s+110', r'110°?\s*c\s+iron', r'iron.*110'])) {
      return IronLevel.low;
    }
    if (_matchesAny(text, [r'iron\s+150', r'150°?\s*c\s+iron', r'iron.*150'])) {
      return IronLevel.medium;
    }
    if (_matchesAny(text, [r'iron\s+200', r'200°?\s*c\s+iron', r'iron.*200'])) {
      return IronLevel.high;
    }

    // Generic "warm iron"
    if (_matchesAny(text, [r'\bwarm iron\b', r'\biron warm\b'])) {
      return IronLevel.medium;
    }

    // Generic "iron" without qualifier
    if (_matchesAny(text, [r'\biron\b'])) {
      return IronLevel.medium;
    }

    return IronLevel.unknown;
  }

  static BleachType _parseBleachType(String text) {
    // No bleach
    if (_matchesAny(text, [
      'do not bleach',
      'no bleach',
      'bleach no',
      'do not use bleach',
      'without bleach',
    ])) {
      return BleachType.noBleach;
    }

    // Non-chlorine only
    if (_matchesAny(text, [
      'non-chlorine bleach',
      'non chlorine bleach',
      'oxygen bleach only',
      'color safe bleach only',
      'colour safe bleach only',
      'if needed',  // common phrase after "non-chlorine bleach if needed"
    ]) && _matchesAny(text, ['bleach', 'non-chlorine', 'nonchlorine'])) {
      if (_matchesAny(text, [
        'non-chlorine',
        'non chlorine',
        'oxygen bleach',
        'color safe bleach',
        'colour safe bleach',
      ])) {
        return BleachType.nonChlorineOnly;
      }
    }

    // Any bleach allowed
    if (_matchesAny(text, [
      'bleach ok',
      'bleach allowed',
      'bleach acceptable',
      'bleach when needed',
    ])) {
      return BleachType.anyBleach;
    }

    return BleachType.unknown;
  }

  static DryMethod _parseDryMethod(String text) {
    // Do not tumble dry
    if (_matchesAny(text, [
      'do not tumble dry',
      'do not tumble',
      'no tumble dry',
      'no tumble',
      'tumble dry no',
    ])) {
      // Check if there's an alternative method mentioned
      if (_matchesAny(text, ['flat dry', 'dry flat', 'lay flat'])) {
        return DryMethod.dryFlat;
      }
      if (_matchesAny(text, ['line dry', 'hang dry', 'hang to dry', 'air dry'])) {
        return DryMethod.lineDry;
      }
      return DryMethod.doNotTumbleDry;
    }

    // Dry flat
    if (_matchesAny(text, [
      'dry flat',
      'flat dry',
      'lay flat',
      'lay flat to dry',
    ])) {
      return DryMethod.dryFlat;
    }

    // Drip dry
    if (_matchesAny(text, ['drip dry', 'drip-dry'])) {
      return DryMethod.dripDry;
    }

    // Line dry / air dry
    if (_matchesAny(text, [
      'line dry',
      'hang dry',
      'hang to dry',
      'air dry',
      'air-dry',
      'dry naturally',
      'dry in the air',
    ])) {
      return DryMethod.lineDry;
    }

    // Tumble dry with heat level
    if (_matchesAny(text, ['tumble dry low', 'tumble dry on low', 'low tumble', 'low heat tumble'])) {
      return DryMethod.tumbleDryLow;
    }
    if (_matchesAny(text, ['tumble dry medium', 'tumble dry on medium', 'medium tumble', 'medium heat tumble'])) {
      return DryMethod.tumbleDryMedium;
    }
    if (_matchesAny(text, ['tumble dry high', 'tumble dry on high', 'high tumble', 'high heat tumble'])) {
      return DryMethod.tumbleDryHigh;
    }

    // Generic tumble dry
    if (_matchesAny(text, ['tumble dry', 'machine dry'])) {
      return DryMethod.tumbleDryMedium;
    }

    return DryMethod.unknown;
  }

  static SpinSpeed _parseSpinSpeed(String text) {
    if (_matchesAny(text, ['do not spin', 'no spin', 'do not wring', 'no wring'])) {
      return SpinSpeed.noSpin;
    }
    if (_matchesAny(text, ['gentle spin', 'gentle cycle', 'delicate cycle', 'gentle wash'])) {
      return SpinSpeed.gentle;
    }
    if (_matchesAny(text, ['normal spin', 'regular spin', 'normal cycle'])) {
      return SpinSpeed.normal;
    }
    return SpinSpeed.unknown;
  }

  static List<String> _parseFabricComposition(String text) {
    final fabrics = <String>[];

    // Common fabric patterns with percentage: "100% Cotton", "80% Polyester 20% Cotton"
    final percentagePattern = RegExp(
      r'(\d+)\s*%\s*(cotton|polyester|nylon|wool|silk|linen|viscose|rayon|acrylic|spandex|elastane|lycra|modal|bamboo|cashmere|hemp|tencel|lyocell|fleece)',
      caseSensitive: false,
    );

    final matches = percentagePattern.allMatches(text);
    for (final match in matches) {
      final percentage = match.group(1);
      final fabric = _capitalizeFabric(match.group(2)!);
      fabrics.add('$percentage% $fabric');
    }

    // Fabric without percentage
    if (fabrics.isEmpty) {
      final fabricKeywords = [
        'cotton', 'polyester', 'nylon', 'wool', 'silk', 'linen',
        'viscose', 'rayon', 'acrylic', 'spandex', 'elastane', 'lycra',
        'modal', 'bamboo', 'cashmere', 'hemp', 'tencel', 'lyocell', 'fleece',
      ];
      for (final fabric in fabricKeywords) {
        if (text.contains(fabric)) {
          fabrics.add(_capitalizeFabric(fabric));
        }
      }
    }

    return fabrics;
  }

  static String _capitalizeFabric(String fabric) {
    if (fabric.isEmpty) return fabric;
    return fabric[0].toUpperCase() + fabric.substring(1).toLowerCase();
  }

  static bool _matchesAny(String text, List<String> patterns) {
    for (final pattern in patterns) {
      if (RegExp(pattern, caseSensitive: false).hasMatch(text)) {
        return true;
      }
    }
    return false;
  }

  static List<String> _generateDoList({
    required WashMethod washMethod,
    required int? temperature,
    required IronLevel ironLevel,
    required BleachType bleachType,
    required DryMethod dryMethod,
    required SpinSpeed spinSpeed,
    required List<String> fabrics,
  }) {
    final dos = <String>[];

    switch (washMethod) {
      case WashMethod.machineWashCold:
        dos.add('Wash in cold water (max ${temperature ?? 30}°C)');
        dos.add('Sort laundry by color before washing');
        dos.add('Use mild laundry detergent');
        break;
      case WashMethod.machineWashWarm:
        dos.add('Wash in warm water (max ${temperature ?? 40}°C)');
        dos.add('Sort laundry by color and fabric type');
        dos.add('Use standard laundry detergent');
        break;
      case WashMethod.machineWashHot:
        dos.add('Wash in hot water (max ${temperature ?? 60}°C)');
        dos.add('Suitable for heavily soiled items');
        break;
      case WashMethod.handWash:
        dos.add('Wash gently by hand in cool water');
        dos.add('Use gentle detergent or delicate wash');
        dos.add('Gently squeeze water through fabric');
        dos.add('Rinse thoroughly with clean water');
        break;
      case WashMethod.dryCleanOnly:
        dos.add('Take to a professional dry cleaner');
        dos.add('Air out after dry cleaning before storing');
        dos.add('Inform cleaner of any stains or fabric concerns');
        break;
      case WashMethod.doNotWash:
        dos.add('Spot clean only with a damp cloth');
        dos.add('Air the garment regularly to freshen');
        break;
      case WashMethod.unknown:
        dos.add('Check the original tag for wash instructions');
        dos.add('When in doubt, use cold water and gentle cycle');
        break;
    }

    if (spinSpeed == SpinSpeed.gentle) {
      dos.add('Use a gentle or delicate spin cycle');
    }

    switch (dryMethod) {
      case DryMethod.lineDry:
        dos.add('Hang to dry on a clothesline or hanger');
        dos.add('Dry away from direct sunlight');
        break;
      case DryMethod.dryFlat:
        dos.add('Dry flat on a clean, dry surface');
        dos.add('Reshape while damp');
        break;
      case DryMethod.tumbleDryLow:
        dos.add('Use tumble dryer on low heat setting');
        dos.add('Remove promptly when dry');
        break;
      case DryMethod.tumbleDryMedium:
        dos.add('Tumble dry on medium heat');
        break;
      case DryMethod.dripDry:
        dos.add('Hang while wet and allow to drip dry naturally');
        break;
      default:
        break;
    }

    switch (ironLevel) {
      case IronLevel.low:
        dos.add('Iron on low heat (max 110°C)');
        dos.add('Iron on the reverse side to protect surface');
        break;
      case IronLevel.medium:
        dos.add('Iron on medium heat (max 150°C)');
        dos.add('Use steam if available for easier ironing');
        break;
      case IronLevel.high:
        dos.add('Iron on high heat (max 200°C)');
        dos.add('Lightly dampen fabric before ironing for best results');
        break;
      case IronLevel.steamOk:
        dos.add('Steam ironing is safe and recommended');
        break;
      default:
        break;
    }

    if (bleachType == BleachType.anyBleach) {
      dos.add('Bleach can be used when needed');
    } else if (bleachType == BleachType.nonChlorineOnly) {
      dos.add('Non-chlorine or oxygen bleach is safe to use');
    }

    if (fabrics.isNotEmpty) {
      dos.add('Store clean and dry to prevent mildew');
      if (fabrics.any((f) => f.toLowerCase().contains('wool') || f.toLowerCase().contains('cashmere'))) {
        dos.add('Store folded (not hung) to prevent stretching');
        dos.add('Use cedar blocks or lavender sachets to deter moths');
      }
      if (fabrics.any((f) => f.toLowerCase().contains('silk'))) {
        dos.add('Store in a breathable bag away from direct light');
      }
    }

    return dos;
  }

  static List<String> _generateDontList({
    required WashMethod washMethod,
    required IronLevel ironLevel,
    required BleachType bleachType,
    required DryMethod dryMethod,
    required SpinSpeed spinSpeed,
  }) {
    final donts = <String>[];

    switch (washMethod) {
      case WashMethod.machineWashCold:
        donts.add('Do not wash in hot water — may shrink or damage fabric');
        break;
      case WashMethod.machineWashWarm:
        donts.add('Do not exceed 40°C wash temperature');
        break;
      case WashMethod.machineWashHot:
        donts.add('Not suitable for delicate or brightly colored items');
        break;
      case WashMethod.handWash:
        donts.add('Do not machine wash — agitation may damage the fabric');
        donts.add('Do not wring or twist the garment');
        donts.add('Do not scrub with a brush');
        break;
      case WashMethod.dryCleanOnly:
        donts.add('Do not wash with water at home');
        donts.add('Do not use household detergents');
        donts.add('Do not tumble dry');
        break;
      case WashMethod.doNotWash:
        donts.add('Do not wash with water');
        donts.add('Do not machine wash');
        break;
      default:
        break;
    }

    if (spinSpeed == SpinSpeed.noSpin) {
      donts.add('Do not use the spin cycle — remove gently and press dry');
    }

    switch (dryMethod) {
      case DryMethod.doNotTumbleDry:
      case DryMethod.lineDry:
      case DryMethod.dryFlat:
      case DryMethod.dripDry:
        donts.add('Do not use a tumble dryer');
        break;
      case DryMethod.dryFlat:
        donts.add('Do not hang — the weight of water may distort the shape');
        break;
      default:
        break;
    }

    switch (ironLevel) {
      case IronLevel.noIron:
        donts.add('Do not iron — heat will damage the fabric or finish');
        break;
      case IronLevel.low:
        donts.add('Do not iron above 110°C — fabric may melt or scorch');
        break;
      case IronLevel.medium:
        donts.add('Do not iron above 150°C');
        break;
      case IronLevel.high:
        donts.add('Let iron warm up fully before use');
        break;
      default:
        break;
    }

    switch (bleachType) {
      case BleachType.noBleach:
        donts.add('Do not use any bleach — will damage color and fibers');
        break;
      case BleachType.nonChlorineOnly:
        donts.add('Do not use chlorine (household) bleach');
        break;
      default:
        break;
    }

    donts.add('Do not leave wet garment bunched up — mildew may develop');

    return donts;
  }

  static List<String> _generateChemicalsAllowed({
    required BleachType bleachType,
    required WashMethod washMethod,
  }) {
    final allowed = <String>[];

    if (washMethod == WashMethod.dryCleanOnly) {
      allowed.addAll([
        'Professional dry-cleaning solvents',
        'Dry-cleaning spot treatment products',
      ]);
      return allowed;
    }

    if (washMethod == WashMethod.doNotWash) {
      allowed.add('Dry-cleaning specialist products only');
      return allowed;
    }

    allowed.add('Mild laundry detergent');

    if (washMethod != WashMethod.handWash) {
      allowed.add('Fabric softener');
    }

    switch (bleachType) {
      case BleachType.anyBleach:
        allowed.add('Chlorine bleach (use sparingly)');
        allowed.add('Non-chlorine (oxygen) bleach');
        allowed.add('Color-safe stain remover');
        allowed.add('Enzyme-based stain remover');
        break;
      case BleachType.nonChlorineOnly:
        allowed.add('Non-chlorine (oxygen) bleach');
        allowed.add('Color-safe bleach');
        allowed.add('Color-safe stain remover');
        break;
      case BleachType.noBleach:
      case BleachType.unknown:
        allowed.add('Color-safe stain remover (test first)');
        break;
    }

    return allowed;
  }

  static List<String> _generateChemicalsNotAllowed({
    required BleachType bleachType,
    required WashMethod washMethod,
  }) {
    final notAllowed = <String>[];

    if (washMethod == WashMethod.dryCleanOnly) {
      notAllowed.addAll([
        'Water-based detergents',
        'Any bleach',
        'Home stain removers',
        'Fabric softener',
      ]);
      return notAllowed;
    }

    if (washMethod == WashMethod.doNotWash) {
      notAllowed.addAll([
        'Water-based detergents',
        'Any bleach',
        'Stain removers',
      ]);
      return notAllowed;
    }

    switch (bleachType) {
      case BleachType.noBleach:
        notAllowed.add('Chlorine bleach');
        notAllowed.add('Non-chlorine bleach');
        notAllowed.add('Bleach-containing laundry products');
        break;
      case BleachType.nonChlorineOnly:
        notAllowed.add('Chlorine bleach (sodium hypochlorite)');
        notAllowed.add('Household bleach');
        break;
      default:
        break;
    }

    notAllowed.add('Dry-cleaning solvents at home');
    notAllowed.add('Harsh abrasive cleaners');

    return notAllowed;
  }
}
