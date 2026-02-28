import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:empleame/models/service_model.dart';
import 'package:empleame/providers/my_services_provider.dart';
import 'package:empleame/screens/services/service_detail_screen.dart';

// ── Categories — shared with app filters ─────────────────────────────────────

const _kCategories = [
  'Limpieza',
  'Plomería',
  'Electricidad',
  'Jardinería',
  'Carpintería',
  'Pintura',
  'Tecnología',
  'Salud',
  'Educación',
  'Otros',
];

class ServiceFormScreen extends ConsumerStatefulWidget {
  final ServiceModel? editing;
  const ServiceFormScreen({super.key, this.editing});

  @override
  ConsumerState<ServiceFormScreen> createState() => _ServiceFormScreenState();
}

class _ServiceFormScreenState extends ConsumerState<ServiceFormScreen> {
  late final TextEditingController _titleCtrl;
  late final TextEditingController _descCtrl;
  late final TextEditingController _rateCtrl;

  static const _primary = Color(0xFF7210FF);
  final _picker = ImagePicker();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    final s = ref.read(serviceFormProvider);
    _titleCtrl = TextEditingController(text: s.title);
    _descCtrl = TextEditingController(text: s.description);
    _rateCtrl = TextEditingController(text: s.rate);
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _rateCtrl.dispose();
    super.dispose();
  }

  // ── Image picking ─────────────────────────────────────────────────────────

  Future<void> _pickImages() async {
    final picked = await _picker.pickMultiImage(imageQuality: 90, limit: 6);
    if (picked.isEmpty) return;

    final compressed = <File>[];
    for (final xf in picked) {
      final result = await FlutterImageCompress.compressAndGetFile(
        xf.path,
        '${xf.path}_c.jpg',
        quality: 75,
        minWidth: 800,
        minHeight: 600,
      );
      compressed.add(File(result?.path ?? xf.path));
    }
    ref.read(serviceFormProvider.notifier).addImages(compressed);
  }

  // ── Preview ───────────────────────────────────────────────────────────────

  void _preview() {
    final s = ref.read(serviceFormProvider);
    final preview = ServiceModel(
      id: '',
      title: s.title.trim().isEmpty ? 'Mi Servicio' : s.title,
      category: s.category.isEmpty ? 'Sin categoría' : s.category,
      description: s.description,
      rate: double.tryParse(s.rate) ?? 0,
      workerId: '',
    );
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            ServiceDetailScreen(service: preview, localImages: s.localImages),
      ),
    );
  }

  // ── Save ──────────────────────────────────────────────────────────────────

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final id = await ref.read(serviceFormProvider.notifier).save();
    if (id != null && mounted) {
      ref.read(serviceFormProvider.notifier).reset();
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            '✅ Servicio guardado — en revisión',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
          backgroundColor: const Color(0xFF10B981),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(serviceFormProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        title: Text(
          widget.editing != null ? 'Editar Servicio' : 'Nuevo Servicio',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: Color(0xFF0F172A),
          ),
        ),
        leading: const BackButton(color: Color(0xFF0F172A)),
        actions: [
          TextButton.icon(
            onPressed: state.title.isNotEmpty ? _preview : null,
            icon: const Icon(Icons.visibility_outlined, size: 18),
            label: const Text('Vista previa'),
            style: TextButton.styleFrom(foregroundColor: _primary),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            // ── Photo picker ─────────────────────────────────────────────
            _SectionLabel(label: 'Fotos del servicio'),
            const SizedBox(height: 10),
            _PhotoPicker(
              images: state.localImages,
              onAddTap: _pickImages,
              onRemove: (i) =>
                  ref.read(serviceFormProvider.notifier).removeImage(i),
            ),
            const SizedBox(height: 28),

            // ── Title ─────────────────────────────────────────────────────
            _SectionLabel(label: 'Título'),
            const SizedBox(height: 8),
            _AppField(
              controller: _titleCtrl,
              hint: 'Ej: Plomería residencial',
              onChanged: ref.read(serviceFormProvider.notifier).setTitle,
              validator: (v) =>
                  (v?.trim().isEmpty ?? true) ? 'Ingresa un título' : null,
            ),
            const SizedBox(height: 20),

            // ── Category ─────────────────────────────────────────────────
            _SectionLabel(label: 'Categoría'),
            const SizedBox(height: 8),
            _CategoryDropdown(
              value: state.category.isEmpty ? null : state.category,
              onChanged: (v) {
                if (v != null) {
                  ref.read(serviceFormProvider.notifier).setCategory(v);
                }
              },
            ),
            const SizedBox(height: 20),

            // ── Description ─────────────────────────────────────────────
            _SectionLabel(label: 'Descripción'),
            const SizedBox(height: 8),
            _AppField(
              controller: _descCtrl,
              hint: 'Describe tu servicio, experiencia y lo que incluye...',
              maxLines: 5,
              onChanged: ref.read(serviceFormProvider.notifier).setDescription,
              validator: (v) => (v?.trim().isEmpty ?? true)
                  ? 'Ingresa una descripción'
                  : null,
            ),
            const SizedBox(height: 20),

            // ── Rate ─────────────────────────────────────────────────────
            _SectionLabel(label: 'Tarifa por hora (USD)'),
            const SizedBox(height: 8),
            _AppField(
              controller: _rateCtrl,
              hint: 'Ej: 25',
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[\d.]')),
              ],
              onChanged: ref.read(serviceFormProvider.notifier).setRate,
              validator: (v) {
                final n = double.tryParse(v ?? '');
                if (n == null || n <= 0) return 'Ingresa una tarifa válida';
                return null;
              },
            ),
            const SizedBox(height: 12),

            // Error message
            if (state.error != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(
                  '❌ ${state.error}',
                  style: const TextStyle(
                    color: Color(0xFFEF4444),
                    fontSize: 13,
                  ),
                ),
              ),

            // ── Save button ───────────────────────────────────────────────
            const SizedBox(height: 12),
            SizedBox(
              height: 56,
              child: ElevatedButton(
                onPressed: state.isSaving ? null : _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _primary,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: const Color(0xFFE2E8F0),
                  elevation: 8,
                  shadowColor: _primary.withValues(alpha: 0.35),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: state.isSaving
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2.5,
                        ),
                      )
                    : const Text(
                        'Guardar servicio',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

// ── Sub-widgets ───────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) => Text(
    label,
    style: const TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w800,
      color: Color(0xFF0F172A),
    ),
  );
}

