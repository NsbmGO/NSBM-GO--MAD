import 'package:flutter/material.dart';

import 'main.dart';
import 'event.dart' as event_lib;
import 'aboutus.dart' as aboutus_lib;
import 'profile.dart';

class ClubsPage extends StatefulWidget {
  const ClubsPage({Key? key}) : super(key: key);

  @override
  _ClubsPageState createState() => _ClubsPageState();
}

class _ClubsPageState extends State<ClubsPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String _selectedCategory = 'ACTIVITY BASED CLUBS';
  int _selectedIndex = 1; // Clubs is selected by default

  @override
  Widget build(BuildContext context) {
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
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore.collection('clubs')
                  .where('clubtype', isEqualTo: _selectedCategory)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('No clubs found'));
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    final club = snapshot.data!.docs[index].data() as Map<String, dynamic>;
                    return _buildClubCard(context, club);
                  },
                );
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
    if (index == _selectedIndex) return; // Already on this page

    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0: // Events
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => event_lib.NSBMHomePage()),
        );
        break;
      case 1: // Clubs - do nothing, we're already here
        break;
      case 2: // Home
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomePage()),
        );
        break;
      case 3: // Faculties
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => aboutus_lib.AboutUsScreen()),
        );
        break;
      case 4: // Profile
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
    final createdAt = club['createdAt'] != null
        ? (club['createdAt'] as Timestamp).toDate()
        : DateTime.now();
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
              builder: (context) => ClubDetailsPage(clubData: club),
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

class ClubDetailsPage extends StatelessWidget {
  final Map<String, dynamic> clubData;

  const ClubDetailsPage({Key? key, required this.clubData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final createdAt = clubData['createdAt'] != null
        ? (clubData['createdAt'] as Timestamp).toDate()
        : DateTime.now();
    final formattedDate = DateFormat('dd MMMM yyyy').format(createdAt);

    return Scaffold(
      appBar: AppBar(
        title: Text(clubData['name'] ?? 'Club Details'),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  clubData['image'] ?? '',
                  width: double.infinity,
                  height: 200,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    height: 200,
                    color: Colors.grey[200],
                    child: const Icon(Icons.group, size: 60),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              clubData['name'] ?? 'Club Name',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Chip(
              label: Text(
                clubData['clubtype'] ?? 'No Type',
                style: const TextStyle(color: Colors.white),
              ),
              backgroundColor: Colors.green,
            ),
            const SizedBox(height: 20),
            const Text(
              'Description',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              clubData['description'] ?? 'No description available',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[700],
                height: 1.5,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Contact Information',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            _buildContactInfo(Icons.person, 'Created by: ${clubData['createdBy'] ?? 'Unknown'}'),
            _buildContactInfo(Icons.email, clubData['mail'] ?? 'No email provided'),
            _buildContactInfo(Icons.phone, clubData['contactnumber'] ?? 'No phone number provided'),
            if (clubData['url'] != null && clubData['url'].isNotEmpty)
              const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildContactInfo(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}