import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'HomeScreen.dart';

enum MobileVerificationState {
  SHOW_MOBILE_FORM_STATE,
  SHOW_OTP_FORM_STATE,
}

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  MobileVerificationState currentState =
      MobileVerificationState.SHOW_MOBILE_FORM_STATE;
  final phoneController = TextEditingController();
  final otpController = TextEditingController();

  FirebaseAuth _auth = FirebaseAuth.instance;

  late String verificationId;

  bool showLoading = false;

  void signInWithPhoneAuthCredential(
      PhoneAuthCredential phoneAuthCredential) async {
    setState(() {
      showLoading = true;
    });

    try {
      final authCredential =
          await _auth.signInWithCredential(phoneAuthCredential);
      setState(() {
        showLoading = false;
      });

      if (authCredential.user != null) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MyHomePage(),
          ),
        );
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        showLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.message!),
        ),
      );
    }
  }

  getMobileFormWidget(context) {
    return Column(
      children: [
        Spacer(),
        TextField(
          controller: phoneController,
          decoration: InputDecoration(hintText: 'Enter your phone'),
        ),
        SizedBox(
          height: 16.0,
        ),
        ElevatedButton(
          onPressed: () async {
            _auth.verifyPhoneNumber(
              phoneNumber: phoneController.text,
              verificationCompleted: (phoneAuthCredential) async {
                setState(() {
                  showLoading = false;
                });
              },
              verificationFailed: (verificationFaild) async {
                setState(() {
                  showLoading = false;
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(verificationFaild.message!),
                  ),
                ); // baaaad thing, try to find another solution
              },
              codeSent: (verificationId, resendingToken) async {
                setState(() {
                  showLoading = false;
                  currentState = MobileVerificationState.SHOW_OTP_FORM_STATE;
                  this.verificationId = verificationId;
                });
              },
              codeAutoRetrievalTimeout: (verificationId) async {},
            );
          },
          child: Text('Verify'),
        ),
        Spacer()
      ],
    );
  }

  getOtpFormWidget(context) {
    return Column(
      children: [
        Spacer(),
        TextField(
          controller: otpController,
          decoration: InputDecoration(hintText: 'Enter your OTP code'),
        ),
        SizedBox(
          height: 16.0,
        ),
        ElevatedButton(
          onPressed: () {
            PhoneAuthCredential phoneAuthCredential =
                PhoneAuthProvider.credential(
                    verificationId: verificationId,
                    smsCode: otpController.text);

            signInWithPhoneAuthCredential(phoneAuthCredential);
          },
          child: Text('Send code'),
        ),
        Spacer()
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: showLoading
            ? Center(child: CircularProgressIndicator())
            : currentState == MobileVerificationState.SHOW_MOBILE_FORM_STATE
                ? getMobileFormWidget(context)
                : getOtpFormWidget(context),
        padding: const EdgeInsets.all(16),
      ),
    );
  }
}
