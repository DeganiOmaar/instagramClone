// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, avoid_print

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:instagram/shared/colors.dart';
// import 'package:instagram/shared/snackbar.dart';

class Profile extends StatefulWidget {
  final String userUid;

  const Profile({super.key, required this.userUid});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  Map userDetails = {};
  bool isLoading = true;

  late bool showFollow;

  late int followers;
  late int following;

  late int postCount;
  getdata() async {
    // get data from DB
    setState(() {
      isLoading = true;
    });
    try {
      DocumentSnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore
          .instance
          .collection('ppl')
          .doc(widget.userUid)
          .get();

      userDetails = snapshot.data()!;

      followers = userDetails["followers"].length;
      following = userDetails["following"].length;

      showFollow = userDetails['followers']
          .contains(FirebaseAuth.instance.currentUser!.uid);

      // to get posts length
      var snapshotPosts = await FirebaseFirestore.instance
          .collection('posts')
          .where("uid", isEqualTo: widget.userUid)
          .get();

      postCount = snapshotPosts.docs.length;
    } catch (e) {
      print(e);
    }
    setState(() {
      isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    getdata();
  }

  @override
  Widget build(BuildContext context) {
    final double widthScreen = MediaQuery.of(context).size.width;

    return isLoading
        ? Scaffold(
            backgroundColor: mobileBackgroundColor,
            body: Center(
                child: CircularProgressIndicator(
              color: Colors.white,
            )),
          )
        : Scaffold(
            backgroundColor: mobileBackgroundColor,
            appBar: AppBar(
              backgroundColor: mobileBackgroundColor,
              title: Text(userDetails["username"]),
            ),
            body: Column(
              children: [
                Row(
                  children: [
                    SizedBox(
                      width: 20,
                    ),
                    Container(
                      padding: EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color.fromARGB(125, 78, 91, 110),
                      ),
                      child: CircleAvatar(
                        radius: 40,
                        backgroundImage: NetworkImage(userDetails["profileImg"]
                            // widget.snap["profileImg"],
                            ),
                      ),
                    ),
                    SizedBox(
                      width: 15,
                    ),
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Column(
                            children: [
                              Text(
                                postCount.toString(),
                                style: TextStyle(
                                    fontSize: 24, color: primaryColor),
                              ),
                              Text(
                                "Posts",
                                style: TextStyle(color: secondaryColor),
                              )
                            ],
                          ),
                          SizedBox(
                            width: 20,
                          ),
                          Column(
                            children: [
                              Text(
                                followers.toString(),
                                style: TextStyle(
                                    fontSize: 24, color: primaryColor),
                              ),
                              Text(
                                "Followers",
                                style: TextStyle(color: secondaryColor),
                              )
                            ],
                          ),
                          SizedBox(
                            width: 20,
                          ),
                          Column(
                            children: [
                              Text(
                                following.toString(),
                                style: TextStyle(
                                    fontSize: 24, color: primaryColor),
                              ),
                              Text(
                                "Following",
                                style: TextStyle(color: secondaryColor),
                              )
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 20,
                ),
                Container(
                  padding: EdgeInsets.only(left: 20),
                  width: double.infinity,
                  child: Text(
                    userDetails["title"],
                    style: TextStyle(color: primaryColor),
                    textAlign: TextAlign.start,
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                // Divider(
                //   color: Colors.white,
                //   thickness: 0.20,
                // ),
                SizedBox(
                  height: 20,
                ),
                widget.userUid != FirebaseAuth.instance.currentUser!.uid
                    ? showFollow == true
                        ? ElevatedButton(
                            onPressed: () async {
                              setState(() {
                                showFollow = !showFollow;
                                followers -= 1;
                              });
                              await FirebaseFirestore.instance
                                  .collection('ppl')
                                  .doc(widget.userUid)
                                  .update({
                                "followers": FieldValue.arrayRemove(
                                    [FirebaseAuth.instance.currentUser!.uid])
                              });
                              await FirebaseFirestore.instance
                                  .collection('ppl')
                                  .doc(FirebaseAuth.instance.currentUser!.uid)
                                  .update({
                                "following":
                                    FieldValue.arrayRemove([widget.userUid])
                              });
                            },
                            style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all(
                                  Color.fromARGB(255, 3, 3, 3)),
                              padding: MaterialStateProperty.all(
                                  EdgeInsets.fromLTRB(60, 10, 60, 10)),
                              shape: MaterialStateProperty.all(
                                  RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                                side: BorderSide(
                                    color: secondaryColor,
                                    style: BorderStyle.solid),
                              )),
                            ),
                            child: Text(
                              "unfollow",
                              style: TextStyle(fontSize: 19),
                            ),
                          )
                        : ElevatedButton(
                            onPressed: () async {
                              setState(() {
                                showFollow = !showFollow;
                                followers += 1;
                              });
                              await FirebaseFirestore.instance
                                  .collection('ppl')
                                  .doc(widget.userUid)
                                  .update({
                                "followers": FieldValue.arrayUnion(
                                    [FirebaseAuth.instance.currentUser!.uid])
                              });

                              await FirebaseFirestore.instance
                                  .collection('ppl')
                                  .doc(FirebaseAuth.instance.currentUser!.uid)
                                  .update({
                                "following":
                                    FieldValue.arrayUnion([widget.userUid])
                              });
                            },
                            style: ButtonStyle(
                              padding: MaterialStateProperty.all(
                                  EdgeInsets.fromLTRB(60, 10, 60, 10)),
                              shape: MaterialStateProperty.all(
                                RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8)),
                              ),
                            ),
                            child: Text(
                              "Follow",
                              style: TextStyle(fontSize: 19),
                            ),
                          )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton.icon(
                            onPressed: () {},
                            icon: Icon(
                              Icons.edit,
                              color: secondaryColor,
                              size: 24.0,
                            ),
                            label: Text(
                              "Edit Profile",
                              style: TextStyle(fontSize: 16),
                            ),
                            style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all(
                                  Color.fromARGB(146, 5, 5, 5)),
                              padding: MaterialStateProperty.all(
                                  EdgeInsets.symmetric(
                                      vertical: widthScreen > 600 ? 20 : 10,
                                      horizontal: widthScreen > 600 ? 40 : 30)),
                              shape: MaterialStateProperty.all(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  side: BorderSide(
                                      color: secondaryColor,
                                      style: BorderStyle.solid),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 15,
                          ),
                          ElevatedButton.icon(
                            onPressed: () async {
                              await FirebaseAuth.instance.signOut();
                            },
                            icon: Icon(
                              Icons.logout,
                              color: Colors.white,
                              size: 24.0,
                            ),
                            label: Text(
                              "Log Out",
                              style: TextStyle(fontSize: 16),
                            ),
                            style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all(
                                  Color.fromARGB(232, 255, 67, 67)),
                              padding: MaterialStateProperty.all(
                                  EdgeInsets.symmetric(
                                      vertical: widthScreen > 600 ? 20 : 10,
                                      horizontal: widthScreen > 600 ? 40 : 30)),
                              shape: MaterialStateProperty.all(
                                  RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8))),
                            ),
                          ),
                        ],
                      ),
                SizedBox(
                  height: 30,
                ),
                FutureBuilder(
                  future: FirebaseFirestore.instance
                      .collection('posts')
                      .where("uid", isEqualTo: widget.userUid)
                      .get(),
                  builder: (BuildContext context, AsyncSnapshot snapshot) {
                    if (snapshot.hasError) {
                      return Text("Something went wrong");
                    }

                    if (snapshot.connectionState == ConnectionState.done) {
                      return Expanded(
                        child: Padding(
                          padding: widthScreen > 600
                              ? const EdgeInsets.all(50.0)
                              : const EdgeInsets.all(3.0),
                          child: GridView.builder(
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 2,
                                      childAspectRatio: 3 / 2,
                                      crossAxisSpacing: 5,
                                      mainAxisSpacing: 5),
                              itemCount: snapshot.data!.docs.length,
                              itemBuilder: (BuildContext context, int index) {
                                return ClipRRect(
                                  borderRadius: BorderRadius.circular(4),
                                  child: Image.network(
                                    snapshot.data!.docs[index]["imgPost"],
                                    // height: 400,
                                    // width: 400,
                                    fit: BoxFit.cover,
                                  ),
                                );
                              }),
                        ),
                      );
                    }

                    return Center(
                        child: CircularProgressIndicator(
                      color: Colors.white,
                    ));
                  },
                ),
              ],
            ),
          );
  }
}
