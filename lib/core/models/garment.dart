import 'care_profile.dart';

enum GarmentCategory {
  tops,
  bottoms,
  dresses,
  outerwear,
  underwear,
  activewear,
  delicates,
  accessories,
  other,
}

extension GarmentCategoryExtension on GarmentCategory {
  String get displayName {
    switch (this) {
      case GarmentCategory.tops:
        return 'Tops';
      case GarmentCategory.bottoms:
        return 'Bottoms';
      case GarmentCategory.dresses:
        return 'Dresses';
      case GarmentCategory.outerwear:
        return 'Outerwear';
      case GarmentCategory.underwear:
        return 'Underwear';
      case GarmentCategory.activewear:
        return 'Activewear';
      case GarmentCategory.delicates:
        return 'Delicates';
      case GarmentCategory.accessories:
        return 'Accessories';
      case GarmentCategory.other:
        return 'Other';
    }
  }

  String get emoji {
    switch (this) {
      case GarmentCategory.tops:
        return '👕';
      case GarmentCategory.bottoms:
        return '👖';
      case GarmentCategory.dresses:
        return '👗';
      case GarmentCategory.outerwear:
        return '🧥';
      case GarmentCategory.underwear:
        return '🩲';
      case GarmentCategory.activewear:
        return '🏃';
      case GarmentCategory.delicates:
        return '🌸';
      case GarmentCategory.accessories:
        return '🧣';
      case GarmentCategory.other:
        return '👔';
    }
  }
}

enum WashMethod {
  machineWashCold,
  machineWashWarm,
  machineWashHot,
  handWash,
  dryCleanOnly,
  doNotWash,
  unknown,
}

extension WashMethodExtension on WashMethod {
  String get displayName {
    switch (this) {
      case WashMethod.machineWashCold:
        return 'Machine Wash Cold';
      case WashMethod.machineWashWarm:
        return 'Machine Wash Warm';
      case WashMethod.machineWashHot:
        return 'Machine Wash Hot';
      case WashMethod.handWash:
        return 'Hand Wash Only';
      case WashMethod.dryCleanOnly:
        return 'Dry Clean Only';
      case WashMethod.doNotWash:
        return 'Do Not Wash';
      case WashMethod.unknown:
        return 'Unknown';
    }
  }

  String get emoji {
    switch (this) {
      case WashMethod.machineWashCold:
        return '🧊';
      case WashMethod.machineWashWarm:
        return '🌡️';
      case WashMethod.machineWashHot:
        return '♨️';
      case WashMethod.handWash:
        return '🖐️';
      case WashMethod.dryCleanOnly:
        return '🧴';
      case WashMethod.doNotWash:
        return '🚫';
      case WashMethod.unknown:
        return '❓';
    }
  }

  String get key {
    return toString().split('.').last;
  }

  static WashMethod fromKey(String key) {
    return WashMethod.values.firstWhere(
      (e) => e.key == key,
      orElse: () => WashMethod.unknown,
    );
  }
}

enum IronLevel {
  noIron,
  low,
  medium,
  high,
  steamOk,
  unknown,
}

extension IronLevelExtension on IronLevel {
  String get displayName {
    switch (this) {
      case IronLevel.noIron:
        return 'Do Not Iron';
      case IronLevel.low:
        return 'Low Heat (110°C)';
      case IronLevel.medium:
        return 'Medium Heat (150°C)';
      case IronLevel.high:
        return 'High Heat (200°C)';
      case IronLevel.steamOk:
        return 'Steam OK';
      case IronLevel.unknown:
        return 'Unknown';
    }
  }

  String get emoji {
    switch (this) {
      case IronLevel.noIron:
        return '🚫';
      case IronLevel.low:
        return '•';
      case IronLevel.medium:
        return '••';
      case IronLevel.high:
        return '•••';
      case IronLevel.steamOk:
        return '💨';
      case IronLevel.unknown:
        return '❓';
    }
  }

  String get key {
    return toString().split('.').last;
  }

  static IronLevel fromKey(String key) {
    return IronLevel.values.firstWhere(
      (e) => e.key == key,
      orElse: () => IronLevel.unknown,
    );
  }
}

enum BleachType {
  anyBleach,
  nonChlorineOnly,
  noBleach,
  unknown,
}

extension BleachTypeExtension on BleachType {
  String get displayName {
    switch (this) {
      case BleachType.anyBleach:
        return 'Bleach OK';
      case BleachType.nonChlorineOnly:
        return 'Non-Chlorine Bleach Only';
      case BleachType.noBleach:
        return 'Do Not Bleach';
      case BleachType.unknown:
        return 'Unknown';
    }
  }

  String get emoji {
    switch (this) {
      case BleachType.anyBleach:
        return '✅';
      case BleachType.nonChlorineOnly:
        return '⚠️';
      case BleachType.noBleach:
        return '🚫';
      case BleachType.unknown:
        return '❓';
    }
  }

