import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/trip_plan.dart';
import '../services/trip_service.dart';

final tripServiceProvider = Provider((ref) => TripService());

final tripsProvider = FutureProvider<List<TripPlan>>((ref) async {
  final service = ref.watch(tripServiceProvider);
  return service.getTrips();
});
