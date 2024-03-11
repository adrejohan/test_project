import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class ResultsMobileBody extends StatefulWidget {
  final List<String> imageName;
  final List<List> urlPic;
  final List<Map> annotationcountList;

  const ResultsMobileBody(
      {Key? key,
      required this.imageName,
      required this.urlPic,
      required this.annotationcountList})
      : super(key: key);

  @override
  _ResultsMobileBodyState createState() => _ResultsMobileBodyState();
}

class _ResultsMobileBodyState extends State<ResultsMobileBody> {
  final controller = CarouselController();
  int activeIndex = 0;
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
          height: maxHeight,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            // First column
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // youtube video
                buildIndicator(),
                SizedBox(
                  height: maxHeight * 0.5,
                  width: maxWidth,
                  // color: Colors.amber,
                  child: Padding(
                    padding: const EdgeInsets.all(1.0),
                    child: CarouselSlider.builder(
                      carouselController: controller,
                      itemCount: widget.urlPic.length,
                      itemBuilder: (context, index, realIndex) {
                        final urlImage = widget.urlPic[index][-1];

                        return SingleChildScrollView(
                          child: Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(1.0),
                                child: Container(
                                  child: buildImage(
                                      urlImage, index, maxHeight, maxWidth),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(1.0),
                                child: SizedBox(
                                  width: maxWidth * 0.45,
                                  child: buildTable(index, maxWidth),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                      options: CarouselOptions(
                        initialPage: 0,
                        viewportFraction: 1,
                        onPageChanged: (index, reason) =>
                            setState(() => activeIndex = index),
                      ),
                    ),
                  ),
                ),
                buildButtons(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildImage(
          String urlImage, int index, double maxHeight, double maxWidth) =>
      SizedBox(
        width: maxWidth * 0.45,
        height: maxHeight * 0.25,
        child: Image.network(
          urlImage,
          fit: BoxFit.contain,
        ),
      );

  Widget buildTable(int index, double maxWidth) => DataTable(
        columns: const <DataColumn>[
          DataColumn(label: Text('部品名')),
          DataColumn(label: Text('数')),
        ],
        rows: widget.annotationcountList[index][-1].entries
            .map((e) => DataRow(cells: [
                  DataCell(Text(e.key.toString())),
                  DataCell(Text(e.value.toString())),
                ]))
            .toList(),
      );

  Widget buildButtons({bool stretch = false}) => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FloatingActionButton.small(
            backgroundColor: Colors.white60,
            onPressed: previous,
            child: const Icon(
              Icons.arrow_back,
              size: 20,
              color: Colors.grey,
            ),
          ),
          stretch ? const Spacer() : const SizedBox(width: 32),
          FloatingActionButton.small(
            backgroundColor: Colors.white60,
            onPressed: next,
            child: const Icon(
              Icons.arrow_forward,
              size: 20,
              color: Colors.grey,
            ),
          ),
        ],
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
  }

  void previous() {
    controller.previousPage(
      duration: const Duration(milliseconds: 500),
    );
  }
}
