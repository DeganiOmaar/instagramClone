// ignore_for_file: avoid_print

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:instagram/firebase_services/storage.dart';
import 'package:instagram/models/post.dart';
import 'package:instagram/shared/snackbar.dart';
import 'package:uuid/uuid.dart';

class FireStoreMethods {
  uploadPost(
      {required imgName,
      required imgPath,
      required description,
      required profileImg,
      required username,
      required context}) async {
    try {
      String urll = await getImgUrl(
          imgName: imgName,
          imgPath: imgPath,
          folderName: 'imgPosts/${FirebaseAuth.instance.currentUser!.uid}');

      // firebase firestore (data base)
      CollectionReference posts =
          FirebaseFirestore.instance.collection('posts');
      String newId = const Uuid().v1();
      PostData post = PostData(
          datePublished: DateTime.now(),
          description: description,
          imgPost: urll,
          likes: [],
          postId: newId,
          profileImg: profileImg,
          uid: FirebaseAuth.instance.currentUser!.uid,
          username: username);

      posts
          .doc(newId)
          .set(post.convert2Map())
          .then((value) => print("Post Added Succeffly"))
          .catchError((error) => print("Failed to add Post: $error"));
    } on FirebaseAuthException catch (e) {
      showSnackBar(context, "ERROR :  ${e.code} ");
    }
  }

  uploadComment(
      {required commentText,
      required postId,
      required profileImg,
      required username,
      required uid}) async {
    String commentId = const Uuid().v1();
    await FirebaseFirestore.instance
        .collection('posts')
        .doc(postId)
        .collection('comments')
        .doc(commentId)
        .set({
      "profilePic": profileImg,
      "username": username,
      "textComment": commentText,
      "datePublished": DateTime.now(),
      "uid": uid,
      "commentId": commentId
    });
  }

  changeLikes({required Map postData}) async {
    try {
      if (postData["likes"].contains(FirebaseAuth.instance.currentUser!.uid)) {
        await FirebaseFirestore.instance
            .collection('posts')
            .doc(postData['postId'])
            .update({
          "likes":
              FieldValue.arrayRemove([FirebaseAuth.instance.currentUser!.uid])
        });
      } else {
        await FirebaseFirestore.instance
            .collection('posts')
            .doc(postData['postId'])
            .update({
          "likes":
              FieldValue.arrayUnion([FirebaseAuth.instance.currentUser!.uid])
        });
      }
    } catch (e) {
      print(e.toString());
    }
  }
}
