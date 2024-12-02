import 'package:trucker_compass/pages/home.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:trucker_compass/auth/login.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:get/get.dart';
import '../services/firestoreServices.dart';

class AuthController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirestoreService _firestoreService = FirestoreService();
  final formkey = GlobalKey<FormState>();
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  Future<void> userRegister({
    required String email,
    required String password,
    required String userName,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      await _firestoreService.saveUserData(
          userId: credential.user!.uid,
          userName: nameController.text, // Update if needed
          email: emailController.text,
          password: passwordController.text);

      // Send email verification
      await credential.user?.sendEmailVerification().then((val) {
        Get.off(() => Login());
      });

      Get.snackbar(
        "Verify Email",
        "A verification link has been sent to $email. Please verify your email before logging in.",
      );
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        print('The password provided is too weak.');
      } else if (e.code == 'email-already-in-use') {
        print('The account already exists for that email.');
      }
    }
  }

  Future<void> userLogin({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Refresh user state
      await credential.user?.reload();

      // Check if email is verified
      if (credential.user?.emailVerified == true) {
        // Save user data to Firestore

        // Navigate to home screen
        Get.offAll(() => Home());
      } else {
        Get.snackbar(
          "Email Not Verified",
          "Please verify your email before logging in.",
        );
        await _auth.signOut(); // Sign out unverified user
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        print('No user found for that email.');
      } else if (e.code == 'wrong-password') {
        print('Wrong password provided for that user.');
      }
    }
  }

  Future<void> logoutUser() async {
    await _auth.signOut();
  }

  // Forget password method
  Future<void> sendPasswordResetEmail({required String email}) async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      Get.back();
      Get.snackbar(
        "Reset Password",
        "A password reset link has been sent to $email. Please check your email to reset your password.",
      );
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        Get.snackbar("Error", "No user found for this email.");
      } else {
        Get.snackbar(
            "Error", "Failed to send password reset email: ${e.message}");
      }
    } catch (e) {
      Get.snackbar("Error", "An unexpected error occurred: ${e.toString()}");
    }
  }
}
