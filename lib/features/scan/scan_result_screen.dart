import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/models/care_profile.dart';
import '../../core/models/garment.dart';
import '../../core/utils/symbol_picker_data.dart';
import '../../shared/widgets/care_chip.dart';

class ScanResultScreen extends ConsumerStatefulWidget {
  final CareProfile careProfile;
  final String? imagePath;
  final String rawText;

  const ScanResultScreen({
    super.key,
    required this.careProfile,
    this.imagePath,
    required this.rawText,
  });

  @override
  ConsumerState<ScanResultScreen> createState() => _ScanResultScreenState();
}

class _ScanResultScreenState extends ConsumerState<ScanResultScreen> {
  late CareProfile _careProfile;
  bool _isTagPhotoExpanded = true;
  bool _isRawTextExpanded = false;
  final Set<String> _selectedSymbolIds = {};

  @override
  void initState() {
    super.initState();
    _careProfile = widget.careProfile;
    _selectedSymbolIds.addAll(widget.careProfile.selectedSymbolIds);
  }

  void _showSymbolPicker() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => _SymbolPickerSheet(
        selectedIds: Set.from(_selectedSymbolIds),
        onSelectionChanged: (ids) {
          setState(() {
            _selectedSymbolIds
              ..clear()
              ..addAll(ids);
            _careProfile = _careProfile.copyWith(
              selectedSymbolIds: ids.toList(),
            );
          });
        },
      ),
    );
  }

  void _navigateToAddGarment() {
    context.push('/garment/add', extra: {'careProfile': _careProfile, 'tagPhotoPath': widget.imagePath});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan Results'),
        actions: [
          TextButton.icon(
            onPressed: _navigateToAddGarment,
            icon: const Icon(Icons.add, color: AppColors.primary),
            label: const Text(
              'Save',
              style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Tag Photo Section
          if (widget.imagePath != null) _buildTagPhotoSection(),

          const SizedBox(height: 12),

          // Raw OCR Text
          if (widget.rawText.isNotEmpty) _buildRawTextSection(),

          const SizedBox(height: 16),

          // Detected Care Info Cards
          _buildCareInfoSection(),

          const SizedBox(height: 16),

          // Symbol Picker button
          _buildSymbolPickerButton(),

          const SizedBox(height: 16),

          // Selected Symbols
          if (_selectedSymbolIds.isNotEmpty) _buildSelectedSymbolsSection(),

          const SizedBox(height: 16),

          // Do's List
          if (_careProfile.doList.isNotEmpty) _buildDoList(),

          const SizedBox(height: 16),

          // Don'ts List
          if (_careProfile.dontList.isNotEmpty) _buildDontList(),

          const SizedBox(height: 100),
        ],
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildTagPhotoSection() {
    return Card(
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.label_outline, color: AppColors.primary),
            title: const Text('Tag Photo', style: TextStyle(fontWeight: FontWeight.w600)),
            trailing: IconButton(
              icon: Icon(
                _isTagPhotoExpanded ? Icons.expand_less : Icons.expand_more,
              ),
              onPressed: () =>
                  setState(() => _isTagPhotoExpanded = !_isTagPhotoExpanded),
            ),
          ),
          if (_isTagPhotoExpanded)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(
                  File(widget.imagePath!),
                  height: 180,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    height: 180,
                    color: AppColors.surfaceVariant,
                    child: const Center(
                      child: Icon(Icons.broken_image_outlined,
                          color: AppColors.textHint, size: 48),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildRawTextSection() {
    return Card(
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.text_snippet_outlined, color: AppColors.textSecondary),
            title: const Text('Detected Text', style: TextStyle(fontWeight: FontWeight.w600)),
            trailing: IconButton(
              icon: Icon(_isRawTextExpanded ? Icons.expand_less : Icons.expand_more),
              onPressed: () =>
                  setState(() => _isRawTextExpanded = !_isRawTextExpanded),
            ),
          ),
          if (_isRawTextExpanded)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  widget.rawText.isEmpty
                      ? 'No text detected. Try the symbol picker below.'
                      : widget.rawText,
                  style: const TextStyle(
                    fontSize: 13,
                    fontFamily: 'monospace',
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCareInfoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Care Instructions',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        _CareInfoCard(
          color: AppColors.washColor,
          icon: Icons.local_laundry_service_outlined,
          title: 'Wash Method',
          value: _careProfile.washMethod.displayName,
          subtitle: _careProfile.maxTemperature != null
              ? 'Max ${_careProfile.maxTemperature}°C'
              : null,
          isUnknown: _careProfile.washMethod == WashMethod.unknown,
        ),
        const SizedBox(height: 8),
        _CareInfoCard(
          color: AppColors.ironColor,
          icon: Icons.iron_outlined,
          title: 'Ironing',
          value: _careProfile.ironLevel.displayName,
          isUnknown: _careProfile.ironLevel == IronLevel.unknown,
        ),
        const SizedBox(height: 8),
        _CareInfoCard(
          color: AppColors.bleachColor,
          icon: Icons.science_outlined,
          title: 'Bleach',
          value: _careProfile.bleachType.displayName,
          isUnknown: _careProfile.bleachType == BleachType.unknown,
        ),
        const SizedBox(height: 8),
        _CareInfoCard(
          color: AppColors.dryColor,
          icon: Icons.air_outlined,
          title: 'Drying',
          value: _careProfile.dryMethod.displayName,
          isUnknown: _careProfile.dryMethod == DryMethod.unknown,
        ),
        if (_careProfile.fabricComposition.isNotEmpty) ...[
          const SizedBox(height: 8),
          _CareInfoCard(
            color: AppColors.dryCleanColor,
            icon: Icons.texture_outlined,
            title: 'Fabric',
            value: _careProfile.fabricComposition.join(', '),
            isUnknown: false,
          ),
        ],
      ],
    );
  }

  Widget _buildSymbolPickerButton() {
    return OutlinedButton.icon(
      onPressed: _showSymbolPicker,
      icon: const Icon(Icons.grid_view_outlined),
      label: Text(
        _selectedSymbolIds.isEmpty
            ? 'Add ISO Symbols Manually'
            : 'Edit Symbols (${_selectedSymbolIds.length} selected)',
      ),
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(double.infinity, 48),
      ),
    );
  }

  Widget _buildSelectedSymbolsSection() {
    final symbols = _selectedSymbolIds
        .map((id) => SymbolPickerData.findById(id))
        .whereType<CareSymbol>()
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Selected Symbols',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: symbols.map((symbol) {
            return CareChip(
              label: symbol.name,
              emoji: symbol.emoji,
              category: symbol.category,
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildDoList() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: const BoxDecoration(
                    color: AppColors.successLight,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check, color: AppColors.success, size: 16),
                ),
                const SizedBox(width: 10),
                const Text(
                  "Do's",
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.success,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...(_careProfile.doList.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.check_circle_outline,
                        color: AppColors.success, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        item,
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildDontList() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: const BoxDecoration(
                    color: AppColors.errorLight,
                    shape: BoxShape.circle,
                  ),
                  child:
                      const Icon(Icons.close, color: AppColors.error, size: 16),
                ),
                const SizedBox(width: 10),
                const Text(
                  "Don'ts",
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.error,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...(_careProfile.dontList.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.cancel_outlined,
                        color: AppColors.error, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        item,
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: EdgeInsets.fromLTRB(
        16,
        12,
        16,
        12 + MediaQuery.of(context).padding.bottom,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 8,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: ElevatedButton.icon(
        onPressed: _navigateToAddGarment,
        icon: const Icon(Icons.checkroom),
        label: const Text('Save to Wardrobe'),
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(double.infinity, 52),
        ),
      ),
    );
  }
}

// ── Care Info Card ────────────────────────────────────────────────────────────

class _CareInfoCard extends StatelessWidget {
  final Color color;
  final IconData icon;
  final String title;
  final String value;
  final String? subtitle;
  final bool isUnknown;

  const _CareInfoCard({
    required this.color,
    required this.icon,
    required this.title,
    required this.value,
    this.subtitle,
    required this.isUnknown,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isUnknown ? AppColors.border : color.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isUnknown
                  ? AppColors.surfaceVariant
                  : color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: isUnknown ? AppColors.textHint : color,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isUnknown
                        ? AppColors.textHint
                        : AppColors.textPrimary,
                  ),
                ),
                if (subtitle != null)
                  Text(
                    subtitle!,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
              ],
            ),
          ),
          if (isUnknown)
            const Icon(Icons.help_outline, color: AppColors.textHint, size: 18),
        ],
      ),
    );
  }
}

