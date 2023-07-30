// ignore_for_file: prefer_const_constructors, avoid_print

// import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:instagram/firebase_services/firestore.dart';
import 'package:instagram/screens/comment.dart';
import 'package:instagram/shared/heart_animation.dart';
import 'package:intl/intl.dart';

import 'colors.dart';

class PostDesign extends StatefulWidget {
  final Map data;
  const PostDesign({super.key, required this.data});

  @override
  State<PostDesign> createState() => _PostDesignState();
}

class _PostDesignState extends State<PostDesign> {
  int commentCount = 0;
  bool showHeart = false;
  bool isLikeAnimating = false;

  getCommentCount() async {
    try {
      QuerySnapshot commentData = await FirebaseFirestore.instance
          .collection('posts')
          .doc(widget.data['postId'])
          .collection('comments')
          .get();
      setState(() {
        commentCount = commentData.docs.length;
      });
    } catch (e) {
      print(e.toString());
    }
  }

  showmodel() {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return SimpleDialog(
          children: [
            FirebaseAuth.instance.currentUser!.uid == widget.data['uid']
                ? SimpleDialogOption(
                    onPressed: () async {
                      Navigator.of(context).pop();
                      await FirebaseFirestore.instance
                          .collection('posts')
                          .doc(widget.data['postId'])
                          .delete();
                    },
                    padding: EdgeInsets.all(20),
                    child: Text(
                      "Delete Post",
                      style: TextStyle(
                        fontSize: 18,
                      ),
                    ),
                  )
                : SimpleDialogOption(
                    padding: EdgeInsets.all(20),
                    child: Text(
                      "Can not delete this Post",
                      style: TextStyle(
                        fontSize: 18,
                      ),
                    ),
                  ),
            SimpleDialogOption(
              onPressed: () async {
                Navigator.of(context).pop();
              },
              padding: EdgeInsets.all(20),
              child: Text(
                "Cancel",
                style: TextStyle(
                  fontSize: 18,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    getCommentCount();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final double widthScreen = MediaQuery.of(context).size.width;
    return Container(
      decoration: BoxDecoration(
          color: mobileBackgroundColor,
          borderRadius: BorderRadius.circular(12)),
      margin: EdgeInsets.symmetric(
        vertical: 11,
        horizontal: widthScreen > 600 ? widthScreen / 5 : 0,
      ),
      child: SingleChildScrollView(
        child: Column(
          children: [
            // SizedBox(
            //   height: 5,
            // ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color.fromARGB(125, 78, 91, 110),
                        ),
                        child: CircleAvatar(
                          radius: 24,
                          backgroundImage: NetworkImage(
                            // widget.snap["profileImg"],
                            widget.data['profileImg'],
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 20,
                      ),
                      Text(
                        widget.data['username'],
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                  IconButton(
                    onPressed: () {
                      showmodel();
                    },
                    icon: Icon(Icons.more_vert),
                  ),
                ],
              ),
            ),
            GestureDetector(
              onDoubleTap: () async {
                setState(() {
                  isLikeAnimating = true;
                });
                await FirebaseFirestore.instance
                    .collection('posts')
                    .doc(widget.data['postId'])
                    .update({
                  "likes": FieldValue.arrayUnion(
                      [FirebaseAuth.instance.currentUser!.uid])
                });

                // // after 1 seec
                // Timer(Duration(seconds: 1), () {
                //   setState(() {
                //     showHeart = false;
                //   });
                // });
              },
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Image.network(
                    // widget.snap["postUrl"],
                    widget.data['imgPost'],
                    loadingBuilder: (context, child, progress) {
                      return progress == null
                          ? child
                          : SizedBox(
                              child: Center(
                                  child: CircularProgressIndicator(
                                color: Colors.white,
                              )),
                            );
                    },
                    fit: BoxFit.cover,
                    // height: MediaQuery.of(context).size.height * 0.35,
                    width: double.infinity,
                  ),
                  AnimatedOpacity(
                    duration: const Duration(milliseconds: 200),
                    opacity: isLikeAnimating ? 1 : 0,
                    child: LikeAnimation(
                      isAnimating: isLikeAnimating,
                      duration: const Duration(
                        milliseconds: 400,
                      ),
                      onEnd: () {
                        setState(() {
                          isLikeAnimating = false;
                        });
                      },
                      child: Icon(
                        Icons.favorite,
                        color: Colors.white,
                        size: 111,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(
              height: 10,
            ),
            Padding(
              padding: const EdgeInsets.only(right: 10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      LikeAnimation(
                        isAnimating: widget.data['likes']
                            .contains(FirebaseAuth.instance.currentUser!.uid),
                        smallLike: true,
                        child: IconButton(
                          onPressed: () async {
                            await FireStoreMethods()
                                .changeLikes(postData: widget.data);
                          },
                          icon: widget.data['likes'].contains(
                                  FirebaseAuth.instance.currentUser!.uid)
                              ? const Icon(
                                  Icons.favorite,
                                  color: Colors.red,
                                )
                              : const Icon(
                                  Icons.favorite_border,
                                ),
                        ),
                      ),
                      

                      SizedBox(
                        width: 10,
                      ),
                      IconButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    CommentScreen(data: widget.data)),
                          );
                        },
                        icon: Icon(Icons.comment_outlined),
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      IconButton(
                        onPressed: () {},
                        icon: Icon(Icons.send),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      IconButton(
                        onPressed: () {},
                        icon: Icon(Icons.bookmark_add_outlined),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 15.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        "${widget.data['likes'].length}  ${widget.data['likes'].length > 1 ? "Likes" : "Like"} ",
                        style: TextStyle(color: secondaryColor, fontSize: 18),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Row(
                    children: [
                      Text(
                        widget.data['username'],
                        style: TextStyle(color: primaryColor, fontSize: 20),
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Text(
                        widget.data['description'],
                        style: TextStyle(color: secondaryColor, fontSize: 18),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Row(
                    children: [
                      InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => CommentScreen(
                                      data: widget.data,
                                    )),
                          );
                        },
                        child: Text(
                          "View All $commentCount Comments",
                          style: TextStyle(color: secondaryColor, fontSize: 18),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Row(
                    children: [
                      Text(
                        // widget.data['datePublished'].toDate().toString(),
                        DateFormat.yMMMMd()
                            .format(widget.data['datePublished'].toDate()),
                        style: TextStyle(color: secondaryColor, fontSize: 16),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 10,
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
