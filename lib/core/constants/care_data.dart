import '../models/garment.dart';

class WashGuideStep {
  final int step;
  final String emoji;
  final String title;
  final String description;

  const WashGuideStep({
    required this.step,
    required this.emoji,
    required this.title,
    required this.description,
  });
}

class FabricCareTip {
  final String fabric;
  final List<String> tips;
  final List<String> warnings;

  const FabricCareTip({
    required this.fabric,
    required this.tips,
    required this.warnings,
  });
}

class CareData {
  CareData._();

  // Wash guide templates by method
  static Map<WashMethod, List<WashGuideStep>> get washGuides => {
    WashMethod.machineWashCold: [
      WashGuideStep(
        step: 1,
        emoji: '🔍',
        title: 'Sort by Color',
        description: 'Separate darks, lights, and whites before washing to prevent color bleeding.',
      ),
      WashGuideStep(
        step: 2,
        emoji: '🔄',
        title: 'Turn Inside Out',
        description: 'Turn dark or printed garments inside out to protect the outer surface from fading.',
      ),
      WashGuideStep(
        step: 3,
        emoji: '🧊',
        title: 'Set Cold Water (30°C max)',
        description: 'Use cold water setting on your machine. Cold water is gentler on fabrics and saves energy.',
      ),
      WashGuideStep(
        step: 4,
        emoji: '🧴',
        title: 'Add Mild Detergent',
        description: 'Use the recommended amount of mild detergent. Too much leaves residue on fabric.',
      ),
      WashGuideStep(
        step: 5,
        emoji: '🌀',
        title: 'Select Gentle Cycle',
        description: 'Choose a gentle or normal cycle depending on how soiled the garment is.',
      ),
      WashGuideStep(
        step: 6,
        emoji: '💨',
        title: 'Remove Promptly',
        description: 'Remove from machine promptly after washing to prevent wrinkles and mildew.',
      ),
    ],
    WashMethod.machineWashWarm: [
      WashGuideStep(
        step: 1,
        emoji: '🔍',
        title: 'Sort by Color and Fabric',
        description: 'Separate by color and check that all items are suitable for warm washing.',
      ),
      WashGuideStep(
        step: 2,
        emoji: '🌡️',
        title: 'Set Warm Water (40°C)',
        description: 'Select warm water setting — typically the 40°C or "warm" option on your machine.',
      ),
      WashGuideStep(
        step: 3,
        emoji: '🧴',
        title: 'Add Standard Detergent',
        description: 'Regular laundry detergent works well in warm water. Follow dosage instructions.',
      ),
      WashGuideStep(
        step: 4,
        emoji: '🌀',
        title: 'Normal Cycle',
        description: 'A normal or permanent press cycle is suitable for most warm-wash items.',
      ),
      WashGuideStep(
        step: 5,
        emoji: '💨',
        title: 'Dry Appropriately',
        description: 'Follow the drying instructions specific to this garment.',
      ),
    ],
    WashMethod.machineWashHot: [
      WashGuideStep(
        step: 1,
        emoji: '⚠️',
        title: 'Check Colorfastness',
        description: 'Only wash colorfast, sturdy items in hot water. Test for color bleeding first.',
      ),
      WashGuideStep(
        step: 2,
        emoji: '♨️',
        title: 'Set Hot Water (60°C)',
        description: 'Select hot water setting. Best for heavily soiled items, towels, and bedding.',
      ),
      WashGuideStep(
        step: 3,
        emoji: '🧴',
        title: 'Full Detergent Dose',
        description: 'Hot water activates most detergents effectively. Use standard dosage.',
      ),
      WashGuideStep(
        step: 4,
        emoji: '🌀',
        title: 'Regular Cycle',
        description: 'Use normal or heavy duty cycle for hot washing.',
      ),
      WashGuideStep(
        step: 5,
        emoji: '📐',
        title: 'Reshape While Damp',
        description: 'Hot water can cause slight shrinkage. Reshape the garment while still damp.',
      ),
    ],
    WashMethod.handWash: [
      WashGuideStep(
        step: 1,
        emoji: '🪣',
        title: 'Fill Basin with Cool Water',
        description: 'Use a clean basin or sink with cool to lukewarm water (max 30°C).',
      ),
      WashGuideStep(
        step: 2,
        emoji: '🧴',
        title: 'Add Gentle Detergent',
        description: 'Add a small amount of gentle or delicate-specific detergent. Mix to dissolve.',
      ),
      WashGuideStep(
        step: 3,
        emoji: '🖐️',
        title: 'Gently Agitate',
        description: 'Submerge the garment and gently squeeze the water through. Do NOT scrub or wring.',
      ),
      WashGuideStep(
        step: 4,
        emoji: '⏱️',
        title: 'Soak 5–10 Minutes',
        description: 'Let it soak briefly for lightly soiled items. Avoid prolonged soaking.',
      ),
      WashGuideStep(
        step: 5,
        emoji: '💧',
        title: 'Rinse Thoroughly',
        description: 'Rinse with clean cool water until all soap is removed. No wringing!',
      ),
      WashGuideStep(
        step: 6,
        emoji: '🧻',
        title: 'Press Out Excess Water',
        description: 'Gently press (do not twist) the garment between clean towels to remove water.',
      ),
      WashGuideStep(
        step: 7,
        emoji: '📐',
        title: 'Dry Flat or Line Dry',
        description: 'Lay flat on a clean dry towel or hang to air dry away from direct sunlight.',
      ),
    ],
    WashMethod.dryCleanOnly: [
      WashGuideStep(
        step: 1,
        emoji: '🧴',
        title: 'Take to Professional Cleaner',
        description: 'This garment requires professional dry cleaning. Do not attempt to wash at home.',
      ),
      WashGuideStep(
        step: 2,
        emoji: '🏷️',
        title: 'Inform Cleaner of Stains',
        description: 'Point out any stains and mention the fabric type to your dry cleaner.',
      ),
      WashGuideStep(
        step: 3,
        emoji: '💨',
        title: 'Air Out After Cleaning',
        description: 'Remove plastic covering and air the garment for a few hours before storing.',
      ),
      WashGuideStep(
        step: 4,
        emoji: '🪡',
        title: 'Store Properly',
        description: 'Store on padded hangers in a breathable garment bag, away from direct light.',
      ),
    ],
    WashMethod.doNotWash: [
      WashGuideStep(
        step: 1,
        emoji: '🚫',
        title: 'Do Not Wash with Water',
        description: 'This item cannot be laundered. Spot clean only or take to a specialist.',
      ),
      WashGuideStep(
        step: 2,
        emoji: '🧽',
        title: 'Spot Clean if Needed',
        description: 'For small stains, use a barely damp cloth and dab gently. Never rub.',
      ),
      WashGuideStep(
        step: 3,
        emoji: '💨',
        title: 'Air Out Regularly',
        description: 'Hang the garment in fresh air to refresh it between wears.',
      ),
      WashGuideStep(
        step: 4,
        emoji: '🔧',
        title: 'Consult a Specialist',
        description: 'For thorough cleaning, consult a professional textile specialist.',
      ),
    ],
    WashMethod.unknown: [
      WashGuideStep(
        step: 1,
        emoji: '🔍',
        title: 'Check Original Tag',
        description: 'The wash method could not be determined. Refer to the original garment tag.',
      ),
      WashGuideStep(
        step: 2,
        emoji: '⚠️',
        title: 'When in Doubt, Gentle',
        description: 'If unsure, use cold water and a gentle cycle to minimize risk of damage.',
      ),
    ],
  };

