import 'dart:developer';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:my_finance1/Model/categorymodelgetx.dart';
import 'package:my_finance1/customwidget.dart';
import 'package:my_finance1/Contoller/databaseconn/dbhelper.dart';

class CategoryController extends GetxController {
  RxList<CategoryModal> categoryList = <CategoryModal>[].obs;
  final Rx<XFile?> selectedFile = Rx<XFile?>(null);
  final ImagePicker _imagePicker = ImagePicker();

  XFile? getterSelectedFile() => selectedFile.value;

  @override
  void onInit() {
    super.onInit();
    fetchCategories();
  }

  Future<void> pickImage() async {
    final pickedFile = await _imagePicker.pickImage(
      source: ImageSource.gallery,
    );
    if (pickedFile != null) {
      selectedFile.value = pickedFile;
      log("Selected File: ${selectedFile.value!.path}");
    }
  }

  // Get next ID from counter document
  Future<int> getNextCategoryId() async {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;

    // Use a transaction to ensure atomicity
    return firestore
        .runTransaction<int>((transaction) async {
          // Get the counter document
          DocumentReference counterRef = firestore
              .collection('counters')
              .doc('categoryCounter');
          DocumentSnapshot counterSnapshot = await transaction.get(counterRef);

          int nextId = 1; // Default start value

          // If counter document exists, increment its value
          if (counterSnapshot.exists) {
            nextId =
                (counterSnapshot.data() as Map<String, dynamic>)['lastId'] + 1;
          }

          // Update the counter with the new value
          transaction.set(counterRef, {
            'lastId': nextId,
          }, SetOptions(merge: true));

          return nextId;
        })
        .catchError((error) {
          log("Error getting next ID: $error");
          throw Exception("Failed to generate ID: $error");
        });
  }

  Future<bool> categoryExists(String categoryName) async {
    try {
      // Query Firestore to check if a category with the same name exists
      final QuerySnapshot result =
          await FirebaseFirestore.instance
              .collection("CategoryDetails")
              .where('name', isEqualTo: categoryName)
              .limit(1)
              .get();

      // If there's at least one document with this name, return true
      return result.docs.isNotEmpty;
    } catch (e) {
      log("Error checking for duplicate category: $e");
      // In case of error, return false to allow the operation to procee
      return false;
    }
  }

