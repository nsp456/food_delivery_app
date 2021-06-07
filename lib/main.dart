import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';

import 'package:food_delivery_app/user/Start.dart';
import 'package:food_delivery_app/auth_screens/sign_in.dart';
import 'package:food_delivery_app/auth_screens/sign_up.dart';
import 'package:food_delivery_app/user/Menucard.dart';
import 'package:food_delivery_app/widgets/loading.dart';
import 'package:food_delivery_app/backend/auth.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
      .then((_) {
    runApp(FoodMain());
  });
}

class FoodMain extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      routes: {
        '/signup': (context) => SignUp(),
        '/signin': (context) => SignIn(),
        '/start': (context) => StartPage(),
        '/user': (context) => StartPage(),
        '/home': (context) => MenuOptionSide(
              automatic: true,
            ),
      },
      home: FutureBuilder(
          future: Auth().getCurrentUser(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Loading();
            } else {
              if (snapshot.hasData) {
                return StartPage();
              } else {
                return SignIn();
              }
            }
          }),
      theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
          fontFamily: 'Roboto',
          hintColor: Color(0xFFd0cece)),
    );
  }
}
