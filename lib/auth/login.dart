import 'package:applanner/auth/authentication.dart';
import 'package:applanner/auth/signup.dart';
import 'package:applanner/main/navigation_bar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<StatefulWidget> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _studentEmailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final AuthenticationService _authService = AuthenticationService();

  final _formKey = GlobalKey<FormState>();

  bool _passwordHidden = true;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  Image.asset(
                    'images/applannerlighttheme.png',
                    width: MediaQuery.of(context).size.width * 0.5,
                    height: MediaQuery.of(context).size.height * 0.1,
                  ),

                  const SizedBox(height: 50),
                  const Text(
                    "Login",
                    style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),

                  // Text field for Student email
                  TextFormField(
                    controller: _studentEmailController,
                    decoration: InputDecoration(
                      labelText: "Student Email",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please Enter Your Name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),

                  // Text field for password
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _passwordHidden,
                    decoration: InputDecoration(
                      labelText: "Password",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      suffixIcon: IconButton(
                        onPressed: () {
                          setState(() {
                            _passwordHidden = !_passwordHidden;
                          });
                        },
                        icon: Icon(
                          _passwordHidden
                              ? Icons.visibility
                              : Icons.visibility_off,
                        ),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your password';
                      } else if (value.length < 6) {
                        return 'Password need to at least 6 characters long';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),

                  // login Button
                  GestureDetector(
                    onTap: () async {
                      if (_formKey.currentState!.validate()) {
                        try {
                          User? user = await _authService.signInWithEmail(
                            _studentEmailController.text.trim(),
                            _passwordController.text.trim(),
                          );

                          if (user != null) {
                            print('Debug: User return with data');
                            String uid = user.uid;
                            DocumentSnapshot<Map<String, dynamic>> userDoc =
                                await FirebaseFirestore.instance
                                    .collection('users')
                                    .doc(uid)
                                    .get();

                            if (userDoc.exists) {
                              int? role = userDoc.data()?['role'];

                              switch (role) {
                                case 0:
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => MainMenu(),
                                    ),
                                  );
                                  // rediect the user
                                  break;
                                case 1:
                                  // rediect to club orgi page
                                  break;
                                case 2:
                                  // redirect to admin page
                                  break;
                                case null:
                                  print("Debug: Role data doesn't exist");
                                  // if the user data do not have role-related numbering
                                  throw FirebaseAuthException(
                                    code: 'internal-error',
                                    message: 'user data error',
                                  );
                                default:
                                  print("Debug: Other issue here");
                                  // if the user data do not have role-related numbering
                                  throw FirebaseAuthException(
                                    code: 'internal-error',
                                    message: 'user data error',
                                  );
                              }
                            }
                          }
                        } catch (e) {
                          String errMessage;
                          if (e is FirebaseAuthException) {
                            print("Debug: " + e.code);
                            switch (e.code) {
                              case 'invalid-credential':
                                errMessage =
                                    'The Email or Password is invalid.';
                                break;
                              case 'user-diabled':
                                errMessage = 'The User has been disabled';
                                break;
                              case 'user-not-found':
                                errMessage = 'No User found with this email';
                                break;
                              case 'internal-error':
                                errMessage = 'Internal error occor';
                                break;
                              default:
                                errMessage = 'Login Failled. Contact us';
                                break;
                            }

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(errMessage),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        }
                      }
                    },
                    child: MouseRegion(
                      onEnter:
                          (_) => setState(() {
                            _isHovered = true;
                          }),
                      onExit:
                          (_) => setState(() {
                            _isHovered = false;
                          }),
                      child: AnimatedContainer(
                        duration: Duration(microseconds: 200),
                        decoration: BoxDecoration(
                          color: _isHovered ? Colors.green : Colors.pink,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 50,
                          vertical: 15,
                        ),
                        child: const Text(
                          "Login",
                          style: TextStyle(color: Colors.white, fontSize: 20),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // redirect to signup page
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Don\'t have an account?'),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const SignUpPage(),
                            ),
                          );
                        },
                        child: const Text('Sign Up'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
