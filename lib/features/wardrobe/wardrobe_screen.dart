import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/models/garment.dart';
import 'wardrobe_provider.dart';

class WardrobeScreen extends ConsumerStatefulWidget {
  const WardrobeScreen({super.key});

  @override
  ConsumerState<WardrobeScreen> createState() => _WardrobeScreenState();
}

class _WardrobeScreenState extends ConsumerState<WardrobeScreen> {
  bool _isSearchActive = false;
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocus = FocusNode();

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  void _toggleSearch() {
    setState(() {
      _isSearchActive = !_isSearchActive;
      if (!_isSearchActive) {
        _searchController.clear();
        ref.read(wardrobeProvider.notifier).setSearchQuery('');
      } else {
        _searchFocus.requestFocus();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(wardrobeProvider);

    return Scaffold(
      appBar: _buildAppBar(state),
      body: Column(
        children: [
          _buildFilterRow(state),
          Expanded(
            child: state.isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  )
                : state.error != null
                    ? _buildErrorState(state.error!)
                    : state.filteredGarments.isEmpty
                        ? _buildEmptyState(state)
                        : _buildGarmentGrid(state),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/scan'),
        tooltip: 'Scan Tag',
        child: const Icon(Icons.camera_alt, size: 28),
      ),
    );
  }

  AppBar _buildAppBar(WardrobeState state) {
    return AppBar(
      title: _isSearchActive
          ? TextField(
              controller: _searchController,
              focusNode: _searchFocus,
              decoration: const InputDecoration(
                hintText: 'Search garments...',
                border: InputBorder.none,
                filled: false,
                contentPadding: EdgeInsets.zero,
              ),
              style: const TextStyle(fontSize: 16, color: AppColors.textPrimary),
              onChanged: (q) =>
                  ref.read(wardrobeProvider.notifier).setSearchQuery(q),
            )
          : const Text('WashWise'),
      actions: [
        if (state.hasActiveFilters && !_isSearchActive)
          TextButton(
            onPressed: () =>
                ref.read(wardrobeProvider.notifier).clearAllFilters(),
            child: const Text(
              'Clear',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        IconButton(
          icon: Icon(_isSearchActive ? Icons.close : Icons.search),
          onPressed: _toggleSearch,
          tooltip: _isSearchActive ? 'Close Search' : 'Search',
        ),
      ],
    );
  }

  Widget _buildFilterRow(WardrobeState state) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: [
            // Wash method filters
            _FilterChipWidget(
              label: 'Machine Wash',
              emoji: '🧺',
              isActive: state.activeWashFilter == WashMethod.machineWashCold ||
                  state.activeWashFilter == WashMethod.machineWashWarm ||
                  state.activeWashFilter == WashMethod.machineWashHot,
              onTap: () {
                if (state.activeWashFilter == WashMethod.machineWashCold ||
                    state.activeWashFilter == WashMethod.machineWashWarm ||
                    state.activeWashFilter == WashMethod.machineWashHot) {
                  ref.read(wardrobeProvider.notifier).setWashFilter(null);
                } else {
                  ref
                      .read(wardrobeProvider.notifier)
                      .setWashFilter(WashMethod.machineWashCold);
                }
              },
            ),
            const SizedBox(width: 8),
            _FilterChipWidget(
              label: 'Hand Wash',
              emoji: '🖐️',
              isActive: state.activeWashFilter == WashMethod.handWash,
              onTap: () {
                ref.read(wardrobeProvider.notifier).setWashFilter(
                      state.activeWashFilter == WashMethod.handWash
                          ? null
                          : WashMethod.handWash,
                    );
              },
            ),
            const SizedBox(width: 8),
            _FilterChipWidget(
              label: 'Dry Clean',
              emoji: '🔵',
              isActive: state.activeWashFilter == WashMethod.dryCleanOnly,
              onTap: () {
                ref.read(wardrobeProvider.notifier).setWashFilter(
                      state.activeWashFilter == WashMethod.dryCleanOnly
                          ? null
                          : WashMethod.dryCleanOnly,
                    );
              },
            ),
            const SizedBox(width: 8),
            const _Divider(),
            const SizedBox(width: 8),
            // Temperature filters
            _FilterChipWidget(
              label: 'Cold ≤30°C',
              emoji: '🧊',
              isActive: state.activeTempFilter == 30,
              onTap: () {
                ref.read(wardrobeProvider.notifier).setTempFilter(
                      state.activeTempFilter == 30 ? null : 30,
                    );
              },
            ),
            const SizedBox(width: 8),
            _FilterChipWidget(
              label: 'Warm 40°C',
              emoji: '🌡️',
              isActive: state.activeTempFilter == 40,
              onTap: () {
                ref.read(wardrobeProvider.notifier).setTempFilter(
                      state.activeTempFilter == 40 ? null : 40,
                    );
              },
            ),
            const SizedBox(width: 8),
            _FilterChipWidget(
              label: 'Hot 60°C+',
              emoji: '♨️',
              isActive: state.activeTempFilter == 60,
              onTap: () {
                ref.read(wardrobeProvider.notifier).setTempFilter(
                      state.activeTempFilter == 60 ? null : 60,
                    );
              },
            ),
            const SizedBox(width: 8),
            const _Divider(),
            const SizedBox(width: 8),
            // Fabric filters
            _FilterChipWidget(
              label: 'Cotton',
              emoji: '🌿',
              isActive: state.activeFabricFilter == 'cotton',
              onTap: () {
                ref.read(wardrobeProvider.notifier).setFabricFilter(
                      state.activeFabricFilter == 'cotton' ? null : 'cotton',
                    );
              },
            ),
            const SizedBox(width: 8),
            _FilterChipWidget(
              label: 'Polyester',
              emoji: '🔬',
              isActive: state.activeFabricFilter == 'polyester',
              onTap: () {
                ref.read(wardrobeProvider.notifier).setFabricFilter(
                      state.activeFabricFilter == 'polyester'
                          ? null
                          : 'polyester',
                    );
              },
            ),
            const SizedBox(width: 8),
            _FilterChipWidget(
              label: 'Wool',
              emoji: '🐑',
              isActive: state.activeFabricFilter == 'wool',
              onTap: () {
                ref.read(wardrobeProvider.notifier).setFabricFilter(
                      state.activeFabricFilter == 'wool' ? null : 'wool',
                    );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGarmentGrid(WardrobeState state) {
    return RefreshIndicator(
      onRefresh: () => ref.read(wardrobeProvider.notifier).refresh(),
      color: AppColors.primary,
      child: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 0.75,
        ),
        itemCount: state.filteredGarments.length,
        itemBuilder: (context, index) {
          final garment = state.filteredGarments[index];
          return GarmentCard(
            garment: garment,
            onTap: () => context.push('/garment/${garment.id}'),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(WardrobeState state) {
    final hasFilters = state.hasActiveFilters;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: AppColors.primaryContainer.withOpacity(0.4),
                shape: BoxShape.circle,
              ),
              child: Icon(
                hasFilters ? Icons.filter_list_off : Icons.checkroom_outlined,
                size: 48,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              hasFilters ? 'No matching garments' : 'Your wardrobe is empty',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              hasFilters
                  ? 'Try adjusting your filters to see more garments.'
                  : 'Scan a clothing tag to add your first garment.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 28),
            if (hasFilters)
              OutlinedButton.icon(
                onPressed: () =>
                    ref.read(wardrobeProvider.notifier).clearAllFilters(),
                icon: const Icon(Icons.clear_all),
                label: const Text('Clear Filters'),
              )
            else
              ElevatedButton.icon(
                onPressed: () => context.push('/scan'),
                icon: const Icon(Icons.camera_alt),
                label: const Text('Scan First Tag'),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: AppColors.error, size: 56),
            const SizedBox(height: 16),
            const Text(
              'Something went wrong',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () => ref.read(wardrobeProvider.notifier).refresh(),
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Filter Chip Widget ────────────────────────────────────────────────────────

class _FilterChipWidget extends StatelessWidget {
  final String label;
  final String emoji;
  final bool isActive;
  final VoidCallback onTap;

  const _FilterChipWidget({
    required this.label,
    required this.emoji,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: isActive ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isActive ? AppColors.primary : AppColors.border,
          ),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.25),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 14)),
            const SizedBox(width: 5),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isActive ? Colors.white : AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 28,
      color: AppColors.border,
    );
  }
}

// ── Garment Card Widget ───────────────────────────────────────────────────────

class GarmentCard extends StatelessWidget {
  final Garment garment;
  final VoidCallback onTap;

  const GarmentCard({
    super.key,
    required this.garment,
    required this.onTap,
  });

  Color _categoryColor(GarmentCategory category) {
    switch (category) {
      case GarmentCategory.tops:
        return AppColors.categoryTops;
      case GarmentCategory.bottoms:
        return AppColors.categoryBottoms;
      case GarmentCategory.dresses:
        return AppColors.categoryDresses;
      case GarmentCategory.outerwear:
        return AppColors.categoryOuterwear;
      case GarmentCategory.underwear:
        return AppColors.categoryUnderwear;
      case GarmentCategory.activewear:
        return AppColors.categoryActivewear;
      case GarmentCategory.delicates:
        return AppColors.categoryDelicates;
      case GarmentCategory.accessories:
        return AppColors.categoryAccessories;
      case GarmentCategory.other:
        return AppColors.categoryOther;
    }
  }

  @override
  Widget build(BuildContext context) {
    final categoryColor = _categoryColor(garment.category);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
          boxShadow: const [
            BoxShadow(
              color: AppColors.shadow,
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Photo area
            Expanded(
              child: ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(16)),
                child: garment.garmentPhotoPath != null
                    ? Image.file(
                        File(garment.garmentPhotoPath!),
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) =>
                            _buildPhotoPlaceholder(categoryColor),
                      )
                    : _buildPhotoPlaceholder(categoryColor),
              ),
            ),

            // Info section
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: categoryColor.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '${garment.category.emoji} ${garment.category.displayName}',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: categoryColor,
                      ),
                    ),
                  ),
                  const SizedBox(height: 5),

                  // Garment name
                  Text(
                    garment.name,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),

                  // Care icons strip
                  _buildCareIconStrip(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotoPlaceholder(Color color) {
    return Container(
      color: color.withOpacity(0.1),
      child: Center(
        child: Text(
          garment.category.emoji,
          style: const TextStyle(fontSize: 48),
        ),
      ),
    );
  }

  Widget _buildCareIconStrip() {
    final icons = <_CareIcon>[];
    final care = garment.careProfile;

    if (care.washMethod != WashMethod.unknown) {
      icons.add(_CareIcon(
        emoji: care.washMethod.emoji,
        color: AppColors.washColor,
      ));
    }
    if (care.ironLevel != IronLevel.unknown) {
      icons.add(_CareIcon(
        emoji: '🔥',
        color: AppColors.ironColor,
      ));
    }
    if (care.bleachType != BleachType.unknown) {
      icons.add(_CareIcon(
        emoji: care.bleachType.emoji,
        color: AppColors.bleachColor,
      ));
    }
    if (care.dryMethod != DryMethod.unknown) {
      icons.add(_CareIcon(
        emoji: care.dryMethod.emoji,
        color: AppColors.dryColor,
      ));
    }

    if (icons.isEmpty) {
      return const Text(
        'No care info',
        style: TextStyle(fontSize: 10, color: AppColors.textHint),
      );
    }

    return Row(
      children: icons.take(4).map((icon) {
        return Container(
          margin: const EdgeInsets.only(right: 4),
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: icon.color.withOpacity(0.12),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Center(
            child: Text(icon.emoji, style: const TextStyle(fontSize: 12)),
          ),
        );
      }).toList(),
    );
  }
}

class _CareIcon {
  final String emoji;
  final Color color;
  const _CareIcon({required this.emoji, required this.color});
}
