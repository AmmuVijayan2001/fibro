import 'dart:convert';
import 'dart:developer';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:network_mapping_app/Data/Interface/CustomerData/customerdata.dart';
import 'package:network_mapping_app/Data/Resources/TokenManage/tokenmanage.dart';

class CustomerController extends GetxController {
  var isLoading = false.obs;
  var customerList = <Customerdata>[].obs;

  Future<void> addCustomer(Customerdata data) async {
    final tokenmanager = TokenManager();
    final token = await tokenmanager.getToken();

    try {
      isLoading(true);
      final response = await http.post(
        Uri.parse("https://backend.fiberonix.in/api/customer/add/"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "$token",
        },
        body: jsonEncode(data.toJson()),
      );

      if (response.statusCode == 201) {
        log("addCustomer Statuscode ${response.statusCode}");
      } else {
        log(response.body);
        Get.snackbar("Error", "Failed to create Customer");
      }
    } catch (e) {
      Get.snackbar("Exception", e.toString());
      log("addCustomer Error  ${e.toString()}");
    } finally {
      isLoading(false);
    }
  }

  Future<List<Customerdata>> getCustomers(int officeId) async {
    final tokenmanager = TokenManager();
    final token = await tokenmanager.getToken();
    try {
      isLoading(true);
      final response = await http.get(
        Uri.parse("https://backend.fiberonix.in/api/customer/list/$officeId"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "$token",
        },
      );
      final responseBody = jsonDecode(response.body);
      if (response.statusCode == 200) {
        log("${response.body}");
        ("getCustomers Statuscode ${response.statusCode}",);
        final List<dynamic> jsonData = jsonDecode(response.body);
        customerList.value =
            jsonData
                .map((e) => Customerdata.fromJson(e as Map<String, dynamic>))
                .toList();
        return customerList;
      } else {
        log("$responseBody");
        Get.snackbar("Error", "Failed to fetch customers");
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

  Future<void> updateCustomer(Customerdata data) async {
    final tokenmanager = TokenManager();
    final token = await tokenmanager.getToken();
    try {
      isLoading(true);
      final response = await http.put(
        Uri.parse(
          "https://backend.fiberonix.in/api/customer/management/${data.customerID}/",
        ),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "$token",
        },
        body: jsonEncode(data.toJson()),
      );
      if (response.statusCode == 200) {
        log("updateCustomer Statuscode ${response.statusCode}");
      } else {
        Get.snackbar("Error", "Failed to update Customer");
      }
    } catch (e) {
      log("Update Customer Error  ${e.toString()}");
      Get.snackbar("Exception", e.toString());
    } finally {
      isLoading(false);
    }
  }

  Future<void> deleteCustomers(int? id) async {
    final tokenmanager = TokenManager();
    final token = await tokenmanager.getToken();
    try {
      isLoading(true);
      final response = await http.delete(
        Uri.parse("https://backend.fiberonix.in/api/customer/management/$id"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "$token",
        },
      );
      if (response.statusCode == 200) {
        log("deleteCustomers Statuscode ${response.statusCode}");
      } else {
        Get.snackbar("Error", "Failed to delete Customer");
      }
    } catch (e) {
      log("deleteCustomers Error  ${e.toString()}");
      Get.snackbar("Exception", e.toString());
    } finally {
      isLoading(false);
    }
  }
}
