import 'dart:developer';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:network_mapping_app/Data/Interface/OfficeAddData/officeadddata.dart'
    show OfficeAddingData;
import 'package:network_mapping_app/Data/Resources/TokenManage/tokenmanage.dart';

class OfficeAController extends GetxController {
  var isLoading = false.obs;
  var officeList = <OfficeAddingData>[].obs;
  var filteredOfficeList = <OfficeAddingData>[].obs;

  @override
  void onInit() {
    fetchOffices();
    super.onInit();
  }

  Future<void> createPost(OfficeAddingData data) async {
    final tokenManager = TokenManager();
    final token = await tokenManager.getToken();

    try {
      isLoading(true);
      final response = await http.post(
        Uri.parse("https://backend.fiberonix.in/api/office/add/"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "$token",
        },
        body: jsonEncode(data.toJson()),
      );

      if (response.statusCode == 201) {
        log("createPost Statuscode ${response.statusCode}");
      } else {
        Get.snackbar("Error", "Failed to create post");
      }
    } catch (e) {
      Get.snackbar("Exception", e.toString());
    } finally {
      isLoading(false);
    }
  }

  Future<void> fetchOffices() async {
    final tokenManager = TokenManager();
    final token = await tokenManager.getToken();
    log("token :$token");
    try {
      isLoading(true);
      final response = await http.get(
        Uri.parse("https://backend.fiberonix.in/api/office/add/"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "$token",
        },
      );
      if (response.statusCode == 200) {
        final List data = json.decode(response.body);
        final offices = data.map((e) => OfficeAddingData.fromJson(e)).toList();
        officeList.assignAll(offices);
        filteredOfficeList.assignAll(officeList);
      } else {
        Get.snackbar("Error", "Failed to get office");
      }
    } catch (e) {
      Get.snackbar("Exception", e.toString());
    } finally {
      isLoading(false);
    }
  }

  Future<List<OfficeAddingData>> getOffice() async {
    final tokenManager = TokenManager();
    final token = await tokenManager.getToken();
    log("token :$token");
    try {
      isLoading(true);
      final response = await http.get(
        Uri.parse("https://backend.fiberonix.in/api/office/add/"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "$token",
        },
      );
      final responseBody = jsonDecode(response.body);
      if (response.statusCode == 200) {
        log("$responseBody");
        log(" getOffice Statuscode ${response.statusCode}");
        final List data = json.decode(response.body);
        return data.map((e) => OfficeAddingData.fromJson(e)).toList();
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

  Future<void> editOfficedetails(String name, String? address, int? id) async {
    final tokenManager = TokenManager();
    final token = await tokenManager.getToken();
    log("token :$token");
    try {
      isLoading(true);
      final response = await http.put(
        Uri.parse("https://backend.fiberonix.in/api/office/management/$id/"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "$token",
        },
        body: jsonEncode({"name": name, "address": address}),
      );

      if (response.statusCode == 200) {
        log(
          "Statuscode editOfficedetails ${response.statusCode} ${response.body}",
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

  Future<void> deleteOfficeDetails(int? id) async {
    final tokenManager = TokenManager();
    final token = await tokenManager.getToken();
    log("token :$token");
    try {
      isLoading(true);
      final response = await http.delete(
        Uri.parse("https://backend.fiberonix.in/api/office/management/$id/"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "$token",
        },
      );

      if (response.statusCode == 204) {
        log("Statuscode deleteOfficeDetails ${response.statusCode}");
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

  void filterOffices(String query) {
    if (query.isEmpty) {
      filteredOfficeList.assignAll(officeList);
    } else {
      final filtered =
          officeList
              .where(
                (office) =>
                    office.name != null &&
                    office.name!.toLowerCase().contains(query.toLowerCase()),
              )
              .toList();
      filtered.sort(
        (a, b) => a.name!.toLowerCase().compareTo(b.name!.toLowerCase()),
      );
      filteredOfficeList.assignAll(filtered);
    }
  }
}
