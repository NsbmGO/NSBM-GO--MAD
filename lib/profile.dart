import 'package:flutter/material.dart';
import 'event.dart' as event_lib;
import 'club.dart' as club_lib;
import 'aboutus.dart' as aboutus_lib;
import 'login.dart'; // Import the login screen

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  Map<String, dynamic>? _studentData;
  bool _isLoading = true;
  String _errorMessage = '';
  int _selectedIndex = 4;

  @override
  void initState() {
    super.initState();
    _fetchStudentData();
  }

  Future<void> _fetchStudentData() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        setState(() {
          _errorMessage = 'No user logged in';
          _isLoading = false;
        });
        return;
      }

      final doc = await _firestore.collection('student').doc(user.uid).get();

      if (!doc.exists) {
        setState(() {
          _errorMessage = 'Student data not found';
          _isLoading = false;
        });
        return;
      }

      setState(() {
        _studentData = doc.data();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error fetching data: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  Future<void> _logout() async {
    try {
      await _auth.signOut();
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
            (Route<dynamic> route) => false,
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error signing out: ${e.toString()}')),
      );
    }
  }

  void _onItemTapped(int index) {
    if (index == 0) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => event_lib.NSBMHomePage()),
      );
      return;
    } else if (index == 1) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => club_lib.ClubsPage()),
      );
      return;
    } else if (index == 2) {
      Navigator.pushNamed(context, '/home');
      return;
    } else if (index == 3) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => aboutus_lib.AboutUsScreen()),
      );
      return;
    }
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false, // This removes the back button
        actions: [
          IconButton(
            icon: Icon(Icons.logout, color: Colors.red),
            onPressed: _logout,
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty
          ? Center(child: Text(_errorMessage))
          : _buildProfileContent(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.grey,
        items: [
          BottomNavigationBarItem(
            icon: Image.asset("assets/events_icon.png", height: 24, color: Colors.black),
            label: "Events",
          ),
          BottomNavigationBarItem(
            icon: Image.asset("assets/clubs_icon.png", height: 24, color: Colors.black),
            label: "Clubs",
          ),
          BottomNavigationBarItem(
            icon: Image.asset("assets/home_icon.png", height: 24, color: Colors.black),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Image.asset("assets/people.png", height: 24, color: Colors.black),
            label: "Faculties",
          ),
          BottomNavigationBarItem(
            icon: Image.asset("assets/profile_icon.png", height: 24, color: Colors.black),
            label: "Profile",
          ),
        ],
      ),
    );
  }

  Widget _buildProfileContent() {
    final dateOfBirth = (_studentData!['dateofbirth'] as Timestamp).toDate();
    final formattedDate = '${dateOfBirth.day} ${_getMonthName(dateOfBirth.month)} ${dateOfBirth.year}';

    return SingleChildScrollView(
      child: Column(
        children: [
          // Profile Header with larger photo moved down
          Container(
            padding: EdgeInsets.only(top: 20, bottom: 30, left: 20, right: 20), // Adjusted top padding
            decoration: BoxDecoration(
              color: Color(0xFFA8D5A1),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            child: Column(
              children: [
                Center(
                  child: CircleAvatar(
                    radius: 80,  // Increased size
                    backgroundColor: Colors.white,
                    child: _studentData!['image'] != null && _studentData!['image'].isNotEmpty
                        ? ClipOval(
                      child: Image.network(
                        _studentData!['image'],
                        width: 150,  // Increased size
                        height: 150, // Increased size
                        fit: BoxFit.cover,
                      ),
                    )
                        : Icon(
                      Icons.person,
                      size: 80,  // Increased size
                      color: Color(0xFFA8D5A1),
                    ),
                  ),
                ),
                SizedBox(height: 25),  // Increased spacing
                Text(
                  _studentData!['name'] ?? 'No Name',
                  style: TextStyle(
                    fontSize: 26,  // Slightly larger
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  _studentData!['studentid'] ?? 'No ID',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,  // Made student ID bold
                  ),
                ),
              ],
            ),
          ),

          // Profile Details
          Padding(
            padding: EdgeInsets.all(25),  // Increased padding
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildDetailCard(
                  icon: Icons.email,
                  title: 'Email',
                  value: _studentData!['email'] ?? 'No Email',
                ),
                _buildDetailCard(
                  icon: Icons.school,
                  title: 'Intake',
                  value: _studentData!['intake'] ?? 'No Intake',
                ),
                _buildDetailCard(
                  icon: Icons.account_balance,
                  title: 'Faculty',
                  value: 'Faculty of Computing',
                ),
                _buildDetailCard(
                  icon: Icons.assignment,
                  title: 'Degree',
                  value: _studentData!['degree'] ?? 'No Degree',
                ),
                _buildDetailCard(
                  icon: Icons.phone,
                  title: 'Phone',
                  value: _studentData!['phoneno'] ?? 'No Phone',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailCard({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10),  // Increased spacing
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),  // Slightly more rounded
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 6,  // Softer shadow
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: ListTile(
        leading: Icon(icon, color: Color(0xFF000000), size: 32),  // Larger icon
        title: Text(
          title,
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.w600,
            fontSize: 16,  // Slightly larger
          ),
        ),
        subtitle: Text(
          value,
          style: TextStyle(
            fontSize: 18,  // Larger text
            color: Colors.black87,  // Darker for better readability
          ),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),  // More padding
      ),
    );
  }

  String _getMonthName(int month) {
    const months = [
      "January", "February", "March", "April", "May", "June",
      "July", "August", "September", "October", "November", "December"
    ];
    return months[month - 1];
  }
}