// ignore_for_file: file_names
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:network_mapping_app/Data/Interface/StaffData/staffdata.dart';
import 'package:network_mapping_app/Data/Resources/StaffApi/staffapi.dart';
import 'package:network_mapping_app/Domine/Core/Constant/constant.dart';
import 'package:network_mapping_app/Domine/Utils/widgets/App%20Text%20Widget/apptextwidget.dart';

class StaffAddingScreen extends StatefulWidget {
  const StaffAddingScreen({super.key});

  @override
  State<StaffAddingScreen> createState() => _StaffAddingScreenState();
}

class _StaffAddingScreenState extends State<StaffAddingScreen> {
  final StaffController staff = Get.put(StaffController());
  @override
  void initState() {
    staff.getStaff();
    super.initState();
  }

  void _showAddStaffDialog() {
    final TextEditingController staffNameController = TextEditingController();
    final TextEditingController staffEmailController = TextEditingController();
    final TextEditingController passwordController = TextEditingController();
    String? role;
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text("Add Staff"),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: staffNameController,
                  decoration: const InputDecoration(
                    hintText: "Enter staff name",
                  ),
                ),
                SizedBox(height: 15),
                TextField(
                  controller: staffEmailController,
                  decoration: const InputDecoration(hintText: "Enter Email"),
                ),
                SizedBox(height: 15),
                TextField(
                  controller: passwordController,
                  decoration: const InputDecoration(hintText: "Enter Password"),
                ),
                SizedBox(height: 15),
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'Role',
                    border: OutlineInputBorder(),
                  ),
                  value: role,
                  items:
                      ["admin", "engineer"].map((type) {
                        return DropdownMenuItem<String>(
                          value: type,
                          child: Text(type),
                        );
                      }).toList(),
                  onChanged: (value) {
                    setState(() {
                      role = value;
                    });
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(ctx).pop();
              },
              child: const Text("Cancel"),
            ),
            Obx(
              () =>
                  staff.isLoading.value
                      ? CircularProgressIndicator()
                      : ElevatedButton(
                        onPressed: () {
                          final post = StaffData(
                            staffName: staffNameController.text,
                            staffEmail: staffEmailController.text,
                            staffPasssword: passwordController.text,
                            staffRole: role,
                          );
                          staff.addStaff(post).then((_) {
                            setState(() {
                              staff.getStaff();
                            });
                          });
                          Navigator.of(ctx).pop();
                        },
                        child: const Text("Add"),
                      ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: whiteClr,
      appBar: AppBar(
        foregroundColor: whiteClr,
        title: AppTextwidget(
          text: "Staffs",
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: whiteClr,
        ),
        backgroundColor: appClr,
        elevation: 0,
      ),
      body: Obx(() {
        if (staff.staffList.isEmpty) {
          return const Center(
            child: Text('No staff added yet', style: TextStyle(fontSize: 18)),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: staff.staffList.length,
          itemBuilder: (context, index) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.15),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 10,
                  ),
                  leading: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          appClr.withOpacity(0.8),
                          appClr.withOpacity(0.5),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.person_outline,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  title: Text(
                    staff.staffList[index].staffName ?? "No Name",
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(
                            Icons.email_outlined,
                            size: 16,
                            color: Colors.grey,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            staff.staffList[index].staffEmail ?? "No Email",
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      }),

      floatingActionButton: FloatingActionButton(
        onPressed: _showAddStaffDialog,
        backgroundColor: appClr,
        child: const Icon(Icons.add, color: whiteClr),
      ),
    );
  }
}
