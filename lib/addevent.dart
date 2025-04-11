import 'package:flutter/material.dart';

class EventForm extends StatefulWidget {
  final Map<String, dynamic> organizerData;

  const EventForm({Key? key, required this.organizerData}) : super(key: key);

  @override
  _EventFormState createState() => _EventFormState();
}

class _EventFormState extends State<EventForm> {
  @override
  Widget build(BuildContext context) {
    return Scaffold();
  }
}