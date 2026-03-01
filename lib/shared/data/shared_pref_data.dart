import 'package:shared_preferences/shared_preferences.dart';

class AppPref {
  static late SharedPreferences prefs;

  static Future<void> init() async {
    prefs = await SharedPreferences.getInstance();
  }

  static void setIsLogin(bool value) => prefs.setBool('isLogin', value);

  static bool getIsLogin() => prefs.getBool('isLogin') ?? false;

  static void setUid(String value) => prefs.setString('uid', value);

  static String getUid() => prefs.getString('uid') ?? '';

  static void setIsDarkTheme(bool value) => prefs.setBool('isDark', value);

  static void setInitMoney(String value) => prefs.setString('initMoney', value);

  static String getInitMoney() => prefs.getString('initMoney') ?? '0';

  static void setIsInitPeruse(bool value) => prefs.setBool('isInitPeruse', value);

  static bool getIsInitPeruse() => prefs.getBool('isInitPeruse') ?? false;

  static bool getIsDarkTheme() => prefs.getBool('isDark') ?? false;

  static Future<void> clearAll() async {
    await prefs.clear();
  }
}
