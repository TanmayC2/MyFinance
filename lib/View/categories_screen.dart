import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_finance1/View/drawer.dart';
import "package:my_finance1/Contoller/categorycontrollergetx.dart";
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

class Categories extends StatefulWidget {
  const Categories({super.key});

  @override
  State<Categories> createState() => _CategoriesState();
}

class _CategoriesState extends State<Categories> with TickerProviderStateMixin {
  final CategoryController categoryController = Get.put(CategoryController());
  final TextEditingController categoryNameController = TextEditingController();
  final TextEditingController categoryColorController = TextEditingController();

  late AnimationController _fabAnimationController;
  late Animation<double> _fabAnimation;

  final Map<String, Color> colorOptions = {
    'Red': Colors.red,
    'Blue': Colors.blue,
    'Green': Colors.green,
    'Yellow': Colors.yellow,
    'Orange': Colors.orange,
    'Purple': Colors.purple,
    'Pink': Colors.pink,
    'Teal': Colors.teal,
  };

  final Rx<Color> selectedColor = Colors.blue.obs;

  @override
  void initState() {
    super.initState();
    categoryController.fetchCategories();

    _fabAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _fabAnimation = CurvedAnimation(
      parent: _fabAnimationController,
      curve: Curves.easeInOut,
    );

    _fabAnimationController.forward();
  }

  @override
  void dispose() {
    categoryNameController.dispose();
    categoryColorController.dispose();
    _fabAnimationController.dispose();
    super.dispose();
  }

