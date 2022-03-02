import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';

class WelcomexxScreen extends StatefulWidget {
  WelcomeScreen({Key key}) : super(key: key);
  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  CollectionReference images = FirebaseFirestore.instance.collection('Images');
  bool _showAppbar = true;
  ScrollController _scrollController = new ScrollController();
  bool _showBottombar = true;

  @override
  void initState() {
    super.initState();
    myScroll();
  }

  @override
  void dispose() {
    _scrollController.removeListener(() { });
    super.dispose();
  }

  void myScroll() {
    _scrollController.addListener(() {
      if (_scrollController.position.userScrollDirection ==
          ScrollDirection.reverse) {
        setState(() {
          _showAppbar = false;
          _showBottombar=false;
        });
      }
      if (_scrollController.position.userScrollDirection ==
          ScrollDirection.forward) {
        setState(() {
          _showAppbar = true;
          _showBottombar=true;
        });
      }
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:_showAppbar?AppBar(
        leading: Icon(Icons.image,color: Colors.black,size: 24.0,),
        backgroundColor: Colors.green,
        title: Text('Pinterest',
            style: TextStyle(
                color: Colors.black,
                fontSize: 22.0,
                fontWeight: FontWeight.bold
            )
        ),
      ): PreferredSize(
        child: Container(),
        preferredSize: Size(0.0, 0.0),
      ),
      body:SafeArea(
        child: Padding(
          padding: EdgeInsets.only(top: 12.0),
          child: StreamBuilder<QuerySnapshot>(
              stream: images.snapshots(),
              builder:   (BuildContext context,AsyncSnapshot<QuerySnapshot> snapshot) {
                  return Stack(
                    children:[
                      MasonryGridView.builder(
                        controller: _scrollController,
                        itemCount: snapshot.data.docs.length,
                        mainAxisSpacing: 8,
                        crossAxisSpacing: 8,
                        padding: EdgeInsets.all(8),
                        gridDelegate: SliverSimpleGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2
                        ),
                        itemBuilder: (BuildContext context, int index) {
                          return Column(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(16),
                                    child: CachedNetworkImage(
                                      imageUrl: snapshot.data.docs[index].get(
                                          'URL'),
                                      errorWidget: (context, url, error) =>
                                          Icon(Icons.error),
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      Expanded(
                                          flex: 4,
                                          child: Padding(
                                              padding: EdgeInsets.only(left: 4),
                                              child: Text('Decoration Item: ' +
                                                  (index + 1).toString(),
                                                style: TextStyle(
                                                    fontWeight: FontWeight.w500
                                                ),
                                              )
                                          )
                                      ),
                                      IconButton(
                                          icon: Icon(Icons.more_horiz_sharp),
                                          alignment: Alignment.centerRight,
                                          onPressed: () {})
                                    ],
                                  )
                                ]
                            );
                        }
                    ),
                      _showBottombar?
                      Container(
                          width: 250,
                          height: 65,
                          margin: EdgeInsets.fromLTRB(68, 640, 0, 0),
                          decoration: BoxDecoration(
                              color: Colors.green.shade400,
                              borderRadius: BorderRadius.circular(40),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: <Widget>[
                              IconButton(icon: Icon(Icons.home, color: Colors.black,size: 32,), onPressed: () {},),
                              IconButton(icon: Icon(Icons.add, color: Colors.black,size: 32), onPressed: ()
                                async {
                                  final pic= await ImagePicker().pickImage(source: ImageSource.gallery);
                                  setState(() {
                                    if (pic!= null) {
                                      uploadFile(pic.path);
                                    } else {
                                      print('No image selected.');
                                    }
                                  });
                                },
                              ),
                              IconButton(icon: Icon(Icons.perm_identity, color: Colors.black,size: 32,), onPressed: () {
                                String userID=FirebaseAuth.instance.currentUser.uid;
                                SnackBar snackBar = SnackBar(
                                  content: Text('User ID: $userID'),
                                  backgroundColor: Colors.transparent,
                                );
                                ScaffoldMessenger.of(context).showSnackBar(snackBar);
                              },),
                            ],
                          )
                      ): PreferredSize(
                        child: Container(),
                        preferredSize: Size(0.0, 0.0),
                      ),
                  ]
                  );
                }
          ),
        ),
      ),
    );
  }
  Future<void> uploadFile(String filePath) async {
    File file = File(filePath);
    int lastindex=filePath.lastIndexOf('/');
    String saveFile=filePath.substring(lastindex);
    await  FirebaseStorage.instance.ref(saveFile).putFile(file);
    String downloadURL = await FirebaseStorage.instance.ref(saveFile).getDownloadURL();
    await FirebaseFirestore.instance.collection('Images').doc(saveFile).set({'URL': downloadURL,});
  }
}
