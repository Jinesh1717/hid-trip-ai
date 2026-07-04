import 'dart:io';
import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';
import '../models/spot.dart';

class ExploreService {
  final Dio _dio = ApiClient.client;

  Future<List<Spot>> searchSpots(String query) async {
    try {
      final response = await _dio.get(
        '/spots/search',
        queryParameters: {'q': query},
      );
      
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => Spot.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load spots');
      }
    } catch (e) {
      print('Error searching spots: $e');
      return [];
    }
  }

  Future<List<Spot>> getSpots() async {
    try {
      final response = await _dio.get('/spots/');
      
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => Spot.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load spots');
      }
    } catch (e) {
      print('Error getting spots: $e');
      return [];
    }
  }

  Future<String?> uploadImage(File image) async {
    try {
      String fileName = image.path.split('/').last;
      FormData formData = FormData.fromMap({
        "file": await MultipartFile.fromFile(image.path, filename: fileName),
      });

      final response = await _dio.post('/upload/image', data: formData);
      if (response.statusCode == 200) {
        return response.data['url'];
      }
    } catch (e) {
      print('Error uploading image: $e');
    }
    return null;
  }

  Future<Spot?> createSpot(Map<String, dynamic> spotData) async {
    try {
      final response = await _dio.post('/spots/', data: spotData);
      if (response.statusCode == 200) {
        return Spot.fromJson(response.data);
      }
    } catch (e) {
      print('Error creating spot: $e');
    }
    return null;
  }
}
