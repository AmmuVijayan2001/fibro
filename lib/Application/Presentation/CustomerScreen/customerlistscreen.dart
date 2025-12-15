import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:network_mapping_app/Data/Resources/CustomerApi/customerapi.dart';
import 'package:network_mapping_app/Domine/Core/Constant/constant.dart';
import 'package:network_mapping_app/Domine/Utils/widgets/App%20Text%20Widget/apptextwidget.dart';

class CustomerListScreen extends StatefulWidget {
  final int officeId;
  final String officeName;
  const CustomerListScreen({
    super.key,
    required this.officeId,
    required this.officeName,
  });
  @override
  State<CustomerListScreen> createState() => _CustomerListScreenState();
}

class _CustomerListScreenState extends State<CustomerListScreen> {
  final CustomerController customerController = Get.put(CustomerController());
  List<bool> _isExpandedList = [];

  @override
  void initState() {
    super.initState();
    customerController.getCustomers(widget.officeId).then((_) {
      setState(() {
        _isExpandedList = List.generate(
          customerController.customerList.length,
          (_) => false,
        );
      });
    });
  }

  Future<void> _openMap(double latitude, double longitude) async {
    final Uri googleMapUri = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude',
    );

    if (!await launchUrl(googleMapUri, mode: LaunchMode.externalApplication)) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Could not open the map.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        foregroundColor: whiteClr,
        title: AppTextwidget(
          text: "${widget.officeName} - Customers",
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: whiteClr,
        ),
        backgroundColor: appClr,
        elevation: 0,
      ),
      body: Obx(() {
        if (customerController.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        if (customerController.customerList.isEmpty) {
          return const Center(child: Text("No data found."));
        }
        return ListView.builder(
          itemCount: customerController.customerList.length,
          itemBuilder: (context, index) {
            final customer = customerController.customerList[index];
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.indigo.shade100, Colors.white],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ExpansionTile(
                key: Key(index.toString()),
                initiallyExpanded:
                    _isExpandedList.length > index
                        ? _isExpandedList[index]
                        : false,
                onExpansionChanged: (expanded) {
                  setState(() {
                    if (_isExpandedList.length > index) {
                      _isExpandedList[index] = expanded;
                    }
                  });
                },
                tilePadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                title: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.deepPurple,
                      child: Text(
                        customer.customerName?[0].toUpperCase() ?? "?",
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        customer.customerName ?? "",
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 4,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _detailRow(
                          Icons.email,
                          "Email",
                          customer.customerEmail,
                        ),
                        _detailRow(
                          Icons.phone,
                          "Phone",
                          customer.customerPhone,
                        ),
                        _detailRow(
                          Icons.location_on,
                          "Address",
                          customer.address,
                        ),
                        const SizedBox(height: 8),
                        // Button to open Google Maps
                        if (customer.latitude != null &&
                            customer.longitude != null)
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton.icon(
                              onPressed: () {
                                _openMap(
                                  customer.latitude!,
                                  customer.longitude!,
                                );
                              },
                              icon: const Icon(
                                Icons.map,
                                color: Colors.deepPurple,
                              ),
                              label: const Text(
                                "View on Map",
                                style: TextStyle(color: Colors.deepPurple),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            );
          },
        );
      }),
    );
  }

  Widget _detailRow(IconData icon, String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, color: Colors.deepPurple),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              "$label: ${value ?? 'N/A'}",
              style: const TextStyle(fontSize: 15),
            ),
          ),
        ],
      ),
    );
  }
}
