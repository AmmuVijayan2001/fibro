// lib/map_routing_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:maplibre_gl/maplibre_gl.dart';
import 'package:network_mapping_app/Application/Presentation/AddNewOlt/adddnewolt.dart';
import 'package:network_mapping_app/Application/Presentation/MapdetailsScreen/mapdetailsscreen.dart';
import 'package:network_mapping_app/Data/Resources/OfficeaddiingApi/officeaddingapi.dart';
import 'package:network_mapping_app/Domine/Core/Constant/constant.dart';
import 'package:network_mapping_app/Domine/Utils/widgets/App%20Text%20Widget/apptextwidget.dart';

class MapRoutingScreen extends StatefulWidget {
  const MapRoutingScreen({super.key});

  @override
  State<MapRoutingScreen> createState() => _MapRoutingScreenState();
}

class _MapRoutingScreenState extends State<MapRoutingScreen> {
  final OfficeAController controller = Get.put(OfficeAController());
  final TextEditingController searchController = TextEditingController();
  @override
  void initState() {
    controller.getOffice();
    controller.fetchOffices();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const AppTextwidget(
          text: "Fiber Route",
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: Colors.black,
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: searchController,
              onChanged: (value) {
                controller.filterOffices(value);
              },
              decoration: InputDecoration(
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                  borderSide: BorderSide(color: Colors.black),
                ),
                hintText: 'Search Fiber Route Name...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                  borderSide: BorderSide(color: Colors.black),
                ),
                filled: true,
                fillColor: const Color.fromARGB(255, 247, 246, 246),
              ),
            ),

            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: appClr,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                icon: const Icon(
                  LucideIcons.map,
                  size: 28,
                  color: Colors.white,
                ),
                label: const Text(
                  'Add New Fiber Route',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onPressed: () {
                  Navigator.of(context)
                      .push(
                        MaterialPageRoute(
                          builder: (context) => AddNewOltScreen(),
                        ),
                      )
                      .then((_) {
                        controller.fetchOffices();
                      });
                },
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return Center(
                    child: Lottie.asset(
                      'asset/lottie/d59LNQLq1X.json',
                      width: 100,
                      height: 100,
                      fit: BoxFit.contain,
                    ),
                  );
                }

                if (controller.officeList.isEmpty) {
                  return const Center(child: Text("No data found."));
                }

                return GridView.builder(
                  itemCount: controller.filteredOfficeList.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1,
                  ),
                  itemBuilder: (context, index) {
                    final office = controller.filteredOfficeList[index];

                    return InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (_) => Mapdetailsscreen(
                                  name: office.name!,
                                  id: office.id!,
                                  index: index,
                                  latitude: double.parse(office.latitude!),
                                  longitude: double.parse(office.longitude!),
                                ),
                          ),
                        );
                      },
                      child: Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 3,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Builder(
                                builder: (context) {
                                  final latitude = double.tryParse(
                                    office.latitude ?? '',
                                  );
                                  final longitude = double.tryParse(
                                    office.longitude ?? '',
                                  );

                                  if (latitude == null || longitude == null) {
                                    return const Center(
                                      child: Text(
                                        'Invalid coordinates',
                                        style: TextStyle(color: Colors.red),
                                      ),
                                    );
                                  }

                                  return ClipRRect(
                                    borderRadius: const BorderRadius.vertical(
                                      top: Radius.circular(16),
                                    ),
                                    child: AbsorbPointer(
                                      // 👈 this disables interaction on map view
                                      child: MaplibreMap(
                                        styleString:
                                            'https://demotiles.maplibre.org/style.json',
                                        initialCameraPosition: CameraPosition(
                                          target: LatLng(latitude, longitude),
                                          zoom: 6,
                                        ),
                                        myLocationEnabled: false,
                                        compassEnabled: false,
                                        rotateGesturesEnabled: false,
                                        scrollGesturesEnabled: false,
                                        tiltGesturesEnabled: false,
                                        zoomGesturesEnabled: false,
                                        attributionButtonPosition:
                                            AttributionButtonPosition
                                                .bottomRight,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    office.name ?? '',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    office.name ?? '',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
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
          ],
        ),
      ),
    );
  }
}