  String get key {
    return toString().split('.').last;
  }

  static BleachType fromKey(String key) {
    return BleachType.values.firstWhere(
      (e) => e.key == key,
      orElse: () => BleachType.unknown,
    );
  }
}

enum DryMethod {
  tumbleDryLow,
  tumbleDryMedium,
  tumbleDryHigh,
  doNotTumbleDry,
  lineDry,
  dryFlat,
  dripDry,
  unknown,
}

extension DryMethodExtension on DryMethod {
  String get displayName {
    switch (this) {
      case DryMethod.tumbleDryLow:
        return 'Tumble Dry Low';
      case DryMethod.tumbleDryMedium:
        return 'Tumble Dry Medium';
      case DryMethod.tumbleDryHigh:
        return 'Tumble Dry High';
      case DryMethod.doNotTumbleDry:
        return 'Do Not Tumble Dry';
      case DryMethod.lineDry:
        return 'Line Dry';
      case DryMethod.dryFlat:
        return 'Dry Flat';
      case DryMethod.dripDry:
        return 'Drip Dry';
      case DryMethod.unknown:
        return 'Unknown';
    }
  }

  String get emoji {
    switch (this) {
      case DryMethod.tumbleDryLow:
        return '🌀';
      case DryMethod.tumbleDryMedium:
        return '🌀';
      case DryMethod.tumbleDryHigh:
        return '🌀';
      case DryMethod.doNotTumbleDry:
        return '🚫';
      case DryMethod.lineDry:
        return '🪢';
      case DryMethod.dryFlat:
        return '📐';
      case DryMethod.dripDry:
        return '💧';
      case DryMethod.unknown:
        return '❓';
    }
  }

  String get key {
    return toString().split('.').last;
  }

  static DryMethod fromKey(String key) {
    return DryMethod.values.firstWhere(
      (e) => e.key == key,
      orElse: () => DryMethod.unknown,
    );
  }
}

enum SpinSpeed {
  gentle,
  normal,
  noSpin,
  unknown,
}

extension SpinSpeedExtension on SpinSpeed {
  String get displayName {
    switch (this) {
      case SpinSpeed.gentle:
        return 'Gentle Spin';
      case SpinSpeed.normal:
        return 'Normal Spin';
      case SpinSpeed.noSpin:
        return 'No Spin';
      case SpinSpeed.unknown:
        return 'Unknown';
    }
  }

  String get key {
    return toString().split('.').last;
  }

  static SpinSpeed fromKey(String key) {
    return SpinSpeed.values.firstWhere(
      (e) => e.key == key,
      orElse: () => SpinSpeed.unknown,
    );
  }
}

class Garment {
  final String id;
  final String name;
  final GarmentCategory category;
  final String? garmentPhotoPath;
  final String? tagPhotoPath;
  final CareProfile careProfile;
  final DateTime createdAt;
  final List<String> customTags;

  const Garment({
    required this.id,
    required this.name,
    required this.category,
    this.garmentPhotoPath,
    this.tagPhotoPath,
    required this.careProfile,
    required this.createdAt,
    this.customTags = const [],
  });

  Garment copyWith({
    String? id,
    String? name,
    GarmentCategory? category,
    String? garmentPhotoPath,
    String? tagPhotoPath,
    CareProfile? careProfile,
    DateTime? createdAt,
    List<String>? customTags,
  }) {
    return Garment(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      garmentPhotoPath: garmentPhotoPath ?? this.garmentPhotoPath,
      tagPhotoPath: tagPhotoPath ?? this.tagPhotoPath,
      careProfile: careProfile ?? this.careProfile,
      createdAt: createdAt ?? this.createdAt,
      customTags: customTags ?? this.customTags,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category': category.name,
      'garmentPhotoPath': garmentPhotoPath,
      'tagPhotoPath': tagPhotoPath,
      'careProfile': careProfile.toJson(),
      'createdAt': createdAt.toIso8601String(),
      'customTags': customTags,
    };
  }

  factory Garment.fromJson(Map<String, dynamic> json) {
    return Garment(
      id: json['id'] as String,
      name: json['name'] as String,
      category: GarmentCategory.values.firstWhere(
        (e) => e.name == json['category'],
        orElse: () => GarmentCategory.other,
      ),
      garmentPhotoPath: json['garmentPhotoPath'] as String?,
      tagPhotoPath: json['tagPhotoPath'] as String?,
      careProfile: CareProfile.fromJson(
        json['careProfile'] as Map<String, dynamic>,
      ),
      createdAt: DateTime.parse(json['createdAt'] as String),
      customTags: List<String>.from(json['customTags'] as List? ?? []),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is Garment && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
