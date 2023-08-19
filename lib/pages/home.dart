import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
// import 'package:path_provider/path_provider.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  File? imageFile;

  Future _pickImage() async {
    final pickedImage = await ImagePicker().pickImage(source: ImageSource.gallery);

    if (pickedImage != null) {
      setState(() {
        imageFile = File(pickedImage.path);
      });
    }
  }

  Future _cropImage() async {
    if (imageFile != null) {
      CroppedFile? cropped = await ImageCropper().cropImage(sourcePath: imageFile!.path, aspectRatioPresets: [
        CropAspectRatioPreset.square,
        CropAspectRatioPreset.ratio3x2,
        CropAspectRatioPreset.original,
        CropAspectRatioPreset.ratio4x3,
        CropAspectRatioPreset.ratio16x9
      ], uiSettings: [
        AndroidUiSettings(toolbarTitle: 'Crop', cropGridColor: Colors.black, initAspectRatio: CropAspectRatioPreset.original, lockAspectRatio: false),
        IOSUiSettings(title: 'Crop'),
      ]);

      if (cropped != null) {
        setState(() {
          imageFile = File(cropped.path);
        });
      }
    }
  }

  void _clearImage() {
    setState(() {
      imageFile = null;
    });
  }

  Future<void> _downloadImage() async {
    if (imageFile != null) {
      Uint8List bytes = await imageFile!.readAsBytes();
      var result = await ImageGallerySaver.saveImage(bytes, quality: 60, name: "new_mage.jpg");
      print(result);
      if (result["isSuccess"] == true) {
        print("Image saved successfully.");
      } else {
        print(result["errorMessage"]);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            backgroundColor: Color.fromARGB(221, 21, 184, 154),
            title: const Text(
              "Crop Your Image",
              style: TextStyle(fontSize: 30),
            )),
        body: Column(
          children: [
            Expanded(
                flex: 3,
                child: imageFile != null
                    ? Container(alignment: Alignment.center, padding: const EdgeInsets.symmetric(vertical: 10), child: Image.file(imageFile!))
                    : const Center(
                        child: Text("Add a picture", style: TextStyle(fontSize: 25)),
                      )),
            Expanded(
                child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildIconButton(icon: Icons.add, onpressed: _pickImage),
                  _buildIconButton(icon: Icons.crop, onpressed: _cropImage),
                  _buildIconButton(icon: Icons.clear, onpressed: _clearImage),
                  _buildIconButton(icon: Icons.download, onpressed: _downloadImage),
                ],
              ),
            ))
          ],
        ));
  }

  Widget _buildIconButton({required IconData icon, required void Function()? onpressed}) {
    return Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(10)),
        child: IconButton(
          onPressed: onpressed,
          icon: Icon(icon),
          color: Colors.white,
        ));
  }
}
