import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:network_mapping_app/Application/Presentation/StaffScreen/staffscreen.dart';
import 'package:network_mapping_app/Application/Presentation/HomeScrren/homescreen.dart';
import 'package:network_mapping_app/Application/Presentation/ProfileScreen/profilescreen.dart';
import 'package:network_mapping_app/Domine/Core/Constant/constant.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    HomeScreen(),
    StaffAddingScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: whiteClr,
      body: _screens[_selectedIndex],
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10),
        child: GNav(
          backgroundColor: whiteClr,
          rippleColor: whiteClr,
          color: appClr,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          gap: 6,
          activeColor: whiteClr,
          iconSize: 24,
          textSize: 9,
          tabBackgroundColor: appClr,
          curve: Curves.easeInOut,
          duration: const Duration(milliseconds: 250),
          selectedIndex: _selectedIndex,
          onTabChange: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
          tabs: const [
            GButton(
              icon: Icons.home,
              text: 'Home',
              textStyle: TextStyle(fontSize: 15, color: whiteClr),
            ),
            GButton(
              icon: Icons.account_balance,
              text: 'Staffs',
              textStyle: TextStyle(fontSize: 15, color: whiteClr),
            ),
            GButton(
              icon: Icons.person,
              text: 'Profile',
              textStyle: TextStyle(fontSize: 15, color: whiteClr),
            ),
          ],
        ),
      ),
    );
  }
}
