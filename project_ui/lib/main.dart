import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:project_ui/config/utils.dart';
import 'package:project_ui/pages/dropzonepage.dart';

void main() {
  runApp(const MyApp());
  configLoading();
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const DropZonePage(),
      builder: EasyLoading.init(),
      theme: ThemeData(primarySwatch: Colors.grey),
    );
  }
}
