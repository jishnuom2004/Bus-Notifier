import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:final_year_project/firebase_options.dart';
import 'package:final_year_project/navigation_files/auth_page.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';


import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  
  WidgetsFlutterBinding.ensureInitialized();
  
  await SharedPreferences.getInstance();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(fontFamily: 'Poppins'),
      home: const AuthPage(),
    );
  }
}