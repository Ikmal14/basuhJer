import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/models/garment.dart';
import '../../data/garment_repository.dart';

// ── Repository Provider ───────────────────────────────────────────────────────

final garmentRepositoryProvider = Provider<GarmentRepository>((ref) {
  // Repository is initialized in main.dart before the app runs
  return GarmentRepository();
});

// ── Wardrobe State ────────────────────────────────────────────────────────────

class WardrobeState {
  final List<Garment> allGarments;
  final List<Garment> filteredGarments;
  final WashMethod? activeWashFilter;
  final int? activeTempFilter;
  final String? activeFabricFilter;
  final GarmentCategory? activeCategoryFilter;
  final String searchQuery;
  final bool isLoading;
  final String? error;

  const WardrobeState({
    this.allGarments = const [],
    this.filteredGarments = const [],
    this.activeWashFilter,
    this.activeTempFilter,
    this.activeFabricFilter,
    this.activeCategoryFilter,
    this.searchQuery = '',
    this.isLoading = false,
    this.error,
  });

  WardrobeState copyWith({
    List<Garment>? allGarments,
    List<Garment>? filteredGarments,
    WashMethod? activeWashFilter,
    bool clearWashFilter = false,
    int? activeTempFilter,
    bool clearTempFilter = false,
    String? activeFabricFilter,
    bool clearFabricFilter = false,
    GarmentCategory? activeCategoryFilter,
    bool clearCategoryFilter = false,
    String? searchQuery,
    bool? isLoading,
    String? error,
    bool clearError = false,
  }) {
    return WardrobeState(
      allGarments: allGarments ?? this.allGarments,
      filteredGarments: filteredGarments ?? this.filteredGarments,
      activeWashFilter:
          clearWashFilter ? null : (activeWashFilter ?? this.activeWashFilter),
      activeTempFilter:
          clearTempFilter ? null : (activeTempFilter ?? this.activeTempFilter),
      activeFabricFilter: clearFabricFilter
          ? null
          : (activeFabricFilter ?? this.activeFabricFilter),
      activeCategoryFilter: clearCategoryFilter
          ? null
          : (activeCategoryFilter ?? this.activeCategoryFilter),
      searchQuery: searchQuery ?? this.searchQuery,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }

  bool get hasActiveFilters =>
      activeWashFilter != null ||
      activeTempFilter != null ||
      activeFabricFilter != null ||
      activeCategoryFilter != null ||
      searchQuery.isNotEmpty;

  int get activeFilterCount {
    int count = 0;
    if (activeWashFilter != null) count++;
    if (activeTempFilter != null) count++;
    if (activeFabricFilter != null) count++;
    if (activeCategoryFilter != null) count++;
    return count;
  }
}

// ── Wardrobe Notifier ─────────────────────────────────────────────────────────

class WardrobeNotifier extends StateNotifier<WardrobeState> {
  final GarmentRepository _repository;

  WardrobeNotifier(this._repository) : super(const WardrobeState()) {
    loadGarments();
  }

  Future<void> loadGarments() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final garments = _repository.getAll();
      final filtered = _applyFilters(garments);
      state = state.copyWith(
        allGarments: garments,
        filteredGarments: filtered,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load garments: $e',
      );
    }
  }

  Future<void> refresh() => loadGarments();

  Future<void> deleteGarment(String id) async {
    try {
      await _repository.delete(id);
      final updated = state.allGarments.where((g) => g.id != id).toList();
      state = state.copyWith(
        allGarments: updated,
        filteredGarments: _applyFilters(updated),
      );
    } catch (e) {
      state = state.copyWith(error: 'Failed to delete: $e');
    }
  }

  void setWashFilter(WashMethod? method) {
    final newState = method == null
        ? state.copyWith(clearWashFilter: true)
        : state.copyWith(activeWashFilter: method);
    state = newState.copyWith(
      filteredGarments: _applyFiltersToState(newState),
    );
  }

  void setTempFilter(int? maxTemp) {
    final newState = maxTemp == null
        ? state.copyWith(clearTempFilter: true)
        : state.copyWith(activeTempFilter: maxTemp);
    state = newState.copyWith(
      filteredGarments: _applyFiltersToState(newState),
    );
  }

  void setFabricFilter(String? fabric) {
    final newState = fabric == null
        ? state.copyWith(clearFabricFilter: true)
        : state.copyWith(activeFabricFilter: fabric);
    state = newState.copyWith(
      filteredGarments: _applyFiltersToState(newState),
    );
  }

  void setCategoryFilter(GarmentCategory? category) {
    final newState = category == null
        ? state.copyWith(clearCategoryFilter: true)
        : state.copyWith(activeCategoryFilter: category);
    state = newState.copyWith(
      filteredGarments: _applyFiltersToState(newState),
    );
  }

  void setSearchQuery(String query) {
    final newState = state.copyWith(searchQuery: query);
    state = newState.copyWith(
      filteredGarments: _applyFiltersToState(newState),
    );
  }

  void clearAllFilters() {
    state = state.copyWith(
      clearWashFilter: true,
      clearTempFilter: true,
      clearFabricFilter: true,
      clearCategoryFilter: true,
      searchQuery: '',
      filteredGarments: state.allGarments,
    );
  }

  List<Garment> _applyFilters(List<Garment> garments) {
    return _applyFiltersToState(state, garments: garments);
  }

  List<Garment> _applyFiltersToState(WardrobeState s,
      {List<Garment>? garments}) {
    var result = garments ?? s.allGarments;

    if (s.searchQuery.isNotEmpty) {
      final q = s.searchQuery.toLowerCase();
      result = result.where((g) {
        return g.name.toLowerCase().contains(q) ||
            g.category.displayName.toLowerCase().contains(q) ||
            g.customTags.any((t) => t.toLowerCase().contains(q)) ||
            g.careProfile.fabricComposition.any(
              (f) => f.toLowerCase().contains(q),
            );
      }).toList();
    }

    if (s.activeWashFilter != null) {
      result = result
          .where((g) => g.careProfile.washMethod == s.activeWashFilter)
          .toList();
    }

    if (s.activeTempFilter != null) {
      result = result.where((g) {
        final temp = g.careProfile.maxTemperature;
        return temp != null && temp <= s.activeTempFilter!;
      }).toList();
    }

    if (s.activeFabricFilter != null) {
      final lower = s.activeFabricFilter!.toLowerCase();
      result = result.where((g) {
        return g.careProfile.fabricComposition.any(
          (f) => f.toLowerCase().contains(lower),
        );
      }).toList();
    }

    if (s.activeCategoryFilter != null) {
      result = result
          .where((g) => g.category == s.activeCategoryFilter)
          .toList();
    }

    return result;
  }
}

// ── Providers ─────────────────────────────────────────────────────────────────

final wardrobeProvider =
    StateNotifierProvider<WardrobeNotifier, WardrobeState>((ref) {
  final repo = ref.watch(garmentRepositoryProvider);
  return WardrobeNotifier(repo);
});
