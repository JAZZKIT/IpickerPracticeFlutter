import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String? imageUrl;

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
          )
        ],
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
        var snapshot =
            await _storage.ref().child('folderName/imageName').putFile(file);

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
