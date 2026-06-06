import 'dart:convert';
import 'package:minimobile/services/api_service.dart';
import 'package:minimobile/models/api_response.dart';
import 'package:minimobile/models/user_model.dart';

class AuthService {
  final ApiService _api = ApiService();

  Future<ApiResponse<Map<String, dynamic>>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _api.post('login', {
        'email': email,
        'password': password,
      });

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return ApiResponse(
          status: 'success',
          message: data['message'],
          data: {
            'access_token': data['data']['access_token'],
            'user': User.fromJson(data['data']['user']),
          },
        );
      } else {
        return ApiResponse(
          status: 'error',
          message: data['message'] ?? 'Login failed',
        );
      }
    } catch (e) {
      return ApiResponse(
        status: 'error',
        message: 'Network error: ${e.toString()}',
      );
    }
  }

  Future<ApiResponse<void>> logout() async {
    try {
      final response = await _api.post('logout', {});
      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return ApiResponse(
          status: 'success',
          message: data['message'],
        );
      } else {
        return ApiResponse(
          status: 'error',
          message: data['message'] ?? 'Logout failed',
        );
      }
    } catch (e) {
      return ApiResponse(
        status: 'error',
        message: 'Network error: ${e.toString()}',
      );
    }
  }
}