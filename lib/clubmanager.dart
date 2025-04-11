import 'package:flutter/material.dart';

class ClubManagerPage extends StatelessWidget {
  final Map<String, dynamic> managerData;

  const ClubManagerPage({Key? key, required this.managerData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(managerData['name'] ?? 'Club Manager'),
      ),
      body: Center(
        child: Text('Club Manager Page for ${managerData['name'] ?? 'Unknown'}'),
      ),
    );
  }
}
