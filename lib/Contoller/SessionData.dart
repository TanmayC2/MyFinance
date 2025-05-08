// import 'dart:developer';

// import 'package:shared_preferences/shared_preferences.dart';

// class SessionData {
//   static bool? isLogin;
//   static String? emailId;

//   // Method to get session data (keep your existing method)
//   static Future<void> getSessionData() async {
//     try {
//       SharedPreferences prefs = await SharedPreferences.getInstance();
//       isLogin = prefs.getBool("isLogin") ?? false;
//       emailId = prefs.getString("emailId") ?? "";
//       log("SESSION DATA: isLogin=$isLogin, emailId=$emailId");
//     } catch (e) {
//       log("Error getting session data: $e");
//       isLogin = false;
//       emailId = "";
//     }
//   }

//   // Store session data for login (keep your existing method if you have one)
//   static Future<void> storeSessionData({
//     required bool loginData,
//     required String emailId,
//   }) async {
//     try {
//       SharedPreferences prefs = await SharedPreferences.getInstance();
//       await prefs.setBool('isLogin', loginData);
//       await prefs.setString('emailId', emailId);

//       // Update in-memory values
//       SessionData.isLogin = loginData;
//       SessionData.emailId = emailId;

//       log("STORED SESSION DATA: isLogin=$loginData, emailId=$emailId");
//     } catch (e) {
//       log("Error storing session data: $e");
//     }
//   }

//   // Clear login session data (for logout)
//   static Future<void> clearLoginData() async {
//     try {
//       SharedPreferences prefs = await SharedPreferences.getInstance();
//       await prefs.setBool('isLogin', false);
//       await prefs.setString('emailId', "");

//       // Keep onboarding status intact
//       SessionData.isLogin = false;
//       SessionData.emailId = "";

//       log("CLEARED LOGIN DATA");
//     } catch (e) {
//       log("Error clearing login data: $e");
//     }
//   }

//   // Generic methods for storing/retrieving various data types
//   static Future<void> setBool(String key, bool value) async {
//     try {
//       SharedPreferences prefs = await SharedPreferences.getInstance();
//       await prefs.setBool(key, value);
//       log("SET BOOL: $key=$value");
//     } catch (e) {
//       log("Error setting bool $key: $e");
//     }
//   }

//   static Future<bool?> getBool(String key) async {
//     try {
//       SharedPreferences prefs = await SharedPreferences.getInstance();
//       final value = prefs.getBool(key);
//       log("GET BOOL: $key=$value");
//       return value;
//     } catch (e) {
//       log("Error getting bool $key: $e");
//       return null;
//     }
//   }

//   static Future<void> setString(String key, String value) async {
//     try {
//       SharedPreferences prefs = await SharedPreferences.getInstance();
//       await prefs.setString(key, value);
//       log("SET STRING: $key=$value");
//     } catch (e) {
//       log("Error setting string $key: $e");
//     }
//   }

//   static Future<String?> getString(String key) async {
//     try {
//       SharedPreferences prefs = await SharedPreferences.getInstance();
//       final value = prefs.getString(key);
//       log("GET STRING: $key=$value");
//       return value;
//     } catch (e) {
//       log("Error getting string $key: $e");
//       return null;
//     }
//   }
// }
import 'dart:developer';
import 'package:shared_preferences/shared_preferences.dart';

class SessionData {
  // Keys for shared preferences (all in one place for easy maintenance)
  static const String _isLoginKey = 'isLogin';
  static const String _emailIdKey = 'emailId';

  // Session state variables
  static bool? isLogin;
  static String? emailId;

  // Initialize session data (call this at app startup)
  static Future<void> initialize() async {
    await getSessionData();
  }

  // Get session data
  static Future<void> getSessionData() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      isLogin = prefs.getBool(_isLoginKey) ?? false;
      emailId = prefs.getString(_emailIdKey) ?? "";
      log("SESSION DATA: isLogin=$isLogin, emailId=$emailId");
    } catch (e) {
      log("Error getting session data: $e");
      _resetSessionData();
    }
  }

  // Store session data for login
  static Future<void> storeSessionData({
    required bool loginData,
    required String emailId,
  }) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await Future.wait([
        prefs.setBool(_isLoginKey, loginData),
        prefs.setString(_emailIdKey, emailId),
      ]);

      // Update in-memory values
      SessionData.isLogin = loginData;
      SessionData.emailId = emailId;

      log("STORED SESSION DATA: isLogin=$loginData, emailId=$emailId");
    } catch (e) {
      log("Error storing session data: $e");
      _resetSessionData();
    }
  }

  // Clear login session data (for logout)
  static Future<void> clearLoginData() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await Future.wait([
        prefs.setBool(_isLoginKey, false),
        prefs.setString(_emailIdKey, ""),
      ]);

      _resetSessionData();
      log("CLEARED LOGIN DATA");
    } catch (e) {
      log("Error clearing login data: $e");
    }
  }

  // Reset in-memory session data
  static void _resetSessionData() {
    isLogin = false;
    emailId = "";
  }

  // Generic preference methods with consistent key handling
  static Future<void> setBool(String key, bool value) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setBool(key, value);
      log("SET BOOL: $key=$value");
    } catch (e) {
      log("Error setting bool $key: $e");
    }
  }

  static Future<bool?> getBool(String key) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final value = prefs.getBool(key);
      log("GET BOOL: $key=$value");
      return value;
    } catch (e) {
      log("Error getting bool $key: $e");
      return null;
    }
  }

  static Future<void> setString(String key, String value) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString(key, value);
      log("SET STRING: $key=$value");
    } catch (e) {
      log("Error setting string $key: $e");
    }
  }

  static Future<String?> getString(String key) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final value = prefs.getString(key);
      log("GET STRING: $key=$value");
      return value;
    } catch (e) {
      log("Error getting string $key: $e");
      return null;
    }
  }

  // Check if user is logged in (convenience method)
  static Future<bool> isUserLoggedIn() async {
    if (isLogin == null) {
      await getSessionData();
    }
    return isLogin ?? false;
  }
}
