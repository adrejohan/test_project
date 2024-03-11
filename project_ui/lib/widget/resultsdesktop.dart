import 'dart:convert';
import 'dart:html' as html;

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:project_ui/pages/detailspage.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:csv/csv.dart';

class ResultsDesktopBody extends StatefulWidget {
  final List<String> imageName;
  final List<List> urlPic;
  final List<Map> annotationcountList;

  const ResultsDesktopBody(
      {Key? key,
      required this.imageName,
      required this.urlPic,
      required this.annotationcountList})
      : super(key: key);

  @override
  _ResultsDesktopBodyState createState() => _ResultsDesktopBodyState();
}

class _ResultsDesktopBodyState extends State<ResultsDesktopBody> {
  late int choosenIndex;
  List<dynamic> _selectedRow = [];
  final controller = CarouselController();
  int activeIndex = 0;

  @override
  void initState() {
    super.initState();
    choosenIndex = 0;
  }

  @override
  Widget build(BuildContext context) {
    final maxWidth = MediaQuery.of(context).size.width;
    final maxHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: Colors.grey[175],
      appBar: AppBar(
        title: const Text('TEST'),
      ),
      body: Center(
        child: SizedBox(
          width: maxWidth,
          height: maxHeight - 55,
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            // First column
            child: SizedBox(
              height: (maxHeight - 70) * 0.9,
              width: maxWidth * 0.195 - 8,
              child: Container(
                color: Colors.black12,
                child: buildTable(maxWidth),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildImage(String imageName, List<dynamic> urlImage, int index,
          double maxHeight, double maxWidth) =>
      Column(children: [
        Text(
          imageName,
          style: const TextStyle(
            fontSize: 20,
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: (maxHeight - 70) * 0.85,
          width: maxWidth * 0.8 - 8,
          child: InteractiveViewer(
            child: Image.network(
              urlImage[index],
              fit: BoxFit.contain,
            ),
          ),
        ),
      ]);

  Widget buildTable(double maxWidth) => Padding(
        padding: const EdgeInsets.all(8.0),
        child: DataTable(
          showCheckboxColumn: false,
          columns: const <DataColumn>[
            DataColumn(
                label: Text(
              'ファイル名',
              style: TextStyle(
                fontSize: 20,
              ),
            )),
          ],
          rows: widget.imageName
              .map(
                (e) => DataRow(
                  selected: _selectedRow.contains(e.toString()),
                  onSelectChanged: (
                    bool? selected,
                  ) {
                    setState(() async {
                      final isAdd = selected != null && selected;

                      if (isAdd) {
                        choosenIndex = widget.imageName.indexWhere(
                            (element) => element.contains(e.toString()));
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => DetailsPage(
                                    imageName: widget.imageName,
                                    urlPic: widget.urlPic,
                                    annotationcountList:
                                        widget.annotationcountList,
                                    choosenindex: choosenIndex,
                                  )),
                        );
                      }
                    });
                  },
                  cells: [
                    DataCell(
                      SizedBox(
                        width: (maxWidth * 0.195 - 8) * 0.6,
                        child: Text(
                          e.toString(),
                          style: const TextStyle(
                            fontSize: 20,
                          ),
                        ),
                      ),
                    ),
                    // DataCell(
                    //   SizedBox(
                    //     width: (maxWidth * 0.195 - 8) * 0.4,
                    //     child: Text(
                    //       e.value.toString(),
                    //       style: const TextStyle(
                    //         fontSize: 20,
                    //       ),
                    //     ),
                    //   ),
                    // ),
                  ],
                ),
              )
              .toList(),
        ),
      );
}