  // Fabric care tips
  static List<FabricCareTip> get fabricTips => [
    FabricCareTip(
      fabric: 'cotton',
      tips: [
        'Can withstand higher temperatures than most fabrics',
        'Pre-wash before first use to prevent shrinkage later',
        'Iron while still slightly damp for best results',
        'Works well with most standard detergents',
      ],
      warnings: [
        'May shrink in hot water — especially on first wash',
        'Colors may fade over many hot washes',
        'Can wrinkle easily',
      ],
    ),
    FabricCareTip(
      fabric: 'polyester',
      tips: [
        'Quick-drying and resistant to wrinkles',
        'Cold to warm water washing is ideal',
        'Low tumble dry or air dry to avoid static',
        'Very durable and easy to care for',
      ],
      warnings: [
        'Avoid high heat — it can melt or damage the fibers',
        'Can accumulate static electricity',
        'May pill over time with abrasive washing',
      ],
    ),
    FabricCareTip(
      fabric: 'wool',
      tips: [
        'Hand wash or use a wool/delicates cycle',
        'Use wool-specific detergent for best results',
        'Dry flat to maintain shape',
        'Store folded, not hung, to prevent stretching',
      ],
      warnings: [
        'Can felt and shrink irreversibly in hot water',
        'Never agitate vigorously — it mats the fibers',
        'Do not tumble dry unless label says so',
        'Keep away from moths — use cedar blocks',
      ],
    ),
    FabricCareTip(
      fabric: 'silk',
      tips: [
        'Hand wash in cool water with silk-specific detergent',
        'Roll in a towel to remove excess water — do not wring',
        'Dry away from direct sunlight to prevent fading',
        'Iron on lowest setting on reverse side',
      ],
      warnings: [
        'Never use bleach or harsh chemicals',
        'Hot water will damage silk fibers permanently',
        'Avoid prolonged contact with water',
        'Sweat and deodorant can stain silk permanently',
      ],
    ),
    FabricCareTip(
      fabric: 'linen',
      tips: [
        'Can be machine washed on gentle cycle',
        'Air drying is preferred to preserve the fabric',
        'Iron while damp with a hot iron for crisp finish',
        'Gets softer with each wash',
      ],
      warnings: [
        'Can shrink — especially on first wash',
        'Creases easily and requires ironing',
        'Bright colors may fade over time',
      ],
    ),
    FabricCareTip(
      fabric: 'nylon',
      tips: [
        'Machine wash cold or warm',
        'Quick drying — ideal for activewear',
        'Resistant to shrinking and stretching',
      ],
      warnings: [
        'Avoid high heat in dryer',
        'May snag on rough surfaces',
        'Static can be an issue',
      ],
    ),
    FabricCareTip(
      fabric: 'spandex',
      tips: [
        'Machine wash cold on gentle cycle',
        'Air dry for longest life',
        'Recovers shape well after stretching',
      ],
      warnings: [
        'Avoid chlorine bleach — it breaks down spandex fibers',
        'High heat degrades elasticity',
        'Do not iron',
      ],
    ),
    FabricCareTip(
      fabric: 'viscose',
      tips: [
        'Hand wash or delicate machine cycle in cool water',
        'Gentle detergent recommended',
        'Dry flat to maintain shape',
      ],
      warnings: [
        'Weak when wet — handle very gently',
        'Prone to shrinking',
        'May lose shape if wrung',
      ],
    ),
  ];

