import 'dart:convert';
import 'dart:developer';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:network_mapping_app/Data/Resources/TokenManage/tokenmanage.dart';

class PaymentController extends GetxController {
  var isLoading = false.obs;

  Future<void> initiatePayment({
    required String phone,
    required String amount,
    required Function(Map<String, dynamic>) onSuccess,
  }) async {
    final tokenManager = TokenManager();
    final token = await tokenManager.getToken();

    try {
      isLoading(true);

      final response = await http.post(
        Uri.parse("https://backend.fiberonix.in/api/payment/initiate/"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "$token",
        },
        body: jsonEncode({"phone": phone, "amount": amount}),
      );

      log("API Response: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        log("result:$data");
        Get.snackbar("Success", "Payment initiated successfully");

        onSuccess(data);
      } else {
        Get.snackbar("Error", "Failed to initiate payment");
        log("Error: ${jsonDecode(response.body)}");
      }
    } catch (e) {
      Get.snackbar("Exception", e.toString());
    } finally {
      isLoading(false);
    }
  }
}
