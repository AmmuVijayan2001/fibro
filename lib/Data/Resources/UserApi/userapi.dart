import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:network_mapping_app/Data/Interface/UserData/userdata.dart';
import 'package:network_mapping_app/Data/Resources/TokenManage/tokenmanage.dart';

class UserDataApi extends GetxController {
  var isLoading = false.obs;
  var userData = Rxn<Userdata>(); // Use Rxn to allow null values initially

  Future<void> getUserData() async {
    final tokenManager = TokenManager();
    final token = await tokenManager.getToken();
    log("token : $token");

    try {
      isLoading(true);
      final response = await http.get(
        Uri.parse(
          "https://backend.fiberonix.in/api/opticalfiber/update/user/profile/",
        ),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "$token",
        },
      );

      log("Response status: ${response.statusCode}");
      final responseBody = jsonDecode(response.body);
      log("Response body of getUserData : $responseBody");

      if (response.statusCode == 200) {
        userData.value = Userdata.fromJson(responseBody);
      } else {
        Get.snackbar("Error", "Failed to get user data");
      }
    } catch (e) {
      log("Exception: $e");
      Get.snackbar("Exception", e.toString());
    } finally {
      isLoading(false);
    }
  }

  Future<void> editUserDetails(Userdata data, File? imageFile) async {
    final tokenManager = TokenManager();
    final token = await tokenManager.getToken();
    log("token :$token");

    try {
      isLoading(true);

      var uri = Uri.parse(
        "https://backend.fiberonix.in/api/opticalfiber/update/user/profile/",
      );
      var request = http.MultipartRequest("PUT", uri);

      request.headers.addAll({
        "Authorization": "$token",
        // Do NOT set "Content-Type" manually; http.MultipartRequest handles it
      });

      request.fields['name'] = data.name ?? '';
      request.fields['email'] = data.email ?? '';

      // Only attach the image file if it's not null
      if (imageFile != null) {
        request.files.add(
          await http.MultipartFile.fromPath('profile_picture', imageFile.path),
        );
      }

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        log(
          "Statuscode editUserDetails ${response.statusCode} ${response.body}",
        );
      } else {
        log("edit failed due to : ${response.body}");
        Get.snackbar("Error", "Failed to edit profile");
      }
    } catch (e) {
      log("editUserDetails error:$e");
      Get.snackbar("Exception", e.toString());
    } finally {
      isLoading(false);
    }
  }
}