  void modalBottomSheet(BuildContext context) {
    categoryNameController.clear();
    categoryController.selectedFile.value = null;
    selectedColor.value = Colors.blue;

    showModalBottomSheet(
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30.0),
          topRight: Radius.circular(30.0),
        ),
      ),
      isDismissible: true,
      context: context,
      builder: (context) {
        return Obx(() {
          return SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: AnimationConfiguration.synchronized(
                duration: const Duration(milliseconds: 500),
                child: SlideAnimation(
                  verticalOffset: 50.0,
                  child: FadeInAnimation(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(height: 10),
                        Container(
                          width: 50,
                          height: 5,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(5),
                          ),
                        ),
                        const SizedBox(height: 20),
                        const Icon(
                          Icons.category,
                          size: 50,
                          color: Colors.green,
                        ),
                        const SizedBox(height: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              "Select Image",
                              style: GoogleFonts.quicksand(
                                color: Colors.black,
                                fontWeight: FontWeight.w600,
                                fontSize: 15,
                              ),
                            ),
                            const SizedBox(height: 8),
                            GestureDetector(
                              onTap: () async {
                                categoryController.pickImage();
                              },
                              child: Center(
                                child: Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.grey),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.image),
                                      const SizedBox(width: 15),
                                      Text(
                                        (categoryController
                                                    .selectedFile
                                                    .value ==
                                                null)
                                            ? "Pick Image"
                                            : "Selected Category Image",
                                        style: GoogleFonts.quicksand(
                                          color:
                                              (categoryController
                                                          .selectedFile
                                                          .value ==
                                                      null)
                                                  ? Colors.black
                                                  : Colors.green,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 15,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              "Category",
                              style: GoogleFonts.quicksand(
                                color: Colors.black,
                                fontWeight: FontWeight.w600,
                                fontSize: 15,
                              ),
                            ),
                            const SizedBox(height: 3),
                            TextField(
                              controller: categoryNameController,
                              keyboardType: TextInputType.name,
                              decoration: InputDecoration(
                                hintText: "Enter category name",
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(
                                    color: Colors.black,
                                    width: 0.5,
                                  ),
                                ),
                                border: OutlineInputBorder(
                                  borderSide: const BorderSide(
                                    color: Colors.black,
                                    width: 0.5,
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              "Choose Color",
                              style: GoogleFonts.quicksand(
                                color: Colors.black,
                                fontWeight: FontWeight.w600,
                                fontSize: 15,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Obx(
                              () => DropdownButtonFormField<Color>(
                                decoration: InputDecoration(
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(
                                      color: Colors.black,
                                      width: 0.5,
                                    ),
                                  ),
                                  border: OutlineInputBorder(
                                    borderSide: const BorderSide(
                                      color: Colors.black,
                                      width: 0.5,
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                value: selectedColor.value,
                                onChanged: (Color? newValue) {
                                  if (newValue != null) {
                                    selectedColor.value = newValue;
                                    categoryColorController.text =
                                        newValue.toString();
                                  }
                                },
                                items:
                                    colorOptions.entries.map((entry) {
                                      return DropdownMenuItem<Color>(
                                        value: entry.value,
                                        child: Row(
                                          children: [
                                            Container(
                                              width: 20,
                                              height: 20,
                                              decoration: BoxDecoration(
                                                color: entry.value,
                                                shape: BoxShape.circle,
                                                border: Border.all(
                                                  color: Colors.black,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 10),
                                            Text(
                                              entry.key,
                                              style: GoogleFonts.quicksand(
                                                fontSize: 14,
                                                color: Colors.black87,
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    }).toList(),
                              ),
                            ),
                            const SizedBox(height: 20),
                            Center(
                              child: Container(
                                height: 50,
                                width: 150,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    backgroundColor: Colors.green,
                                    elevation: 3,
                                  ),
                                  onPressed: () async {
                                    if (categoryNameController
                                            .text
                                            .isNotEmpty &&
                                        categoryController.selectedFile.value !=
                                            null) {
                                      final categoryName =
                                          categoryNameController.text.trim();
                                      final selectedFile =
                                          categoryController
                                              .selectedFile
                                              .value!;
                                      final String fileName =
                                          '${selectedFile.name}_${DateTime.now().millisecondsSinceEpoch}';

                                      Get.dialog(
                                        const Center(
                                          child: CircularProgressIndicator(),
                                        ),
                                        barrierDismissible: false,
                                      );

                                      try {
                                        bool exists = await categoryController
                                            .categoryExists(categoryName);

                                        Get.back();

                                        if (exists) {
                                          Get.snackbar(
                                            'Duplicate Error',
                                            'A category with this name already exists',
                                            snackPosition: SnackPosition.BOTTOM,
                                            backgroundColor: Colors.red[100],
                                            colorText: Colors.red[800],
                                            borderRadius: 10,
                                            margin: const EdgeInsets.all(15),
                                          );
                                          return;
                                        }
                                        await categoryController.uploadImage(
                                          fileName: fileName,
                                        );

                                        final url = await categoryController
                                            .downloadImageURL(
                                              fileName: fileName,
                                            );

                                        final int nextId =
                                            await categoryController
                                                .getNextCategoryId();
                                        final String firebaseDocId =
                                            'category_$nextId';

                                        await categoryController
                                            .addCategoryToFirebase(
                                              categoryId: firebaseDocId,
                                              context: context,
                                              imageUrl: url,
                                              name:
                                                  categoryNameController.text
                                                      .trim(),
                                              color:
                                                  colorOptions.entries
                                                      .firstWhere(
                                                        (entry) =>
                                                            entry.value ==
                                                            selectedColor.value,
                                                      )
                                                      .key,
                                            );

                                        Get.back();

                                        Get.snackbar(
                                          'Success',
                                          'Category added successfully',
                                          snackPosition: SnackPosition.BOTTOM,
                                          backgroundColor: Colors.green[100],
                                          colorText: Colors.green[800],
                                          borderRadius: 10,
                                          margin: const EdgeInsets.all(15),
                                          duration: const Duration(seconds: 2),
                                        );

                                        Navigator.pop(context);
                                      } catch (e) {
                                        Get.back();

                                        Get.snackbar(
                                          'Error',
                                          'Failed to add category: $e',
                                          snackPosition: SnackPosition.BOTTOM,
                                          backgroundColor: Colors.red[100],
                                          colorText: Colors.red[800],
                                          borderRadius: 10,
                                          margin: const EdgeInsets.all(15),
                                        );
                                      }
                                    } else {
                                      Get.snackbar(
                                        'Validation Error',
                                        'Please fill all the fields',
                                        snackPosition: SnackPosition.BOTTOM,
                                        backgroundColor: Colors.amber[100],
                                        colorText: Colors.amber[800],
                                        borderRadius: 10,
                                        margin: const EdgeInsets.all(15),
                                      );
                                    }
                                  },
                                  child: Text(
                                    "Add",
                                    style: GoogleFonts.inter(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 20,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 30),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        });
      },
    );
  }

  Future<dynamic> showDeleteDialog(String id) async {
    return await showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: const Color.fromRGBO(0, 0, 0, 0.2),
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            "Delete Category",
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          content: Text(
            "Are you sure you want to delete the selected category?",
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w400,
            ),
          ),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  style: const ButtonStyle(
                    backgroundColor: WidgetStatePropertyAll(
                      Color.fromRGBO(14, 161, 125, 1),
                    ),
                    shape: WidgetStatePropertyAll(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(20)),
                      ),
                    ),
                  ),
                  onPressed: () async {
                    // Show loading indicator
                    Get.dialog(
                      const Center(child: CircularProgressIndicator()),
                      barrierDismissible: false,
                    );

                    // Delete category
                    await categoryController.deleteCategory(id);
                    //  await categoryControllerSQ.deleteCategory(id);

                    // Close loading dialog
                    Get.back();

                    Get.snackbar(
                      'Success',
                      'Category deleted successfully',
                      snackPosition: SnackPosition.BOTTOM,
                      backgroundColor: Colors.green[100],
                      colorText: Colors.green[800],
                      borderRadius: 10,
                      margin: const EdgeInsets.all(15),
                      duration: const Duration(seconds: 2),
                    );

                    Navigator.of(context).pop();
                  },
                  child: Center(
                    child: Text(
                      "Delete",
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                ElevatedButton(
                  style: const ButtonStyle(
                    backgroundColor: WidgetStatePropertyAll(
                      Color.fromRGBO(140, 128, 128, 0.2),
                    ),
                    shape: WidgetStatePropertyAll(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(20)),
                      ),
                    ),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Center(
                    child: Text(
                      "Cancel",
                      style: GoogleFonts.poppins(
                        color: Colors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: CustomDrawer(),
      appBar: AppBar(
        elevation: 0,
        title: Text(
          "Categories",
          style: GoogleFonts.poppins(
            textStyle: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 18,
              color: Colors.black,
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              categoryController.fetchCategories();

              Get.snackbar(
                'Refreshing',
                'Updating categories...',
                snackPosition: SnackPosition.TOP,
                backgroundColor: Colors.blue[100],
                colorText: Colors.blue[800],
                borderRadius: 10,
                margin: const EdgeInsets.all(15),
                duration: const Duration(seconds: 1),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey,
                    spreadRadius: 1,
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                decoration: InputDecoration(
                  hintText: "Search categories...",
                  prefixIcon: const Icon(Icons.search),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.all(15),
                  hintStyle: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.grey[500],
                  ),
                ),
                onChanged: (value) {},
              ),
            ),
          ),
          const SizedBox(height: 20),
          Obx(() {
            if (categoryController.categoryList.isEmpty) {
              return Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.category_outlined,
                        size: 70,
                        color: Colors.grey,
                      ),
                      const SizedBox(height: 15),
                      Text(
                        "No categories found",
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          color: Colors.grey[700],
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        "Add a category to get started",
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            return Expanded(
              child: AnimationLimiter(
                child: GridView.builder(
                  shrinkWrap: true,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 15,
                    crossAxisSpacing: 15,
                    childAspectRatio: 0.85,
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: categoryController.categoryList.length,
                  itemBuilder: (context, index) {
                    final category = categoryController.categoryList[index];
                    return AnimationConfiguration.staggeredGrid(
                      position: index,
                      duration: const Duration(milliseconds: 500),
                      columnCount: 2,
                      child: ScaleAnimation(
                        child: FadeInAnimation(
                          child: GestureDetector(
                            onTap: () {
                              showDeleteDialog(category.id);
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(15),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey,
                                    spreadRadius: 1,
                                    blurRadius: 8,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(15),
                                child: Stack(
                                  children: [
                                    Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Expanded(
                                          child: Padding(
                                            padding: const EdgeInsets.all(15.0),
                                            child:
                                                category
                                                        .categoryImageUrl
                                                        .isNotEmpty
                                                    ? Hero(
                                                      tag:
                                                          'category_${category.id}',
                                                      child: Image.network(
                                                        category
                                                            .categoryImageUrl,
                                                        fit: BoxFit.contain,
                                                        errorBuilder: (
                                                          context,
                                                          error,
                                                          stackTrace,
                                                        ) {
                                                          return const Icon(
                                                            Icons
                                                                .image_not_supported,
                                                            size: 50,
                                                            color: Colors.grey,
                                                          );
                                                        },
                                                      ),
                                                    )
                                                    : const Icon(
                                                      Icons.category,
                                                      size: 50,
                                                      color: Colors.grey,
                                                    ),
                                          ),
                                        ),
                                        Container(
                                          width: double.infinity,
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 12,
                                          ),
                                          decoration: BoxDecoration(
                                            color: _getCategoryColor(
                                              category.color,
                                            ),
                                            borderRadius:
                                                const BorderRadius.only(
                                                  bottomLeft: Radius.circular(
                                                    15,
                                                  ),
                                                  bottomRight: Radius.circular(
                                                    15,
                                                  ),
                                                ),
                                          ),
                                          child: Text(
                                            category.name ?? 'Category Name',
                                            textAlign: TextAlign.center,
                                            style: GoogleFonts.poppins(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500,
                                              color: Colors.white,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Positioned(
                                      top: 5,
                                      right: 5,
                                      child: Container(
                                        padding: const EdgeInsets.all(4),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          Icons.more_horiz,
                                          size: 16,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            );
          }),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: ScaleTransition(
        scale: _fabAnimation,
        child: FloatingActionButton.extended(
          backgroundColor: Colors.green,
          elevation: 4,
          onPressed: () {
            modalBottomSheet(context);
          },
          icon: const Icon(
            Icons.add_circle_rounded,
            color: Colors.white,
            size: 30,
          ),
          label: Text(
            "Add Category",
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  Color _getCategoryColor(String? colorName) {
    if (colorName == null) return Colors.blue;

    switch (colorName.toLowerCase()) {
      case 'red':
        return Colors.red;
      case 'blue':
        return Colors.blue;
      case 'green':
        return Colors.green;
      case 'yellow':
        return Colors.yellow;
      case 'orange':
        return Colors.orange;
      case 'purple':
        return Colors.purple;
      case 'pink':
        return Colors.pink;
      case 'teal':
        return Colors.teal;
      default:
        return Colors.blue;
    }
  }
}
