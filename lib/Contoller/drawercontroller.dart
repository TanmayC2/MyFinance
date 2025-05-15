import 'package:get/get.dart';

class DrawerControllerDemo extends GetxController {
  // Observable for selected index
  final RxInt selectedIndex = 1.obs; // Default to "Transactions"

  // Observable for hover index
  final RxInt hoveredIndex = 0.obs;

  // Update the selected index
  void setSelectedIndex(int index) {
    selectedIndex.value = index;
  }

  // Update the hovered index
  void setHoveredIndex(int index) {
    hoveredIndex.value = index;
  }

  // Reset the hovered index when mouse leaves
  void resetHoveredIndex() {
    hoveredIndex.value = 0;
  }

  // Check if an item is selected
  bool isSelected(int index) {
    return selectedIndex.value == index;
  }

  // Check if an item is hovered
  bool isHovered(int index) {
    return hoveredIndex.value == index;
  }
}
