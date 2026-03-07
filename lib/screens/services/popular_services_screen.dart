import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:empleame/config/app_categories.dart';
import 'package:empleame/providers/providers.dart';
import 'package:empleame/providers/services_provider.dart';
import 'package:empleame/widgets/home/service_card.dart';

class PopularServicesScreen extends ConsumerStatefulWidget {
  /// Technical category ID (e.g. 'carpentry'). Null means "show all".
  final String? category;

  const PopularServicesScreen({super.key, this.category});

  @override
  ConsumerState<PopularServicesScreen> createState() =>
      _PopularServicesScreenState();
}

class _PopularServicesScreenState extends ConsumerState<PopularServicesScreen> {
  late String _selectedId;

  @override
  void initState() {
    super.initState();
    // Default to the incoming category id, or 'all' if none provided.
    _selectedId = widget.category ?? 'all';
  }

  @override
  Widget build(BuildContext context) {
    final asyncServices = ref.watch(popularServicesProvider);

    // Resolve a localized header title from the technical id
    final headerTitle = _selectedId == 'all'
        ? tr('filter.all')
        : tr(AppCategories.byId(_selectedId)?.localizationKey ?? _selectedId);

    return Scaffold(
      appBar: AppBar(
        title: Text(headerTitle),
        actions: [
          IconButton(icon: const Icon(Icons.more_horiz), onPressed: () {}),
        ],
      ),
      body: Column(
        children: [
          // Category Filter Chips — built with ListView.builder (skill: lazy lists)
          SizedBox(
            height: 50,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              itemCount: AppCategories.filterIds.length,
              itemBuilder: (context, index) {
                final id = AppCategories.filterIds[index];
                final isSelected = id == _selectedId;
                final label = id == 'all'
                    ? tr('filter.all')
                    : tr(AppCategories.byId(id)?.localizationKey ?? id);

                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(label),
                    selected: isSelected,
                    onSelected: (_) => setState(() => _selectedId = id),
                    selectedColor: Theme.of(context).colorScheme.primary,
                    labelStyle: TextStyle(
                      color: isSelected
                          ? Colors.white
                          : Theme.of(context).textTheme.bodyMedium?.color,
                      fontWeight: isSelected
                          ? FontWeight.w700
                          : FontWeight.w500,
                    ),
                  ),
                );
              },
            ),
          ),

          // Services List
          Expanded(
            child: asyncServices.when(
              data: (activeServices) {
                // Filter by technical id — locale-independent
                final filteredServices = _selectedId == 'all'
                    ? activeServices
                    : activeServices
                          .where((s) => s.category == _selectedId)
                          .toList();

                if (filteredServices.isEmpty) {
                  return Center(
                    child: Text(
                      'No services found',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 40),
                  itemCount: filteredServices.length,
                  itemBuilder: (context, index) {
                    final service = filteredServices[index];
                    final user = ref
                        .watch(currentUserStreamProvider)
                        .valueOrNull;
                    final isBookmarked =
                        user?.savedServices.contains(service.id) ?? false;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: ServiceCard(
                        title: service.title,
                        category: service.category,
                        provider: 'Worker Name', // TODO: user table join
                        price: service.rate,
                        rating: 5.0, // TODO: store rating
                        reviews: 0,
                        imageUrl: service.imageUrls.isNotEmpty
                            ? service.imageUrls.first
                            : '',
                        isBookmarked: isBookmarked,
                        onTap: () =>
                            context.push('/service-detail/${service.id}'),
                        onBookmark: () {
                          if (user != null) {
                            ref
                                .read(userRepositoryProvider)
                                .toggleSavedService(
                                  uid: user.uid,
                                  serviceId: service.id,
                                  save: !isBookmarked,
                                );
                          }
                        },
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      color: Colors.red,
                      size: 48,
                    ),
                    const SizedBox(height: 16),
                    const Text('Failed to load services'),
                    TextButton(
                      onPressed: () => ref.invalidate(popularServicesProvider),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
