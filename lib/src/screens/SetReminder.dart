import 'dart:isolate';

import 'package:drug_alarm/config/SizeConfig.dart';
import 'package:drug_alarm/src/models/ReminderModel.dart';
import 'package:drug_alarm/src/utils/DatabaseHelper.dart';
import 'package:drug_alarm/src/widgets/MultiSelectChips.dart';
import 'package:drug_alarm/src/widgets/Popup.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

///Defining global variables>
const String isolateName = 'isolate';
final ReceivePort port = ReceivePort();
SharedPreferences prefs;

class SetReminder extends StatefulWidget {
  SetReminder(this.selectedOption);
  final selectedOption;

  @override
  _SetReminderState createState() => _SetReminderState();
}

class _SetReminderState extends State<SetReminder> {
  DatabaseStatus _dbStatus;
  DatabaseHelper db = DatabaseHelper();

  TimeOfDay _time;

  final nameTextController = TextEditingController();
  final pillTextController = TextEditingController();
  Map<String, dynamic> _reminderDataMap;
  Reminder _newReminder;
  List<String> _selectedDaysList = [];

  String _drugName = "";
  String _selectedTime = "";
  String _days = "";
  int _numberOfPills = 0;

  List<String> _daysList = ["MON", "TUE", "WED", "THU", "FRI", "SAT", "SUN"];

