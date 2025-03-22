import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';

import '../navigation_files/navigator.dart';

class AuthService {
  final _auth = FirebaseAuth.instance;
  // Google signin
  Future<UserCredential?> signInWithGoogle(BuildContext context) async {
    try {
      
      final googleUser = await GoogleSignIn().signIn();

      
      final googleAuth = await googleUser?.authentication;

      
      final cred = GoogleAuthProvider.credential(idToken: googleAuth?.idToken,accessToken: googleAuth?.accessToken);

      
      UserCredential userCredential = await _auth.signInWithCredential(cred);

      if(userCredential.user != null){
        Navigator.pushReplacement(
          // ignore: use_build_context_synchronously
          context,
          MaterialPageRoute(
            builder: (context) => const NavigatorMangement()
          ),
        );
      }

      return userCredential;

    } on FirebaseAuthException catch (e) {
      // Handle signin error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message ?? 'Sign in failed')),
      );
      return null;
    }
  }
  Future <UserCredential?> signInWithFacebook(BuildContext context) async {
    try {
      
      final LoginResult result = await FacebookAuth.instance.login();

      if (result.status == LoginStatus.success && result.accessToken != null) {
        
        final OAuthCredential facebookAuthCredential =
            FacebookAuthProvider.credential(result.accessToken!.tokenString);

        
        UserCredential userCredential =
            await _auth.signInWithCredential(facebookAuthCredential);

        
        if (userCredential.user != null) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const NavigatorMangement()),
          );
        }

        return userCredential;
      } else {
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result.message ?? 'Sign in failed')),
        );
        return null;
      }
    } on FirebaseAuthException catch (e) {
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message ?? 'Sign in failed')),
      );
      return null;
    }
  }
}