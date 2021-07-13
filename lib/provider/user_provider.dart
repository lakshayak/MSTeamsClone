import 'package:flutter/widgets.dart';
import 'package:teams_clone/models/user.dart';
import 'package:teams_clone/resources/auth_methods.dart';

// To access user details
class UserProvider with ChangeNotifier {
  User? _user;
  AuthMethods _authMethods = AuthMethods();

  // Refreshes if a user changes any user details --> Eg: Profile Picture
  Future<void> refreshUser() async {
    User user = await _authMethods.getUserDetails();
    _user = user;
    notifyListeners();
  }
  User? get getUser => _user;

}