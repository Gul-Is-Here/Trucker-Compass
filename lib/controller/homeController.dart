import 'dart:io';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';

class HomeController extends GetxController {
  File? file;
  String? url;
  var name;

  getFile(BuildContext context) async {
    try {
      FilePickerResult? result =
          await FilePicker.platform.pickFiles(type: FileType.any);

      if (result != null) {
        if (result.files.single.path != null) {
          // File has a valid path
          file = File(result.files.single.path!);
          name = result.files.single.name;
          uploadFile(context);
        } else if (result.files.single.bytes != null) {
          // File is in memory (e.g., from cloud storage)
          Uint8List fileBytes = result.files.single.bytes!;
          name = result.files.single.name;

          // Upload file directly from bytes
          var myFile = FirebaseStorage.instance.ref().child('users/$name');
          await myFile.putData(fileBytes);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Uploaded Successfully from bytes')),
          );
        } else {
          print('Failed to retrieve file path or bytes.');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to retrieve file data.')),
          );
        }
      } else {
        print('File picking was canceled.');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('File selection canceled.')),
        );
      }
    } catch (e) {
      print('Error during file selection: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to pick file.')),
      );
    }
  }

  // Upload file to Firebase Storage
  Future<void> uploadFile(BuildContext context) async {
    if (file == null) {
      print('No file provided for upload.');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No file selected to upload.')),
      );
      return;
    }

    try {
      // Adding timestamp for unique file naming
      var timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      var myFile =
          FirebaseStorage.instance.ref().child('users/$timestamp-$name');
      UploadTask task = myFile.putFile(file!);

      // Await upload task completion
      TaskSnapshot snapshot = await task;
      url = await snapshot.ref.getDownloadURL();
      print('File URL: $url');

      if (url != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Uploaded Successfully')),
        );

        // Extract and save text from PDF
        await extractAndSavePdfText(context, file!, timestamp);
      }
    } catch (e) {
      print('Error during file upload: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to upload file.')),
      );
    }
  }

  // Extract text from PDF and save to Firestore
  Future<void> extractAndSavePdfText(
      BuildContext context, File pdfFile, String timestamp) async {
    try {
      // Load the PDF document
      final PdfDocument document =
          PdfDocument(inputBytes: pdfFile.readAsBytesSync());

      // Extract text from all pages
      String extractedText = PdfTextExtractor(document).extractText();

      // Dispose of the document
      document.dispose();

      // Save extracted text to Firestore
      await FirebaseFirestore.instance.collection('pdf_data').add({
        'file_name': name,
        'upload_time': DateTime.now(),
        'text': extractedText,
        'storage_url': url,
      });

      print('Extracted text saved successfully.');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Text extracted and saved successfully')),
      );
    } catch (e) {
      print('Error during text extraction: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to extract text from PDF.')),
      );
    }
  }
}