// ── Symbol Picker Bottom Sheet ────────────────────────────────────────────────

class _SymbolPickerSheet extends StatefulWidget {
  final Set<String> selectedIds;
  final ValueChanged<Set<String>> onSelectionChanged;

  const _SymbolPickerSheet({
    required this.selectedIds,
    required this.onSelectionChanged,
  });

  @override
  State<_SymbolPickerSheet> createState() => _SymbolPickerSheetState();
}

class _SymbolPickerSheetState extends State<_SymbolPickerSheet>
    with SingleTickerProviderStateMixin {
  late Set<String> _selectedIds;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _selectedIds = Set.from(widget.selectedIds);
    _tabController = TabController(
      length: SymbolCategory.values.length,
      vsync: this,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _toggleSymbol(String id) {
    setState(() {
      if (_selectedIds.contains(id)) {
        _selectedIds.remove(id);
      } else {
        _selectedIds.add(id);
      }
    });
    widget.onSelectionChanged(Set.from(_selectedIds));
  }

  @override
  Widget build(BuildContext context) {
    final byCategory = SymbolPickerData.symbolsByCategory;

    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Column(
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 12),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Text(
                    'ISO Care Symbols',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Spacer(),
                  Text(
                    'Tap to select',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            // Tab bar
            TabBar(
              controller: _tabController,
              isScrollable: true,
              tabs: SymbolCategory.values
                  .map((c) => Tab(text: c.displayName))
                  .toList(),
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: SymbolCategory.values.map((category) {
                  final symbols = byCategory[category] ?? [];
                  return ListView.builder(
                    controller: scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: symbols.length,
                    itemBuilder: (context, index) {
                      final symbol = symbols[index];
                      final isSelected = _selectedIds.contains(symbol.id);
                      return _SymbolTile(
                        symbol: symbol,
                        isSelected: isSelected,
                        onTap: () => _toggleSymbol(symbol.id),
                      );
                    },
                  );
                }).toList(),
              ),
            ),
            // Done button
            Padding(
              padding: EdgeInsets.fromLTRB(
                16,
                8,
                16,
                16 + MediaQuery.of(context).padding.bottom,
              ),
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 48),
                ),
                child: Text(
                  _selectedIds.isEmpty
                      ? 'Done'
                      : 'Done (${_selectedIds.length} selected)',
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _SymbolTile extends StatelessWidget {
  final CareSymbol symbol;
  final bool isSelected;
  final VoidCallback onTap;

  const _SymbolTile({
    required this.symbol,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withOpacity(0.08)
              : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Text(symbol.emoji, style: const TextStyle(fontSize: 28)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    symbol.name,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    symbol.description,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(Icons.check_circle, color: AppColors.primary, size: 22),
          ],
        ),
      ),
    );
  }
}
