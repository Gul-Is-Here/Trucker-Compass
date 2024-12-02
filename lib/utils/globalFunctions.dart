// ignore: file_names
import 'package:flutter/material.dart';

class GlobalFunctions {
  GlobalFunctions._internal();
  static final GlobalFunctions global = GlobalFunctions._internal();
  static bool validateFields(GlobalKey<FormState> formKey) {
    if (formKey.currentState == null) {
      throw Exception('FormKey is null or not associated with a Form widget.');
    }

    // Validate form and return the result
    if (formKey.currentState!.validate()) {
      formKey.currentState!.save();
      return true;
    }
    return false;
  }
}
