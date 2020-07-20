import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:upload_pic/Screens/MyHomePage.dart';

class Login extends StatelessWidget {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.white30,
        child: GestureDetector(
          onTap: () {
            signinwithGoogle().whenComplete(() {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => MyHomePage()),
              );
            });
          },
          child: Center(
            child: Chip(
              elevation: 10,
              backgroundColor: Colors.grey,
              label: Text(
                "Login with Gmail",
                style: TextStyle(fontSize: 30),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<FirebaseUser> signinwithGoogle() async {
    ///creating a refrence for google signinaccount
    final GoogleSignInAccount googleSignInAccount =
        await _googleSignIn.signIn();

    final GoogleSignInAuthentication googleSignInAuthentication =
        await googleSignInAccount.authentication;

    final AuthCredential credential = GoogleAuthProvider.getCredential(
      accessToken: googleSignInAuthentication.accessToken,
      idToken: googleSignInAuthentication.idToken,
    );

    final AuthResult authResult =
        await _firebaseAuth.signInWithCredential(credential);

    final FirebaseUser user = authResult.user;

    final FirebaseUser currentUser = await _firebaseAuth.currentUser();

    if (currentUser != null) {
      final QuerySnapshot result = await Firestore.instance
          .collection('users')
          .where("id", isEqualTo: currentUser.uid)
          .getDocuments();

      final List<DocumentSnapshot> document = result.documents;

      if (document.length == 0) {
        Firestore.instance
            .collection('users')
            .document(currentUser.uid)
            .setData({
          /// here then we setData i.e, we can say we push the data unto the firebase of the user info.
          'id': currentUser.uid,
          'username': currentUser.displayName,
          'profilePicture': currentUser.photoUrl
        });
      } else {}
    }
    return user;
  }
}
