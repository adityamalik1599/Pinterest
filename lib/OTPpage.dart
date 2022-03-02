import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:upload_pictures/WelcomeScreen.dart';
import 'package:fluttertoast/fluttertoast.dart';

class OTP extends StatefulWidget {
  final String number;
  OTP(
      {Key key, @required this.number})
      : super(key: key);

  @override
  _OTPState createState() => _OTPState();
}

class _OTPState extends State<OTP> {
  final _formstate = GlobalKey<FormState>();
  String smsCode;
  String verificationCode;
  FirebaseAuthException exception;
  FirebaseAuth _auth=FirebaseAuth.instance;

  @override
  void initState() {
    _letsbegin();
    super.initState();
  }

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
        key: _formstate,
        child: Padding(
          padding: EdgeInsets.all(10),
          child: Container(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                TextFormField(
                  onChanged: (value) {
                    smsCode = value;
                  },
                  textInputAction: TextInputAction.done,
                  validator: (String name) {
                    if (smsCode != 6||exception.code=='invalid-verification-code')
                      return 'Invalid OTP';
                    else
                      return null;
                  },
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.start,
                  decoration: InputDecoration(
                    labelText: 'OTP',
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.green, width: 3.0),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.green, width: 3.0),
                    ),
                  ),
                ),
                SizedBox(
                  height: 16.0,
                ),
                Container(
                  color: Colors.green,
                  child: TextButton(
                      child: Text('Verify', style: TextStyle(color: Colors.black),),
                      onPressed: () async {
                        FocusScope.of(context).requestFocus(FocusNode());
                        if(_formstate.currentState.validate()) {
                          PhoneAuthCredential phoneAuthCredential = PhoneAuthProvider
                              .credential(verificationId: verificationCode,
                              smsCode: smsCode);
                          UserCredential result = await _auth
                              .signInWithCredential(phoneAuthCredential);
                          User user = result.user;
                          if (user != null) {
                              Navigator.pushAndRemoveUntil(context,
                                  MaterialPageRoute(builder: (context) =>WelcomeScreen()),
                                      (Route<dynamic> route) => false
                              );
                            }
                          } else {
                            Fluttertoast.showToast(msg:'Some Error Occured');
                          }
                        }

                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _letsbegin() async
  {
    await _auth.verifyPhoneNumber(
      phoneNumber: '+91' + widget.number,
      timeout: Duration(seconds: 60),
      verificationCompleted: (PhoneAuthCredential credential) async {
        UserCredential result = await _auth.signInWithCredential(credential);
        User user = result.user;
        if (user != null) {
  Navigator.pushAndRemoveUntil(context,
  MaterialPageRoute(builder: (context) => WelcomeScreen()),
  (Route<dynamic> route) => false
  );
  }
        else {
          Fluttertoast.showToast(msg: 'Some Error Occured');
        }
      },
      verificationFailed: (FirebaseAuthException e) {
        exception=e;
        if (e.code == 'invalid-verification-code') {
          Fluttertoast.showToast(msg:'Invalid Verification Code');
        }
      },
      codeSent: (String verificationId, int resendToken) {
        this.verificationCode = verificationId;
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        this.verificationCode = verificationId;
      },
    );
  }
}

