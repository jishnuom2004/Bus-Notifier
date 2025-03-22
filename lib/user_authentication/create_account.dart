import 'package:final_year_project/basic_pages/home_page.dart';
import 'package:final_year_project/reusable_components/input_textfield.dart';
import 'package:final_year_project/reusable_components/main_button.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:final_year_project/services/google_authentication.dart';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';





class Createaccount extends StatefulWidget {
  final Function()? onTap;
  const Createaccount({super.key, required this.onTap});


  @override
  State<Createaccount> createState() => _CreateaccountState();
}

class _CreateaccountState extends State<Createaccount> {
  final signUpEmailController = TextEditingController();
  final signUpPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  final _auth = AuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 10,
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 90),
            const SizedBox(
              height: 130,
              width: 450,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 10.0),
                child: Text(
                  'Create your Account',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 35),
                ),
              ),
            ),
            SizedBox(
              height: 250,
              width: 350,
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    MyTextField(
                      label: 'Email',
                      icon: Icons.email,
                      obscureText: false,
                      controller: signUpEmailController,
                      validator: (value) {
                        if (value!.isEmpty || !value.contains('@')) {
                          return 'Invalid email';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 15),
                    MyTextField(
                      label: 'Password',
                      icon: Icons.lock,
                      obscureText: true,
                      controller: signUpPasswordController,
                      validator: (value) {
                        if (value!.length < 8) {
                          return 'Password must be at least 8 characters';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 15),
                    MyMainButtons(
                      text: "Signup",
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          signUserIn(context);
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
            Column(
              children: [
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 15.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Divider(
                          thickness: 0.6,
                          color: Colors.grey,
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8.0),
                        child: Text(
                          'Or continue with',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                      Expanded(
                        child: Divider(
                          thickness: 0.6,
                          color: Colors.grey,
                        ),
                      )
                    ],
                  ),
                ),
                const SizedBox(height: 25),
                OutlinedButton(
                  onPressed: () async {
                    await _auth.signInWithGoogle(context);
                  },
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.black, width: 1),
                    minimumSize: const Size(330, 50),
                    padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 7),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SvgPicture.asset('assets/icons/google.svg', height: 20, width: 20),
                      const SizedBox(width: 10),
                      const Text(
                        "Continue with Google",
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 15),
                OutlinedButton(
                  onPressed: () async {
                    await _auth.signInWithFacebook(context);
                  },
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.black, width: 1),
                    minimumSize: const Size(330, 50),
                    padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 7),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SvgPicture.asset('assets/icons/facebook.svg', height: 20, width: 20),
                      const SizedBox(width: 10),
                      const Text(
                        "Continue with Facebook",
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 15),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Already have an account?", style: TextStyle(fontSize: 14, color: Colors.grey)),
                    GestureDetector(
                      onTap: widget.onTap,
                      child: const Text(
                        'Login now',
                        style: TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ],
        ),
      ),
    );
  }

  void signUserIn(BuildContext context) async {
    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: signUpEmailController.text,
        password: signUpPasswordController.text,
      );
      showDialog(
        context: context,
        builder: (context) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      );
      if (context.mounted) {
        Navigator.pop(context);
      }
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomePage()),
      );
    } on FirebaseAuthException catch (e) {
      if (context.mounted) {
        Navigator.pop(context);
      }
      // show error (username and password don't match)
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message!)),
      );
    }
  }
}


