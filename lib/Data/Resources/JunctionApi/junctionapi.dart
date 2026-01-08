import 'dart:developer';

import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:network_mapping_app/Data/Interface/JunctionData/junctiondata.dart';
import 'dart:convert';

import 'package:network_mapping_app/Data/Resources/TokenManage/tokenmanage.dart';

class JunctionController extends GetxController {
  var isLoading = false.obs;
  var juntionList = <JunctionAddingData>[].obs;

  @override
  void onInit() {
    fetchJunction();
    super.onInit();
  }

  Future<void> createJunction(JunctionAddingData data) async {
    final tokenManager = TokenManager();
    final token = await tokenManager.getToken();

    try {
      isLoading(true);
      final response = await http.post(
        Uri.parse("https://backend.fiberonix.in/api/junction/add/"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "$token",
        },
        body: jsonEncode(data.toJson()),
      );

      if (response.statusCode == 201) {
        log("createJunction Statuscode ${response.statusCode}");
      } else {
        Get.snackbar("Error", "Failed to create post");
      }
    } catch (e) {
      Get.snackbar("Exception", e.toString());
    } finally {
      isLoading(false);
    }
  }

  Future<void> fetchJunction() async {
    final tokenManager = TokenManager();
    final token = await tokenManager.getToken();
    log("token :$token");
    try {
      isLoading(true);
      final response = await http.get(
        Uri.parse("https://backend.fiberonix.in/api/junction/get/"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "$token",
        },
      );
      if (response.statusCode == 200) {
        log("fetchJunction Statuscode ${response.statusCode}");
        final List data = json.decode(response.body);
        juntionList.assignAll(
          data.map((e) => JunctionAddingData.fromJson(e)).toList(),
        );
      } else {
        Get.snackbar("Error", "Failed to get junction");
      }
    } catch (e) {
      Get.snackbar("Exception", e.toString());
    } finally {
      isLoading(false);
    }
  }

  Future<List<JunctionAddingData>> getJunction() async {
    final tokenManager = TokenManager();
    final token = await tokenManager.getToken();
    log("token :$token");
    try {
      isLoading(true);
      final response = await http.get(
        Uri.parse("https://backend.fiberonix.in/api/junction/get/"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "$token",
        },
      );
      final responseBody = jsonDecode(response.body);
      if (response.statusCode == 200) {
        log("$responseBody");
        log(" getJunction Statuscode ${response.statusCode}");
        final List data = json.decode(response.body);
        return data.map((e) => JunctionAddingData.fromJson(e)).toList();
      } else {
        log("$responseBody");
        Get.snackbar("Error", "Failed to get junction");
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

  Future<void> editJuncdetails(String name, String? postcode, int? id) async {
    final tokenManager = TokenManager();
    final token = await tokenManager.getToken();
    log("token :$token");
    try {
      isLoading(true);
      final response = await http.put(
        Uri.parse("https://backend.fiberonix.in/api/junction/get/$id/update/"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "$token",
        },
        body: jsonEncode({"name": name, "post_code": postcode}),
      );

      if (response.statusCode == 200) {
        log(
          "Statuscode editJuncdetails ${response.statusCode} ${response.body}",
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

  Future<void> deleteJunDetails(int? id) async {
    final tokenManager = TokenManager();
    final token = await tokenManager.getToken();
    log("token :$token");
    try {
      isLoading(true);
      final response = await http.delete(
        Uri.parse("https://backend.fiberonix.in/api/junction/get/$id/delete/"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "$token",
        },
      );

      if (response.statusCode == 204) {
        log("Statuscode deleteJuncdetails ${response.statusCode}");
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
