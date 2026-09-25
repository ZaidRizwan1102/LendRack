import 'package:flutter/material.dart';
import 'package:wallet/utils/responsive.dart';

class CustomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  const CustomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final size = Responsive(context);
    BottomNavigationBarItem buildNavItem({
      required IconData inactiveIcon,
      required IconData activeIcon,
      required String label,
    }) {
      return BottomNavigationBarItem(
        icon: Icon(inactiveIcon),
        activeIcon: Container(
          padding: EdgeInsets.all(size.widthPerc(2)),
          decoration: BoxDecoration(color: Theme.of(context).colorScheme.primary,
          borderRadius: BorderRadius.circular(size.widthPerc(2))),
          child: Icon(activeIcon, color: Theme.of(context).colorScheme.surface),
        ),
        label: label,
      );
    }
    return Theme(
      data: Theme.of(context).copyWith(
        splashFactory: NoSplash.splashFactory,
      ),
      child: BottomNavigationBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        currentIndex: currentIndex,
        onTap: onTap,
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Theme.of(context).textTheme.bodyMedium?.color,
        type: BottomNavigationBarType.fixed,
        items: [
          buildNavItem(
            inactiveIcon: Icons.home,
            activeIcon: Icons.home,
            label: "Home",
          ),
          buildNavItem(
            inactiveIcon: Icons.track_changes_rounded,
            activeIcon: Icons.track_changes_outlined,
            label: "Activity",
          ),
          buildNavItem(
            inactiveIcon: Icons.settings,
            activeIcon: Icons.settings,
            label: "Settings",
          ),
        ],
      ),
    );
  }
}
