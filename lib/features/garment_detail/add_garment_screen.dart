import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import '../../core/constants/app_colors.dart';
import '../../core/models/care_profile.dart';
import '../../core/models/garment.dart';
import '../../data/garment_repository.dart';
import '../../features/wardrobe/wardrobe_provider.dart';

class AddGarmentScreen extends ConsumerStatefulWidget {
  final CareProfile? careProfile;
  final String? tagPhotoPath;
  final Garment? existingGarment;

  const AddGarmentScreen({
    super.key,
    this.careProfile,
    this.tagPhotoPath,
    this.existingGarment,
  });

  @override
  ConsumerState<AddGarmentScreen> createState() => _AddGarmentScreenState();
}

class _AddGarmentScreenState extends ConsumerState<AddGarmentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _tagController = TextEditingController();

  GarmentCategory _selectedCategory = GarmentCategory.tops;
  String? _garmentPhotoPath;
  final List<String> _customTags = [];
  bool _isSaving = false;
  bool _isCareExpanded = true;

  late CareProfile _careProfile;

  @override
  void initState() {
    super.initState();
    final existing = widget.existingGarment;
    if (existing != null) {
      _nameController.text = existing.name;
      _selectedCategory = existing.category;
      _garmentPhotoPath = existing.garmentPhotoPath;
      _customTags.addAll(existing.customTags);
      _careProfile = existing.careProfile;
    } else {
      _careProfile = widget.careProfile ?? CareProfile.empty();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _tagController.dispose();
    super.dispose();
  }

  Future<void> _pickGarmentPhoto(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: source,
        imageQuality: 85,
        maxWidth: 1200,
        maxHeight: 1200,
      );
      if (image != null) {
        setState(() => _garmentPhotoPath = image.path);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to pick image: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _showPhotoOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.camera_alt_outlined, color: AppColors.primary),
              title: const Text('Take Photo'),
              onTap: () {
                Navigator.pop(context);
                _pickGarmentPhoto(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined, color: AppColors.primary),
              title: const Text('Choose from Gallery'),
              onTap: () {
                Navigator.pop(context);
                _pickGarmentPhoto(ImageSource.gallery);
              },
            ),
            if (_garmentPhotoPath != null)
              ListTile(
                leading: const Icon(Icons.delete_outline, color: AppColors.error),
                title: const Text('Remove Photo',
                    style: TextStyle(color: AppColors.error)),
                onTap: () {
                  Navigator.pop(context);
                  setState(() => _garmentPhotoPath = null);
                },
              ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  void _addCustomTag(String tag) {
    final trimmed = tag.trim();
    if (trimmed.isNotEmpty && !_customTags.contains(trimmed)) {
      setState(() {
        _customTags.add(trimmed);
        _tagController.clear();
      });
    }
  }

  Future<void> _saveGarment() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final repo = ref.read(garmentRepositoryProvider);
      final existing = widget.existingGarment;

      final garment = Garment(
        id: existing?.id ?? const Uuid().v4(),
        name: _nameController.text.trim(),
        category: _selectedCategory,
        garmentPhotoPath: _garmentPhotoPath,
        tagPhotoPath: widget.tagPhotoPath ?? existing?.tagPhotoPath,
        careProfile: _careProfile,
        createdAt: existing?.createdAt ?? DateTime.now(),
        customTags: List.from(_customTags),
      );

      if (existing != null) {
        await repo.update(garment);
      } else {
        await repo.save(garment);
      }

      await ref.read(wardrobeProvider.notifier).refresh();

      if (mounted) {
        context.go('/');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.existingGarment != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Garment' : 'Add Garment'),
        actions: [
          if (_isSaving)
            const Padding(
              padding: EdgeInsets.all(16),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          else
            TextButton(
              onPressed: _saveGarment,
              child: const Text(
                'Save',
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
              ),
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Garment Photo Section
            _buildPhotoSection(),
            const SizedBox(height: 20),

            // Name field
            _buildNameField(),
            const SizedBox(height: 20),

            // Category picker
            _buildCategoryPicker(),
            const SizedBox(height: 20),

            // Care Instructions Preview
            _buildCareInstructionsPreview(),
            const SizedBox(height: 20),

            // Custom Tags
            _buildCustomTagsSection(),
            const SizedBox(height: 100),
          ],
        ),
      ),
      bottomNavigationBar: Container(
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
          onPressed: _isSaving ? null : _saveGarment,
          icon: _isSaving
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                      color: Colors.white, strokeWidth: 2),
                )
              : const Icon(Icons.save_outlined),
          label: Text(isEditing ? 'Update Garment' : 'Save to Wardrobe'),
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(double.infinity, 52),
          ),
        ),
      ),
    );
  }

  Widget _buildPhotoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Garment Photo',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: _showPhotoOptions,
          child: Container(
            height: 200,
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: _garmentPhotoPath != null
                    ? AppColors.primary.withOpacity(0.3)
                    : AppColors.border,
                width: 1.5,
              ),
            ),
            child: _garmentPhotoPath != null
                ? Stack(
                    fit: StackFit.expand,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(15),
                        child: Image.file(
                          File(_garmentPhotoPath!),
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) =>
                              _buildPhotoPlaceholder(),
                        ),
                      ),
                      Positioned(
                        bottom: 12,
                        right: 12,
                        child: GestureDetector(
                          onTap: _showPhotoOptions,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: const BoxDecoration(
                              color: Colors.black54,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.edit, color: Colors.white, size: 18),
                          ),
                        ),
                      ),
                    ],
                  )
                : _buildPhotoPlaceholder(),
          ),
        ),
      ],
    );
  }

  Widget _buildPhotoPlaceholder() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.add_a_photo_outlined,
              color: AppColors.primary, size: 28),
        ),
        const SizedBox(height: 10),
        const Text(
          'Tap to add photo',
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const Text(
          'Camera or gallery',
          style: TextStyle(color: AppColors.textHint, fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildNameField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Garment Name',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _nameController,
          decoration: const InputDecoration(
            hintText: 'e.g. Blue Oxford Shirt, Black Jeans...',
            prefixIcon: Icon(Icons.label_outline, color: AppColors.textSecondary),
          ),
          textCapitalization: TextCapitalization.words,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please enter a name for this garment';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildCategoryPicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Category',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: GarmentCategory.values.map((category) {
            final isSelected = _selectedCategory == category;
            return GestureDetector(
              onTap: () => setState(() => _selectedCategory = category),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primary
                      : AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected ? AppColors.primary : AppColors.border,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      category.emoji,
                      style: const TextStyle(fontSize: 18),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      category.displayName,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: isSelected
                            ? Colors.white
                            : AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildCareInstructionsPreview() {
    final care = _careProfile;
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.info_outline, color: AppColors.primary),
            title: const Text(
              'Care Instructions Preview',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            trailing: IconButton(
              icon: Icon(
                _isCareExpanded ? Icons.expand_less : Icons.expand_more,
              ),
              onPressed: () =>
                  setState(() => _isCareExpanded = !_isCareExpanded),
            ),
          ),
          if (_isCareExpanded) ...[
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(16),
              child: care.hasData
                  ? Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        if (care.washMethod != WashMethod.unknown)
                          _CareBadge(
                            label: care.washMethod.displayName,
                            emoji: care.washMethod.emoji,
                            color: AppColors.washColor,
                          ),
                        if (care.maxTemperature != null)
                          _CareBadge(
                            label: '${care.maxTemperature}°C',
                            emoji: '🌡️',
                            color: AppColors.primary,
                          ),
                        if (care.ironLevel != IronLevel.unknown)
                          _CareBadge(
                            label: care.ironLevel.displayName,
                            emoji: '🔥',
                            color: AppColors.ironColor,
                          ),
                        if (care.bleachType != BleachType.unknown)
                          _CareBadge(
                            label: care.bleachType.displayName,
                            emoji: care.bleachType.emoji,
                            color: AppColors.bleachColor,
                          ),
                        if (care.dryMethod != DryMethod.unknown)
                          _CareBadge(
                            label: care.dryMethod.displayName,
                            emoji: care.dryMethod.emoji,
                            color: AppColors.dryColor,
                          ),
                        ...care.fabricComposition.map(
                          (f) => _CareBadge(
                            label: f,
                            emoji: '🧵',
                            color: AppColors.dryCleanColor,
                          ),
                        ),
                      ],
                    )
                  : const Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        child: Text(
                          'No care data available.\nScan a tag or add symbols manually.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppColors.textHint,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCustomTagsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Custom Tags',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Add personal labels like "work", "favourite", "gym"',
          style: TextStyle(fontSize: 12, color: AppColors.textHint),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _tagController,
                decoration: const InputDecoration(
                  hintText: 'Type a tag and press Add',
                  prefixIcon: Icon(Icons.tag, color: AppColors.textSecondary, size: 20),
                ),
                onSubmitted: _addCustomTag,
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: () => _addCustomTag(_tagController.text),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              ),
              child: const Text('Add'),
            ),
          ],
        ),
        if (_customTags.isNotEmpty) ...[
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _customTags.map((tag) {
              return Chip(
                label: Text(tag),
                deleteIcon: const Icon(Icons.close, size: 16),
                onDeleted: () => setState(() => _customTags.remove(tag)),
                backgroundColor: AppColors.primaryContainer.withOpacity(0.4),
                side: const BorderSide(color: AppColors.primary, width: 0.5),
                labelStyle: const TextStyle(
                  color: AppColors.primaryDark,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              );
            }).toList(),
          ),
        ],
      ],
    );
  }
}

class _CareBadge extends StatelessWidget {
  final String label;
  final String emoji;
  final Color color;

  const _CareBadge({
    required this.label,
    required this.emoji,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
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
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
