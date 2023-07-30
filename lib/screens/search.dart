// ignore_for_file: prefer_const_constructors

import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:instagram/screens/profile.dart';
import 'package:instagram/shared/colors.dart';

class Search extends StatefulWidget {
  const Search({super.key});

  @override
  State<Search> createState() => _SearchState();
}

class _SearchState extends State<Search> {
  final usernameController = TextEditingController();
  @override
  void initState() {
    super.initState();
    // Start listening to changes.
    usernameController.addListener(_printLatestValue);
  }

  _printLatestValue() {
    setState(() {});
  }

  @override
  void dispose() {
    usernameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: mobileBackgroundColor,
        appBar: AppBar(
          backgroundColor: mobileBackgroundColor,
          title: TextFormField(
            // onChanged: (value) {
            //   setState(() {});
            // },
            controller: usernameController,
            decoration:
                const InputDecoration(labelText: 'Search For a user ...'),
          ),
        ),
        body: FutureBuilder(
          future: FirebaseFirestore.instance
              .collection('ppl')
              .where("username", isEqualTo: usernameController.text)
              .get(),
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (snapshot.hasError) {
              return Text("Something went wrong");
            }

            if (snapshot.connectionState == ConnectionState.done) {
              return ListView.builder(
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (BuildContext context, int index) {
                    return ListTile(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => Profile(
                                      userUid: snapshot.data!.docs[index]
                                          ['uid'],
                                    )));
                      },
                      title: Text(snapshot.data!.docs[index]['username']),
                      leading: CircleAvatar(
                        radius: 30,
                        backgroundImage: NetworkImage(
                            snapshot.data!.docs[index]['profileImg']),
                      ),
                    );
                    
                  });
                  
            }

            return Center(
                child: CircularProgressIndicator(
              color: Colors.white,
            ));
          },
        ));
  }
}
