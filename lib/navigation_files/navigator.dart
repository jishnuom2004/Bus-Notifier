import 'package:final_year_project/basic_pages/profile_page.dart';
import 'package:final_year_project/basic_pages/add_bus_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';


import '../basic_pages/home_page.dart';



class NavigatorMangement extends StatelessWidget {
  const NavigatorMangement({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(NavigationController());

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 10,
      ),
      bottomNavigationBar: Obx(
        () => BottomNavigationBar(
          currentIndex: controller.selectedIndex.value,
          onTap: (index) {
            controller.selectedIndex.value = index;
          },
          showSelectedLabels: true,
          showUnselectedLabels: false,
          items: [
            BottomNavigationBarItem(
              icon: Padding(
                padding: const EdgeInsets.only(top: 8.0), // Adjust the padding as needed
                child: SvgPicture.asset(
                  'assets/icons/Home.svg', // Path to your SVG asset
                  height: 26,
                  width: 26,
                ),
              ),
              label: '',
            ),
            BottomNavigationBarItem(
              icon: Padding(
                padding: const EdgeInsets.only(top: 8.0), // Adjust the padding as needed
                child: SvgPicture.asset(
                  'assets/icons/Add.svg', // Path to your SVG asset
                  height: 40,
                  width: 40,
                ),
              ),
              label: '',
            ),
            BottomNavigationBarItem(
              icon: Padding(
                padding: const EdgeInsets.only(top: 8.0), // Adjust the padding as needed
                child: SvgPicture.asset(
                  'assets/icons/Profile.svg', // Path to your SVG asset
                  height: 30,
                  width: 30,
                ),
              ),
              label: '',
            ),
            
          ],
        ),
      ),
      body: Obx(() => controller.screens[controller.selectedIndex.value]),
    );
  }
}

class NavigationController extends GetxController {
  final Rx<int> selectedIndex = 0.obs;
  final RxBool isAdmin = false.obs;

  final screens = [
    const HomePage(),
    const AddBusPage(),
    const ProfilePage(),
    
  ];

}
  