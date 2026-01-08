import 'dart:convert';
import 'dart:developer';

import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:network_mapping_app/Data/Interface/RouteData/routedata.dart';
import 'package:network_mapping_app/Data/Resources/TokenManage/tokenmanage.dart';

class RouteController extends GetxController {
  var isLoading = false.obs;
  var routeList = <RouteData>[].obs;

  Future<Map<String, dynamic>> addRoute(RouteData data) async {
    final tokenManager = TokenManager();
    final token = await tokenManager.getToken();
    try {
      isLoading(true);
      final response = await http.post(
        Uri.parse("https://backend.fiberonix.in/api/route/add/"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "$token",
        },
        body: jsonEncode(data.toJson()),
      );
      log("Add Route body ${response.body}");
      if (response.statusCode == 201) {
        log("Add Route Statuscode ${response.statusCode}");
        return {"success": true};
      } else {
        final decodedBody = jsonDecode(response.body);
        final messageData = decodedBody['message'];
        final errorMessage =
            messageData is List
                ? messageData.join(' ')
                : messageData.toString();
        return {"success": false, "message": errorMessage};
      }
    } catch (e) {
      Get.snackbar("Exception", e.toString());
      log("Add Route Error  ${e.toString()}");
      return {"success": false, "message": "An unexpected error occurred."};
    } finally {
      isLoading(false);
    }
  }

  Future<List<RouteData>> getRoute(int officeId) async {
    final token = await TokenManager().getToken();
    isLoading(true);

    try {
      final response = await http.get(
        Uri.parse('https://backend.fiberonix.in/api/route/list/$officeId/'),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "$token",
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonData =
            jsonDecode(response.body) as List<dynamic>;

        routeList.value =
            jsonData
                .map((e) => RouteData.fromJson(e as Map<String, dynamic>))
                .toList();
        //log("routelist :${jsonData.first["total_km"]}");
        return routeList;
      }
      log('get route ${jsonDecode(response.body)}');
      //  Get.snackbar('Error', '${jsonDecode(response.body)}');
      return [];
    } catch (e, st) {
      log('Exception while parsing route list: $e\n$st');
      Get.snackbar('Exception', e.toString());
      return [];
    } finally {
      isLoading(false);
    }
  }

  Future<void> editRoute(RouteData data) async {
    final tokenManager = TokenManager();
    final token = await tokenManager.getToken();
    log("token :$token");
    try {
      isLoading(true);
      final response = await http.put(
        Uri.parse(
          "https://backend.fiberonix.in/api/route/management/${data.id}/update/",
        ),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "$token",
        },
        body: jsonEncode(data.toJson()),
      );
      if (response.statusCode == 200) {
        log("edit Route Statuscode ${response.statusCode}");
      } else {
        Get.snackbar("Error", "Failed to edit post");
      }
    } catch (e) {
      log("edit Route error:$e");
      Get.snackbar("Exception", e.toString());
    } finally {
      isLoading(false);
    }
  }

  Future<void> deleteRoute(int? id) async {
    final tokenManager = TokenManager();
    final token = await tokenManager.getToken();
    log("token :$token");
    try {
      isLoading(true);
      final response = await http.delete(
        Uri.parse(
          "https://backend.fiberonix.in/api/route/management/$id/delete/",
        ),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "$token",
        },
      );
      if (response.statusCode == 204) {
        log("delete Route Statuscode ${response.statusCode}");
      } else {
        log("Statuscode $response");
        Get.snackbar("Error", "Failed to delete post");
      }
    } catch (e) {
      log("delete Route error:$e");
      Get.snackbar("Exception", e.toString());
    } finally {
      isLoading(false);
    }
  }
}