  // Chemical compatibility rules
  static Map<String, Map<String, List<String>>> get chemicalRules => {
    'standard': {
      'allowed': [
        'Standard laundry detergent',
        'Fabric softener',
        'Color-safe stain remover',
        'Fabric conditioner',
      ],
      'notAllowed': [],
    },
    'noBleach': {
      'allowed': [
        'Standard laundry detergent',
        'Fabric softener',
        'Enzyme-based stain remover',
        'Oxygen-based stain remover',
        'Color-safe detergent',
      ],
      'notAllowed': [
        'Chlorine bleach',
        'Sodium hypochlorite',
        'Bleach-containing cleaners',
      ],
    },
    'nonChlorineOnly': {
      'allowed': [
        'Standard laundry detergent',
        'Fabric softener',
        'Non-chlorine / oxygen bleach',
        'Color-safe stain remover',
      ],
      'notAllowed': [
        'Chlorine bleach',
        'Sodium hypochlorite',
      ],
    },
    'delicate': {
      'allowed': [
        'Gentle or delicate detergent',
        'Silk or wool wash',
        'pH-neutral soap',
      ],
      'notAllowed': [
        'Standard laundry detergent (harsh)',
        'Fabric softener (can coat fibers)',
        'Any bleach',
        'Enzyme-based detergents',
        'Stain remover sprays',
      ],
    },
    'dryClean': {
      'allowed': [
        'Professional dry-cleaning solvents',
        'Dry-cleaning spot treatment',
      ],
      'notAllowed': [
        'Water-based detergents',
        'Any bleach',
        'Home stain removers',
        'Fabric softener',
      ],
    },
  };

