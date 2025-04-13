import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'main.dart';
import 'addevent.dart';
import 'clubmanager.dart';
import 'login.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  int selectedUserType = 0;
  bool obscurePassword = true;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool isLoading = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: Offset(0.0, 0.2),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    setState(() => isLoading = true);

    try {
      final email = _emailController.text.trim();
      final password = _passwordController.text;

      String collectionName;
      Widget destination;

      switch (selectedUserType) {
        case 0: // Student
        // First authenticate with Firebase Auth
          final authResult = await FirebaseAuth.instance.signInWithEmailAndPassword(
            email: email,
            password: password,
          );

          // Then get additional data from Firestore
          final userDoc = await FirebaseFirestore.instance
              .collection('student')
              .doc(authResult.user?.uid)
              .get();

          if (!userDoc.exists) {
            throw FirebaseAuthException(
              code: 'user-not-found',
              message: 'No student found with that email.',
            );
          }

          final userData = userDoc.data()!;
          destination = HomePage(studentData: userData);
          break;

        case 1: // Event Organizer
          collectionName = 'eventorganizer';
          final querySnapshot = await FirebaseFirestore.instance
              .collection(collectionName)
              .where('email', isEqualTo: email)
              .limit(1)
              .get();

          if (querySnapshot.docs.isEmpty) {
            throw FirebaseAuthException(
              code: 'user-not-found',
              message: 'No organizer found with that email.',
            );
          }

          final userDoc = querySnapshot.docs.first;
          final userData = userDoc.data();

          if (userData['password'] != password) {
            throw FirebaseAuthException(
              code: 'wrong-password',
              message: 'Incorrect password.',
            );
          }

          destination = EventForm(organizerData: userData);
          break;

        case 2: // Club Manager
          collectionName = 'clubmanager';
          final querySnapshot = await FirebaseFirestore.instance
              .collection(collectionName)
              .where('email', isEqualTo: email)
              .limit(1)
              .get();

          if (querySnapshot.docs.isEmpty) {
            throw FirebaseAuthException(
              code: 'user-not-found',
              message: 'No club manager found with that email.',
            );
          }

          final userDoc = querySnapshot.docs.first;
          final userData = userDoc.data();

          if (userData['password'] != password) {
            throw FirebaseAuthException(
              code: 'wrong-password',
              message: 'Incorrect password.',
            );
          }

          destination = ClubManagerPage(managerData: userData);
          break;

        default:
          throw Exception('Invalid user type selected');
      }

      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => destination,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: animation,
              child: child,
            );
          },
          transitionDuration: Duration(milliseconds: 500),
        ),
      );
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message ?? 'Authentication failed')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  void _changeUserType(int type) {
    if (selectedUserType != type) {
      setState(() {
        selectedUserType = type;
        _animationController.reset();
        _animationController.forward();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('assets/logo.png', height: 120),
              SizedBox(height: 30),
              Text(
                'Login to NSBM Go',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
              SizedBox(height: 20),
              Row(
                children: [
                  Expanded(child: _buildToggleButton('Student', 0)),
                  SizedBox(width: 10),
                  Expanded(child: _buildToggleButton('Organizer', 1)),
                  SizedBox(width: 10),
                  Expanded(child: _buildToggleButton('Club Manager', 2)),
                ],
              ),
              SizedBox(height: 20),
              SlideTransition(
                position: _slideAnimation,
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: _buildEmailField(),
                ),
              ),
              SizedBox(height: 15),
              SlideTransition(
                position: _slideAnimation,
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: _buildPasswordField(),
                ),
              ),
              SizedBox(height: 30),
              SlideTransition(
                position: _slideAnimation,
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: _buildLoginButton(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildToggleButton(String text, int userType) {
    return ElevatedButton(
      onPressed: () => _changeUserType(userType),
      style: ElevatedButton.styleFrom(
        backgroundColor: selectedUserType == userType ? Colors.green : Colors.grey[300],
        padding: EdgeInsets.symmetric(vertical: 15),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: AnimatedSwitcher(
        duration: Duration(milliseconds: 200),
        transitionBuilder: (Widget child, Animation<double> animation) {
          return ScaleTransition(scale: animation, child: child);
        },
        child: Text(
          text,
          key: ValueKey<int>(userType),
          style: TextStyle(
            color: selectedUserType == userType ? Colors.white : Colors.black,
          ),
        ),
      ),
    );
  }

  Widget _buildEmailField() {
    String labelText;
    switch (selectedUserType) {
      case 0:
        labelText = 'Student Email';
        break;
      case 1:
        labelText = 'Organizer Email';
        break;
      case 2:
        labelText = 'Club Manager Email';
        break;
      default:
        labelText = 'Email';
    }

    return TextField(
      controller: _emailController,
      decoration: InputDecoration(
        labelText: labelText,
        prefixIcon: Icon(Icons.email),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15.0), // Increased from default
        ),
        contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 15),
      ),
      keyboardType: TextInputType.emailAddress,
    );
  }

  Widget _buildPasswordField() {
    return TextField(
      controller: _passwordController,
      obscureText: obscurePassword,
      decoration: InputDecoration(
        labelText: 'Password',
        prefixIcon: Icon(Icons.lock),
        suffixIcon: IconButton(
          icon: Icon(
            obscurePassword ? Icons.visibility_off : Icons.visibility,
          ),
          onPressed: () => setState(() => obscurePassword = !obscurePassword),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15.0), // Increased from default
        ),
        contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 15),
      ),
    );
  }

  Widget _buildLoginButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: isLoading ? null : _login,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: isLoading
            ? CircularProgressIndicator(color: Colors.white)
            : Text(
          'LOGIN',
          style: TextStyle(fontSize: 16, color: Colors.white),
        ),
      ),
    );
  }
}