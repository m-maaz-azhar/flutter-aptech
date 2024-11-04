import 'package:firstapp/bottom_nav.dart';
import 'package:firstapp/login.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Auth extends StatefulWidget {
  const Auth({super.key});

  @override
  State<Auth> createState() => _AuthState();
}

class _AuthState extends State<Auth> {
  Future<bool> checkLoginState() async {
    SharedPreferences storage = await SharedPreferences.getInstance();
    String? isUser = storage.getString('user');

    return isUser != null;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: checkLoginState(),
        builder: (context, AsyncSnapshot<bool> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          } else if (snapshot.data == true) {
            return const BottomNav();
          } else {
            return const Login();
          }
        });
  }
}