  @override
  void dispose() {
    nameTextController.dispose();
    pillTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return SafeArea(
      child: Scaffold(
        body: Container(
          height: SizeConfig.screenHeight,
          width: SizeConfig.screenWidth,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.black, Colors.blue],
            ),
          ),
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                Container(
                  color: Colors.grey.withOpacity(0.1),
                  width: SizeConfig.screenWidth,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      IconButton(
                        icon: Icon(
                          Icons.arrow_back_ios,
                          color: Colors.white,
                        ),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                      FlatButton(
                        child: Text(
                          "SAVE",
                          style: TextStyle(color: Colors.white),
                        ),
                        onPressed: () {
                          _saveReminder();
                        },
                      )
                    ],
                  ),
                ),
                SizedBox(
                  height: SizeConfig.blockSizeVertical * 3,
                ),
                Container(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                      color: Colors.grey.withOpacity(0.25),
                      child: InkWell(
                        onTap: widget.selectedOption == "Other"
                            ? () {
                                _showEnterNameDialog(context);
                              }
                            : null,
                        customBorder: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        child: Row(
                          children: <Widget>[
                            DecoratedBox(
                              decoration: BoxDecoration(
                                color: Colors.grey.withOpacity(0.25),
                                borderRadius: BorderRadius.circular(50.0),
                              ),
                              child: Container(
                                child: Icon(Icons.edit),
                                height: SizeConfig.blockSizeVertical * 10,
                                width: SizeConfig.blockSizeVertical * 10,
                              ),
                            ),
                            SizedBox(
                              width: SizeConfig.blockSizeHorizontal * 3,
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  "Drug Name",
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 15.0),
                                ),
                                SizedBox(
                                  height: SizeConfig.blockSizeVertical * 0.3,
                                ),
                                _drugName == null || _drugName.isEmpty
                                    ? Text(
                                        widget.selectedOption == "Other"
                                            ? "Tap to enter a name"
                                            : "${widget.selectedOption}",
                                        style: TextStyle(color: Colors.grey),
                                      )
                                    : Text(
                                        _drugName,
                                        style: TextStyle(color: Colors.grey),
                                      ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                Container(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                      color: Colors.grey.withOpacity(0.25),
                      child: InkWell(
                        onTap: () {
                          _showEnterDaysDialog(context);
                        },
                        customBorder: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        child: Row(
                          children: <Widget>[
                            DecoratedBox(
                              decoration: BoxDecoration(
                                color: Colors.grey.withOpacity(0.25),
                                borderRadius: BorderRadius.circular(50.0),
                              ),
                              child: Container(
                                child: Icon(Icons.today),
                                height: SizeConfig.blockSizeVertical * 10,
                                width: SizeConfig.blockSizeVertical * 10,
                              ),
                            ),
                            SizedBox(
                              width: SizeConfig.blockSizeHorizontal * 3,
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  "Choose Days",
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 15.0),
                                ),
                                SizedBox(
                                  height: SizeConfig.blockSizeVertical * 0.3,
                                ),
                                Text(
                                  _selectedDaysList.isEmpty
                                      ? "Choose days to remind"
                                      : _selectedDaysList.join(" , "),
                                  style: TextStyle(color: Colors.grey),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                Container(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                      color: Colors.grey.withOpacity(0.25),
                      child: InkWell(
                        onTap: () {
                          _showTimePicker(context);
                        },
                        customBorder: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        child: Row(
                          children: <Widget>[
                            DecoratedBox(
                              decoration: BoxDecoration(
                                color: Colors.grey.withOpacity(0.25),
                                borderRadius: BorderRadius.circular(50.0),
                              ),
                              child: Container(
                                child: Icon(Icons.access_time),
                                height: SizeConfig.blockSizeVertical * 10,
                                width: SizeConfig.blockSizeVertical * 10,
                              ),
                            ),
                            SizedBox(
                              width: SizeConfig.blockSizeHorizontal * 3,
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  "Pick Time",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 15.0,
                                  ),
                                ),
                                SizedBox(
                                  height: SizeConfig.blockSizeVertical * 0.3,
                                ),
                                Text(
                                    _selectedTime.isEmpty
                                        ? "Tap to pick a time for reminder"
                                        : _selectedTime,
                                    style: TextStyle(color: Colors.grey)),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                Container(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                      color: Colors.grey.withOpacity(0.25),
                      child: InkWell(
                        onTap: () {
                          _showEnterPillCountDialog(context);
                        },
                        customBorder: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        child: Row(
                          children: <Widget>[
                            DecoratedBox(
                              decoration: BoxDecoration(
                                color: Colors.grey.withOpacity(0.25),
                                borderRadius: BorderRadius.circular(50.0),
                              ),
                              child: Container(
                                child: Icon(Icons.add_circle_outline),
                                height: SizeConfig.blockSizeVertical * 10,
                                width: SizeConfig.blockSizeVertical * 10,
                              ),
                            ),
                            SizedBox(
                              width: SizeConfig.blockSizeHorizontal * 3,
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  "Number of pills",
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 15.0),
                                ),
                                SizedBox(
                                  height: SizeConfig.blockSizeVertical * 0.3,
                                ),
                                _numberOfPills > 0
                                    ? Text(
                                        _numberOfPills.toString(),
                                        style: TextStyle(color: Colors.grey),
                                      )
                                    : Text(
                                        "Tap to enter number of pills",
                                        style: TextStyle(color: Colors.grey),
                                      ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  } //Build

  void _showEnterNameDialog(context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: Text("Drug Name"),
          content: TextField(
            textAlign: TextAlign.start,
            controller: nameTextController,
          ),
          actions: <Widget>[
            FlatButton(
              child: Text("SAVE"),
              onPressed: () {
                setState(() {
                  _drugName = nameTextController.text;
                });
                Navigator.of(context).pop();
              },
            ),
            FlatButton(
              child: Text("CANCEL"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showEnterPillCountDialog(context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: Text("Number of Pills"),
          content: TextField(
            textAlign: TextAlign.start,
            controller: pillTextController,
          ),
          actions: <Widget>[
            FlatButton(
              child: Text("SAVE"),
              onPressed: () {
                setState(() {
                  _numberOfPills = int.parse(pillTextController.text);
                });
                Navigator.of(context).pop();
              },
            ),
            FlatButton(
              child: Text("CANCEL"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showEnterDaysDialog(context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Choose Days"),
          content: MultiSelectChips(
            _daysList,
            _selectedDaysList,
            onSelectionChanged: (selectedList) {
              setState(() {
                _selectedDaysList = selectedList;
              });
            },
          ),
          actions: <Widget>[
            FlatButton(
              child: Text("SAVE"),
              onPressed: () {
                setState(() {
                  _days = _selectedDaysList
                      .reduce((value, element) => value + ',' + element);
                  print(_days);
                });
                Navigator.of(context).pop();
              },
            ),
            FlatButton(
              child: Text("CLEAR"),
              onPressed: () {
                setState(() {
                  _selectedDaysList = [];
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<Null> _showTimePicker(BuildContext context) async {
    _time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    setState(() {
      _selectedTime = formatTimeOfDay(_time);
    });
  }

  String formatTimeOfDay(TimeOfDay tod) {
    final now = new DateTime.now();
    final dt = DateTime(now.year, now.month, now.day, tod.hour, tod.minute);
    final format = DateFormat.jm(); //"6:00 AM"
    return format.format(dt);
  }

  void _saveReminder() {
    setState(() {
      _reminderDataMap = {
        "drugName": _drugName.isEmpty ? widget.selectedOption : _drugName,
        "time": _selectedTime,
        "days": _days,
        "numberOfPills": _numberOfPills,
      };

      _newReminder = Reminder.fromMap(_reminderDataMap);
      print(_newReminder.toMap());
    });
    try {
      db.addReminder(_newReminder).then((value) => {
            if (value > 1)
              {
                showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return PopupMessage(
                          message: "Reminder added successfully!",
                          onSubmit: () {
                            Navigator.of(context).pushNamedAndRemoveUntil(
                                '/dashboard', (Route<dynamic> route) => false);
                          });
                    })
              }
          });
    } catch (e) {
      print(e);
    }
  }


} //State

enum DatabaseStatus { LOADING, COMPLETE, FAILED }
