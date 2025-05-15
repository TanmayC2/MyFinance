//Category For FireBase and Storage
import 'dart:developer';

class CategoryModal {
  final String id; // Unique ID for the category
  final String
  name; // Category name (e.g., "Food", "Transportation", "Utilities")
  final String color; // hex color of the category.
  final String categoryImageUrl;
  int? categoryId;
  int? viewCount;

  CategoryModal({
    categoryId,
    viewCount,
    required this.id,
    required this.name,
    required this.color,
    required this.categoryImageUrl,
  });

  get type => null;

  @override
  String toString() {
    return 'CategoryModal{id: $id, name: $name, color: $color,categoryImageUrl:$categoryImageUrl,categoryId:$categoryId,viewCount:$viewCount}';
  }
}

class CategorySQ {
  final String
  name; // Category name (e.g., "Food", "Transportation", "Utilities")
  final String color; // hex color of the category.
  final String categoryImageUrl;
  int? idSQ;
  final String firebaseid;

  CategorySQ({
    this.idSQ,
    required this.firebaseid,
    required this.name,
    required this.color,
    required this.categoryImageUrl,
  });

  //Why Required To convert data into Map to Store
  Map<String, dynamic> toMap() {
    log("in CategorySQ Model");
    return {
      'idSQ': idSQ,
      'name': name,
      'color': color,
      'categoryImageUrl': categoryImageUrl,
      'firebaseid': firebaseid,
    };
  }

  @override
  String toString() {
    return 'CategorySQFLITE{idSQ:$idSQ name: $name, color: $color,categoryImageUrl:$categoryImageUrl,firebaseid:$firebaseid}';
  }
}
