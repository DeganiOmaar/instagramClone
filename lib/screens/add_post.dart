// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors, use_build_context_synchronously, depend_on_referenced_packages

import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:instagram/firebase_services/firestore.dart';
import 'package:instagram/provider/user_provider.dart';
// import 'package:instagram/screens/home.dart';
import 'package:instagram/shared/colors.dart';
import 'package:instagram/shared/snackbar.dart';

import 'package:path/path.dart' show basename;
import 'package:provider/provider.dart';

class AddPost extends StatefulWidget {
  const AddPost({super.key});

  @override
  State<AddPost> createState() => _AddPostState();
}

class _AddPostState extends State<AddPost> {
  final descriptionController = TextEditingController();
  Uint8List? imgPath;
  String? imgName;
  bool isloading = false;

  uploadImage2Screen(ImageSource source) async {
    Navigator.pop(context);
    final XFile? pickedImg = await ImagePicker().pickImage(source: source);
    try {
      if (pickedImg != null) {
        imgPath = await pickedImg.readAsBytes();
        setState(() {
          // imgPath = File(pickedImg.path);
          imgName = basename(pickedImg.path);
          int random = Random().nextInt(9999999);
          imgName = "$random$imgName";
          // print(imgName);
        });
      } else {
        showSnackBar(context, 'NO img selected');
      }
    } catch (e) {
      showSnackBar(context, "Error => $e");
    }
  }

  showmodel() {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return SimpleDialog(
          children: [
            SimpleDialogOption(
              onPressed: () async {
                // Navigator.of(context).pop();
                await uploadImage2Screen(ImageSource.camera);
              },
              padding: EdgeInsets.all(20),
              child: Text(
                "From Camera",
                style: TextStyle(
                  fontSize: 18,
                ),
              ),
            ),
            SimpleDialogOption(
              onPressed: () async {
                // Navigator.of(context).pop();
                await uploadImage2Screen(ImageSource.gallery);
              },
              padding: EdgeInsets.all(20),
              child: Text(
                "From Gallary",
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
  Widget build(BuildContext context) {
    final allDataFromDB = Provider.of<UserProvider>(context).getUser;
    return imgPath != null
        ? Scaffold(
            backgroundColor: mobileBackgroundColor,
            appBar: AppBar(
              actions: [
                TextButton(
                  onPressed: () async {
                    setState(() {
                      isloading = true;
                    });
                    await FireStoreMethods().uploadPost(
                        imgName: imgName,
                        imgPath: imgPath,
                        description: descriptionController.text,
                        profileImg: allDataFromDB!.profileImg,
                        username: allDataFromDB.username,
                        context: context);
                    setState(() {
                      isloading = false;
                      imgPath = null;
                    });
                  },
                  child: const Text(
                    "Post",
                    style: TextStyle(
                        color: Colors.blueAccent,
                        fontSize: 19,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ],
              backgroundColor: mobileBackgroundColor,
              leading: IconButton(
                  onPressed: () {
                    setState(() {
                      imgPath = null;
                      isloading = false;
                    });
                  },
                  icon: Icon(Icons.arrow_back)),
            ),
            body: Column(
              children: [
                isloading
                    ? LinearProgressIndicator()
                    : Divider(
                        thickness: 1,
                        height: 30,
                      ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundImage: NetworkImage(allDataFromDB!.profileImg),
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.3,
                      child: TextField(
                        controller: descriptionController,
                        maxLines: 8,
                        decoration: InputDecoration(
                            hintText: "Write ur Description ...",
                            border: InputBorder.none),
                      ),
                    ),
                    Container(
                      width: 66,
                      height: 74,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                            image: MemoryImage(imgPath!), fit: BoxFit.cover),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          )
        : Scaffold(
            backgroundColor: mobileBackgroundColor,
            body: Center(
              child: IconButton(
                onPressed: () {
                  showmodel();
                },
                icon: const Icon(
                  Icons.upload,
                  size: 50,
                ),
              ),
            ),
          );
  }
}
