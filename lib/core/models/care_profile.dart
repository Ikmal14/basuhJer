import 'garment.dart';

class CareProfile {
  final WashMethod washMethod;
  final int? maxTemperature;
  final IronLevel ironLevel;
  final BleachType bleachType;
  final DryMethod dryMethod;
  final SpinSpeed spinSpeed;
  final List<String> doList;
  final List<String> dontList;
  final List<String> chemicalsAllowed;
  final List<String> chemicalsNotAllowed;
  final List<String> fabricComposition;
  final List<String> selectedSymbolIds;
  final String rawTagText;

  const CareProfile({
    required this.washMethod,
    this.maxTemperature,
    required this.ironLevel,
    required this.bleachType,
    required this.dryMethod,
    required this.spinSpeed,
    this.doList = const [],
    this.dontList = const [],
    this.chemicalsAllowed = const [],
    this.chemicalsNotAllowed = const [],
    this.fabricComposition = const [],
    this.selectedSymbolIds = const [],
    this.rawTagText = '',
  });

  factory CareProfile.empty() {
    return const CareProfile(
      washMethod: WashMethod.unknown,
      maxTemperature: null,
      ironLevel: IronLevel.unknown,
      bleachType: BleachType.unknown,
      dryMethod: DryMethod.unknown,
      spinSpeed: SpinSpeed.unknown,
      doList: [],
      dontList: [],
      chemicalsAllowed: [],
      chemicalsNotAllowed: [],
      fabricComposition: [],
      selectedSymbolIds: [],
      rawTagText: '',
    );
  }

  CareProfile copyWith({
    WashMethod? washMethod,
    int? maxTemperature,
    bool clearTemperature = false,
    IronLevel? ironLevel,
    BleachType? bleachType,
    DryMethod? dryMethod,
    SpinSpeed? spinSpeed,
    List<String>? doList,
    List<String>? dontList,
    List<String>? chemicalsAllowed,
    List<String>? chemicalsNotAllowed,
    List<String>? fabricComposition,
    List<String>? selectedSymbolIds,
    String? rawTagText,
  }) {
    return CareProfile(
      washMethod: washMethod ?? this.washMethod,
      maxTemperature:
          clearTemperature ? null : (maxTemperature ?? this.maxTemperature),
      ironLevel: ironLevel ?? this.ironLevel,
      bleachType: bleachType ?? this.bleachType,
      dryMethod: dryMethod ?? this.dryMethod,
      spinSpeed: spinSpeed ?? this.spinSpeed,
      doList: doList ?? this.doList,
      dontList: dontList ?? this.dontList,
      chemicalsAllowed: chemicalsAllowed ?? this.chemicalsAllowed,
      chemicalsNotAllowed: chemicalsNotAllowed ?? this.chemicalsNotAllowed,
      fabricComposition: fabricComposition ?? this.fabricComposition,
      selectedSymbolIds: selectedSymbolIds ?? this.selectedSymbolIds,
      rawTagText: rawTagText ?? this.rawTagText,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'washMethod': washMethod.key,
      'maxTemperature': maxTemperature,
      'ironLevel': ironLevel.key,
      'bleachType': bleachType.key,
      'dryMethod': dryMethod.key,
      'spinSpeed': spinSpeed.key,
      'doList': doList,
      'dontList': dontList,
      'chemicalsAllowed': chemicalsAllowed,
      'chemicalsNotAllowed': chemicalsNotAllowed,
      'fabricComposition': fabricComposition,
      'selectedSymbolIds': selectedSymbolIds,
      'rawTagText': rawTagText,
    };
  }

  factory CareProfile.fromJson(Map<String, dynamic> json) {
    return CareProfile(
      washMethod: WashMethodExtension.fromKey(json['washMethod'] as String? ?? 'unknown'),
      maxTemperature: json['maxTemperature'] as int?,
      ironLevel: IronLevelExtension.fromKey(json['ironLevel'] as String? ?? 'unknown'),
      bleachType: BleachTypeExtension.fromKey(json['bleachType'] as String? ?? 'unknown'),
      dryMethod: DryMethodExtension.fromKey(json['dryMethod'] as String? ?? 'unknown'),
      spinSpeed: SpinSpeedExtension.fromKey(json['spinSpeed'] as String? ?? 'unknown'),
      doList: List<String>.from(json['doList'] as List? ?? []),
      dontList: List<String>.from(json['dontList'] as List? ?? []),
      chemicalsAllowed: List<String>.from(json['chemicalsAllowed'] as List? ?? []),
      chemicalsNotAllowed: List<String>.from(json['chemicalsNotAllowed'] as List? ?? []),
      fabricComposition: List<String>.from(json['fabricComposition'] as List? ?? []),
      selectedSymbolIds: List<String>.from(json['selectedSymbolIds'] as List? ?? []),
      rawTagText: json['rawTagText'] as String? ?? '',
    );
  }

  bool get hasData =>
      washMethod != WashMethod.unknown ||
      ironLevel != IronLevel.unknown ||
      bleachType != BleachType.unknown ||
      dryMethod != DryMethod.unknown ||
      fabricComposition.isNotEmpty;
}
