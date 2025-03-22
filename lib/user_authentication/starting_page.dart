import 'package:final_year_project/reusable_components/main_button.dart';

import 'package:final_year_project/user_authentication/login.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../services/google_authentication.dart';



class Startingpage extends StatefulWidget {
  final Function()? onTap;
  const Startingpage({super.key, required this.onTap});

  @override
  State<Startingpage> createState() => _StartingpageState();
}

class _StartingpageState extends State<Startingpage> {
  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Container(
        padding: EdgeInsets.zero,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 0),
            const Section1(),
            Section2(),
            SizedBox(
              height: 100,
              width: 450,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  MyMainButtons(
                    text: "Sign in with password",
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const Loginwithacc()),
                      );
                    },
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Text(
                        "Don't have an account? ",
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.black54,
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                      GestureDetector(
                        onTap: widget.onTap,
                        child: const Text(
                          'Sign up',
                          style: TextStyle(
                            color: Colors.blue,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Section1 extends StatelessWidget {
  const Section1({super.key});

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: 255,
      width: 450,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image(
            image: AssetImage('assets/images/logo ln.png'),
            height: 180,
            width: 220,
          ),
          SizedBox(height: 0),
          Text(
            "Welcome",
            style: TextStyle(
              color: Colors.black,
              fontSize: 40,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class Section2 extends StatelessWidget {
  Section2({super.key});
  final _auth = AuthService();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 250,
      width: 450,
      child: Column(
        children: [
          const SizedBox(height: 40),
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
          const SizedBox(height: 20),
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
          const SizedBox(height: 40),
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
                    'OR',
                    style: TextStyle(
                      color: Colors.grey,
                    ),
                  ),
                ),
                Expanded(
                  child: Divider(
                    thickness: 0.6,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
