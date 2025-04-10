import 'package:flutter/material.dart';
import 'package:animated_notch_bottom_bar/animated_notch_bottom_bar/animated_notch_bottom_bar.dart';
class CustomBottomNavigationBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onTap;

  const CustomBottomNavigationBar({
    super.key,
    required this.selectedIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Controller to handle the selected index for AnimatedNotchBottomBar
    final NotchBottomBarController controller = NotchBottomBarController(index: selectedIndex);

    // Fetch theme colors
    final theme = Theme.of(context);
    final backgroundColor = theme.bottomNavigationBarTheme.backgroundColor ?? Colors.black;
    final selectedColor = theme.bottomNavigationBarTheme.selectedItemColor ?? Colors.white;
    final unselectedColor = theme.bottomNavigationBarTheme.unselectedItemColor ?? Colors.grey[600]!;

    return AnimatedNotchBottomBar(
      notchBottomBarController: controller,
      color: backgroundColor, // Background color of the bar
      notchColor: backgroundColor, // Notch color (same as background for seamless look)
      showLabel: false, // Hide the labels
      kIconSize: 24.0, // Icon size
      bottomBarItems: [
        BottomBarItem(
          inActiveItem: Icon(
            Icons.home,
            color: unselectedColor,
          ),
          activeItem: Icon(
            Icons.home,
            color: selectedColor,
          ),
          itemLabel: '',
        ),
        BottomBarItem(
          inActiveItem: Icon(
            Icons.search,
            color: unselectedColor,
          ),
          activeItem: Icon(
            Icons.search,
            color: selectedColor,
          ),
          itemLabel: '',
        ),
        BottomBarItem(
          inActiveItem: Icon(
            Icons.favorite,
            color: unselectedColor,
          ),
          activeItem: Icon(
            Icons.favorite,
            color: selectedColor,
          ),
          itemLabel: '',
        ),
      ],
      onTap: (index) {
        onTap(index); // Call the provided onTap callback to update the selected index
      },
      durationInMilliSeconds: 300, // Animation duration
      kBottomRadius: 20.0, // Match the border radius of your original design
      showShadow: true,
      shadowElevation: 10,
      elevation: 2.0,
    );
  }
}
