import 'package:final_year_project/navigation_files/login_or_register.dart';
import 'package:final_year_project/navigation_files/navigator.dart';
import 'package:flutter/material.dart';


import 'package:firebase_auth/firebase_auth.dart';

class AuthPage extends StatelessWidget{
  const AuthPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return const NavigatorMangement();//it should be the mainscreen after auth sucessful
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          } else {
            return const LoginOrRegisterPage();
          }
        },
      ),
    );
  }
}