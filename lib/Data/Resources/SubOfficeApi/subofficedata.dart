import 'dart:convert';
import 'dart:developer';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:network_mapping_app/Data/Interface/SubBranchData/subbranchdata.dart';
import 'package:network_mapping_app/Data/Resources/TokenManage/tokenmanage.dart';

class SubOfficeController extends GetxController {
  var isLoading = false.obs;
  var officeList = <SucbOfficeAddingData>[].obs;

  @override
  void onInit() {
    fetchSubOffices();
    super.onInit();
  }

  Future<void> createSubOffice(SucbOfficeAddingData data) async {
    final tokenManager = TokenManager();
    final token = await tokenManager.getToken();

    try {
      isLoading(true);
      final response = await http.post(
        Uri.parse("https://backend.fiberonix.in/api/office/branch/add/"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "$token",
        },
        body: jsonEncode(data.toJson()),
      );

      if (response.statusCode == 201) {
        log(" createSubOffice Statuscode ${response.statusCode}");
      } else {
        Get.snackbar("Error", "Failed to  createSubOffice");
      }
    } catch (e) {
      Get.snackbar("Exception", e.toString());
    } finally {
      isLoading(false);
    }
  }

  Future<void> fetchSubOffices() async {
    final tokenManager = TokenManager();
    final token = await tokenManager.getToken();
    log("token :$token");
    try {
      isLoading(true);
      final response = await http.get(
        Uri.parse("https://backend.fiberonix.in/api/office/branch/add/"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "$token",
        },
      );
      if (response.statusCode == 200) {
        log(" fetchSubOffices Statuscode ${response.statusCode}");
        final List data = json.decode(response.body);
        officeList.assignAll(
          data.map((e) => SucbOfficeAddingData.fromJson(e)).toList(),
        );
      } else {
        log(
          " fetchSubOffices Statuscode ${json.decode(response.body)} Statuscode ${response.statusCode}",
        );
        //Get.snackbar("Error", "Failed to get Suboffice");
      }
    } catch (e) {
      Get.snackbar("Exception", e.toString());
    } finally {
      isLoading(false);
    }
  }

  Future<List<SucbOfficeAddingData>> getSubOffice() async {
    final tokenManager = TokenManager();
    final token = await tokenManager.getToken();
    log("token :$token");
    try {
      isLoading(true);
      final response = await http.get(
        Uri.parse("https://backend.fiberonix.in/api/office/branch/add/"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "$token",
        },
      );
      final responseBody = jsonDecode(response.body);
      if (response.statusCode == 200) {
        log("$responseBody");
        log(" SucbOfficeAddingData Statuscode ${response.statusCode}");
        final List data = json.decode(response.body);
        return data.map((e) => SucbOfficeAddingData.fromJson(e)).toList();
      } else {
        log("get sub office  $responseBody");
        //  Get.snackbar("Error", "Failed to get Suboffice");
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

  Future<void> editSubOfficedetails(
    String name,
    String? address,
    int? id,
  ) async {
    final tokenManager = TokenManager();
    final token = await tokenManager.getToken();
    log("token :$token");
    try {
      isLoading(true);
      final response = await http.put(
        Uri.parse(
          "https://backend.fiberonix.in/api/office/branch/management/$id/",
        ),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "$token",
        },
        body: jsonEncode({"name": name, "address": address}),
      );

      if (response.statusCode == 200) {
        log(
          "Statuscode editSubOfficedetails ${response.statusCode} ${response.body}",
        );
      } else {
        log("Statuscode $response");
        Get.snackbar("Error", "Failed to editoffice");
      }
    } catch (e) {
      log("editOfficeDetails error:$e");
      Get.snackbar("Exception", e.toString());
    } finally {
      isLoading(false);
    }
  }

  Future<void> deleteSubOfficeDetails(int? id) async {
    final tokenManager = TokenManager();
    final token = await tokenManager.getToken();
    log("token :$token");
    try {
      isLoading(true);
      final response = await http.delete(
        Uri.parse(
          "https://backend.fiberonix.in/api/office/branch/management/$id/",
        ),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "$token",
        },
      );

      if (response.statusCode == 204) {
        log("Statuscode deleteSubOfficeDetails ${response.statusCode}");
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
