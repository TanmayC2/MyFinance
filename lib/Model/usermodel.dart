import 'package:flutter/material.dart';

class UserInfo extends InheritedWidget {
  final UserModel obj;
  const UserInfo({super.key, required this.obj, required super.child});

  @override
  bool updateShouldNotify(UserInfo oldWidget) {
    return obj != oldWidget.obj;
  }

  static UserInfo? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<UserInfo>();
  }
}

class UserModel {
  final String username;
  final String email;
  final int userId;

  const UserModel({
    required this.username,
    required this.email,
    required this.userId,
  });
}
