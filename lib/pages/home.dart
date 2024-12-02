import 'package:trucker_compass/auth/login.dart';
import 'package:trucker_compass/controller/authController.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:trucker_compass/controller/homeController.dart';

import '../services/firestoreServices.dart';

class Home extends StatelessWidget {
  Home({super.key});
  final authController = Get.put(AuthController());
  final homeController = Get.put(HomeController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.deepOrangeAccent,
          actions: [
            IconButton(
                onPressed: () {
                  authController.logoutUser().then((val) {
                    Get.offAll(() => Login());
                  });
                },
                icon: Icon(
                  Icons.badge,
                  color: Colors.white,
                ))
          ],
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: () async {
                  await homeController.getFile(context);
                },
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        IconButton(
                            onPressed: () async {
                              await homeController.getFile(context);
                            },
                            icon: Icon(
                              Icons.upload_file,
                              size: 50,
                              color: Colors.orange,
                            )),
                        Text(
                          'Upload Pdf',
                          style: TextStyle(),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ));
  }
}
