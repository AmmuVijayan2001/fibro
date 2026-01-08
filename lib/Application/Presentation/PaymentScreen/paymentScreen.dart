import 'package:flutter/material.dart';
import 'package:flutter_cashfree_pg_sdk/utils/cfenums.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:network_mapping_app/Application/Presentation/PaymentScreen/cashfree.dart';
import 'package:network_mapping_app/Data/Interface/PaymentData/paymentdata.dart';
import 'package:network_mapping_app/Data/Resources/PaymentApi/paymentapi.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final PaymentController paymentController = Get.put(PaymentController());
  String currentPlan = "free";
  String billingPeriod = "year";

  final List<Plan> plans = [
    Plan(
      id: 'free',
      name: 'Free Plan',
      description: 'Single user',
      price: 0,
      period: 'year',
      limit: 50,
      used: 350,
      features: ['Single user access', 'Up to 50 KM tracking'],
      gradient: [
        const Color.fromARGB(255, 3, 137, 32),
        const Color.fromARGB(255, 5, 104, 66),
      ],
    ),
    Plan(
      id: 'Starter',
      name: 'Plan Starter',
      description: '500 km',
      price: 1200,
      period: 'year',
      limit: 500,
      used: 0,
      features: [
        'Single user - App/Web',
        '1 session/use',
        '500 km',
        'Standart support',
        'Add-on : ₹3000 / year per additional user',
      ],
      gradient: [Colors.blue.shade400, Colors.purple.shade400],
    ),
    Plan(
      id: 'Standard',
      name: 'Plan Standard',
      description: '1000 km',
      price: 18000,
      period: 'year',
      limit: 1000,
      used: 32000,
      features: [
        '2 Users',
        '2 session total(1 app,1 web)',
        '1000 km',
        'API access',
        'Standart support',
        'Add-on : ₹4000 / year per additional user',
      ],
      gradient: [Colors.green.shade400, Colors.green.shade700],
      popular: true,
    ),
    Plan(
      id: 'Pro',
      name: 'Plan Pro',
      description: '2000 km Plan',
      price: 26000,
      period: 'year',
      limit: 2000,
      used: 75000,
      features: [
        '2 Users',
        '2 session /user(1 app,1 web)',
        '2000 km',
        'API access',
        'Standart support',
        'Add-on : ₹4000 / year per additional user',
      ],
      gradient: [Colors.orange.shade400, Colors.red.shade400],
    ),
    Plan(
      id: 'Enterprise',
      name: 'Plan Enterprise',
      description: 'Upto 10,000 km',
      price: 48000,
      period: 'year',
      limit: 10000,
      used: 450000,
      features: [
        'Unlimited users',
        '2 session /user(1 app,1 web)',
        'Up to 10,000 km',
        'Stansard support',
      ],
      gradient: [Colors.purple.shade400, Colors.pink.shade400],
    ),
  ];

  String formatUsage(int used, int limit) {
    String formatNumber(int num) {
      if (num >= 1000) {
        return "${(num / 1000).toStringAsFixed(0)}K";
      }
      return num.toString();
    }

    return "${formatNumber(used)} / ${formatNumber(limit)} KM";
  }

  int getDiscountedPrice(int price, String period) {
    if (period == 'year') {
      return (price * 10); // 2 months free
    }
    return price;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Header
              Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.blue, Colors.purple],
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          LucideIcons.network,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 8),
                      ShaderMask(
                        shaderCallback:
                            (bounds) => const LinearGradient(
                              colors: [Colors.blueAccent, Colors.purpleAccent],
                            ).createShader(bounds),
                        child: Text(
                          "FiberOnix Pro",
                          style: GoogleFonts.poppins(
                            fontSize: 25,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              "Current Plan",
                              style: TextStyle(color: Colors.black54),
                            ),
                            Row(
                              children: [
                                const Icon(
                                  LucideIcons.crown,
                                  size: 16,
                                  color: Colors.orange,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  plans
                                      .firstWhere((p) => p.id == currentPlan)
                                      .name,
                                  style: const TextStyle(
                                    color: Colors.green,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        LinearProgressIndicator(
                          value:
                              plans
                                  .firstWhere((p) => p.id == currentPlan)
                                  .used /
                              plans
                                  .firstWhere((p) => p.id == currentPlan)
                                  .limit,
                          backgroundColor: Colors.grey.shade300,
                          valueColor: AlwaysStoppedAnimation(Colors.green),
                          minHeight: 8,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "${formatUsage(plans.firstWhere((p) => p.id == currentPlan).used, plans.firstWhere((p) => p.id == currentPlan).limit)} used",
                          style: const TextStyle(
                            color: Colors.black54,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),
                ],
              ),

              const SizedBox(height: 5),

              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: plans.length,
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 300, // each card max width
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  mainAxisExtent: 380, // fixed height to prevent overflow
                ),
                itemBuilder: (context, index) {
                  return _planCard(plans[index]);
                },
              ),

              const SizedBox(height: 32),

              Column(
                children: const [
                  Text(
                    "All plans include SSL security, regular backups, and 99.9% uptime guarantee",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.black54),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "✓ Cancel anytime    ✓ 30-day money back    ✓ 24/7 support",
                    style: TextStyle(color: Colors.black54, fontSize: 12),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _planCard(Plan plan) {
    bool isCurrent = currentPlan == plan.id;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            spreadRadius: 2,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (plan.popular)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [Colors.green, Colors.teal]),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(LucideIcons.star, size: 14, color: Colors.white),
                  SizedBox(width: 4),
                  Text(
                    "Most Popular",
                    style: TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 12),
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: plan.gradient),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(_getPlanIcon(plan.id), color: Colors.white),
          ),
          const SizedBox(height: 12),
          Text(
            plan.name,
            style: const TextStyle(
              color: Colors.black87,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            plan.description,
            style: const TextStyle(color: Colors.black54, fontSize: 12),
          ),

          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                "₹${getDiscountedPrice(plan.price, billingPeriod)}",
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                "/ ${billingPeriod == 'year' ? 'year' : 'month'}",
                style: const TextStyle(color: Colors.black54),
              ),
            ],
          ),
          if (billingPeriod == 'year' && plan.price > 0)
            // Text(
            //   "Save ₹${(plan.price * 2)} annually",
            //   style: const TextStyle(color: Colors.green, fontSize: 12),
            // ),
            // LinearProgressIndicator(
            //   value: plan.used / plan.limit,
            //   backgroundColor: Colors.grey.shade300,
            //   valueColor: AlwaysStoppedAnimation(plan.gradient.first),
            //   minHeight: 6,
            // ),
            // Text(
            //   formatUsage(plan.used, plan.limit),
            //   style: const TextStyle(color: Colors.black54, fontSize: 12),
            // ),
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children:
                    plan.features
                        .map(
                          (f) => Row(
                            children: [
                              const Icon(
                                LucideIcons.check,
                                size: 14,
                                color: Colors.green,
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  f,
                                  style: const TextStyle(
                                    color: Colors.black54,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                        .toList(),
              ),
            ),
          gradientButton(
            isCurrent: isCurrent,
            colors: plan.gradient,
            onPressed: () {
              paymentController.initiatePayment(
                phone: "9876543210", // pass actual phone
                amount: plan.price.toString(),
                onSuccess: (data) {
                  Get.to(
                    () => PaymentPage(
                      environment: CFEnvironment.SANDBOX,
                      orderId: data['order_id'],
                      paymentSessionId: data['payment_session_id'],
                    ),
                  );
                },
              );
            },
            label: isCurrent ? "Current Plan" : "Select Plan",
          ),
        ],
      ),
    );
  }

  IconData _getPlanIcon(String id) {
    switch (id) {
      case 'free':
        return LucideIcons.globe;
      case 'basic':
        return LucideIcons.mapPin;
      case 'pro':
        return LucideIcons.router;
      case 'enterprise':
        return LucideIcons.lineChart;
      case 'unlimited':
        return LucideIcons.crown;
      default:
        return LucideIcons.zap;
    }
  }

  Widget gradientButton({
    required bool isCurrent,
    required List<Color> colors,
    required VoidCallback? onPressed,
    required String label,
  }) {
    if (isCurrent) {
      return ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.grey.shade400,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onPressed: null,
        child: Text(label),
      );
    }

    return Container(
      width: 100,
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: colors),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onPressed: onPressed,
        child: Text(label, style: const TextStyle(color: Colors.white)),
      ),
    );
  }
}
