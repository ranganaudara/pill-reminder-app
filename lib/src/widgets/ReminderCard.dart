import 'package:flutter/material.dart';

class ReminderCard extends StatelessWidget {
  ReminderCard({this.drugName, this.days, this.time, this.numberOfPills,this.action});

  final String drugName;
  final String days;
  final String time;
  final int numberOfPills;
  final VoidCallback action;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListTile(
          title: Text("$drugName"),
          subtitle: Text("$days\nTime: $time\nNumber of pills: $numberOfPills"),
          trailing: IconButton(
            onPressed: action,
            icon: Icon(Icons.delete),
          ),
        ),
      ),
    );
  }
}
