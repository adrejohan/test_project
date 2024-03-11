import 'package:flutter/material.dart';
import 'package:project_ui/widget/dropzonedesktop.dart';
import 'package:project_ui/widget/dropzonemobile.dart';
import 'package:project_ui/widget/responsivelayout.dart';

class DropZonePage extends StatefulWidget {
  const DropZonePage({Key? key}) : super(key: key);

  @override
  _DropZonePageState createState() => _DropZonePageState();
}

class _DropZonePageState extends State<DropZonePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ResponsiveLayout(
        mobileBody: MyMobileBody(),
        desktopBody: MyDesktopBody(),
      ),
    );
  }
}
