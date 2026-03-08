import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:empleame/models/service_model.dart';
import 'package:empleame/providers/providers.dart';
import 'package:empleame/providers/services_provider.dart';
import 'package:empleame/widgets/home/service_card.dart';

/// FutureProvider to fetch search results dynamically
final searchResultsProvider = FutureProvider.family<List<ServiceModel>, String>(
  (ref, query) async {
    final repo = ref.read(globalServiceRepositoryProvider);
    return repo.searchActiveServices(
      query,
      limit: 50,
    ); // Generous limit for dedicated screen
  },
);

class SearchResultsScreen extends ConsumerWidget {
  final String query;

  const SearchResultsScreen({super.key, required this.query});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncResults = ref.watch(searchResultsProvider(query));

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text('${tr("home.searchHint")}: "$query"'),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
      ),
      body: asyncResults.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: Color(0xFF7210FF)),
        ),
        error: (err, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 48),
              const SizedBox(height: 16),
              Text(tr('common.error')),
            ],
          ),
        ),
        data: (services) {
          if (services.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.search_off,
                    size: 64,
                    color: Color(0xFF94A3B8),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No se encontraron resultados para "$query"',
                    style: const TextStyle(
                      fontSize: 16,
                      color: Color(0xFF64748B),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 40),
            itemCount: services.length,
            itemBuilder: (context, index) {
              final service = services[index];
              final user = ref.watch(currentUserStreamProvider).valueOrNull;
              final isBookmarked =
                  user?.savedServices.contains(service.id) ?? false;

              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: ServiceCard(
                  title: service.title,
                  category: service.category,
                  provider: 'Worker-${service.workerId.substring(0, 4)}',
                  price: service.rate,
                  rating: 5.0,
                  reviews: 0,
                  imageUrl: service.imageUrls.isNotEmpty
                      ? service.imageUrls.first
                      : '',
                  isBookmarked: isBookmarked,
                  onTap: () => context.push('/service-detail/${service.id}'),
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
      ),
    );
  }
}
