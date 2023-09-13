// Import necessary libraries
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tflite/tflite.dart';

// Define the Home widget
class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

// Define the state for the Home widget
class _HomeState extends State<Home> {
  late File _image;       // To store the selected image
  late List _results;     // To store the classification results
  bool imageSelect = false; // Flag to track if an image is selected

  // Initialize the state
  @override
  void initState() {
    super.initState();
    loadModel(); // Load the Tflite model when the widget is created
  }

  // Load the Tflite model
  Future loadModel() async {
    Tflite.close();
    String res;
    res = (await Tflite.loadModel(
        model: "assets/tomato.tflite", labels: "assets/labels.txt"))!;
    print("Models loading status: $res");
  }

  // Perform image classification using Tflite
  Future imageClassification(File image) async {
    final List? recognitions = await Tflite.runModelOnImage(
      path: image.path,
      numResults: 6,
      threshold: 0.05,
      imageMean: 127.5,
      imageStd: 127.5,
    );
    setState(() {
      _results = recognitions!;
      _image = image;
      imageSelect = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Image Classification"),
      ),
      body: ListView(
        children: [
          (imageSelect)
              ? Container(
                  margin: const EdgeInsets.all(10),
                  child: Image.file(_image),
                )
              : Container(
                  margin: const EdgeInsets.all(10),
                  child: const Opacity(
                    opacity: 0.8,
                    child: Center(
                      child: Text("No image selected"),
                    ),
                  ),
                ),
          SingleChildScrollView(
            child: Column(
              children: (imageSelect)
                  ? _results.map((result) {
                      return Card(
                        child: Container(
                          margin: const EdgeInsets.all(10),
                          child: Text(
                            "${result['label']} - ${result['confidence'].toStringAsFixed(2)}",
                            style: const TextStyle(
                                color: Colors.red, fontSize: 20),
                          ),
                        ),
                      );
                    }).toList()
                  : [],
            ),
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: pickImage, // Call pickImage function when the button is pressed
        tooltip: "Pick Image",
        child: const Icon(Icons.image),
      ),
    );
  }

  // Function to pick an image from the gallery
  Future pickImage() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
    );
    File image = File(pickedFile!.path);
    imageClassification(image); // Perform image classification on the selected image
  }
}
