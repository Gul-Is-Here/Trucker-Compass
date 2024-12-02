import 'package:trucker_compass/auth/login.dart';
import 'package:trucker_compass/controller/authController.dart';
import 'package:trucker_compass/utils/globalFunctions.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:velocity_x/velocity_x.dart';

class Register extends StatelessWidget {
  Register({super.key});
  final authController = Get.find<AuthController>();

  @override
  Widget build(BuildContext context) {
    final _signupFormKey = GlobalKey<FormState>();

    return Scaffold(
      body: SingleChildScrollView(
        child: Form(
          key: _signupFormKey,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 40.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Register',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                20.heightBox,
                TextFormField(
                  controller: authController.nameController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Name cannot be empty';
                    }
                    if (value.length < 3) {
                      return 'Name must be at least 3 characters';
                    }
                    return null;
                  },
                  decoration: const InputDecoration(labelText: 'Name'),
                ),
                15.heightBox,
                TextFormField(
                  controller: authController.emailController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Email cannot be empty';
                    }
                    final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
                    if (!emailRegex.hasMatch(value)) {
                      return 'Enter a valid email address';
                    }
                    return null;
                  },
                  decoration: const InputDecoration(labelText: 'Email'),
                ),
                15.heightBox,
                TextFormField(
                  controller: authController.passwordController,
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Password cannot be empty';
                    }
                    if (value.length < 6) {
                      return 'Password must be at least 6 characters';
                    }
                    return null;
                  },
                  decoration: const InputDecoration(labelText: 'Password'),
                ),
                20.heightBox,
                ElevatedButton(
                  onPressed: () async {
                    if (GlobalFunctions.validateFields(_signupFormKey)) {
                      await authController.userRegister(
                        email: authController.emailController.text.trim(),
                        password: authController.passwordController.text.trim(),
                        userName: authController.nameController.text.trim(),
                      );
                    }
                  },
                  child: const Text('Register'),
                ),
                20.heightBox,
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Already have an account? "),
                    GestureDetector(
                      onTap: () {
                        Get.to(() => Login());
                      },
                      child: const Text(
                        'Login',
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
        ),
      ),
    );
  }
}
