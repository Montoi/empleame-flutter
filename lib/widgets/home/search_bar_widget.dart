import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:empleame/providers/services_provider.dart';

class SearchBarWidget extends ConsumerStatefulWidget {
  final VoidCallback? onFilterTap;
  final String hintText;

  const SearchBarWidget({
    super.key,
    this.onFilterTap,
    this.hintText = 'Buscar',
  });

  @override
  ConsumerState<SearchBarWidget> createState() => _SearchBarWidgetState();
}

class _SearchBarWidgetState extends ConsumerState<SearchBarWidget> {
  final LayerLink _layerLink = LayerLink();
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  OverlayEntry? _overlayEntry;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _removeOverlay();
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  Future<void> _performSearch() async {
    final query = _controller.text.trim();
    if (query.isEmpty) {
      _removeOverlay();
      return;
    }

    setState(() => _isLoading = true);

    // Create/update overlay to show loading state if needed
    _showOverlay(query);

    try {
      final repo = ref.read(globalServiceRepositoryProvider);
      final results = await repo.searchActiveServices(query, limit: 5);

      if (mounted && _overlayEntry != null) {
        _showOverlay(query, results: results);
      }
    } catch (e) {
      if (mounted) {
        _removeOverlay();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Error al buscar. Revisa la consola si falta un índice de Firestore.',
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
        // Force the active overlay (if any) to redraw without the loader
        _overlayEntry?.markNeedsBuild();
      }
    }
  }

  void _showOverlay(String query, {List? results}) {
    _removeOverlay();

    final renderBox = context.findRenderObject() as RenderBox;
    final size = renderBox.size;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        width: size.width - 48, // Padding (24 * 2) from horizontal symmetric
        child: CompositedTransformFollower(
          link: _layerLink,
          showWhenUnlinked: false,
          offset: Offset(
            24,
            size.height - 4,
          ), // 24 is the start of padding, below TextField
          child: Material(
            elevation: 8,
            color: Colors.transparent,
            child: TapRegion(
              groupId: 'search_bar_overlay',
              child: Container(
                constraints: const BoxConstraints(maxHeight: 280),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1F222A) : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Theme.of(
                      context,
                    ).colorScheme.primary.withOpacity(0.2),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Material(
                    type: MaterialType.transparency,
                    child: _buildOverlayContent(context, query, results),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  Widget _buildOverlayContent(
    BuildContext parentContext,
    String query,
    List? results,
  ) {
    if (results == null) {
      if (_isLoading) {
        return const SizedBox(
          height: 100,
          child: Center(
            child: CircularProgressIndicator(color: Color(0xFF7210FF)),
          ),
        );
      } else {
        return const SizedBox.shrink();
      }
    }

    if (results.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.search_off, size: 40, color: Color(0xFF94A3B8)),
            const SizedBox(height: 12),
            Text(
              'No se encontraron servicios para "$query"',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14, color: Color(0xFF64748B)),
            ),
          ],
        ),
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Flexible(
          child: ListView.separated(
            padding: const EdgeInsets.all(12),
            shrinkWrap: true,
            physics: const ClampingScrollPhysics(),
            itemCount: results.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final service = results[index];
              return InkWell(
                onTap: () {
                  _removeOverlay();
                  _focusNode.unfocus();
                  parentContext.push('/service-detail/${service.id}');
                },
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: service.imageUrls.isNotEmpty
                            ? Image.network(
                                service.imageUrls.first,
                                width: 48,
                                height: 48,
                                fit: BoxFit.cover,
                              )
                            : Container(
                                width: 48,
                                height: 48,
                                color: const Color(0xFFF3ECFF),
                                child: const Icon(
                                  Icons.work_outline,
                                  color: Color(0xFF7210FF),
                                ),
                              ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              service.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              service.category,
                              style: const TextStyle(
                                color: Color(0xFF64748B),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        '\$${service.rate.toStringAsFixed(0)}',
                        style: const TextStyle(
                          color: Color(0xFF7210FF),
                          fontWeight: FontWeight.w800,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        Container(
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(color: Colors.grey.withOpacity(0.2)),
            ),
          ),
          child: TextButton(
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.zero,
              ),
            ),
            onPressed: () {
              _removeOverlay();
              _focusNode.unfocus();
              parentContext.push(
                '/search-results?q=${Uri.encodeComponent(query)}',
              );
            },
            child: Text(
              'Ver más resultados para "$query"',
              style: const TextStyle(
                color: Color(0xFF7210FF),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return TapRegion(
      groupId: 'search_bar_overlay',
      onTapOutside: (_) {
        _focusNode.unfocus();
        _removeOverlay();
      },
      child: CompositedTransformTarget(
        link: _layerLink,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          child: TextField(
            controller: _controller,
            focusNode: _focusNode,
            onSubmitted: (_) {
              _performSearch();
            },
            textInputAction: TextInputAction.search,
            decoration: InputDecoration(
              hintText: widget.hintText,
              suffixIcon: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.search, color: Color(0xFF7210FF)),
                    onPressed: () {
                      _performSearch();
                    },
                  ),
                ],
              ),
              filled: true,
              fillColor: isDark ? const Color(0xFF1F222A) : Colors.grey[50],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                  color: Theme.of(context).colorScheme.primary,
                  width: 2,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
