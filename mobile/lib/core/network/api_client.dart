import 'dart:io';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class ApiClient {
  static final Dio _dio = Dio(
    BaseOptions(
      // Use 10.0.2.2 for Android emulator to access localhost, or 127.0.0.1 for iOS
      baseUrl: _getBaseUrl(),
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {
        'Content-Type': 'application/json',
      },
    ),
  )..interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final user = FirebaseAuth.instance.currentUser;
          if (user != null) {
            final token = await user.getIdToken();
            if (token != null) {
              options.headers['Authorization'] = 'Bearer $token';
            }
          }
          return handler.next(options);
        },
      ),
    );

  static Dio get client => _dio;

  static String _getBaseUrl() {
    try {
      if (kIsWeb) {
        return 'http://localhost:8000/api/v1';
      }
      if (Platform.isAndroid) {
        return 'http://10.0.2.2:8000/api/v1';
      } else {
        return 'http://127.0.0.1:8000/api/v1';
      }
    } catch (e) {
      // Fallback
      return 'http://127.0.0.1:8000/api/v1';
    }
  }
}
