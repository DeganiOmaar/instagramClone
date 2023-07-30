// ignore_for_file: unused_local_variable, avoid_print

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_storage/firebase_storage.dart';
import 'package:instagram/firebase_services/storage.dart';
import 'package:instagram/models/user.dart';
import 'package:instagram/shared/snackbar.dart';

class AuthMethods {
  register(
      {required emaill,
      required passwordd,
      required context,
      required titlee,
      required usernamee,
      required imgPath,
      required imgName}) async {
    try {
      final credential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emaill,
        password: passwordd,
      );
      String urll = await getImgUrl(
          imgName: imgName, imgPath: imgPath, folderName: 'UserProfileImg');

      // firebase firestore (data base)
      CollectionReference users = FirebaseFirestore.instance.collection('ppl');

      UserData userr = UserData(
          email: emaill,
          password: passwordd,
          title: titlee,
          username: usernamee,
          profileImg: urll,
          uid: credential.user!.uid,
          followers: [],
          following: []);

      users
          .doc(credential.user!.uid)
          .set(userr.convert2Map())
          .then((value) => print("User Added"))
          .catchError((error) => print("Failed to add user: $error"));
    } on FirebaseAuthException catch (e) {
      showSnackBar(context, "ERROR :  ${e.code} ");
    }
  }

  signIn({required emailAddress, required password, required context}) async {
    try {
      final credential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: emailAddress, password: password);
    } on FirebaseAuthException catch (e) {
      showSnackBar(context, "ERROR :  ${e.code} ");
    }
  }

  // functoin to get user details from Firestore (Database)
  Future<UserData> getUserDetails() async {
    DocumentSnapshot snap = await FirebaseFirestore.instance
        .collection('ppl')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get();
    return UserData.convertSnap2Model(snap);
  }
}
