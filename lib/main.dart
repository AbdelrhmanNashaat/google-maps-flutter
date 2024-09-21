import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:maps/widgets/custom_google_maps.dart';

void main() async {
  await dotenv.load(fileName: ".env");
  runApp(const TestGoogleMapsWithFlutter());
}

class TestGoogleMapsWithFlutter extends StatelessWidget {
  const TestGoogleMapsWithFlutter({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: CustomGoogleMap(),
    );
  }
}
