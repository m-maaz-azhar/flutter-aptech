import 'package:firstapp/signup.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firstapp/home.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final TextEditingController email = TextEditingController();
  final TextEditingController password = TextEditingController();

  Future<void> signin(BuildContext context) async {
    try {
      UserCredential user = await FirebaseAuth.instance
          .signInWithEmailAndPassword(
              email: email.text, password: password.text);

      SharedPreferences storage = await SharedPreferences.getInstance();

      await storage.setString("user", user.user!.uid);

      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const Home()));

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e")));
    }
  }

  void gotoSignUp(){
     Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const Signup()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text("Email"),
            TextField(
              decoration: const InputDecoration(hintText: 'Please Enter Email'),
              controller: email,
            ),
            const SizedBox(
              height: 20,
            ),
            const Text("Password"),
            TextField(
              controller: password,
              decoration: const InputDecoration(hintText: 'Please Enter Password'),
              obscureText: true,
            ),
            const SizedBox(
              height: 20,
            ),
            const SizedBox(
              height: 20,
            ),
            ElevatedButton(
                onPressed: () async {
                  await signin(context);
                },
                child: const Text("Login")),
            TextButton(onPressed: gotoSignUp, child: const Text("Sign up"))
          ],
        ),
      ),
    );
  }
}
