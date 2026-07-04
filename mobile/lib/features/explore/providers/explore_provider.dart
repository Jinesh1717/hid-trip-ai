import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/spot.dart';
import '../services/explore_service.dart';

final exploreServiceProvider = Provider((ref) => ExploreService());

class SearchQueryNotifier extends Notifier<String> {
  @override
  String build() => '';
  void updateQuery(String val) => state = val;
}
final exploreSearchQueryProvider = NotifierProvider<SearchQueryNotifier, String>(() => SearchQueryNotifier());

class CategoryFilterNotifier extends Notifier<String?> {
  @override
  String? build() => null;
  void updateCategory(String? val) => state = val;
}
final exploreCategoryFilterProvider = NotifierProvider<CategoryFilterNotifier, String?>(() => CategoryFilterNotifier());

class ParkingFilterNotifier extends Notifier<bool> {
  @override
  bool build() => false;
  void toggle(bool val) => state = val;
}
final exploreParkingFilterProvider = NotifierProvider<ParkingFilterNotifier, bool>(() => ParkingFilterNotifier());

final exploreSpotsProvider = FutureProvider<List<Spot>>((ref) async {
  final query = ref.watch(exploreSearchQueryProvider);
  final category = ref.watch(exploreCategoryFilterProvider);
  final parkingRequired = ref.watch(exploreParkingFilterProvider);
  final service = ref.watch(exploreServiceProvider);

  List<Spot> results;
  if (query.isNotEmpty) {
    results = await service.searchSpots(query);
  } else {
    results = await service.getSpots();
  }

  if (category != null) {
    results = results.where((spot) => spot.category == category).toList();
  }
  
  if (parkingRequired) {
    results = results.where((spot) => spot.parkingAvailable).toList();
  }

  return results;
});
