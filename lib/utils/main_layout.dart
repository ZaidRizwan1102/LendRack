import 'package:flutter/material.dart';
import 'package:wallet/screens/activity.dart';
import 'package:wallet/screens/home_page.dart';
import 'package:wallet/screens/settings.dart';
import 'package:wallet/widgets/navbar.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _currentIndex = 0;
    late final PageController _pageController;
    @override
    void initState(){
      super.initState();
      _pageController = PageController(initialPage: _currentIndex);
    }
    @override
    void dispose(){
      _pageController.dispose();
      super.dispose();
    }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: (index){
          setState(() {
            _currentIndex = index;
          });
        },
        children: [
          HomePage(),
          Activity(),
          Settings()
        ],
      ),
      bottomNavigationBar: CustomNavBar(currentIndex: _currentIndex,
       onTap: (index){
        _pageController.animateToPage(
          index,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
        setState(() {
          _currentIndex = index;
        });
       }
       ),
    );
  }
}