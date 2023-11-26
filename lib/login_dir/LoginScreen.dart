import 'package:flutter/material.dart';
import 'package:animated_switch/animated_switch.dart';
import 'forgotPassword.dart';
import '../pages/google_map.dart';
import 'Signup.dart';

class AuthService {
  // This function simulates checking credentials against a database
  bool checkCredentials(String enteredEmail, String enteredPassword) {

    const String validEmail = '123';
    const String validPassword = '123';

    return enteredEmail == validEmail && enteredPassword == validPassword;
  }
}

class LoginScreen extends StatelessWidget {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final AuthService authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset : false ,
      body: Stack(
        children: [
          const Image(
            fit: BoxFit.cover,
            height: double.infinity,
            width: double.infinity,
            image: AssetImage('assets/splash.png'),
          ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [
                  Colors.black,
                  Colors.black.withOpacity(0.4),
                  Colors.black.withOpacity(0.2),
                  Colors.black.withOpacity(0.8),
                ],
              ),
            ),
          ),
          Align(
            alignment: Alignment.center,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Login',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(20.0),
                  child: TextField(
                    controller: emailController,
                    decoration: InputDecoration(
                      hintText: 'Email Address',
                      label: Text('Email Address'),
                      fillColor: Color(0xffD8D8DD),
                      filled: true,
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(20.0),
                  child: TextField(
                    controller: passwordController,
                    decoration: InputDecoration(
                      hintText: 'Password',
                      label: Text('Password'),
                      suffixIcon: Icon(Icons.visibility_off),
                      fillColor: Color(0xffD8D8DD),
                      filled: true,
                    ),
                    obscureText: true,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(left: 19, top: 8, right: 19),
                  child: Row(
                    children: [
                      AnimatedSwitch(
                        colorOff: Color(0xffA09F99),
                      ),
                      SizedBox(
                        width: 5,
                      ),
                      Text(
                        'Remember me',
                        style: TextStyle(color: Colors.white, fontSize: 18),
                      ),
                      Spacer(),
                      InkWell(
                        onTap: () {
                          // Navigate to the forgot password page here
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => forgotPassword()),
                          );
                        },
                        child: Text(
                          "Forgot Password",
                          style: TextStyle(color: Colors.white, fontSize: 18),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                Container(
                  height: 60,
                  width: 320,
                  child: ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all<Color>(Color(0xff0ACF83)),
                      shape: MaterialStateProperty.all<OutlinedBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0), // Adjust the border radius as needed
                        ),
                      ),
                    ),
                    onPressed: () {
                      // Call the login function to check credentials
                      login(context);
                    },
                    child: Center(
                      child: Text(
                        'Login',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 25,
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(15),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(height: 20),
                        Text(
                          "Don't have an account ?",
                          style: TextStyle(color: Colors.white, fontSize: 25),
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => Signup()));
                        },
                        child: Text("Sign Up", style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 25)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void login(BuildContext context) {
    final String enteredEmail = emailController.text.trim();
    final String enteredPassword = passwordController.text.trim();

    // Check if credentials are valid
    if (authService.checkCredentials(enteredEmail, enteredPassword)) {
      // Navigate to the next page if credentials are correct
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => MapPage()));
    } else {
      // Show an error message if credentials are incorrect
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Invalid email or password. Please try again.'),
          duration: Duration(seconds: 3),
        ),
      );
    }
  }
}
