// ignore: import_of_legacy_library_into_null_safe
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:teams_clone/resources/auth_methods.dart';
//import 'package:teams_clone/resources/firebase_repository.dart';
import 'package:teams_clone/screens/home_screen.dart';
import 'package:teams_clone/screens/pageviews/auth_meet_screen.dart';
import 'package:teams_clone/screens/pageviews/enter_groupcall.dart';
import 'package:teams_clone/utils/universal_variables.dart';
import 'package:url_launcher/url_launcher.dart';

// Screen visible when user opens the app
class LoginScreen extends StatefulWidget{
  @override
  LoginScreenState createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen>{
  final AuthMethods _authMethods = AuthMethods();
  bool isLoginPressed = false;


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Container(
        padding: EdgeInsets.fromLTRB(10, 40, 10, 10),
        child: Stack(
          children:
          [Column(children:[
            Center(
             child: Text('Teams Clone',
                style: TextStyle(color: Colors.deepPurple, fontSize: 24.0),
              ),
            ),
            Container(
              height: 300.0,
              width: 300.0,
              child: Image.asset('assets/team.png',),
            ),
            SizedBox(height: 20,),
            Text( 'Welcome To Microsoft Teams Clone! \n A happier place for teams \n to work together.',
              style: TextStyle(color: Colors.grey, fontSize: 20.0),
              textAlign: TextAlign.center,
            ), // Text
            SizedBox(height: 20.0),
            Container( height: 50.0, width: 280.0,
              child: Material(
                borderRadius: BorderRadius.circular(3.0),
                color: Colors.deepPurple,
                child: GestureDetector( onTap: (){
                  performLogin();},
                  child: Center(
                    child: Text('Sign in',
                      style: TextStyle(color: Colors.white, fontSize: 15.0),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 10.0),
            Container(height: 50.0,
              width: 280.0,
              child: Material(
                shape: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(3) ),
                color: Colors.white,
                child: GestureDetector(
                  onTap: ()
                  {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MeetScreen(),
                        ));
                    },
                  child: Center(
                    child: Text('Join a meeting',
                      style: TextStyle(color: Colors.deepPurple, fontSize: 15.0), ), // Text
                  ),
                ),
              ),
            ),
            SizedBox(height: 40.0),
            InkWell(
                onTap: (){
                  launch('https://support.microsoft.com/en-us/office/learn-more-about-teams-f87289ef-3c5a-4b8e-aaed-6eb99e51ade7');
                },
                child: Text("Learn More",
                  style: TextStyle(color: Colors.deepPurple, fontSize: 15.0),
                )


            ),],
          ),
          ],
        ),
      ),
    );
  } // Scaffold

  Widget loginButton(){
    return TextButton(
      onPressed: ()=>performLogin(), 
      child: Text(
        "LOGIN",
        style: TextStyle(
          fontSize: 35,
          fontWeight: FontWeight.w900,
          letterSpacing: 1.2
        ),
      ),
      );
  }

  void performLogin(){
    setState(() {
      isLoginPressed = true;
    });
    _authMethods.signIn().then((FirebaseUser user){
      if (user!=null){
        authenticateUser(user);
      }
      else{
        print("Error!");
      }
    });
  }
  void authenticateUser(FirebaseUser user){
    _authMethods.authenticateUser(user).then((isNewUser){
      setState(() {
        isLoginPressed = false;
      });
      if (isNewUser){
        _authMethods.addDataToDb(user).then((value){
          Navigator.pushReplacement(context, 
          MaterialPageRoute(builder: (context){
            return HomeScreen();
          }));
        });
      }
      else {
        Navigator.pushReplacement(context, 
          MaterialPageRoute(builder: (context){
            return HomeScreen();
          }));
      }
    });
  }
}