import 'dart:convert';
import 'dart:developer';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:network_mapping_app/Data/Interface/DeviceportData/deviceportdata.dart';
import 'package:network_mapping_app/Data/Resources/TokenManage/tokenmanage.dart';

class DeviceportController extends GetxController {
  var isLoading = false.obs;
  var deviceportList = <Deviceportdata>[].obs;

  Future<void> createDevicePort(Deviceportdata data) async {
    final tokenManager = TokenManager();
    final token = await tokenManager.getToken();

    try {
      isLoading(true);
      final response = await http.post(
        Uri.parse(
          "https://backend.fiberonix.in/api/network-device/deviceport/${data.deviceId}/",
        ),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "$token",
        },
        body: jsonEncode(data.toJson()),
      );
      if (response.statusCode == 201) {
        log("createDevicePort Statuscode ${response.statusCode}");
      } else {
        Get.snackbar("Error", "Failed to create post");
      }
    } catch (e) {
      log("Exception: $e");
      Get.snackbar("  Exception", e.toString());
    } finally {
      isLoading(false);
    }
  }

  Future<List<Deviceportdata>> getDevicePort(int deviceId) async {
    final tokenManager = TokenManager();
    final token = await tokenManager.getToken();
    log("token :$token");
    try {
      isLoading(true);
      final response = await http.get(
        Uri.parse(
          "https://backend.fiberonix.in/api/network-device/deviceport/$deviceId/",
        ),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "$token",
        },
      );
      final responseBody = jsonDecode(response.body);
      if (response.statusCode == 200) {
        log("$responseBody");
        log("getDevicePort Statuscode ${response.statusCode}");
        final List<dynamic> jsonData = jsonDecode(response.body);
        deviceportList.value =
            jsonData.map((e) => Deviceportdata.fromJson(e)).toList();
        return deviceportList;
      } else {
        log("$responseBody");
        Get.snackbar("Error", "Failed to fetch device ");
        return [];
      }
    } catch (e) {
      log("Exception: $e");
      Get.snackbar("Exception", e.toString());
      return [];
    } finally {
      isLoading(false);
    }
  }

  Future<void> editDevicePort(Deviceportdata data) async {
    final tokenManager = TokenManager();
    final token = await tokenManager.getToken();
    log("token :$token");
    try {
      isLoading(true);
      final response = await http.put(
        Uri.parse(
          "https://backend.fiberonix.in/api/network-device/deviceport/${data.id}/",
        ),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "$token",
        },
        body: jsonEncode(data.toJson()),
      );
      if (response.statusCode == 200) {
        log("editDevicePort Statuscode ${response.statusCode}");
      } else {
        Get.snackbar("Error", "Failed to edit post");
      }
    } catch (e) {
      log("editDevicePort error:$e");
      Get.snackbar("Exception", e.toString());
    } finally {
      isLoading(false);
    }
  }

  Future<void> deleteDevicePort(int? id) async {
    final tokenManager = TokenManager();
    final token = await tokenManager.getToken();
    log("token :$token");
    try {
      isLoading(true);
      final response = await http.delete(
        Uri.parse(
          "https://backend.fiberonix.in/api/network-device/deviceport/$id/",
        ),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "$token",
        },
      );
      if (response.statusCode == 204) {
        log("deleteDevicePort Statuscode ${response.statusCode}");
      } else {
        log("Statuscode $response");
        Get.snackbar("Error", "Failed to delete post");
      }
    } catch (e) {
      log("deleteDevicePort error:$e");
      Get.snackbar("Exception", e.toString());
    } finally {
      isLoading(false);
    }
  }
}
