import 'dart:io';

import 'package:flutter/material.dart';
import 'package:snake/profile_page.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite/sqflite.dart';
void main() {
  if (Platform.isWindows || Platform.isLinux) {
    // Initialize FFI
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }
  runApp(const Snake());
}

class Snake extends StatelessWidget {
  const Snake({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
          scaffoldBackgroundColor: Color(0xFFE8F6EF),
          textTheme: Theme.of(context)
              .textTheme
              .apply(bodyColor: Colors.black, fontFamily: 'Urbanist')),
      home: ProfilePage(),
    );
  }
}
