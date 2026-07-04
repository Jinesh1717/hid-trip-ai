import '../../../core/network/api_client.dart';
import '../models/trip_plan.dart';

class TripService {
  final _client = ApiClient.client;

  Future<List<TripPlan>> getTrips() async {
    try {
      final response = await _client.get('/trips/');
      final data = response.data as List;
      return data.map((json) => TripPlan.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to load trips: $e');
    }
  }

  Future<TripPlan> createTrip({
    required String title,
    required String destination,
    double? budget,
    int? durationDays,
  }) async {
    try {
      final response = await _client.post(
        '/trips/',
        data: {
          'title': title,
          'destination': destination,
          'budget': budget,
          'duration_days': durationDays,
        },
      );
      return TripPlan.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to create trip: $e');
    }
  }

  Future<void> deleteTrip(int tripId) async {
    try {
      await _client.delete('/trips/$tripId');
    } catch (e) {
      throw Exception('Failed to delete trip: $e');
    }
  }
}
