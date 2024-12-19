// NEW FILE: lib/services/account_service.dart
// This service class encapsulates logic for loading and saving user profile data
// to SharedPreferences, following OOP and encapsulation principles.

import 'package:shared_preferences/shared_preferences.dart';

class UserProfileData {
  final String? username;
  final int? age;
  final String? gender;
  final String? lifestyle;
  final String? avatarPath;
  final int? klooicash;

  const UserProfileData({
    this.username,
    this.age,
    this.gender,
    this.lifestyle,
    this.avatarPath,
    this.klooicash,
  });
}

class AccountService {
  static const _keyUsername = 'username';
  static const _keyAge = 'age';
  static const _keyGender = 'gender';
  static const _keyLifestyle = 'lifestyle';
  static const _keyAvatar = 'avatarImagePath';
  static const _klooicash = 'klooicash';

  static Future<UserProfileData> loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    return UserProfileData(
      username: prefs.getString(_keyUsername),
      age: prefs.getInt(_keyAge),
      gender: prefs.getString(_keyGender),
      lifestyle: prefs.getString(_keyLifestyle),
      avatarPath: prefs.getString(_keyAvatar),
      klooicash: prefs.getInt(_klooicash)
    );
  }

  static Future<void> saveUserData({
    required String username,
    int? age,
    String? gender,
    String? lifestyle,
    String? avatarPath,
    int? klooicash,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyUsername, username);
    if (age != null) {
      await prefs.setInt(_keyAge, age);
    } else {
      await prefs.remove(_keyAge);
    }

    if (gender != null && gender.isNotEmpty) {
      await prefs.setString(_keyGender, gender);
    } else {
      await prefs.remove(_keyGender);
    }

    if (lifestyle != null && lifestyle.isNotEmpty) {
      await prefs.setString(_keyLifestyle, lifestyle);
    } else {
      await prefs.remove(_keyLifestyle);
    }

    if (avatarPath != null && avatarPath.isNotEmpty) {
      await prefs.setString(_keyAvatar, avatarPath);
    } else {
      await prefs.remove(_keyAvatar);
    }
  }
}
