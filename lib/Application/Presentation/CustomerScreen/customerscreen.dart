import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:network_mapping_app/Application/Presentation/CustomerScreen/customerlistscreen.dart';
import 'package:network_mapping_app/Data/Resources/OfficeaddiingApi/officeaddingapi.dart';
import 'package:network_mapping_app/Domine/Core/Constant/constant.dart';
import 'package:network_mapping_app/Domine/Utils/widgets/App%20Text%20Widget/apptextwidget.dart';

class CustomerScreen extends StatefulWidget {
  const CustomerScreen({super.key});

  @override
  State<CustomerScreen> createState() => _CustomerScreenState();
}

class _CustomerScreenState extends State<CustomerScreen> {
  final OfficeAController controller = Get.put(OfficeAController());

  @override
  void initState() {
    controller.getOffice();
    controller.fetchOffices();
    super.initState();
  }

  String searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final screenHeight = mediaQuery.size.height;
    final isTablet = screenWidth > 600;

    return Scaffold(
      appBar: AppBar(
        foregroundColor: whiteClr,
        title: AppTextwidget(
          text: "Customers",
          fontSize: isTablet ? 24 : 20,
          fontWeight: FontWeight.w600,
          color: whiteClr,
        ),
        backgroundColor: appClr,
        elevation: 0,
      ),
      backgroundColor: whiteClr,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: screenHeight * 0.01),
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: screenWidth * 0.04,
                vertical: screenHeight * 0.01,
              ),
              child: TextField(
                decoration: InputDecoration(
                  hintText: "Search Customers...",
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: const Color.fromARGB(255, 237, 235, 235),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
                onChanged: (value) {
                  setState(() {
                    searchQuery = value;
                  });
                },
              ),
            ),
            Padding(
              padding: EdgeInsets.only(left: screenWidth * 0.05),
              child: Text(
                "Customer",
                style: TextStyle(
                  fontSize: isTablet ? 26 : 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(height: screenHeight * 0.01),
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
                child: Obx(() {
                  if (controller.isLoading.value) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (controller.officeList.isEmpty) {
                    return const Center(child: Text("No data found."));
                  }

                  return GridView.builder(
                    itemCount: controller.filteredOfficeList.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: isTablet ? 3 : 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: isTablet ? 1.5 : 1.3,
                    ),
                    itemBuilder: (context, index) {
                      final office = controller.filteredOfficeList[index];

                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) => CustomerListScreen(
                                    officeId: office.id!,
                                    officeName: office.name ?? '',
                                  ),
                            ),
                          );
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.2),
                                spreadRadius: 2,
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                            border: Border.all(color: appClr.withOpacity(0.2)),
                          ),
                          padding: EdgeInsets.all(screenWidth * 0.04),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CircleAvatar(
                                radius: isTablet ? 28 : 24,
                                backgroundColor: appClr.withOpacity(0.1),
                                child: Icon(
                                  Icons.apartment_rounded,
                                  color: appClr,
                                  size: isTablet ? 32 : 28,
                                ),
                              ),
                              sizedboxwidget(8),
                              Text(
                                office.name ?? '',
                                style: TextStyle(
                                  color: Colors.black87,
                                  fontSize: isTablet ? 18 : 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),

                              Text(
                                "Tap to view customers",
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: isTablet ? 14 : 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                }),
              ),
            ),
            SizedBox(height: screenHeight * 0.02),
          ],
        ),
      ),
    );
  }
}