  // Operation 1: Upload Image to Firebase Storage
  Future<void> uploadImage({required String fileName}) async {
    log("ADD IMAGE TO FIREBASE");
    try {
      final Reference storageReference = FirebaseStorage.instance.ref().child(
        'categories/$fileName',
      );
      final UploadTask uploadTask = storageReference.putFile(
        File(selectedFile.value!.path),
      );

      // Monitor upload progress
      uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
        log(
          'Upload progress: ${(snapshot.bytesTransferred / snapshot.totalBytes) * 100}%',
        );
      });
      await uploadTask.whenComplete(() => log('Image uploaded!'));
    } catch (e) {
      log("Error uploading image: $e");
      throw Exception("Failed to upload image: $e");
    }
  }

  // Operation 2: Download Image URL from Firebase Storage
  Future<String> downloadImageURL({required String fileName}) async {
    log("GET URL FROM FIREBASE");
    try {
      final String url =
          await FirebaseStorage.instance
              .ref()
              .child('categories/$fileName')
              .getDownloadURL();

      log("Download URL: $url");
      return url;
    } catch (e) {
      log("Error getting download URL: $e");
      throw Exception("Failed to get download URL: $e");
    }
  }

  // Category CRUD Operations
  Future<void> addCategoryToFirebase({
    required String name,
    required String color,
    required categoryId,
    required BuildContext context,
    String? imageUrl, // Optional if you want to allow pre-uploaded images
  }) async {
    log("Adding category data to Firestore...");
    try {
      final int numericId = int.parse(
        categoryId.split('_')[1],
      ); // Create category data
      final categoryData = {
        'categoryImageUrl': imageUrl,
        'viewCount': 0,
        'name': name,
        'color': color, // Store as hex string
        'categoryId': numericId, // Store numeric ID for sorting or queries
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      // Add to Firestore with custom document ID
      await FirebaseFirestore.instance
          .collection("CategoryDetails")
          .doc(categoryId)
          .set(categoryData);

      // Update local state
      fetchCategories();

      // Show success feedback
      if (context.mounted) {
        CustomSnackbar.showCustomSnackbar(
          message: "Category added successfully",
          context: context,
        );
      }
    } catch (e) {
      log("Error adding category: $e");

      if (context.mounted) {
        CustomSnackbar.showCustomSnackbar(
          message: "Error adding category: ${e.toString()}",
          context: context,
        );
      }
    }
  }

  Future<void> fetchCategories() async {
    // Clear list

    try {
      QuerySnapshot response =
          await FirebaseFirestore.instance
              .collection("CategoryDetails")
              .orderBy(
                'categoryId',
                descending: true,
              ) // Order by numeric ID instead
              .get();
      categoryList.clear();
      for (var value in response.docs) {
        final data = value.data() as Map<String, dynamic>;
        categoryList.add(
          CategoryModal(
            categoryImageUrl: data['categoryImageUrl'] ?? '',
            name: data['name'] ?? 'Unnamed Category',
            color: data['color'] ?? '',
            id: value.id,
            viewCount: data['viewCount'] ?? 0,
            categoryId: data['categoryId'] ?? 0,
          ),
        );
        //can add data here to list of category
      }
      log("LENGTH OF CATEGORIES LIST: ${categoryList.length}");
    } catch (e) {
      log("Error fetching categories: $e");
      Get.snackbar(
        'Error',
        'Failed to load categories: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> deleteCategory(String categoryId) async {
    try {
      await FirebaseFirestore.instance
          .collection("CategoryDetails")
          .doc(categoryId)
          .delete();

      fetchCategories();
      Get.snackbar(
        'Success',
        'Category deleted successfully!',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to delete category: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> incrementViews(String categoryId) async {
    try {
      await FirebaseFirestore.instance
          .collection('CategoryDetails')
          .doc(categoryId)
          .update({'viewCount': FieldValue.increment(1)});

      // Optionally refresh the list to show updated count
      fetchCategories();
    } catch (e) {
      log("Error incrementing views: $e");
    }
  }
}

// //SQFLITE OPERATIONS Related to Categories

// class CategoryControllerSQ extends GetxController {
//   final RxList<CategorySQ> categoriesSQ = <CategorySQ>[].obs;

//   // Selected category tracking (optional, similar to selectedType)
//   Rx<String> selectedCategoryName = ''.obs;

//   final DatabaseHelper _dbHelper = DatabaseHelper.instance;

//   setSelectedCategory(String categoryName) {
//     selectedCategoryName.value = categoryName;
//     update();
//     return selectedCategoryName.value;
//   }

//   bool isCategorySelected(String categoryName) {
//     return selectedCategoryName.value == categoryName;
//   }

//   // Fetch all categories
//   Future<void> fetchCategories() async {
//     try {
//       final fetchedCategories = await _dbHelper.getCategoriesSQ();

//       categoriesSQ.assignAll(fetchedCategories);
//     } catch (e) {
//       log('Error fetching categories: $e');
//       categoriesSQ.clear();
//     }
//   }

//   // Add new category
//   Future<void> addCategory(CategorySQ category) async {
//     try {
//       await _dbHelper.insertCategorySQ(category);
//       await fetchCategories();
//     } catch (e) {
//       log('Error adding category: $e');
//     }
//   }

//   // Delete category
//   Future<void> deleteCategory(String firebaseid) async {
//     try {
//       await _dbHelper.deleteCategorySQ(firebaseid);
//       await fetchCategories();
//     } catch (e) {
//       log('Error deleting category: $e');
//     }
//   }

//   @override
//   void onInit() {
//     super.onInit();
//     fetchCategories();
//   }
// }
