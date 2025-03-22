import 'package:final_year_project/user_authentication/create_account.dart';
import 'package:final_year_project/user_authentication/starting_page.dart';
import 'package:flutter/material.dart';

class LoginOrRegisterPage extends StatefulWidget {
  const LoginOrRegisterPage({super.key});

  @override
  State<LoginOrRegisterPage> createState() => _LoginOrRegisterPageState();
}

class _LoginOrRegisterPageState extends State<LoginOrRegisterPage> {
  bool _isLoginPage = true;

  void _togglePage() {
    setState(() {
      _isLoginPage = !_isLoginPage;
    });
  }

  @override
  Widget build(BuildContext context) {
    return _isLoginPage
        ? Startingpage(onTap: _togglePage)
        : Createaccount(onTap: _togglePage);
  }
}
//improved