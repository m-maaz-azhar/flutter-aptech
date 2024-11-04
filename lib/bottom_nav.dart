import 'package:firebase_auth/firebase_auth.dart';
import 'package:firstapp/home.dart';
import 'package:firstapp/api_test.dart';
import 'package:firstapp/login.dart';
import 'package:firstapp/maps.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BottomNav extends StatefulWidget {
  const BottomNav({super.key});

  @override
  State<BottomNav> createState() => _BottomNavState();
}

class _BottomNavState extends State<BottomNav> {
  Future<void> logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();

    SharedPreferences storage = await SharedPreferences.getInstance();
    await storage.remove('user');

    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => const Login()));
  }

  int currentScreen = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: const Text('Todo App'),
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () => logout(context),
            )
          ]),

      body: <Widget>[
        const ApiTest(),
        const Home(),
        const Maps()
      ][currentScreen],

      bottomNavigationBar: BottomNavigationBar(
        onTap: (int screen) {
          setState(() {
            currentScreen = screen;
          });
        },
        currentIndex: currentScreen,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon:  Icon(Icons.home) , activeIcon: Icon(Icons.home_filled) , label: 'Home'),
          BottomNavigationBarItem(icon:  Icon(Icons.task_alt_outlined) , activeIcon: Icon(Icons.task) , label: 'Todo'),
          BottomNavigationBarItem(icon:  Icon(Icons.location_city_outlined) , activeIcon: Icon(Icons.location_city) , label: 'Maps')
        ],
      ),
      
    );
  }
}
