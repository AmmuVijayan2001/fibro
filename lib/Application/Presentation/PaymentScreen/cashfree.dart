import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_cashfree_pg_sdk/api/cferrorresponse/cferrorresponse.dart';
import 'package:flutter_cashfree_pg_sdk/api/cfpaymentgateway/cfpaymentgatewayservice.dart';
import 'package:flutter_cashfree_pg_sdk/api/cfpayment/cfwebcheckoutpayment.dart';
import 'package:flutter_cashfree_pg_sdk/api/cfsession/cfsession.dart';
import 'package:flutter_cashfree_pg_sdk/utils/cfenums.dart';
import 'package:flutter_cashfree_pg_sdk/utils/cfexceptions.dart';

class PaymentPage extends StatefulWidget {
  final String orderId;
  final String paymentSessionId;
  final CFEnvironment environment; // CFEnvironment.SANDBOX or .PRODUCTION

  const PaymentPage({
    super.key,
    required this.orderId,
    required this.paymentSessionId,
    required this.environment,
  });

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  late CFPaymentGatewayService _pgService;

  @override
  void initState() {
    super.initState();
    _pgService = CFPaymentGatewayService();
    _pgService.setCallback(_verifyPayment, _onError);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startPayment();
    });
  }

  void _verifyPayment(String orderId) {
    log("Payment successful for order: $orderId");
    Navigator.pop(context);
  }

  void _onError(CFErrorResponse errorResponse, String? orderId) {
    log("Payment failed: ${errorResponse.getMessage()}");
    Navigator.pop(context);
  }

  CFSession? _createSession() {
    try {
      return CFSessionBuilder()
          .setEnvironment(widget.environment)
          .setOrderId(widget.orderId)
          .setPaymentSessionId(widget.paymentSessionId)
          .build();
    } on CFException catch (e) {
      log("Session error: ${e.message}");
    }
    return null;
  }

  void _startPayment() {
    try {
      final session = _createSession();
      final cfWebCheckout =
          CFWebCheckoutPaymentBuilder().setSession(session!).build();
      _pgService.doPayment(cfWebCheckout);
    } on CFException catch (e) {
      log("Payment initiation error: ${e.message}");
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