  // ISO symbol descriptions
  static List<Map<String, String>> get isoSymbolDescriptions => [
    {
      'id': 'wash_30',
      'name': 'Machine Wash 30°C',
      'description': 'Machine wash at a maximum temperature of 30°C.',
      'emoji': '🧺',
      'category': 'wash',
    },
    {
      'id': 'wash_40',
      'name': 'Machine Wash 40°C',
      'description': 'Machine wash at a maximum temperature of 40°C.',
      'emoji': '🧺',
      'category': 'wash',
    },
    {
      'id': 'wash_60',
      'name': 'Machine Wash 60°C',
      'description': 'Machine wash at a maximum temperature of 60°C.',
      'emoji': '🧺',
      'category': 'wash',
    },
    {
      'id': 'wash_hand',
      'name': 'Hand Wash',
      'description': 'Hand wash only, gentle with cool water.',
      'emoji': '🖐️',
      'category': 'wash',
    },
    {
      'id': 'wash_no',
      'name': 'Do Not Wash',
      'description': 'Do not wash with water.',
      'emoji': '🚫',
      'category': 'wash',
    },
    {
      'id': 'bleach_any',
      'name': 'Bleach Allowed',
      'description': 'Any bleach may be used.',
      'emoji': '▲',
      'category': 'bleach',
    },
    {
      'id': 'bleach_nonchlorine',
      'name': 'Non-Chlorine Bleach Only',
      'description': 'Only non-chlorine bleach may be used.',
      'emoji': '▲',
      'category': 'bleach',
    },
    {
      'id': 'bleach_no',
      'name': 'Do Not Bleach',
      'description': 'Do not use any bleach.',
      'emoji': '🚫',
      'category': 'bleach',
    },
    {
      'id': 'dry_tumble_low',
      'name': 'Tumble Dry Low Heat',
      'description': 'Tumble dry with low heat setting.',
      'emoji': '🌀',
      'category': 'dry',
    },
    {
      'id': 'dry_tumble_medium',
      'name': 'Tumble Dry Medium Heat',
      'description': 'Tumble dry with medium heat setting.',
      'emoji': '🌀',
      'category': 'dry',
    },
    {
      'id': 'dry_tumble_no',
      'name': 'Do Not Tumble Dry',
      'description': 'Do not use a tumble dryer.',
      'emoji': '🚫',
      'category': 'dry',
    },
    {
      'id': 'dry_line',
      'name': 'Line Dry',
      'description': 'Hang to dry on a line or hanger.',
      'emoji': '🪢',
      'category': 'dry',
    },
    {
      'id': 'dry_flat',
      'name': 'Dry Flat',
      'description': 'Lay flat to dry to maintain shape.',
      'emoji': '📐',
      'category': 'dry',
    },
    {
      'id': 'dry_drip',
      'name': 'Drip Dry',
      'description': 'Hang while wet and allow to drip dry.',
      'emoji': '💧',
      'category': 'dry',
    },
    {
      'id': 'iron_low',
      'name': 'Iron Low (110°C)',
      'description': 'Iron at low temperature, max 110°C. Suitable for synthetics.',
      'emoji': '🔥',
      'category': 'iron',
    },
    {
      'id': 'iron_medium',
      'name': 'Iron Medium (150°C)',
      'description': 'Iron at medium temperature, max 150°C. Suitable for wool and polyester.',
      'emoji': '🔥',
      'category': 'iron',
    },
    {
      'id': 'iron_high',
      'name': 'Iron High (200°C)',
      'description': 'Iron at high temperature, max 200°C. Suitable for cotton and linen.',
      'emoji': '🔥',
      'category': 'iron',
    },
    {
      'id': 'iron_no',
      'name': 'Do Not Iron',
      'description': 'Do not apply heat from an iron.',
      'emoji': '🚫',
      'category': 'iron',
    },
    {
      'id': 'iron_steam_no',
      'name': 'Do Not Steam',
      'description': 'Iron without steam. Steam can damage this fabric.',
      'emoji': '💨',
      'category': 'iron',
    },
    {
      'id': 'dryclean_any',
      'name': 'Dry Clean',
      'description': 'Dry clean with any solvent.',
      'emoji': '🔵',
      'category': 'dryClean',
    },
    {
      'id': 'dryclean_no',
      'name': 'Do Not Dry Clean',
      'description': 'Do not dry clean this garment.',
      'emoji': '🚫',
      'category': 'dryClean',
    },
    {
      'id': 'dryclean_gentle',
      'name': 'Dry Clean Gentle',
      'description': 'Dry clean with gentle treatment.',
      'emoji': '🔵',
      'category': 'dryClean',
    },
    {
      'id': 'wash_30_gentle',
      'name': 'Machine Wash 30°C Gentle',
      'description': 'Machine wash at a maximum of 30°C on gentle cycle.',
      'emoji': '🧺',
      'category': 'wash',
    },
    {
      'id': 'wash_40_gentle',
      'name': 'Machine Wash 40°C Gentle',
      'description': 'Machine wash at a maximum of 40°C on gentle cycle.',
      'emoji': '🧺',
      'category': 'wash',
    },
    {
      'id': 'dry_shade',
      'name': 'Dry in Shade',
      'description': 'Dry away from direct sunlight to prevent fading.',
      'emoji': '🌥️',
      'category': 'dry',
    },
    {
      'id': 'dry_line_shade',
      'name': 'Line Dry in Shade',
      'description': 'Hang on a line to dry, away from direct sunlight.',
      'emoji': '🌥️',
      'category': 'dry',
    },
    {
      'id': 'wash_95',
      'name': 'Machine Wash 95°C',
      'description': 'Machine wash at up to 95°C (hot wash for sanitation).',
      'emoji': '🧺',
      'category': 'wash',
    },
    {
      'id': 'spin_no',
      'name': 'Do Not Spin',
      'description': 'Remove without spinning to prevent distortion.',
      'emoji': '🚫',
      'category': 'wash',
    },
    {
      'id': 'iron_steam_ok',
      'name': 'Steam Ironing OK',
      'description': 'Can use steam ironing.',
      'emoji': '💨',
      'category': 'iron',
    },
    {
      'id': 'dry_tumble_no_heat',
      'name': 'Tumble Dry No Heat',
      'description': 'Tumble dry on air-only setting with no heat.',
      'emoji': '🌀',
      'category': 'dry',
    },
  ];
}
