import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:network_mapping_app/Domine/Models/network_design_model.dart';
import 'package:network_mapping_app/Data/Resources/TokenManage/tokenmanage.dart';

class NetworkRepository {
  static final NetworkRepository _instance = NetworkRepository._internal();
  factory NetworkRepository() => _instance;
  NetworkRepository._internal();

  final String _baseUrl =
      "https://backend.fiberonix.in/api/network-device/designs/";
  final TokenManager _tokenManager = TokenManager();

  Future<Map<String, String>> _getHeaders() async {
    final token = await _tokenManager.getToken();
    return {
      "Content-Type": "application/json",
      if (token != null) "Authorization": "$token",
    };
  }

  Future<List<NetworkDesignModel>> getDesigns() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(Uri.parse(_baseUrl), headers: headers);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => NetworkDesignModel.fromJson(json)).toList();
      } else {
        throw Exception(
          "Failed to load designs: ${response.statusCode} - ${response.body}",
        );
      }
    } catch (e) {
      print("Error fetching designs: $e");

      throw Exception("Error fetching designs: $e");
    }
  }

  Future<void> saveDesign(NetworkDesignModel design) async {
    final headers = await _getHeaders();
    final body = json.encode(design.toJson());

    if (design.id == null) {
      // CREATE
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: headers,
        body: body,
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception("Failed to create design: ${response.body}");
      }
    } else {
      // UPDATE
      final url = "$_baseUrl${design.id}/";
      final response = await http.put(
        Uri.parse(url),
        headers: headers,
        body: body,
      );

      if (response.statusCode == 405) {
        final patchResponse = await http.patch(
          Uri.parse(url),
          headers: headers,
          body: body,
        );
        if (patchResponse.statusCode != 200) {
          throw Exception(
            "Failed to update design (PATCH): ${patchResponse.body}",
          );
        }
      } else if (response.statusCode != 200) {
        throw Exception("Failed to update design: ${response.body}");
      }
    }
  }

  Future<void> deleteDesign(String id) async {
    final headers = await _getHeaders();
    final url = "$_baseUrl$id/";

    final response = await http.delete(Uri.parse(url), headers: headers);

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception(
        "Failed to delete design: ${response.statusCode} - ${response.body}",
      );
    }
  }
}
