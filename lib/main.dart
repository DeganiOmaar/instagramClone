import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:instagram/provider/user_provider.dart';
import 'package:instagram/responsive/mobile.dart';
import 'package:instagram/responsive/reponsive.dart';
import 'package:instagram/responsive/web.dart';
import 'package:instagram/screens/sign_in.dart';
import 'package:instagram/shared/snackbar.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (kIsWeb) {
    await Firebase.initializeApp(
        options: const FirebaseOptions(
            apiKey: "AIzaSyByS8xZsmRvsipLI4yEDhgIYAptcoI4ZQA",
            authDomain: "secondinsta-430c8.firebaseapp.com",
            projectId: "secondinsta-430c8",
            storageBucket: "secondinsta-430c8.appspot.com",
            messagingSenderId: "1070296504185",
            appId: "1:1070296504185:web:d4a2706ba170c6d8cb41a8"));
  } else {
    await Firebase.initializeApp();
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) {
        return UserProvider();
      },
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData.dark(),
        home: StreamBuilder(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                  child: CircularProgressIndicator(
                color: Colors.white,
              ));
            } else if (snapshot.hasError) {
              return showSnackBar(context, "Something went wrong");
            } else if (snapshot.hasData) {
              return const Responsive(
                myMobileScreen: MobileScreen(),
                myWebScreen: WebScerren(),
              );
            } else {
              return const Login();
            }
          },
        ),
        // home: const Responsive(
        //   myMobileScreen: MobileScreen(),
        //   myWebScreen: WebScerren(),
        // ),
      ),
    );
  }
}
