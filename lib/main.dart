import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:cached_network_image/cached_network_image.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  CollectionReference images = FirebaseFirestore.instance.collection('Images');
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:StreamBuilder<QuerySnapshot>(
          stream: images.snapshots(),
        builder:   (BuildContext context,AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return Text("Something went wrong");
          }

          if (snapshot.connectionState == ConnectionState.waiting ||
              snapshot.hasData != true) {
            return Container(
              height: double.infinity,
              width: double.infinity,
              color: Colors.white,
              child: Center(
                child: CircularProgressIndicator(
                  backgroundColor: Colors.black,),
              ),
            );
          }
          else {
            return SafeArea(
              child: MasonryGridView.builder(
                  itemCount: snapshot.data.docs.length,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                  padding: EdgeInsets.all(8),
                  gridDelegate: SliverSimpleGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2
                  ),
                  itemBuilder: (BuildContext context, int index) {
                    return Container(
                      child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: CachedNetworkImage(
                            imageUrl: snapshot.data.docs[index].get('URL'),
                            errorWidget: (context,url,error)=>Icon(Icons.error),
                          ),
                      ),
                    );
                  }
              ),
            );
        }
        }
      ),
      floatingActionButton: FloatingActionButton(
       onPressed: () async {
        final pic= await ImagePicker().pickImage(source: ImageSource.gallery);
         setState(() {
           if (pic!= null) {
             uploadFile(pic.path);
           } else {
             print('No image selected.');
           }
         });
       },
          child: Icon(Icons.add),
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
