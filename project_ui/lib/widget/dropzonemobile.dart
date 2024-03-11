// ignore_for_file: must_be_immutable

import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_dropzone/flutter_dropzone.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:project_ui/pages/resultspage.dart';

import 'package:http/http.dart' as http;

class MyMobileBody extends StatelessWidget {
  MyMobileBody({Key? key}) : super(key: key);

  late DropzoneViewController controller;

  @override
  Widget build(BuildContext context) {
    const colorButton = Colors.lightBlue;
    return Scaffold(
      backgroundColor: Colors.grey[175],
      appBar: AppBar(
        title: const Text('TEST'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 40),
          child: Container(
            height: MediaQuery.of(context).size.height * 0.4,
            decoration: BoxDecoration(
              color: colorButton,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(5),
              child: DottedBorder(
                strokeWidth: 2.5,
                dashPattern: const [3, 3],
                color: Colors.white,
                borderType: BorderType.RRect,
                radius: const Radius.circular(12),
                child: Stack(
                  children: [
                    DropzoneView(
                      onCreated: (controller) => this.controller = controller,
                      onDropMultiple: (event) async {
                        List<Map> base64list = [];
                        List<String> urlPicList = [];
                        List<Map> annotationList = [];
                        for (var i = 0; i < event!.length; i++) {
                          final mimePic =
                              await controller.getFileMIME(event[i]);
                          final namePic =
                              await controller.getFilename(event[i]);
                          if (mimePic == "image/png" ||
                              mimePic == "image/jpeg") {
                            Uint8List bytes =
                                await controller.getFileData(event[i]);
                            String base64String = base64Encode(bytes);
                            Map<String, dynamic> jsonData = {
                              "name": namePic,
                              "image": base64String
                            };
                            base64list.add(jsonData);
                          }
                        }
                        if (base64list.isNotEmpty) {
                          Map<String, dynamic> images = {"images": base64list};
                          String json = jsonEncode(images);

                          var apiUrl =
                              Uri.parse("https://192.168.3.122:5000/images");

                          try {
                            // Make a POST request to the API
                            var response = await http.post(
                              apiUrl,
                              headers: {
                                "Access-Control-Allow-Origin": "*",
                                "Content-type": "application/json",
                                "Accept": "application/json",
                              },
                              body: json,
                            );

                            // Check if the request was successful (status code 200)
                            if (response.statusCode == 200) {
                              //print("API Response: ${response.body}");
                              final Map<String, dynamic> data =
                                  jsonDecode(response.body);
                              for (Map<String, dynamic> i in data["data"]) {
                                // print(i.runtimeType);
                                urlPicList.add(i["image_url"]);
                                annotationList.add(i["annotations"]);
                              }
                              // await Navigator.push(
                              //   context,
                              //   MaterialPageRoute(
                              //       builder: (context) => ResultsPage(
                              //           imageName: [],
                              //           urlPic: urlPicList,
                              //           annotations: annotationList)),
                              // );
                            } else {
                              print("Error: ${response.statusCode}");
                              print("Response: ${response.body}");
                            }
                          } catch (e) {
                            print("Error: $e");
                          }
                        } else {
                          const snackBar = SnackBar(
                              content: Text('エラー：ドロップしたファイルは.pngや.jpgのみです'),
                              duration: Duration(seconds: 1));
                          ScaffoldMessenger.of(context).showSnackBar(snackBar);
                        }
                      },
                    ),
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.cloud_upload,
                              size: 80, color: Colors.white),
                          const Text(
                            '写真ファイルをドロップしてください。',
                            style: TextStyle(color: Colors.white, fontSize: 24),
                          ),
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              backgroundColor: colorButton,
                            ),
                            icon: const Icon(
                              Icons.search,
                              size: 32,
                              color: Colors.white,
                            ),
                            label: const Text(
                              '写真ファイルを選んでください。',
                              style:
                                  TextStyle(color: Colors.white, fontSize: 24),
                            ),
                            onPressed: () async {
                              final events =
                                  await controller.pickFiles(multiple: true);
                              if (events.isEmpty) return;
                              List<Map> base64list = [];
                              List<String> urlPicList = [];
                              List<Map> annotationList = [];
                              for (var i = 0; i < events.length; i++) {
                                // final urlPic =
                                //     await controller.createFileUrl(events[i]);
                                final namePic =
                                    await controller.getFilename(events[i]);
                                Uint8List bytes =
                                    await controller.getFileData(events[i]);
                                String base64String = base64Encode(bytes);
                                Map<String, dynamic> jsonData = {
                                  "name": namePic,
                                  "image": base64String
                                };
                                base64list.add(jsonData);
                              }
                              Map<String, dynamic> images = {
                                "images": base64list
                              };
                              String json = jsonEncode(images);

                              var apiUrl = Uri.parse(
                                  "https://192.168.3.122:5000/images");

                              try {
                                // Make a POST request to the API
                                var response = await http.post(
                                  apiUrl,
                                  headers: {
                                    "Access-Control-Allow-Origin": "*",
                                    "Content-type": "application/json",
                                    "Accept": "application/json",
                                  },
                                  body: json,
                                );

                                // Check if the request was successful (status code 200)
                                if (response.statusCode == 200) {
                                  // print("API Response: ${response.body}");
                                  final Map<String, dynamic> data =
                                      jsonDecode(response.body);
                                  for (Map<String, dynamic> i in data["data"]) {
                                    // print(i.runtimeType);
                                    urlPicList.add(i["image_url"]);
                                    annotationList.add(i["annotations"]);
                                  }
                                  // await Navigator.push(
                                  //   context,
                                  //   MaterialPageRoute(
                                  //       builder: (context) => ResultsPage(
                                  //           imageName: [],
                                  //           urlPic: urlPicList,
                                  //           annotations: annotationList)),
                                  // );
                                } else {
                                  print("Error: ${response.statusCode}");
                                  print("Response: ${response.body}");
                                }
                              } catch (e) {
                                print("Error: $e");
                              }
                            },
                          ),
                          const Text(
                            "(.jpgと.pngファイルのみ)",
                            style: TextStyle(color: Colors.white, fontSize: 20),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
