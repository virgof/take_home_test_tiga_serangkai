import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:minimobile/utils/constants.dart';
import 'package:minimobile/services/storage_service.dart';

class ApiService {
  final StorageService _storage = StorageService();

  Future<Map<String, String>> _getHeaders() async {
    final token = await _storage.getToken();
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<http.Response> get(String endpoint) async {
    final headers = await _getHeaders();
    final url = Uri.parse('${Constants.baseUrl}/$endpoint');
    return await http.get(url, headers: headers);
  }

  Future<http.Response> post(String endpoint, dynamic data) async {
    final headers = await _getHeaders();
    final url = Uri.parse('${Constants.baseUrl}/$endpoint');
    return await http.post(
      url,
      headers: headers,
      body: jsonEncode(data),
    );
  }

  Future<http.Response> put(String endpoint, dynamic data) async {
    final headers = await _getHeaders();
    final url = Uri.parse('${Constants.baseUrl}/$endpoint');
    return await http.put(
      url,
      headers: headers,
      body: jsonEncode(data),
    );
  }

  Future<http.Response> delete(String endpoint) async {
    final headers = await _getHeaders();
    final url = Uri.parse('${Constants.baseUrl}/$endpoint');
    return await http.delete(url, headers: headers);
  }
}