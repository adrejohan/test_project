import 'package:flutter/material.dart';
import 'package:project_ui/widget/detailsdesktop.dart';
import 'package:project_ui/widget/responsivelayout.dart';
import 'package:project_ui/widget/resultsdesktop.dart';
import 'package:project_ui/widget/resultsmobile.dart';

class DetailsPage extends StatefulWidget {
  final List<String> imageName;
  final List<List> urlPic;
  final List<Map> annotationcountList;
  final int choosenindex;

  const DetailsPage(
      {Key? key,
      required this.imageName,
      required this.urlPic,
      required this.annotationcountList,
      required this.choosenindex})
      : super(key: key);

  @override
  _DetailsPageState createState() => _DetailsPageState();
}

class _DetailsPageState extends State<DetailsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ResponsiveLayout(
        mobileBody: ResultsMobileBody(
          imageName: widget.imageName,
          urlPic: widget.urlPic,
          annotationcountList: widget.annotationcountList,
        ),
        desktopBody: DetailsDesktopBody(
          imageName: widget.imageName,
          urlPic: widget.urlPic,
          annotationcountList: widget.annotationcountList,
          choosenindex: widget.choosenindex,
        ),
      ),
    );
  }
}
