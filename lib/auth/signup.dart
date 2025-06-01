import 'package:applanner/auth/authentication.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:applanner/auth/login.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<StatefulWidget> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final TextEditingController _studentIDController = TextEditingController();
  final TextEditingController _studentNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _universityNameController =
      TextEditingController();
  final AuthenticationService _authService = AuthenticationService();

  final _formKey = GlobalKey<FormState>();

  bool _passwordVisble = false;
  bool _confirmPasswordVisble = false;
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 18, 18, 18),
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              SizedBox(height: MediaQuery.of(context).size.height * 0.1),

              Form(
                key: _formKey,
                child: Column(
                  children: [
                    const Text(
                      "Sign Up",
                      style: TextStyle(
                        color: Color.fromARGB(255, 153, 153, 153),
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Text field for Name
                    TextFormField(
                      controller: _studentNameController,
                      decoration: InputDecoration(
                        labelText: 'Student Name',
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
                    const SizedBox(height: 10),

                    // field for ID
                    TextFormField(
                      controller: _studentIDController,
                      decoration: InputDecoration(
                        labelText: 'Student ID',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please Enter Your ID';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 10),

                    // field for email
                    TextFormField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        labelText: 'University Email',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your email';
                        } else if (!RegExp(
                          r'^[^@]+@[^@]+\.edu$',
                        ).hasMatch(value)) {
                          return 'Please eneter an educational email';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 10),

                    // field for password
                    TextFormField(
                      controller: _passwordController,
                      obscureText: !_passwordVisble,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        suffixIcon: IconButton(
                          onPressed: () {
                            setState(() {
                              _passwordVisble = !_passwordVisble;
                            });
                          },
                          icon: Icon(
                            _passwordVisble
                                ? Icons.visibility
                                : Icons.visibility_off,
                          ),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter password';
                        } else if (value.length < 6) {
                          return 'Password need to at least 6 characters long';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 10),

                    // field for confirm password
                    TextFormField(
                      controller: _confirmPasswordController,
                      obscureText: !_confirmPasswordVisble,
                      decoration: InputDecoration(
                        labelText: 'Confirm Password',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        suffixIcon: IconButton(
                          onPressed: () {
                            setState(() {
                              _confirmPasswordVisble = !_confirmPasswordVisble;
                            });
                          },
                          icon: Icon(
                            _confirmPasswordVisble
                                ? Icons.visibility
                                : Icons.visibility_off,
                          ),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please confirm your password';
                        } else if (value != _passwordController.text) {
                          return 'Password do not match.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 10),

                    // field for University
                    TextFormField(
                      controller: _universityNameController,
                      decoration: InputDecoration(
                        labelText: 'University Name',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter University Name';
                        }
                      },
                    ),
                    const SizedBox(height: 20),

                    // Sign Up Button
                    GestureDetector(
                      onTap: () async {
                        if (_formKey.currentState!.validate()) {
                          try {
                            User? user = await _authService.createUserWithEmail(
                              _emailController.text.trim(),
                              _passwordController.text.trim(),
                              _studentNameController.text.trim(),
                              _studentIDController.text.trim(),
                              _universityNameController.text.trim(),
                            );

                            if (user != null) {
                              // save the user to firestore
                              await _authService.saveUserDetails(
                                _studentNameController.text.trim(),
                                _studentIDController.text.trim(),
                                _emailController.text.trim(),
                                _universityNameController.text.trim(),
                              );

                              // If signup is successfull, then redirect to x Place
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    "Sign Up sucessful, Please Login",
                                  ),
                                  backgroundColor: Colors.green,
                                ),
                              );
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const LoginPage(),
                                ),
                              );
                            }
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(e.toString())),
                            );
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
                          duration: Duration(milliseconds: 200),
                          decoration: BoxDecoration(
                            color:
                                _isHovered
                                    ? Colors.green
                                    : Color.fromARGB(255, 134, 53, 214),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 25,
                            vertical: 15,
                          ),
                          child: const Text(
                            "Sign Up",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Have an account?',
                          style: TextStyle(
                            color: Color.fromARGB(255, 153, 153, 153),
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const LoginPage(),
                              ),
                            );
                          },
                          child: const Text(
                            'Login now',
                            style: TextStyle(
                              color: Color.fromARGB(255, 134, 53, 214),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
