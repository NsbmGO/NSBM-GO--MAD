import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'login.dart';
import 'addevent.dart';
import 'dart:math';
import 'event.dart' as event_lib;
import 'club.dart' as club_lib;
import 'aboutus.dart' as aboutus_lib;
import 'profile.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'NSBM Events',
      theme: ThemeData(primarySwatch: Colors.green),
      home: LoginScreen(),
      routes: {
        '/home': (context) => HomePage(),
        '/addEvent': (context) => EventForm(organizerData: {}),
      },
    );
  }
}

class HomePage extends StatefulWidget {
  final Map<String, dynamic>? studentData;

  const HomePage({Key? key, this.studentData}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 2;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Random _random = Random();

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
          child: Image.asset("assets/logo.png", fit: BoxFit.contain),
        ),
        centerTitle: true,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Latest Events",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore.collection('events').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(child: Text('No events found'));
                }

                var allEvents = snapshot.data!.docs;

                if (allEvents.length <= 3) {
                  return ListView.builder(
                    itemCount: allEvents.length,
                    itemBuilder: (context, index) {
                      final event =
                          allEvents[index].data() as Map<String, dynamic>;
                      return _buildEventCard(context, event);
                    },
                  );
                }

                Set<int> randomIndices = {};
                while (randomIndices.length < 3) {
                  randomIndices.add(_random.nextInt(allEvents.length));
                }

                return ListView.builder(
                  itemCount: 3,
                  itemBuilder: (context, index) {
                    final eventIndex = randomIndices.elementAt(index);
                    final event =
                        allEvents[eventIndex].data() as Map<String, dynamic>;
                    return _buildEventCard(context, event);
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
            icon: Image.asset(
              "assets/events_icon.png",
              height: 24,
              color: Colors.black,
            ),
            label: "Events",
          ),
          BottomNavigationBarItem(
            icon: Image.asset(
              "assets/clubs_icon.png",
              height: 24,
              color: Colors.black,
            ),
            label: "Clubs",
          ),
          BottomNavigationBarItem(
            icon: Image.asset(
              "assets/home_icon.png",
              height: 24,
              color: Colors.black,
            ),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Image.asset(
              "assets/People.png",
              height: 24,
              color: Colors.black,
            ),
            label: "About Us",
          ),
          BottomNavigationBarItem(
            icon: Image.asset(
              "assets/profile_icon.png",
              height: 24,
              color: Colors.black,
            ),
            label: "Profile",
          ),
        ],
      ),
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
    } else if (index == 3) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => aboutus_lib.AboutUsScreen()),
      );
      return;
    } else if (index == 4) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => ProfileScreen()),
      );
      return;
    }
    setState(() {
      _selectedIndex = index;
    });
  }

  Widget _buildEventCard(BuildContext context, Map<String, dynamic> event) {
    final dateTime = (event['dateandtime'] as Timestamp).toDate();
    final formattedDate =
        "${dateTime.day} ${_getMonthName(dateTime.month)} ${dateTime.year}";

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => event_lib.EventDetailsPage(eventData: event),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          elevation: 3,
          child: Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: Image.network(
                  event['image'],
                  fit: BoxFit.cover,
                  height: 200,
                  width: double.infinity,
                  errorBuilder:
                      (context, error, stackTrace) => Image.asset(
                        "assets/placeholder.jpg",
                        fit: BoxFit.cover,
                        height: 200,
                      ),
                ),
              ),
              Container(
                height: 200,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Colors.black.withOpacity(0.7),
                      Colors.black.withOpacity(0.3),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
              Positioned(
                bottom: 20,
                left: 16,
                right: 16,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      event['name'],
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      formattedDate,
                      style: TextStyle(color: Colors.white, fontSize: 14),
                    ),
                    SizedBox(height: 4),
                    Text(
                      event['venue'],
                      style: TextStyle(color: Colors.white, fontSize: 14),
                    ),
                    SizedBox(height: 8),
                    Text(
                      event['description'],
                      style: TextStyle(color: Colors.white, fontSize: 14),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
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

  String _getMonthName(int month) {
    const months = [
      "January",
      "February",
      "March",
      "April",
      "May",
      "June",
      "July",
      "August",
      "September",
      "October",
      "November",
      "December",
    ];
    return months[month - 1];
  }
}
