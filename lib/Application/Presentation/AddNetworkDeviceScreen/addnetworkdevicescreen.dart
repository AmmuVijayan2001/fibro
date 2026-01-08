import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:network_mapping_app/Domine/Core/Constant/constant.dart';
import 'package:network_mapping_app/Domine/Utils/widgets/App%20Text%20Widget/apptextwidget.dart';

class Addnetworkdevicescreen extends StatefulWidget {
  const Addnetworkdevicescreen({super.key});

  @override
  State<Addnetworkdevicescreen> createState() => _AddnetworkdevicescreenState();
}

class _AddnetworkdevicescreenState extends State<Addnetworkdevicescreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        foregroundColor: appClr,
        title: AppTextwidget(
          text: "Network Devices",
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: appClr,
        ),
        backgroundColor: whiteClr,
        elevation: 0,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          sizedboxwidget(10),
          SizedBox(
            height: 200,
            width: double.infinity,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.asset(
                  "asset/images/Screenshot_2025-05-15_154217-removebg-preview.png",
                  fit: BoxFit.cover,
                  height: 250,
                  width: double.infinity,
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Image.asset(
                    "asset/images/networking-concept-still-life-composition-removebg-preview.png",
                    height: 190,
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
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
                  LucideIcons.network,
                  size: 28,
                  color: Colors.white,
                ),
                label: const Text(
                  'Add New Device',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onPressed: () {
                  String? selectedDeviceType;
                  final TextEditingController modelNameController =
                      TextEditingController();
                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: const Text('Add New Network Device'),
                        content: StatefulBuilder(
                          builder: (context, setState) {
                            return Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                DropdownButtonFormField<String>(
                                  decoration: const InputDecoration(
                                    labelText: 'Device Type',
                                    border: OutlineInputBorder(),
                                  ),
                                  value: selectedDeviceType,
                                  items:
                                      [
                                        'Splitter',
                                        'Coupler',
                                        'Transceiver',
                                        'Patch Panel',
                                        'Optical Switch',
                                        'Media Converter',
                                        'Network Interface Card (NIC)',
                                        'Router',
                                        'Switch',
                                        'Firewall',
                                      ].map((type) {
                                        return DropdownMenuItem<String>(
                                          value: type,
                                          child: Text(type),
                                        );
                                      }).toList(),
                                  onChanged: (value) {
                                    setState(() {
                                      selectedDeviceType = value;
                                    });
                                  },
                                ),
                                const SizedBox(height: 16),

                                TextFormField(
                                  controller: modelNameController,
                                  decoration: const InputDecoration(
                                    labelText: 'Model Name',
                                    border: OutlineInputBorder(),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: const Text('Cancel'),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              final selectedType = selectedDeviceType;
                              final modelName = modelNameController.text;

                              if (selectedType != null &&
                                  modelName.isNotEmpty) {
                                Navigator.of(context).pop();
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text("Please fill all fields"),
                                  ),
                                );
                              }
                            },
                            child: const Text('Add'),
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
