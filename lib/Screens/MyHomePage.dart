import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'dart:io';
import 'package:validators/validators.dart' as validator;

import 'package:path/path.dart';

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<Map<String, dynamic>> firebaseItem = new List<Map<String, dynamic>>();
  String searchImage;

  List networkUrl = new List();
  List networkimage = new List();
  Future GetData;

  getData() async {
    Firestore.instance.collection('Images').getDocuments().then((value) {
      value.documents.forEach((result) {
        firebaseItem.add(result.data);
      });
    });
  }

  @override
  void initState() {
    GetData = getData();

    // TODO: implement initState
    super.initState();
  }

  File img;
  String downloadUrl;
  String ImageContainerContent = "Image will come here";
  String imageName;
  final imagenameController = TextEditingController();
  final searchImageController = TextEditingController();
  final _formkey = GlobalKey<FormState>();
  final _searchformkey = GlobalKey<FormState>();

  ///Get Data from gallery
  Future getImageCamera() async {
    var image = await ImagePicker.pickImage(
        source: ImageSource.camera, imageQuality: 50);
    setState(() {
      img = image;
      print("Image path $img");
    });
  }

  Future getImageGallery() async {
    var image = await ImagePicker.pickImage(
        source: ImageSource.gallery, imageQuality: 50);
    setState(() {
      img = image;
//      print("Image path $img");
    });
  }

  Future UploadImage(context) async {
    String filename = basename(img.path);

    StorageReference firebaseStorageRef =
        FirebaseStorage.instance.ref().child(filename);

    StorageUploadTask uploadTask = firebaseStorageRef.putFile(
      img,
    );

    StorageTaskSnapshot taskSnapshot = await uploadTask.onComplete;
    downloadUrl = await taskSnapshot.ref.getDownloadURL();
    setState(() {
      Scaffold.of(context)
          .showSnackBar(SnackBar(content: Text("Image uploaded")));
    });
  }

  @override
  Widget build(BuildContext context) {
    int i = 0;
    int j = 0;

    return SafeArea(
      child: Scaffold(
        body: SingleChildScrollView(
          child: Container(
            child: Column(
              children: [
                Form(
                  key: _formkey,
                  child: Container(
                    child: Column(
                      children: [
                        Text(
                          "PICSHO",
                          style: TextStyle(
                              decoration: TextDecoration.underline,
                              fontWeight: FontWeight.bold,
                              fontSize: 30),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        GestureDetector(
                          child: Container(
                            decoration: BoxDecoration(
                                border: Border.all(color: Colors.black),
                                borderRadius: BorderRadius.circular(50)),
                            height: 200,
//                  width: 100,
                            child: (img == null)
                                ? Center(child: Text(ImageContainerContent))
                                : Image.file(
                                    img,
                                    fit: BoxFit.fill,
                                  ),
                          ),
                        ),
                        TextFormField(
                          controller: imagenameController,
                          decoration:
                              InputDecoration(hintText: "Enter the name here"),
                          validator: (value) {
                            if (!validator.isAlpha(value)) {
                              return "Enter a valid name";
                            }
                            return null;
                          },
                          onSaved: (value) {
                            imageName = value;
                          },
                        ),
                        RaisedButton(
                          onPressed: () {
                            showDialog(
                                context: context,
                                builder: (BuildContext buildContext) {
                                  return Dialog(
                                    child: Container(
                                      height: 200,
                                      width: MediaQuery.of(context).size.width,
                                      child: Column(
                                        children: [
                                          Text(
                                            "Select Image",
                                            style: TextStyle(fontSize: 30),
                                          ),
                                          SizedBox(
                                            height: 20,
                                          ),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              RaisedButton(
                                                onPressed: () {
                                                  getImageCamera();
                                                },
                                                child: Text("Camera"),
                                              ),
                                              SizedBox(
                                                width: 20,
                                              ),
                                              RaisedButton(
                                                onPressed: () {
                                                  getImageGallery();
                                                },
                                                child: Text("Gallery"),
                                              ),
                                            ],
                                          )
                                        ],
                                      ),
                                    ),
                                  );
                                });
                          },
                          child: Text("Tap to Add Image"),
                        ),
//                        CircularProgressIndicator(),
                        RaisedButton(
                          onPressed: () {
                            if (_formkey.currentState.validate()) {
                              _formkey.currentState.save();
                            }
                            imagenameController.clear();

                            UploadImage(context).whenComplete(() {
                              setState(() {
                                img = null;
                                ImageContainerContent =
                                    "Your Image has been loaded successfully add another image or please rerun the app the search this image";
                              });
                              Firestore.instance
                                  .collection("Images")
                                  .document()
                                  .setData({
                                'imageUrl': downloadUrl,
                                'name': imageName.toUpperCase(),
                                'searchKey': imageName[0].toUpperCase(),
                              });
                            });
                          },
                          child: Text("Upload it to Server"),
                        ),
                        Divider(
                          thickness: 2,
                        ),
                      ],
                    ),
                  ),
                ),
                Form(
                  key: _searchformkey,
                  child: Column(
                    children: [
                      Chip(
                        backgroundColor: Colors.blueGrey,
                        label: Text(
                          "Search Result will be shown here",
                        ),
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: searchImageController,
                              onChanged: (value) {
                                if (value.length == 0) {
                                  networkUrl = [];
                                }
                              },
                              validator: (value) {
                                if (!validator.isAlpha(value)) {
                                  return "Enter a valid search";
                                }
                                return null;
                              },
                              onSaved: (value) {
                                searchImage = value.toUpperCase();
                              },
                              decoration: InputDecoration(
                                  hintText: "Search images here"),
                            ),
                          ),
                          RaisedButton(
                            onPressed: () {
                              if (_searchformkey.currentState.validate()) {
                                _searchformkey.currentState.save();
                              }
                              imagenameController.clear();

                              for (int i = 0; i < firebaseItem.length; i++) {
                                if (firebaseItem[i]['name'] == searchImage) {
                                  setState(() {
                                    networkUrl.add(firebaseItem[i]['imageUrl']);
                                    networkimage.add(firebaseItem[i]['name']);
                                  });
                                }
                              }
                            },
                            child: Text("Tap"),
                          )
                        ],
                      ),
                      (networkUrl.length > 0)
                          ? GridView.count(
                              crossAxisCount: 2,
                              crossAxisSpacing: 4,
                              mainAxisSpacing: 4,
                              shrinkWrap: true,
                              children: (networkUrl.length > 0)
                                  ? networkUrl
                                      .map((e) => Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Container(
                                              decoration: BoxDecoration(
                                                border: Border.all(
                                                    color: Colors.black),
                                              ),
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 8.0,
                                                        vertical: 8.0),
                                                child: Column(
                                                  children: [
                                                    Expanded(
                                                      child: Container(
                                                        child: Image.network(
                                                            networkUrl[i++]),
                                                      ),
                                                    ),
                                                    Text(networkimage[j++])
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ))
                                      .toList()
                                  : Text("Fetching image..."),
                            )
                          : Center(
                              child: Chip(
                                label: Text("Images will be displayed here"),
                              ),
                            ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
