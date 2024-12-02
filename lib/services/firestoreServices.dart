import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> saveUserData(
      {required String userId,
      required String userName,
      required String email,
      required String password}) async {
    try {
      await _firestore.collection('users').doc(userId).set({
        'userName': userName,
        'email': email,
        'password': password,
        'createdAt': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      // You can handle Firestore-specific errors here
      throw Exception('Failed to save user data: ${e.toString()}');
    }
  }

  // uplaod File to Firebase Stroage According to user
 Future<void> uploadFile(String name, File? file, String? url, BuildContext context) async {
  if (file == null) {
    // Handle the case where the file is null
    print('No file provided for upload.');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('No file selected to upload.')),
    );
    return;
  }

  try {
    var myFile = FirebaseStorage.instance.ref().child('users').child('/$name');
    UploadTask task = myFile.putFile(file);
    TaskSnapshot snapshot = await task;
    url = await snapshot.ref.getDownloadURL();
    print('PDF URL: $url');

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Uploaded Successfully')),
    );
  } catch (e) {
    print('Error: $e');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Something went wrong')),
    );
  }
}
}
