// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:network_mapping_app/Application/Presentation/MapdetailsScreen/mapdetailsscreen.dart';
import 'package:network_mapping_app/Data/Resources/JunctionApi/junctionapi.dart';
import 'package:network_mapping_app/Domine/Core/Constant/constant.dart';
import 'package:network_mapping_app/Domine/Utils/widgets/App%20Text%20Widget/apptextwidget.dart';

class Junctionscreen extends StatefulWidget {
  const Junctionscreen({super.key});

  @override
  State<Junctionscreen> createState() => _JunctionscreenState();
}

class _JunctionscreenState extends State<Junctionscreen> {
  String selectedJunctionType = 'main';
  final JunctionController junctionController = Get.put(JunctionController());
  @override
  void initState() {
    junctionController.getJunction();
    junctionController.fetchJunction();
    super.initState();
  }

  final List<String> mainJunctions = List.generate(
    10,
    (i) => 'Main Junction ${i + 1}',
  );
  final List<String> childJunctions = List.generate(
    10,
    (i) => 'Child Junction ${i + 1}',
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F8),
      appBar: AppBar(
        foregroundColor: whiteClr,
        title: AppTextwidget(
          text: "Junctions",
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: whiteClr,
        ),
        backgroundColor: appClr,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            sizedboxwidget(20),

            Text(
              '${selectedJunctionType == 'main' ? 'Main' : 'Child'} Junctions',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black54,
              ),
            ),

            const SizedBox(height: 10),

            Expanded(
              child: Obx(() {
                return ListView.builder(
                  itemCount: junctionController.juntionList.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              index.isEven
                                  ? Colors.teal.shade50
                                  : Colors.orange.shade50,
                              Colors.white,
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 8,
                              offset: const Offset(2, 4),
                            ),
                          ],
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          leading: Container(
                            decoration: BoxDecoration(
                              color: appClr.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            padding: const EdgeInsets.all(10),
                            child: Image.asset(
                              'asset/images/360_F_690988325_KxZyQLpuKYxHfs0LZ06Fy738PzUT66xO-removebg-preview.png',
                              width: 40,
                              height: 40,
                            ),
                          ),
                          title: Text(
                            junctionController.juntionList[index].name!,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          subtitle: Text(
                            "Postcode : ${junctionController.juntionList[index].postCode!}",
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          trailing: Icon(
                            Icons.arrow_forward_ios,
                            size: 16,
                            color: Colors.grey.shade600,
                          ),
                          onTap: () {
                            // Navigator.of(context).push(
                            //   MaterialPageRoute(
                            //     builder: (context) => Addnetworkdevicescreen(),
                            //   ),
                            // );
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (_) => Mapdetailsscreen(
                                      name:
                                          junctionController
                                              .juntionList[index]
                                              .name!,
                                      id:
                                          junctionController
                                              .juntionList[index]
                                              .id!,
                                      index: index,
                                      latitude: double.parse(
                                        junctionController
                                            .juntionList[index]
                                            .latitude!,
                                      ),
                                      longitude: double.parse(
                                        junctionController
                                            .juntionList[index]
                                            .longitude!,
                                      ),
                                    ),
                              ),
                            );
                          },
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
