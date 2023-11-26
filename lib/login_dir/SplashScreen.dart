import 'package:flutter/material.dart';
class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) :super(key : key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>{
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body : Stack(
        children: [
          Image(
              fit:BoxFit.cover,
              height:double.infinity,
              width: double.infinity,
              image: AssetImage('assets/splash.png')),
          Container(
            decoration:BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                colors: [
                  Colors.black,
                  Colors.black.withOpacity(0.4),
                  Colors.black.withOpacity(0.2),
                  Colors.black.withOpacity(0.8),
                ]
              )
            )
          ),
          Align(
            alignment: Alignment.topCenter,
              child: Image(
                height: 300,
                width: 300,
                  image: AssetImage('assets/logo.png'))
              )

        ],
      )
    );
  }
}