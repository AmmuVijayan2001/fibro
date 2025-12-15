import 'dart:developer';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:network_mapping_app/Data/Interface/NetworkDeviceData/networkdevicedata.dart';
import 'dart:convert';
import 'package:network_mapping_app/Data/Resources/TokenManage/tokenmanage.dart';

class NetworkDeviceController extends GetxController {
  var isLoading = false.obs;
  var networkDevicesList = <NetworkDeviceData>[].obs;

  Future<void> addNetworkDevices(NetworkDeviceData data) async {
    final tokenManager = TokenManager();
    final token = await tokenManager.getToken();

    try {
      isLoading(true);
      final response = await http.post(
        Uri.parse(
          "https://backend.fiberonix.in/api/network-device/networkdevice/",
        ),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "$token",
        },
        body: jsonEncode(data.toJson()),
      );

      if (response.statusCode == 201) {
        log("NetworkDeviceController Statuscode ${response.statusCode}");
      } else {
        Get.snackbar("Error", "Failed to create post");
      }
    } catch (e) {
      Get.snackbar("Exception", e.toString());
    } finally {
      isLoading(false);
    }
  }

  Future<void> fetchNetworkDevices() async {
    final tokenManager = TokenManager();
    final token = await tokenManager.getToken();
    log("token :$token");
    try {
      isLoading(true);
      final response = await http.get(
        Uri.parse(
          "https://backend.fiberonix.in/api/network-device/networkdevice/",
        ),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "$token",
        },
      );
      if (response.statusCode == 200) {
        log("NetworkDeviceController Statuscode ${response.statusCode}");
        final List data = json.decode(response.body);
        networkDevicesList.assignAll(
          data.map((e) => NetworkDeviceData.fromJson(e)).toList(),
        );
      } else {
        Get.snackbar("Error", "Failed to get office");
      }
    } catch (e) {
      Get.snackbar("Exception", e.toString());
    } finally {
      isLoading(false);
    }
  }

  Future<List<NetworkDeviceData>> getNetworkDevices() async {
    final tokenManager = TokenManager();
    final token = await tokenManager.getToken();
    log("token :$token");
    try {
      isLoading(true);
      final response = await http
          .get(
            Uri.parse(
              "https://backend.fiberonix.in/api/network-device/networkdevice/",
            ),
            headers: {
              "Content-Type": "application/json",
              "Authorization": "$token",
            },
          )
          .timeout(Duration(seconds: 10));
      final responseBody = jsonDecode(response.body);
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseBody = jsonDecode(response.body);
        final List<dynamic> results = responseBody["results"];

        log("Results: $results");
        return results.map((e) => NetworkDeviceData.fromJson(e)).toList();
      } else {
        log("$responseBody");
        Get.snackbar("Error", "Failed to get office");
        return [];
      }
    } catch (e) {
      log("error:$e");
      Get.snackbar("Exception", e.toString());
      return [];
    } finally {
      isLoading(false);
    }
  }

  Future<void> editNetworkDevices(NetworkDeviceData data) async {
    final tokenManager = TokenManager();
    final token = await tokenManager.getToken();
    log("token :$token");
    try {
      isLoading(true);
      final response = await http.put(
        Uri.parse(
          "https://backend.fiberonix.in/api/network-device/networkdevice/${data.id}/update/",
        ),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "$token",
        },
        body: jsonEncode(data.toJson()),
      );

      if (response.statusCode == 200) {
        log(
          "Statuscode EditNetworkDevice ${response.statusCode} ${response.body}",
        );
      } else {
        log("Statuscode $response");
        Get.snackbar("Error", "Failed to editoffice");
      }
    } catch (e) {
      log("editJuncdetails error:$e");
      Get.snackbar("Exception", e.toString());
    } finally {
      isLoading(false);
    }
  }

  Future<void> deleteNetworkDevice(int? id) async {
    final tokenManager = TokenManager();
    final token = await tokenManager.getToken();
    log("token :$token");
    try {
      isLoading(true);
      final response = await http.delete(
        Uri.parse(
          "https://backend.fiberonix.in/api/network-device/networkdevice/$id/delete/",
        ),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "$token",
        },
      );

      if (response.statusCode == 204) {
        log("Statuscode deleteNetworkDevice ${response.statusCode}");
      } else {
        log("delete ${response.body}");
      }
    } catch (e) {
      log("error:$e");
      Get.snackbar("Exception", e.toString());
    } finally {
      isLoading(false);
    }
  }
}
