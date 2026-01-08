import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart' show ImagePicker, ImageSource;
import 'package:network_mapping_app/Application/Presentation/AboutUsScreen/aboutUs.dart';
import 'package:network_mapping_app/Application/Presentation/ChangePasswordScreen/changepassword.dart';
import 'package:network_mapping_app/Application/Presentation/Login%20Screen/loginscreen.dart';
import 'package:network_mapping_app/Application/Presentation/PrivacyPolicyScreen/privacyPolicy.dart';
import 'package:network_mapping_app/Data/Interface/UserData/userdata.dart';
import 'package:network_mapping_app/Data/Resources/UserApi/userapi.dart';
import 'package:network_mapping_app/Domine/Core/Constant/constant.dart';
import 'package:network_mapping_app/Domine/Utils/widgets/App%20Text%20Widget/apptextwidget.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final userController = Get.put(UserDataApi());
  File? _image;
  final picker = ImagePicker();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();

  @override
  void initState() {
    userController.getUserData();
    userController.getUserData().then((_) {
      setState(() {
        _nameController.text = userController.userData.value?.name ?? '';
        _emailController.text = userController.userData.value?.email ?? '';
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        foregroundColor: whiteClr,
        title: AppTextwidget(
          text: "Profile",
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: whiteClr,
        ),
        backgroundColor: appClr,
        elevation: 0,
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Stack(
              children: [
                ClipPath(
                  clipper: WaveClipper(),
                  child: Container(
                    width: double.infinity,
                    height: 280,
                    color: appClr,
                  ),
                ),
                Positioned(
                  top: 40,
                  left: 0,
                  right: 0,
                  child: Column(
                    children: [
                      Stack(
                        children: [
                          CircleAvatar(
                            backgroundColor: const Color.fromARGB(
                              255,
                              119,
                              52,
                              170,
                            ),
                            radius: 70,
                            child: Obx(
                              () => CircleAvatar(
                                backgroundImage: NetworkImage(
                                  "https://backend.fiberonix.in${userController.userData.value?.profileImage ?? ''}",
                                ),
                                radius: 66,
                                backgroundColor: whiteClr,
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 4,
                            child: GestureDetector(
                              onTap: () => _showEditDialog(),
                              child: CircleAvatar(
                                radius: 16,
                                backgroundColor: Colors.white,
                                child: Icon(
                                  Icons.edit,
                                  color: appClr,
                                  size: 18,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Obx(() {
                        final name =
                            userController.userData.value?.name ?? "Loading...";
                        return AppTextwidget(
                          text: name,
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: whiteClr,
                        );
                      }),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 40),

            buildListTile("Bank Account Info", null),
            buildListTile("Return Address Info", null),
            buildListTile("Change Password", ChangePasswordScreen()),
            buildListTile("Privacy Policy", Privacypolicyscreen()),
            buildListTile("About Us", Aboutusscreen()),
            SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.only(bottom: 50),
              child: GestureDetector(
                onTap: () => _showLogoutDialog(context),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    border: Border.all(color: Colors.red, width: 1.8),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(Icons.logout, color: Colors.red),
                      SizedBox(width: 10),
                      Text(
                        "Logout",
                        style: TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildListTile(String title, Widget? navigateTo) {
    return Column(
      children: [
        ListTile(
          title: Text(title),
          trailing: Icon(Icons.arrow_forward_ios, size: 16),
          onTap:
              navigateTo == null
                  ? null // disables tap (no ripple, no action)
                  : () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => navigateTo),
                    );
                  },
        ),
        Divider(height: 1),
      ],
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: Row(
              children: const [
                Icon(Icons.logout, color: Colors.red),
                SizedBox(width: 10),
                Text('Logout'),
              ],
            ),
            content: const Text(
              'Are you sure you want to logout?',
              style: TextStyle(fontSize: 16),
            ),
            actionsPadding: const EdgeInsets.symmetric(
              horizontal: 15,
              vertical: 10,
            ),
            actions: [
              TextButton(
                style: TextButton.styleFrom(
                  backgroundColor: Colors.green[100],
                  foregroundColor: Colors.green[800],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              TextButton(
                style: TextButton.styleFrom(
                  backgroundColor: Colors.red[100],
                  foregroundColor: Colors.red[800],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () async {
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.remove('access_token');
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (context) => LoginScreen()),
                    (Route<dynamic> route) => false,
                  );
                },
                child: const Text('Logout'),
              ),
            ],
          ),
    );
  }

  void _showEditDialog() {
    File? tempImage = _image;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Edit Profile'),
              content: SingleChildScrollView(
                child: Column(
                  children: [
                    Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        CircleAvatar(
                          radius: 45,
                          backgroundImage:
                              tempImage != null
                                  ? FileImage(tempImage!)
                                  : (userController
                                                      .userData
                                                      .value
                                                      ?.profileImage !=
                                                  null &&
                                              userController
                                                  .userData
                                                  .value!
                                                  .profileImage!
                                                  .isNotEmpty
                                          ? NetworkImage(
                                            "https://backend.fiberonix.in${userController.userData.value!.profileImage!}",
                                          )
                                          : null)
                                      as ImageProvider?,
                          backgroundColor: Colors.grey.shade200,
                          child:
                              (userController.userData.value?.profileImage ==
                                              null ||
                                          userController
                                              .userData
                                              .value!
                                              .profileImage!
                                              .isEmpty) &&
                                      tempImage == null
                                  ? const Icon(
                                    Icons.person,
                                    size: 40,
                                    color: Colors.white,
                                  )
                                  : null,
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: GestureDetector(
                            onTap: () async {
                              final picker = ImagePicker();
                              final pickedFile = await picker.pickImage(
                                source: ImageSource.gallery,
                              );
                              if (pickedFile != null) {
                                setDialogState(() {
                                  tempImage = File(pickedFile.path);
                                });
                              }
                            },
                            child: Container(
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.black,
                              ),
                              padding: const EdgeInsets.all(6),
                              child: const Icon(
                                Icons.edit,
                                size: 16,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(labelText: 'Name'),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _emailController,
                      decoration: const InputDecoration(labelText: 'Email'),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () async {
                    final post = Userdata(
                      name: _nameController.text,
                      email: _emailController.text,
                    );
                    await userController.editUserDetails(post, tempImage);
                    await userController.getUserData();
                    setState(() {}); // Refresh profile screen
                    Navigator.of(context).pop();
                  },
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

class WaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height - 60);
    path.quadraticBezierTo(
      size.width / 4,
      size.height,
      size.width / 2,
      size.height - 30,
    );
    path.quadraticBezierTo(
      size.width * 3 / 4,
      size.height - 60,
      size.width,
      size.height - 20,
    );
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
