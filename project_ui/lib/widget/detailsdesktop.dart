import 'dart:convert';
import 'dart:html' as html;

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:csv/csv.dart';

class DetailsDesktopBody extends StatefulWidget {
  final List<String> imageName;
  final List<List> urlPic;
  final List<Map> annotationcountList;
  final int choosenindex;

  const DetailsDesktopBody(
      {Key? key,
      required this.imageName,
      required this.urlPic,
      required this.annotationcountList,
      required this.choosenindex})
      : super(key: key);

  @override
  _DetailsDesktopBodyState createState() => _DetailsDesktopBodyState();
}

class _DetailsDesktopBodyState extends State<DetailsDesktopBody> {
  late int visibleIndex;
  List<dynamic> _selectedRow = [];
  final controller = CarouselController();
  int activeIndex = 0;

  @override
  void initState() {
    super.initState();
    visibleIndex = 0;
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
            child:
                Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              SizedBox(
                width: maxWidth,
                height: (maxHeight - 55) * 0.05,
                child: Container(color: Colors.black12, child: buildButtons()),
              ),
              const SizedBox(
                height: 1,
              ),
              SizedBox(
                height: (maxHeight - 70) * 0.9,
                width: maxWidth,
                child: CarouselSlider.builder(
                  carouselController: controller,
                  itemCount: widget.urlPic.length,
                  itemBuilder: (context, index, realIndex) {
                    final imageUrl = widget.urlPic[index];
                    final imageName = widget.imageName[index];

                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        SizedBox(
                          height: (maxHeight - 70) * 0.9,
                          width: maxWidth * 0.8 - 8,
                          child: Container(
                            color: Colors.black12,
                            child: buildImage(imageName, imageUrl, visibleIndex,
                                maxHeight, maxWidth),
                          ),
                        ),
                        SizedBox(
                          height: (maxHeight - 70) * 0.9,
                          width: maxWidth * 0.195 - 8,
                          child: Container(
                            color: Colors.black12,
                            child: buildTable(index, maxWidth),
                          ),
                        ),
                        SizedBox(
                          height: (maxHeight - 70) * 0.9,
                          width: maxWidth * 0.005 - 8,
                        )
                      ],
                    );
                  },
                  options: CarouselOptions(
                    scrollPhysics: const NeverScrollableScrollPhysics(),
                    initialPage: widget.choosenindex,
                    viewportFraction: 1,
                    onPageChanged: (index, reason) =>
                        setState(() => activeIndex = index),
                  ),
                ),
              ),
            ]),
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

  Widget buildTable(int index, double maxWidth) => Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                buildExportButton(index),
                SizedBox(
                  width: maxWidth * 0.0075,
                )
              ],
            ),
            const SizedBox(
              height: 5,
            ),
            DataTable(
              showCheckboxColumn: false,
              columns: const <DataColumn>[
                DataColumn(
                    label: Text(
                  '部品名',
                  style: TextStyle(
                    fontSize: 20,
                  ),
                )),
                DataColumn(
                    label: Text(
                  '数',
                  style: TextStyle(
                    fontSize: 20,
                  ),
                )),
              ],
              rows: widget.annotationcountList[index].entries
                  .map(
                    (e) => DataRow(
                      selected: _selectedRow.contains(e.key.toString()),
                      onSelectChanged: (
                        bool? selected,
                      ) {
                        setState(() {
                          final isAdd = selected != null && selected;

                          if (isAdd) {
                            if (_selectedRow == []) {
                              _selectedRow.add(e.key.toString());
                              visibleIndex = widget.urlPic[index].indexWhere(
                                  (element) =>
                                      element.contains(e.key.toString()));
                            } else {
                              _selectedRow = [];
                              _selectedRow.add(e.key.toString());
                              visibleIndex = widget.urlPic[index].indexWhere(
                                  (element) =>
                                      element.contains(e.key.toString()));
                            }
                          } else {
                            _selectedRow.remove(e.key.toString());
                            visibleIndex = 0;
                          }
                        });
                      },
                      cells: [
                        DataCell(
                          SizedBox(
                            width: (maxWidth * 0.195 - 8) * 0.6,
                            child: Text(
                              e.key.toString(),
                              style: const TextStyle(
                                fontSize: 20,
                              ),
                            ),
                          ),
                        ),
                        DataCell(
                          SizedBox(
                            width: (maxWidth * 0.195 - 8) * 0.4,
                            child: Text(
                              e.value.toString(),
                              style: const TextStyle(
                                fontSize: 20,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                  .toList(),
            ),
          ],
        ),
      );

  Widget buildButtons({bool stretch = false}) => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FloatingActionButton.small(
            backgroundColor: Colors.white12,
            elevation: 0,
            onPressed: previous,
            child: const Icon(
              Icons.arrow_back,
              size: 20,
              color: Colors.grey,
            ),
          ),
          stretch ? const Spacer() : const SizedBox(width: 10),
          Text(
            "${activeIndex + 1}/${widget.imageName.length}",
            style: TextStyle(
              fontSize: 20,
            ),
          ),
          stretch ? const Spacer() : const SizedBox(width: 10),
          FloatingActionButton.small(
            backgroundColor: Colors.white12,
            elevation: 0,
            onPressed: next,
            child: const Icon(
              Icons.arrow_forward,
              size: 20,
              color: Colors.grey,
            ),
          ),
        ],
      );

  Widget buildExportButton(int index) => SizedBox(
        height: 30,
        child: FloatingActionButton.extended(
          onPressed: () {
            List<List<dynamic>> csvdata = widget
                .annotationcountList[index].entries
                .map((entry) => [entry.key, entry.value])
                .toList();
            String csv = const ListToCsvConverter().convert(csvdata);
            List<int> csvBytes = utf8.encode(csv);
            final blob = html.Blob([csvBytes]);
            final url = html.Url.createObjectUrlFromBlob(blob);
            final anchor = html.AnchorElement(href: url)
              ..setAttribute("download", widget.imageName[index] + ".csv")
              ..click();

            // Clean up
            html.Url.revokeObjectUrl(url);
          },
          backgroundColor: Colors.black26,
          icon: const Icon(
            Icons.download,
            size: 24.0,
            color: Colors.white,
          ),
          label: const Text(
            'エクスポート',
            style: TextStyle(color: Colors.white),
          ),
        ),
      );

  Widget buildIndicator() => AnimatedSmoothIndicator(
        activeIndex: activeIndex,
        count: widget.urlPic.length,
        onDotClicked: animateToSlide,
        effect: const JumpingDotEffect(
            dotWidth: 15,
            dotHeight: 15,
            activeDotColor: Colors.lightBlue,
            dotColor: Colors.black12),
      );

  void animateToSlide(int index) {
    controller.animateToPage(index);
  }

  void next() {
    controller.nextPage(
      duration: const Duration(milliseconds: 500),
    );
    setState(() {
      visibleIndex = 0;
      _selectedRow = [];
    });
  }

  void previous() {
    controller.previousPage(
      duration: const Duration(milliseconds: 500),
    );
    setState(() {
      visibleIndex = 0;
      _selectedRow = [];
    });
  }

  String removeFileExtension(String filename) {
    List<String> parts = filename.split('.');
    // If there's no extension, return the original filename
    if (parts.length <= 1) {
      return filename;
    }
    // Join all parts except the last one, which is the extension
    return parts.sublist(0, parts.length - 1).join('.');
  }
}
