import 'package:upload_pictures/OTPpage.dart';
import 'package:flutter/material.dart';
import 'package:upload_pictures/WelcomeScreen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:fluttertoast/fluttertoast.dart';
class Verification extends StatefulWidget {
  @override
  _VerificationState createState() => _VerificationState();
}

class _VerificationState extends State<Verification> {
  String number;
  final _form = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Icon(Icons.image,color: Colors.black,size: 24.0,),
        backgroundColor: Colors.green,
        title: Text('Pinterest',
        style: TextStyle(
          color: Colors.black,
        fontSize: 22.0,
        fontWeight: FontWeight.bold
      )
      ),
      ),
      body: Form(
        key: _form,
        child: Padding(
          padding: EdgeInsets.all(10),
          child: Container(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                    Container(
                      margin: EdgeInsets.fromLTRB(80.0, 0.0, 80.0, 120.0),
                      padding: EdgeInsets.all(16.0),
                        decoration: BoxDecoration(color: Colors.green.shade400,borderRadius: BorderRadius.circular(8.0)),
                        child: Center(child: Text('Register',style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold),)),
                    ),
                TextFormField(
                  onChanged: (value) {
                    number = value;
                  },
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.done,
                  textAlign: TextAlign.start,
                  validator: (String no) {
                    if (no.length != 10)
                      return 'Invalid Number';
                    else
                      return null;
                  },
                  decoration: InputDecoration(
                    labelText: 'Mobile Number',
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.green, width: 3.0),),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.green, width: 3.0),
                    ),
                ),
                ),
                SizedBox(
                  height: 16.0,
                ),
                Padding(
                  padding: EdgeInsets.all(5),
                  child: MaterialButton(
                    color: Colors.green,
                    onPressed: () async {
                      FocusScope.of(context).requestFocus(FocusNode());
                      if (_form.currentState.validate()) {
                            Navigator.pushAndRemoveUntil(context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      OTP(
                                          number: number)),
                                  (Route<dynamic> route) => false,
                            );
                          }
                          else {
                            Fluttertoast.showToast(
                                msg: 'Invaild Number');
                          }
                        },
                    child: Text('Send OTP'),
                  ),
                ),
                SizedBox(
                  height: 32.0,
                ),
                Divider(
                  thickness: 3.0,
                  color: Colors.green.shade200,
                ),
                SizedBox(
                  height: 32.0,
                ),
                Padding(
                  padding: EdgeInsets.all(5),
                  child: MaterialButton(
                    color: Colors.blue,
                    onPressed: () {
                      _signInWithGoogle();
                    },
                    child:Text('Register with Google')
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _signInWithGoogle() async {
    FirebaseAuth _firebase = FirebaseAuth.instance;
   // FirebaseFirestore _firestore = FirebaseFirestore.instance;
    final GoogleSignInAccount googleSignInAccount = await GoogleSignIn()
        .signIn();
    final GoogleSignInAuthentication googleSignInAuthentication = await googleSignInAccount
        .authentication;
    final GoogleAuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleSignInAuthentication.accessToken,
      idToken: googleSignInAuthentication.idToken,
    );
    final UserCredential authResult = await _firebase.signInWithCredential(
        credential);
    final User user = authResult.user;
    if (user != null) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) =>
                WelcomeScreen()),
                (Route<dynamic> route) => false,
          );
        }
        else {
          Fluttertoast.showToast(msg: 'Invalid Person');
        }
      }

}