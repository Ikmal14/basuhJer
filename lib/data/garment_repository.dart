import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import '../core/models/garment.dart';

class GarmentRepository {
  static const String _boxName = 'garments';
  late Box<String> _box;

  Future<void> init() async {
    _box = await Hive.openBox<String>(_boxName);
  }

  Box<String> get box => _box;

  List<Garment> getAll() {
    final garments = <Garment>[];
    for (final key in _box.keys) {
      final jsonStr = _box.get(key.toString());
      if (jsonStr != null) {
        try {
          final json = jsonDecode(jsonStr) as Map<String, dynamic>;
          garments.add(Garment.fromJson(json));
        } catch (e) {
          // Skip corrupted entries
        }
      }
    }
    garments.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return garments;
  }

  Garment? getById(String id) {
    final jsonStr = _box.get(id);
    if (jsonStr == null) return null;
    try {
      final json = jsonDecode(jsonStr) as Map<String, dynamic>;
      return Garment.fromJson(json);
    } catch (_) {
      return null;
    }
  }

  Future<void> save(Garment garment) async {
    await _box.put(garment.id, jsonEncode(garment.toJson()));
  }

  Future<void> update(Garment garment) async {
    await _box.put(garment.id, jsonEncode(garment.toJson()));
  }

  Future<void> delete(String id) async {
    await _box.delete(id);
  }

  List<Garment> filterByWashMethod(WashMethod method) {
    return getAll()
        .where((g) => g.careProfile.washMethod == method)
        .toList();
  }

  List<Garment> filterByMaxTemp(int maxTemp) {
    return getAll().where((g) {
      final temp = g.careProfile.maxTemperature;
      return temp != null && temp <= maxTemp;
    }).toList();
  }

  List<Garment> filterByFabric(String fabric) {
    final lowerFabric = fabric.toLowerCase();
    return getAll().where((g) {
      return g.careProfile.fabricComposition.any(
        (f) => f.toLowerCase().contains(lowerFabric),
      );
    }).toList();
  }

  List<Garment> filterByCategory(GarmentCategory category) {
    return getAll().where((g) => g.category == category).toList();
  }

  List<Garment> search(String query) {
    final lowerQuery = query.toLowerCase();
    return getAll().where((g) {
      return g.name.toLowerCase().contains(lowerQuery) ||
          g.category.displayName.toLowerCase().contains(lowerQuery) ||
          g.customTags.any((t) => t.toLowerCase().contains(lowerQuery)) ||
          g.careProfile.fabricComposition.any(
            (f) => f.toLowerCase().contains(lowerQuery),
          );
    }).toList();
  }

  Future<void> close() async {
    await _box.close();
  }
}
