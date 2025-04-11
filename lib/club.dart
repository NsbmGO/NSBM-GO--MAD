import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'main.dart';
import 'event.dart' as event_lib;
import 'aboutus.dart' as aboutus_lib;
import 'profile.dart';
import 'clubmanager.dart';

class ClubsPage extends StatefulWidget {
  const ClubsPage({Key? key}) : super(key: key);

  @override
  _ClubsPageState createState() => _ClubsPageState();
}

class _ClubsPageState extends State<ClubsPage> {
  String _selectedCategory = 'ACTIVITY BASED CLUBS';
  int _selectedIndex = 1;

  List<Map<String, dynamic>> allClubs = [
    {
      'name': 'Photography Club',
      'description': 'Capture memories and moments.',
      'clubtype': 'ACTIVITY BASED CLUBS',
      'image': 'https://via.placeholder.com/150',
      'createdAt': DateTime(2024, 3, 5),
      'createdBy': 'John Doe',
      'mail': 'photo@club.com',
      'contactnumber': '+1234567890',
      'url': 'https://example.com'
    },
    {
      'name': 'Global Connections',
      'description': 'International student bonding events.',
      'clubtype': 'INTERNATIONAL CLUBS',
      'image': 'https://via.placeholder.com/150',
      'createdAt': DateTime(2024, 2, 10),
      'createdBy': 'Jane Smith',
      'mail': 'global@club.com',
      'contactnumber': '+9876543210',
      'url': 'https://example.org'
    },
  ];

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> filteredClubs = allClubs
        .where((club) => club['clubtype'] == _selectedCategory)
        .toList();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        toolbarHeight: 120,
        leadingWidth: 150,
        leading: Padding(
          padding: EdgeInsets.only(left: 20, top: 10, bottom: 10),
          child: Image.asset(
            "assets/logo.png",
            fit: BoxFit.contain,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          _buildCategorySelector(),
          Expanded(
            child: filteredClubs.isEmpty
                ? const Center(child: Text('No clubs found'))
                : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: filteredClubs.length,
              itemBuilder: (context, index) {
                return _buildClubCard(context, filteredClubs[index]);
              },
            ),
          ),
        ],
      ),
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
            label: "About Us",
          ),
          BottomNavigationBarItem(
            icon: Image.asset("assets/profile_icon.png", height: 24, color: Colors.black),
            label: "Profile",
          ),
        ],
      ),
    );
  }

  void _onItemTapped(int index) {
    if (index == _selectedIndex) return;

    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => event_lib.NSBMHomePage()),
        );
        break;
      case 1:
        break;
      case 2:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomePage()),
        );
        break;
      case 3:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => aboutus_lib.AboutUsScreen()),
        );
        break;
      case 4:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => ProfileScreen()),
        );
        break;
    }
  }

  Widget _buildCategorySelector() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Clubs & Societies',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildCategoryChip('ACTIVITY BASED CLUBS'),
                const SizedBox(width: 8),
                _buildCategoryChip('INTERNATIONAL CLUBS'),
                const SizedBox(width: 8),
                _buildCategoryChip('RELIGIOUS CLUBS'),
                const SizedBox(width: 8),
                _buildCategoryChip('SPORTS CLUBS'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChip(String category) {
    return ChoiceChip(
      label: Text(category),
      selected: _selectedCategory == category,
      onSelected: (selected) {
        setState(() {
          _selectedCategory = category;
        });
      },
      selectedColor: Colors.green,
      labelStyle: TextStyle(
        color: _selectedCategory == category ? Colors.white : Colors.black,
      ),
    );
  }

  Widget _buildClubCard(BuildContext context, Map<String, dynamic> club) {
    final createdAt = club['createdAt'] ?? DateTime.now();
    final formattedDate = DateFormat('dd MMM yyyy').format(createdAt);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 2,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ClubManagerPage(managerData: club),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  club['image'] ?? '',
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    width: 80,
                    height: 80,
                    color: Colors.grey[200],
                    child: const Icon(Icons.group, size: 40),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      club['name'] ?? 'Club Name',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      club['description'] ?? 'No description available',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[700],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const SizedBox(width: 4),
                        const Spacer(),
                        Text(
                          formattedDate,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
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
