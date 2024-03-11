import 'dart:convert';

import 'package:http/http.dart' as http;

postData() async {
  var apiUrl = Uri.parse("https://5311-60-102-79-51.ngrok-free.app/pdfs");

  try {
    // Make a POST request to the API
    var response = await http.post(
      apiUrl,
      headers: {'Content-Type': 'application/json'},
      body: json,
    );

    // Check if the request was successful (status code 200)
    if (response.statusCode == 200) {
      print("API Response: ${response.body}");
    } else {
      print("Error: ${response.statusCode}");
      print("Response: ${response.body}");
    }
  } catch (e) {
    print("Error: $e");
  }
}
