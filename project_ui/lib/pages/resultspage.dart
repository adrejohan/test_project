import 'package:flutter/material.dart';
import 'package:project_ui/widget/responsivelayout.dart';
import 'package:project_ui/widget/resultsdesktop.dart';
import 'package:project_ui/widget/resultsmobile.dart';

class ResultsPage extends StatefulWidget {
  final List<String> imageName;
  final List<List> urlPic;
  final List<Map> annotationcountList;

  const ResultsPage(
      {Key? key,
      required this.imageName,
      required this.urlPic,
      required this.annotationcountList})
      : super(key: key);

  @override
  _ResultsPageState createState() => _ResultsPageState();
}

class _ResultsPageState extends State<ResultsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ResponsiveLayout(
        mobileBody: ResultsMobileBody(
          imageName: widget.imageName,
          urlPic: widget.urlPic,
          annotationcountList: widget.annotationcountList,
        ),
        desktopBody: ResultsDesktopBody(
          imageName: widget.imageName,
          urlPic: widget.urlPic,
          annotationcountList: widget.annotationcountList,
        ),
      ),
    );
  }
}
