import 'package:flutter/material.dart';
import 'package:animated_switch/animated_switch.dart';

import 'LoginScreen.dart';

class Signup extends StatelessWidget {
  const Signup ({Key? key}) : super(key:key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body : Stack(
          children: [
            const Image(
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
            Align(//you added the const keyword ,if there a problem with the execution of your code,remove it
                alignment: Alignment.center,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text('SignUp',style:TextStyle(
                      color:Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),),
                    Padding(
                      padding: EdgeInsets.all(20.0),
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'Email Address',
                          label:Text('Email Address'),
                          fillColor: Color(0xffD8D8DD),
                          filled: true,
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(20.0),
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'User',
                          label:Text('UserName'),
                          fillColor: Color(0xffD8D8DD),
                          filled: true,
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(20.0),
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'Password',
                          label:Text('Password'),
                          suffixIcon: Icon(Icons.visibility_off),
                          fillColor: Color(0xffD8D8DD),
                          filled: true,
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(20.0),
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'Confirm password',
                          label:Text('Confirm password'),
                          fillColor: Color(0xffD8D8DD),
                          filled: true,
                        ),
                      ),
                    ),

                    SizedBox(height:20,),
                    Container(
                      height: 60,
                      width:320,
                      decoration: BoxDecoration(
                        color:Color(0xff0ACF83),
                      ),
                      child : Center(child: Text('Sign Up',
                        style:TextStyle(
                            color:Colors.white,
                            fontWeight:FontWeight.bold,
                            fontSize:25
                        ),),),

                    ),

                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Row(

                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children:[

                          Text("Already have an account ?",style:TextStyle(
                              color:Colors.white,
                              fontSize:25
                          ),),

                        ],
                      ),

                    ),
                    Padding(
                      padding: const EdgeInsets.all(0),
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children:[
                          ElevatedButton(onPressed:
                          (){
                          Navigator.push(context, MaterialPageRoute(builder: (context) => LoginScreen()));
                            }
                        , child:
                            Text("Login",style: TextStyle(
                                color: Colors.green,
                                fontWeight: FontWeight.bold,
                                fontSize: 25
                            ))
                          )]
                      ),
                    )
                  ],
                )
            )

          ],
        )
    );
  }
}