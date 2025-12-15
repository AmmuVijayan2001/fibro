import 'dart:convert';
import 'dart:developer';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:network_mapping_app/Data/Interface/StaffData/staffdata.dart';
import 'package:network_mapping_app/Data/Resources/TokenManage/tokenmanage.dart';

class StaffController extends GetxController {
  var isLoading = false.obs;
  final RxList<StaffData> staffList = <StaffData>[].obs;

  @override
  void onInit() {
    getStaff();
    super.onInit();
  }

  Future<void> addStaff(StaffData data) async {
    final tokenManager = TokenManager();
    final token = await tokenManager.getToken();

    try {
      isLoading(true);
      final response = await http.post(
        Uri.parse(
          "https://backend.fiberonix.in/api/opticalfiber/company/staffs/",
        ),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "$token",
        },
        body: jsonEncode(data.toJson()),
      );

      if (response.statusCode == 201) {
        log(" add staff successfully with Statuscode ${response.statusCode}");
      } else {
        log(" add staff failed ${jsonDecode(response.body)}");
        Get.snackbar("Error", "Failed to creat e staff");
      }
    } catch (e) {
      Get.snackbar("Exception staff fetch", e.toString());
    } finally {
      isLoading(false);
    }
  }

  // Future<void> fetchStaff() async {
  //   final tokenManager = TokenManager();
  //   final token = await tokenManager.getToken();
  //   log("token :$token");
  //   try {
  //     isLoading(true);
  //     final response = await http.get(
  //       Uri.parse(
  //         "https://backend.fiberonix.in/api/opticalfiber/company/staffs/",
  //       ),
  //       headers: {
  //         "Content-Type": "application/json",
  //         "Authorization": "$token",
  //       },
  //     );

  //     final responseBody = jsonDecode(response.body);

  //     if (response.statusCode == 200) {
  //       log("fetchStaff StatusCode: ${response.statusCode}");
  //       log("fetchStaff Response Body: $responseBody");

  //       if (responseBody["data"] != null &&
  //           responseBody["data"]["staffs"] is List) {
  //         final List<dynamic> jsonData = responseBody["data"]["staffs"];

  //         staffList.assignAll(
  //           jsonData.map((e) => StaffData.fromJson(e)).toList(),
  //         );
  //       } else {
  //         log("Invalid format in response data");
  //         Get.snackbar("Error", "Invalid data format from server.");
  //       }
  //     } else {
  //       log("Failed with status ${response.statusCode}: $responseBody");
  //       Get.snackbar("Error", "Failed to get staff data.");
  //     }
  //   } catch (e) {
  //     log("Exception in fetchStaff: $e");
  //     Get.snackbar("Exception", e.toString());
  //   } finally {
  //     isLoading(false);
  //   }
  // }

  Future<List<StaffData>> getStaff() async {
    final tokenManager = TokenManager();
    final token = await tokenManager.getToken();
    log("token :$token");

    try {
      isLoading(true);
      final response = await http.get(
        Uri.parse(
          "https://backend.fiberonix.in/api/opticalfiber/company/staffs/",
        ),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "$token",
        },
      );

      final responseBody = jsonDecode(response.body);
      if (response.statusCode == 200) {
        log("getStaff StatusCode: $response.statusCode");
        log("getStaff Response Body: $responseBody");

        // Ensure data and staffs keys exist and are of expected types
        if (responseBody["data"] != null &&
            responseBody["data"]["staffs"] is List) {
          final List<dynamic> jsonData = responseBody["data"]["staffs"];

          staffList.value =
              jsonData
                  .map((e) => StaffData.fromJson(e as Map<String, dynamic>))
                  .toList();

          log("Parsed staff list: $staffList");
          return staffList;
        } else {
          log("Invalid format in response data");
          Get.snackbar("Error", "Invalid data format from server.");
          return [];
        }
      } else {
        log("Failed with status ${response.statusCode}: $responseBody");
        Get.snackbar("Error", "Failed to get staff data.");
        return [];
      }
    } catch (e) {
      log("Exception in getStaff: $e");
      Get.snackbar("Exception getStaff", e.toString());
      return [];
    } finally {
      isLoading(false);
    }
  }
}
