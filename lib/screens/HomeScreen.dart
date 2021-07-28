import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

import 'login_screen.dart';

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String? imageUrl;

  FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Upload Image')),
      body: Column(
        children: <Widget>[
          (imageUrl != null)
              ? Image.network(imageUrl!)
              : Placeholder(
                  fallbackHeight: 200.0, fallbackWidth: double.infinity),
          SizedBox(
            height: 20.0,
          ),
          ElevatedButton(
            child: Text('Upload Image'),
            onPressed: () => uploadImage(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await _auth.signOut();
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (context) => LoginScreen()));
        },
        child: Icon(Icons.logout),
      ),
    );
  }

  uploadImage() async {
    final _storage = FirebaseStorage.instance;
    final ImagePicker _picker = ImagePicker();
    // PickedFile image;

    //Check Permissions

    //await Permission.photos.request();
    print('permissionStatus - ${await Permission.photos.request()}');

    //var permissionStatus = await Permission.photos.status;
    Permission permission = Permission.photos;
    PermissionStatus permissionStatus = await permission.status;

    //print('permissionStatus - $permissionStatus');
    if (permissionStatus.isGranted) {
      //Select Image
      //final ImagePicker _picker = ImagePicker();
      // Pick an image
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      print('image - $image');
      //image = (await _picker.getImage(source: ImageSource.gallery))!;
      var file = File(image!.path);
      print('image - $image');

      if (image != null) {
        //Upload to Firebase
        var snapshot = await _storage
            .ref()
            .child('folderName/${image.name}')
            .putFile(file);

        var downloadUrl = await snapshot.ref.getDownloadURL();

        setState(() {
          imageUrl = downloadUrl;
        });
      } else {
        print('No Path Received');
      }
    } else {
      print('Grant Permissions and try again');
    }
  }
}