class _AppField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final int maxLines;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final ValueChanged<String>? onChanged;
  final FormFieldValidator<String>? validator;

  const _AppField({
    required this.controller,
    required this.hint,
    this.maxLines = 1,
    this.keyboardType,
    this.inputFormatters,
    this.onChanged,
    this.validator,
  });

  @override
  Widget build(BuildContext context) => TextFormField(
    controller: controller,
    onChanged: onChanged,
    maxLines: maxLines,
    keyboardType: keyboardType,
    inputFormatters: inputFormatters,
    validator: validator,
    style: const TextStyle(fontSize: 15, color: Color(0xFF0F172A)),
    decoration: InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Color(0xFF94A3B8)),
      filled: true,
      fillColor: const Color(0xFFF8FAFC),
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFF7210FF), width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFFEF4444)),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFFEF4444), width: 2),
      ),
    ),
  );
}

class _CategoryDropdown extends StatelessWidget {
  final String? value;
  final ValueChanged<String?> onChanged;
  const _CategoryDropdown({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) => DropdownButtonFormField<String>(
    value: value,
    onChanged: onChanged,
    validator: (v) => (v == null || v.isEmpty) ? 'Elige una categoría' : null,
    decoration: InputDecoration(
      hintText: 'Selecciona una categoría',
      hintStyle: const TextStyle(color: Color(0xFF94A3B8)),
      filled: true,
      fillColor: const Color(0xFFF8FAFC),
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFF7210FF), width: 2),
      ),
    ),
    items: _kCategories
        .map((c) => DropdownMenuItem(value: c, child: Text(c)))
        .toList(),
  );
}

class _PhotoPicker extends StatelessWidget {
  final List<File> images;
  final VoidCallback onAddTap;
  final ValueChanged<int> onRemove;

  const _PhotoPicker({
    required this.images,
    required this.onAddTap,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 110,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          // Add button
          GestureDetector(
            onTap: onAddTap,
            child: Container(
              width: 90,
              height: 100,
              margin: const EdgeInsets.only(right: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFF3ECFF),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: const Color(0xFF7210FF).withValues(alpha: 0.4),
                  width: 1.5,
                ),
              ),
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.add_photo_alternate_outlined,
                    size: 28,
                    color: Color(0xFF7210FF),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Añadir',
                    style: TextStyle(
                      fontSize: 11,
                      color: Color(0xFF7210FF),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Selected photos
          ...images.asMap().entries.map(
            (e) => Stack(
              children: [
                Container(
                  width: 90,
                  height: 100,
                  margin: const EdgeInsets.only(right: 10),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.file(
                      e.value,
                      fit: BoxFit.cover,
                      width: 90,
                      height: 100,
                    ),
                  ),
                ),
                Positioned(
                  top: 4,
                  right: 14,
                  child: GestureDetector(
                    onTap: () => onRemove(e.key),
                    child: Container(
                      width: 22,
                      height: 22,
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.55),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.close,
                        size: 14,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
