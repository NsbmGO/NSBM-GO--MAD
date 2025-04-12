import 'package:flutter/material.dart';
import 'event.dart' as event_lib;
import 'club.dart' as club_lib;
import 'aboutus.dart' as aboutus_lib;
import 'login.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
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
    await Future.delayed(Duration(seconds: 1)); // Simulate network delay

    setState(() {
      _studentData = {
        'name': 'Pulindu Thenura',
        'studentid': 'NSBM/SE/2022/001',
        'email': 'pulindu@example.com',
        'intake': 'March 2022',
        'degree': 'BSc (Hons) in Software Engineering',
        'phoneno': '+94771234567',
        'image': '', // Or insert a valid image URL here
        'dateofbirth': DateTime(2002, 11, 4), // Replace with desired date
      };
      _isLoading = false;
    });
  }

  Future<void> _logout() async {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
          (Route<dynamic> route) => false,
    );
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
        automaticallyImplyLeading: false,
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
    final dateOfBirth = _studentData!['dateofbirth'] as DateTime;
    final formattedDate = '${dateOfBirth.day} ${_getMonthName(dateOfBirth.month)} ${dateOfBirth.year}';

    return SingleChildScrollView(
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.only(top: 20, bottom: 30, left: 20, right: 20),
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
                    radius: 80,
                    backgroundColor: Colors.white,
                    child: _studentData!['image'] != null && _studentData!['image'].isNotEmpty
                        ? ClipOval(
                      child: Image.network(
                        _studentData!['image'],
                        width: 150,
                        height: 150,
                        fit: BoxFit.cover,
                      ),
                    )
                        : Icon(
                      Icons.person,
                      size: 80,
                      color: Color(0xFFA8D5A1),
                    ),
                  ),
                ),
                SizedBox(height: 25),
                Text(
                  _studentData!['name'] ?? 'No Name',
                  style: TextStyle(
                    fontSize: 26,
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
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.all(25),
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
      margin: EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 6,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: ListTile(
        leading: Icon(icon, color: Color(0xFF000000), size: 32),
        title: Text(
          title,
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        subtitle: Text(
          value,
          style: TextStyle(
            fontSize: 18,
            color: Colors.black87,
          ),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
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