import 'package:cloud_firestore/cloud_firestore.dart';

class UserData {
  String username;
  String title;
  String email;
  String password;
  String profileImg;
  String uid;
  List followers;
  List following;

  UserData(
      {required this.username,
      required this.title,
      required this.email,
      required this.password,
      required this.profileImg,
      required this.uid,
      required this.followers,
      required this.following});

  // to convert the UserData( Data Type) to Map<String>, Object>

  Map<String, dynamic> convert2Map() {
    return {
      "username": username,
      "title": title,
      "email": email,
      "password": password,
      "profileImg": profileImg,
      "uid": uid,
      "followers": [],
      "following": []
    };
  }

  // function that convert "DocumentSnapshot" to a User
// function that takes "DocumentSnapshot" and return a User

  static convertSnap2Model(DocumentSnapshot snap) {
    var snapshot = snap.data() as Map<String, dynamic>;
    return UserData(
      username: snapshot["username"],
      title: snapshot["title"],
      email: snapshot["email"],
      password: snapshot["password"],
      profileImg: snapshot["profileImg"],
      uid: snapshot["uid"],
      followers: snapshot["followers"],
      following: snapshot["following"],
    );
  }
}
