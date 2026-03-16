import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/care_data.dart';
import '../../core/models/care_profile.dart';
import '../../core/models/garment.dart';
import '../../core/utils/symbol_picker_data.dart';
import '../../data/garment_repository.dart';
import '../../features/wardrobe/wardrobe_provider.dart';
import '../../shared/widgets/care_chip.dart';
import '../../shared/widgets/wash_guide_card.dart';

class GarmentDetailScreen extends ConsumerWidget {
  final String garmentId;

  const GarmentDetailScreen({super.key, required this.garmentId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repo = ref.read(garmentRepositoryProvider);
    final garment = repo.getById(garmentId);

    if (garment == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Garment')),
        body: const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.search_off, size: 56, color: AppColors.textHint),
              SizedBox(height: 16),
              Text(
                'Garment not found',
                style: TextStyle(
                  fontSize: 18,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return _GarmentDetailContent(garment: garment);
  }
}

class _GarmentDetailContent extends ConsumerStatefulWidget {
  final Garment garment;

  const _GarmentDetailContent({required this.garment});

  @override
  ConsumerState<_GarmentDetailContent> createState() =>
      _GarmentDetailContentState();
}

class _GarmentDetailContentState
    extends ConsumerState<_GarmentDetailContent>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _deleteGarment() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Garment'),
        content: Text(
          'Are you sure you want to delete "${widget.garment.name}"? This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await ref.read(wardrobeProvider.notifier).deleteGarment(widget.garment.id);
      if (mounted) context.go('/');
    }
  }

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
    final g = widget.garment;
    final care = g.careProfile;
    final categoryColor = _categoryColor(g.category);

    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            floating: false,
            forceElevated: innerBoxIsScrolled,
            backgroundColor: Colors.white,
            foregroundColor: AppColors.textPrimary,
            actions: [
              PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'edit') {
                    context.push(
                      '/garment/add',
                      extra: {
                        'careProfile': g.careProfile,
                        'tagPhotoPath': g.tagPhotoPath,
                        'existingGarment': g,
                      },
                    );
                  } else if (value == 'delete') {
                    _deleteGarment();
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit_outlined, size: 18),
                        SizedBox(width: 10),
                        Text('Edit'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete_outline, size: 18, color: AppColors.error),
                        SizedBox(width: 10),
                        Text('Delete', style: TextStyle(color: AppColors.error)),
                      ],
                    ),
                  ),
                ],
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: g.garmentPhotoPath != null
                  ? Image.file(
                      File(g.garmentPhotoPath!),
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) =>
                          _buildPhotoPlaceholder(categoryColor, g),
                    )
                  : _buildPhotoPlaceholder(categoryColor, g),
            ),
          ),

          // Garment name + care chips
          SliverToBoxAdapter(
            child: Container(
              color: Colors.white,
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: categoryColor.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                '${g.category.emoji} ${g.category.displayName}',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: categoryColor,
                                ),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              g.name,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  // Care symbols strip
                  _buildCareChipsStrip(care),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),

          // Tab bar
          SliverPersistentHeader(
            pinned: true,
            delegate: _SliverTabBarDelegate(
              TabBar(
                controller: _tabController,
                isScrollable: true,
                tabs: const [
                  Tab(text: 'How to Wash'),
                  Tab(text: "Do's & Don'ts"),
                  Tab(text: 'Chemicals'),
                  Tab(text: 'Handling'),
                ],
              ),
            ),
          ),
        ],
        body: TabBarView(
          controller: _tabController,
          children: [
            _HowToWashTab(garment: g),
            _DosDontsTab(garment: g),
            _ChemicalsTab(garment: g),
            _HandlingTab(garment: g),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push(
          '/garment/add',
          extra: {
            'careProfile': g.careProfile,
            'tagPhotoPath': g.tagPhotoPath,
            'existingGarment': g,
          },
        ),
        mini: false,
        child: const Icon(Icons.edit_outlined),
      ),
    );
  }

  Widget _buildPhotoPlaceholder(Color color, Garment g) {
    return Container(
      color: color.withOpacity(0.15),
      child: Center(
        child: Text(g.category.emoji, style: const TextStyle(fontSize: 80)),
      ),
    );
  }

  Widget _buildCareChipsStrip(CareProfile careProfile) {
    final symbols = careProfile.selectedSymbolIds
        .map((id) => SymbolPickerData.findById(id))
        .whereType<CareSymbol>()
        .toList();

    final builtInChips = <Widget>[];
    if (careProfile.washMethod != WashMethod.unknown) {
      builtInChips.add(CareChip(
        label: careProfile.washMethod.displayName,
        emoji: careProfile.washMethod.emoji,
        category: SymbolCategory.wash,
      ));
    }
    if (careProfile.maxTemperature != null) {
      builtInChips.add(CareChip(
        label: '${careProfile.maxTemperature}°C',
        emoji: '🌡️',
        category: SymbolCategory.wash,
      ));
    }
    if (careProfile.ironLevel != IronLevel.unknown) {
      builtInChips.add(CareChip(
        label: careProfile.ironLevel.displayName,
        emoji: '🔥',
        category: SymbolCategory.iron,
      ));
    }
    if (careProfile.bleachType != BleachType.unknown) {
      builtInChips.add(CareChip(
        label: careProfile.bleachType.displayName,
        emoji: careProfile.bleachType.emoji,
        category: SymbolCategory.bleach,
      ));
    }
    if (careProfile.dryMethod != DryMethod.unknown) {
      builtInChips.add(CareChip(
        label: careProfile.dryMethod.displayName,
        emoji: careProfile.dryMethod.emoji,
        category: SymbolCategory.dry,
      ));
    }

    final allChips = [
      ...builtInChips,
      ...symbols.map(
        (s) => CareChip(
          label: s.name,
          emoji: s.emoji,
          category: s.category,
        ),
      ),
    ];

    if (allChips.isEmpty) {
      return const Text(
        'No care symbols recorded.',
        style: TextStyle(color: AppColors.textHint, fontSize: 13),
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: allChips
            .map((chip) => Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: chip,
                ))
            .toList(),
      ),
    );
  }
}

