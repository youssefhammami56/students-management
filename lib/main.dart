import 'package:flutter/material.dart';

import 'login.dart'; // Import your 'Login' class.

void main() {
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: Login(), // Use the 'Login' class, not the 'login' function.
  ));
}