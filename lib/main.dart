import 'dart:async';
import 'package:flutter/material.dart';
import 'package:maxfit/core/constants.dart';
import 'package:maxfit/domain/user.dart';
import 'package:maxfit/screens/landing.dart';
import 'package:maxfit/services/auth.dart';
import 'package:provider/provider.dart';

void main() => runApp(MaxFitApp());

class MaxFitApp extends StatefulWidget {
  @override
  _MaxFitAppState createState() => _MaxFitAppState();
}

class _MaxFitAppState extends State<MaxFitApp> {
  StreamSubscription<User> userStreamSubscription;
  Stream<User> userDataStream;

  StreamSubscription<User> setUserDataStream(){
    final auth = AuthService();
    return auth.currentUser.listen((user) {
      userDataStream = auth.getCurrentUserWithData(user);
      setState(() {});
    });
  }

  @override
  void initState() {
    super.initState();
    userStreamSubscription = setUserDataStream();
  }

  @override
  void dispose() {
    super.dispose();
    userStreamSubscription.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return StreamProvider<User>.value(
      value: userDataStream,
      child: MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Max Fitness',
          theme: ThemeData(
              primaryColor: bgColorPrimary,
              textTheme: TextTheme(headline6: TextStyle(color: Colors.white))),
          home: LandingPage()),
    );
  }
}