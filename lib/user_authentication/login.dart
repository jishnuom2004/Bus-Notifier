import 'package:final_year_project/basic_pages/home_page.dart';
import 'package:final_year_project/reusable_components/input_textfield.dart';
import 'package:final_year_project/reusable_components/main_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:logger/logger.dart';



import 'package:firebase_auth/firebase_auth.dart';

import '../services/google_authentication.dart';

class Loginwithacc extends StatefulWidget {
  const Loginwithacc({super.key});

  @override
  State<Loginwithacc> createState() => _LoginwithaccState();
}

class _LoginwithaccState extends State<Loginwithacc> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(toolbarHeight: 10,),
      body:SingleChildScrollView(child:LoginEmail(),)
    );
  }
}

class LoginEmail extends StatelessWidget{

  final loginEmailController = TextEditingController();
  final loginPasswordController = TextEditingController();
  final logger = Logger();
  final _auth = AuthService();

  LoginEmail({super.key});

  @override
  Widget build(BuildContext context) {
    return
    Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
          
        const SizedBox(height: 90),
        const SizedBox(            
          height: 100,
          width: 450,         
          child: Padding(padding: EdgeInsets.symmetric(horizontal: 10.0) ,
            child:Text('Login to your Account',
            style: TextStyle(fontWeight: FontWeight.w600,fontSize: 35),
            ),
          ),
        ),

        const SizedBox(height: 30),

        Padding(padding:const EdgeInsets.symmetric(horizontal: 10.0),
          child:MyTextField(
            label: 'Email',
            icon: Icons.email,
            obscureText: false,
            controller: loginEmailController,
          ),
        ),

        const SizedBox(height: 20),

        Padding(padding:const EdgeInsets.symmetric(horizontal: 10.0),
          child:MyTextField(
            label: 'Password',
            icon: Icons.lock,
            obscureText: true,
            controller: loginPasswordController,
          ),
        ),

        const SizedBox(height: 20),

        MyMainButtons(
          text: "Login",
          onPressed: () => loginUser (context),
        ),

        

        const SizedBox(height: 10),

        const Text('Forgot password?'),

        const SizedBox(height: 30),

        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 15.0),
          child:
            Row(
              children: [
                Expanded(
                  child: Divider(
                    thickness: 0.6,
                    color: Colors.grey,
                  )
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8.0),
                  child: Text('Or continue with',
                    style: TextStyle(
                    color: Colors.grey,
                    ),
                  ),
                ),
                Expanded(
                  child: Divider(
                    thickness: 0.6,
                    color: Colors.grey,
                  )
                )
              ],
          )
        ),

        const SizedBox(height: 30),

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
            children: 
              [ 
              SvgPicture.asset('assets/icons/google.svg',height: 20,width: 20,),
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

          const SizedBox(height: 20),

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
            children: 
              [ 
              SvgPicture.asset('assets/icons/facebook.svg',height: 20,width: 20,),
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


      ]
    );

  }

  

void loginUser (BuildContext context) async {
  try {
    await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: loginEmailController.text,
      password: loginPasswordController.text,
    );
    //show loading circle
    showDialog(
      context: context,
      builder:(context) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      }
    );
    if (context.mounted){ Navigator.pop(context);}
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) =>const HomePage()),
    );
  } on FirebaseAuthException catch (e) {
    if (context.mounted){ Navigator.pop(context);}
    logger.e(e);
  }


  }

}

