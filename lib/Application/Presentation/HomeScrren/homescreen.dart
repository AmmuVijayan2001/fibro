// ignore_for_file: deprecated_member_use
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:network_mapping_app/Application/Presentation/AreaScreen/areascreen.dart';
import 'package:network_mapping_app/Application/Presentation/CustomerScreen/customerscreen.dart';
import 'package:network_mapping_app/Application/Presentation/InventoryScreen/inventoryscreen.dart';
import 'package:network_mapping_app/Application/Presentation/JunctionScreen/junctionscreen.dart';
import 'package:network_mapping_app/Application/Presentation/MaprouteScreen/maproutescreen.dart';
import 'package:network_mapping_app/Application/Presentation/NetworkDesignScreen/networkdesignsavedscreen.dart';
import 'package:network_mapping_app/Data/Resources/UserApi/userapi.dart';
import 'package:network_mapping_app/Domine/Core/Constant/constant.dart';
import 'package:network_mapping_app/Domine/Utils/widgets/App%20Text%20Widget/apptextwidget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final userController = Get.put(UserDataApi());

  final List<Map<String, dynamic>> _statusData = const [
    {"title": "Route Map", "icon": Icons.map_outlined},
    {"title": "Junction", "icon": Icons.alt_route},
    {"title": "Inventory", "icon": Icons.inventory_rounded},
    {"title": "Area", "icon": Icons.area_chart},
    {"title": "NetWork Design", "icon": Icons.route},
    {"title": "Customers", "icon": Icons.people},
  ];

  final List<String> imageUrls = [
    'https://i.pinimg.com/736x/83/c5/bd/83c5bdde763c87e4c9d2f9b79028c448.jpg',
    'https://i.pinimg.com/736x/56/f0/da/56f0da38a8722398d776bd30b8e7f79c.jpg',
    "https://i.pinimg.com/736x/15/cb/00/15cb00d0a16d26035c2bdd662e75b041.jpg",
    "https://i.pinimg.com/736x/9f/f2/c2/9ff2c216fce881ddcf45349adb3faa64.jpg",
  ];

  final List<Color> colors = [
    Colors.purple,
    Colors.red,
    Colors.green,
    Colors.pink,
    Colors.teal,
    Colors.black,
  ];

  Widget _buildStatusCard({
    required String title,
    required IconData icon,
    required int index,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colors[index % colors.length].withOpacity(0.7),
            colors[index % colors.length].withOpacity(0.9),
          ],
        ),
      ),
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(color: Colors.white)),
              const SizedBox(height: 6),
            ],
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: Icon(icon, color: Colors.white.withOpacity(0.8), size: 30),
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    userController.getUserData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final height = size.height;
    final width = size.width;

    return Scaffold(
      backgroundColor: appClr,
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [appClr, appClr.withOpacity(0.8)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          Positioned(
            top: height * 0.06,
            left: width * 0.05,
            right: width * 0.05,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppTextwidget(
                      text: "Welcome",
                      fontSize: height * 0.022,
                      fontWeight: FontWeight.w500,
                      color: whiteClr,
                    ),
                    Obx(() {
                      final name =
                          userController.userData.value?.name ?? "Loading...";
                      return AppTextwidget(
                        text: name,
                        fontSize: height * 0.025,
                        fontWeight: FontWeight.w600,
                        color: whiteClr,
                      );
                    }),
                  ],
                ),
                Row(
                  children: [
                    Obx(
                      () => CircleAvatar(
                        backgroundImage: NetworkImage(
                          "https://backend.fiberonix.in${userController.userData.value?.profileImage ?? ''}",
                        ),
                        radius: 22,
                      ),
                    ),
                    SizedBox(width: 12),
                    Icon(Icons.notifications, color: Colors.white, size: 28),
                  ],
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              width: width,
              height: height * 0.75,
              padding: EdgeInsets.all(width * 0.05),
              decoration: const BoxDecoration(
                color: whiteClr,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(25),
                  topRight: Radius.circular(25),
                ),
              ),
              child: Column(
                children: [
                  SizedBox(height: height * 0.02),
                  SizedBox(
                    width: width,
                    child: CarouselSlider(
                      options: CarouselOptions(
                        height: height * 0.18,
                        enlargeCenterPage: true,
                        autoPlay: true,
                        aspectRatio: 16 / 9,
                        autoPlayCurve: Curves.fastOutSlowIn,
                        enableInfiniteScroll: true,
                        autoPlayAnimationDuration: const Duration(
                          milliseconds: 800,
                        ),
                        viewportFraction: 1.0,
                      ),
                      items: List.generate(imageUrls.length, (index) {
                        final imageUrl = imageUrls[index];
                        return ClipRRect(
                          borderRadius: BorderRadius.circular(8.0),
                          child:
                              imageUrl.isNotEmpty
                                  ? Image.network(
                                    imageUrl,
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                  )
                                  : Container(
                                    color: Colors.grey,
                                    child: const Center(
                                      child: Text("No Image"),
                                    ),
                                  ),
                        );
                      }),
                    ),
                  ),
                  SizedBox(height: height * 0.02),
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.all(width * 0.04),
                      decoration: BoxDecoration(
                        color: whiteClr,
                        borderRadius: BorderRadius.circular(25),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.5),
                            blurRadius: 8,
                            offset: const Offset(0, 7),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AppTextwidget(
                            text: "Operating Features ",
                            fontSize: height * 0.023,
                            fontWeight: FontWeight.w600,
                            color: blackClr,
                          ),
                          const SizedBox(height: 10),
                          Expanded(
                            child: GridView.builder(
                              itemCount: _statusData.length,
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 3,
                                    mainAxisSpacing: 20,
                                    crossAxisSpacing: 10,
                                    childAspectRatio: 0.8,
                                  ),
                              itemBuilder: (context, index) {
                                final item = _statusData[index];
                                return GestureDetector(
                                  onTap: () {
                                    switch (index) {
                                      case 0:
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => MapRoutingScreen(),
                                          ),
                                        );
                                        break;
                                      case 1:
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => Junctionscreen(),
                                          ),
                                        );
                                        break;
                                      case 2:
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => Inventoryscreen(),
                                          ),
                                        );
                                        break;
                                      case 3:
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => Areascreen(),
                                          ),
                                        );
                                        break;
                                      case 4:
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder:
                                                (_) =>
                                                    Networkdesignsavedscreen(),
                                          ),
                                        );
                                        break;
                                      case 5:
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => CustomerScreen(),
                                          ),
                                        );
                                        break;
                                      default:
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          const SnackBar(
                                            content: Text('No screen defined'),
                                          ),
                                        );
                                    }
                                  },
                                  child: _buildStatusCard(
                                    title: item["title"],
                                    icon: item["icon"],
                                    index: index,
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
