// ignore: import_of_legacy_library_into_null_safe
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:teams_clone/provider/image_upload_provider.dart';
import 'package:teams_clone/provider/user_provider.dart';
import 'package:teams_clone/resources/auth_methods.dart';
//import 'package:teams_clone/resources/firebase_repository.dart';
import 'package:teams_clone/screens/home_screen.dart';
import 'package:teams_clone/screens/login_screen.dart';
import 'package:teams_clone/screens/search_screen.dart';


void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  final AuthMethods _authMethods = AuthMethods();
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ImageUploadProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
      ],
      child: MaterialApp(
       title: "teams Clone",
       debugShowCheckedModeBanner: false,
       initialRoute: "/",
       routes: {
          '/search_screen' : (context) => SearchScreen(),
          },
       home: FutureBuilder(
         future: _authMethods.getCurrentUser(),
         builder: (context, AsyncSnapshot<FirebaseUser> snapshot) {
          if (snapshot.hasData){
            return HomeScreen();
          }
          else {
            return LoginScreen();
          }
         },
       ),
      ),
    );
  }
}