// ── How to Wash Tab ───────────────────────────────────────────────────────────

class _HowToWashTab extends StatelessWidget {
  final Garment garment;

  const _HowToWashTab({required this.garment});

  @override
  Widget build(BuildContext context) {
    final steps =
        CareData.washGuides[garment.careProfile.washMethod] ?? [];
    final temp = garment.careProfile.maxTemperature;
    final spinSpeed = garment.careProfile.spinSpeed;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Summary card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.primary, AppColors.primaryLight],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Text(
                garment.careProfile.washMethod.emoji,
                style: const TextStyle(fontSize: 32),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      garment.careProfile.washMethod.displayName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (temp != null)
                      Text(
                        'Max temperature: $temp°C',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 13,
                        ),
                      ),
                    if (spinSpeed != SpinSpeed.unknown)
                      Text(
                        spinSpeed.displayName,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 13,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Step by step guide
        const Text(
          'Step-by-Step Guide',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        ...steps.map(
          (step) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: WashGuideCard(step: step),
          ),
        ),

        // Fabric-specific tips
        if (garment.careProfile.fabricComposition.isNotEmpty) ...[
          const SizedBox(height: 8),
          _buildFabricTips(),
        ],
        const SizedBox(height: 40),
      ],
    );
  }

  Widget _buildFabricTips() {
    final allTips = <FabricCareTip>[];
    for (final fabric in garment.careProfile.fabricComposition) {
      final lower = fabric.toLowerCase().replaceAll(RegExp(r'\d+%\s*'), '').trim();
      final tip = CareData.fabricTips.where((t) => lower.contains(t.fabric)).toList();
      allTips.addAll(tip);
    }

    if (allTips.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Fabric Care Tips',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        ...allTips.map(
          (tip) => Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.infoLight,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.info.withOpacity(0.2)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${tip.fabric[0].toUpperCase()}${tip.fabric.substring(1)} Tips',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.info,
                  ),
                ),
                const SizedBox(height: 8),
                ...tip.tips.map(
                  (t) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('• ', style: TextStyle(color: AppColors.info)),
                        Expanded(
                          child: Text(
                            t,
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ── Do's & Don'ts Tab ─────────────────────────────────────────────────────────

class _DosDontsTab extends StatelessWidget {
  final Garment garment;

  const _DosDontsTab({required this.garment});

  @override
  Widget build(BuildContext context) {
    final care = garment.careProfile;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Do's section
        _SectionHeader(
          title: "Do's",
          icon: Icons.check_circle_outline,
          color: AppColors.success,
        ),
        const SizedBox(height: 10),
        ...care.doList.map(
          (item) => _DoCard(text: item),
        ),
        if (care.doList.isEmpty)
          const _EmptySection(message: 'No specific instructions detected.'),
        const SizedBox(height: 20),

        // Don'ts section
        _SectionHeader(
          title: "Don'ts",
          icon: Icons.cancel_outlined,
          color: AppColors.error,
        ),
        const SizedBox(height: 10),
        ...care.dontList.map(
          (item) => _DontCard(text: item),
        ),
        if (care.dontList.isEmpty)
          const _EmptySection(message: 'No specific restrictions detected.'),
        const SizedBox(height: 40),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;

  const _SectionHeader({
    required this.title,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: color, size: 22),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
      ],
    );
  }
}

class _DoCard extends StatelessWidget {
  final String text;
  const _DoCard({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.successLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.success.withOpacity(0.25)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.check, color: AppColors.success, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DontCard extends StatelessWidget {
  final String text;
  const _DontCard({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.errorLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.error.withOpacity(0.25)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.close, color: AppColors.error, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptySection extends StatelessWidget {
  final String message;
  const _EmptySection({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        message,
        style: const TextStyle(
          color: AppColors.textHint,
          fontSize: 13,
          fontStyle: FontStyle.italic,
        ),
      ),
    );
  }
}

// ── Chemicals Tab ─────────────────────────────────────────────────────────────

class _ChemicalsTab extends StatelessWidget {
  final Garment garment;

  const _ChemicalsTab({required this.garment});

  @override
  Widget build(BuildContext context) {
    final care = garment.careProfile;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Safe to use
        _SectionHeader(
          title: 'Safe to Use',
          icon: Icons.check_circle_outline,
          color: AppColors.success,
        ),
        const SizedBox(height: 10),
        ...care.chemicalsAllowed.map(
          (item) => _ChemicalItem(
            text: item,
            isAllowed: true,
          ),
        ),
        if (care.chemicalsAllowed.isEmpty)
          const _EmptySection(message: 'No specific chemicals recommended.'),

        const SizedBox(height: 20),

        // Avoid
        _SectionHeader(
          title: 'Avoid These',
          icon: Icons.block_outlined,
          color: AppColors.error,
        ),
        const SizedBox(height: 10),
        ...care.chemicalsNotAllowed.map(
          (item) => _ChemicalItem(
            text: item,
            isAllowed: false,
          ),
        ),
        if (care.chemicalsNotAllowed.isEmpty)
          const _EmptySection(message: 'No specific chemicals to avoid.'),

        const SizedBox(height: 20),

        // General advice
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.warningLight,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.warning.withOpacity(0.3)),
          ),
          child: const Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.info_outline, color: AppColors.warning, size: 20),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Always test new products on a hidden area first. Follow product instructions and never mix chemicals.',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 40),
      ],
    );
  }
}

class _ChemicalItem extends StatelessWidget {
  final String text;
  final bool isAllowed;

  const _ChemicalItem({required this.text, required this.isAllowed});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: isAllowed ? AppColors.successLight : AppColors.errorLight,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isAllowed
              ? AppColors.success.withOpacity(0.2)
              : AppColors.error.withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          Icon(
            isAllowed ? Icons.check : Icons.block,
            color: isAllowed ? AppColors.success : AppColors.error,
            size: 18,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 14, color: AppColors.textPrimary),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Handling Tab ──────────────────────────────────────────────────────────────

class _HandlingTab extends StatelessWidget {
  final Garment garment;

  const _HandlingTab({required this.garment});

  @override
  Widget build(BuildContext context) {
    final care = garment.careProfile;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Iron guide
        _HandlingSection(
          title: 'Ironing',
          icon: Icons.iron_outlined,
          color: AppColors.ironColor,
          child: _buildIronGuide(care.ironLevel),
        ),
        const SizedBox(height: 16),

        // Drying guide
        _HandlingSection(
          title: 'Drying',
          icon: Icons.air_outlined,
          color: AppColors.dryColor,
          child: _buildDryGuide(care.dryMethod),
        ),
        const SizedBox(height: 16),

        // Fabric composition
        if (care.fabricComposition.isNotEmpty) ...[
          _HandlingSection(
            title: 'Fabric Composition',
            icon: Icons.texture_outlined,
            color: AppColors.dryCleanColor,
            child: _buildFabricInfo(care.fabricComposition),
          ),
          const SizedBox(height: 16),
        ],

        // Storage tips
        _HandlingSection(
          title: 'Storage Tips',
          icon: Icons.inventory_2_outlined,
          color: AppColors.primary,
          child: _buildStorageTips(care),
        ),

        const SizedBox(height: 40),
      ],
    );
  }

  Widget _buildIronGuide(IronLevel ironLevel) {
    if (ironLevel == IronLevel.unknown) {
      return const Text(
        'No ironing information detected.',
        style: TextStyle(color: AppColors.textHint, fontSize: 13),
      );
    }

    final info = {
      IronLevel.noIron: {
        'icon': '🚫',
        'title': 'Do Not Iron',
        'detail': 'This garment should not be ironed. The heat may melt, distort, or damage the fabric or decorative elements.',
        'tips': ['Steam the garment on a hanger to remove wrinkles', 'Use a fabric steamer instead', 'Fold and store flat to minimize creasing'],
      },
      IronLevel.low: {
        'icon': '🔥',
        'title': 'Low Heat — 110°C max',
        'detail': 'Use the lowest iron setting (1 dot). Suitable for synthetics like nylon, polyester, and acrylic.',
        'tips': ['Iron on the reverse side', 'Use a pressing cloth as protection', 'Avoid steam unless stated otherwise'],
      },
      IronLevel.medium: {
        'icon': '🔥',
        'title': 'Medium Heat — 150°C max',
        'detail': 'Use medium iron setting (2 dots). Suitable for wool, polyester blends, and silk.',
        'tips': ['Use steam for easier ironing', 'Iron while slightly damp', 'Use a pressing cloth for delicate finishes'],
      },
      IronLevel.high: {
        'icon': '🔥',
        'title': 'High Heat — 200°C max',
        'detail': 'Use high iron setting (3 dots). Suitable for cotton and linen.',
        'tips': ['Dampen fabric lightly for best results', 'Iron while slightly damp', 'Use steam for stubborn creases'],
      },
      IronLevel.steamOk: {
        'icon': '💨',
        'title': 'Steam Ironing OK',
        'detail': 'Steam ironing is safe and recommended for this garment.',
        'tips': ['Use steam throughout', 'Hold steamer 2-3 cm from fabric', 'Hang immediately after steaming'],
      },
    }[ironLevel];

    if (info == null) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(info['icon'] as String, style: const TextStyle(fontSize: 24)),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                info['title'] as String,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          info['detail'] as String,
          style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
        ),
        const SizedBox(height: 10),
        ...(info['tips'] as List<String>).map(
          (tip) => Padding(
            padding: const EdgeInsets.only(bottom: 5),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('• ', style: TextStyle(color: AppColors.ironColor)),
                Expanded(
                  child: Text(
                    tip,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDryGuide(DryMethod dryMethod) {
    if (dryMethod == DryMethod.unknown) {
      return const Text(
        'No drying information detected.',
        style: TextStyle(color: AppColors.textHint, fontSize: 13),
      );
    }

    String emoji;
    String title;
    String detail;
    List<String> tips;

    switch (dryMethod) {
      case DryMethod.tumbleDryLow:
        emoji = '🌀';
        title = 'Tumble Dry — Low Heat';
        detail = 'Use the tumble dryer on a low heat setting to minimize shrinkage and damage.';
        tips = ['Remove promptly when dry', 'Use a dryer sheet to reduce static', 'Do not overdry'];
        break;
      case DryMethod.tumbleDryMedium:
        emoji = '🌀';
        title = 'Tumble Dry — Medium Heat';
        detail = 'Tumble dry on a medium heat setting.';
        tips = ['Remove while slightly damp if prone to wrinkles', 'Reshape while warm'];
        break;
      case DryMethod.tumbleDryHigh:
        emoji = '🌀';
        title = 'Tumble Dry — High Heat';
        detail = 'Tumble dry on high heat. Suitable for sturdy items like towels and cotton.';
        tips = ['Check for shrinkage on first use', 'Remove promptly to avoid over-drying'];
        break;
      case DryMethod.doNotTumbleDry:
        emoji = '🚫';
        title = 'Do Not Tumble Dry';
        detail = 'The heat and tumbling motion will damage this garment.';
        tips = ['Air dry on a hanger or flat surface', 'Keep away from direct heat or sunlight'];
        break;
      case DryMethod.lineDry:
        emoji = '🪢';
        title = 'Line Dry';
        detail = 'Hang on a line, hanger, or drying rack to air dry naturally.';
        tips = ['Dry away from direct sunlight to prevent fading', 'Reshape while damp', 'Ensure good air circulation'];
        break;
      case DryMethod.dryFlat:
        emoji = '📐';
        title = 'Dry Flat';
        detail = 'Lay the garment flat on a clean dry surface. This prevents stretching from the weight of water.';
        tips = ['Use a clean towel underneath', 'Reshape immediately after washing', 'Turn halfway through drying'];
        break;
      case DryMethod.dripDry:
        emoji = '💧';
        title = 'Drip Dry';
        detail = 'Hang while wet and allow to drip dry naturally. Do not squeeze out water.';
        tips = ['Hang over the bath or outside', 'Do not wring', 'Ensure good air flow'];
        break;
      case DryMethod.unknown:
        emoji = '❓';
        title = 'Unknown Dry Method';
        detail = 'No specific drying instructions found. Air drying is generally safest.';
        tips = [];
        break;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 24)),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          detail,
          style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
        ),
        if (tips.isNotEmpty) ...[
          const SizedBox(height: 10),
          ...tips.map(
            (tip) => Padding(
              padding: const EdgeInsets.only(bottom: 5),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('• ', style: TextStyle(color: AppColors.dryColor)),
                  Expanded(
                    child: Text(
                      tip,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildFabricInfo(List<String> fabrics) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: fabrics.map((fabric) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.dryCleanColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: AppColors.dryCleanColor.withOpacity(0.3),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('🧵', style: TextStyle(fontSize: 16)),
              const SizedBox(width: 6),
              Text(
                fabric,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.dryCleanColor,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildStorageTips(CareProfile care) {
    final tips = <String>[
      'Ensure garment is fully clean and dry before storing',
      'Store in a cool, dry, well-ventilated area',
    ];

    final fabrics = care.fabricComposition
        .map((f) => f.toLowerCase())
        .join(' ');

    if (fabrics.contains('wool') || fabrics.contains('cashmere')) {
      tips.add('Fold and store flat — do not hang, as it can stretch');
      tips.add('Use cedar blocks or lavender to repel moths');
    }
    if (fabrics.contains('silk') || fabrics.contains('delicate')) {
      tips.add('Store in a breathable cotton or linen garment bag');
      tips.add('Keep away from direct sunlight to prevent yellowing');
    }
    if (fabrics.contains('linen') || fabrics.contains('cotton')) {
      tips.add('Can be stored on hangers — use padded or wide hangers');
    }

    tips.add('Do not store in plastic bags — fabric needs to breathe');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: tips
          .map(
            (tip) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('• ', style: TextStyle(color: AppColors.primary)),
                  Expanded(
                    child: Text(
                      tip,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )
          .toList(),
    );
  }
}

class _HandlingSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final Widget child;

  const _HandlingSection({
    required this.title,
    required this.icon,
    required this.color,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

// ── Sliver Tab Bar Delegate ───────────────────────────────────────────────────

class _SliverTabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;

  _SliverTabBarDelegate(this.tabBar);

  @override
  double get minExtent => tabBar.preferredSize.height;

  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Colors.white,
      child: tabBar,
    );
  }

  @override
  bool shouldRebuild(covariant _SliverTabBarDelegate oldDelegate) {
    return tabBar != oldDelegate.tabBar;
  }
}
