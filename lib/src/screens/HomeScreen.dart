import 'package:drug_alarm/config/SizeConfig.dart';
import 'package:drug_alarm/src/models/ReminderModel.dart';
import 'package:drug_alarm/src/screens/SetReminder.dart';
import 'package:drug_alarm/src/utils/DatabaseHelper.dart';
import 'package:drug_alarm/src/widgets/ReminderCard.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  DatabaseStatus _dbStatus;

  DatabaseHelper db = DatabaseHelper();

  AnimationController _controller;
  static List<String> _optionsList = const [
    "Alendronate",
    "Methotrexate",
    "Other"
  ];

  List<Reminder> _remindersList;

  @override
  void initState() {
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _dbStatus = DatabaseStatus.LOADING;
    _getAllReminders();
    super.initState();
  }

  _getAllReminders() async {
    try {
      _remindersList = await db.getAllReminders();
      setState(() {
        _dbStatus = DatabaseStatus.COMPLETE;
      });
    } catch(e) {
      print(e);
      setState(() {
        _dbStatus = DatabaseStatus.FAILED;
      });
    }
  }
  
  _deleteReminder(Reminder reminder) async {
    await db.deleteReminder(reminder);
    List _newRemindersList = await db.getAllReminders();
    setState(() {
      _remindersList = _newRemindersList;
    });
  }

//  List<Reminder> _remindersList = [
//    Reminder(
//      drugName: "Citirizine",
//      days: "Sunday, Monday",
//      time: "7.00am",
//      numberOfPills: 2,
//    ),
//    Reminder(
//      drugName: "Citirizine",
//      days: "Sunday,Monday",
//      time: "7.00am",
//      numberOfPills: 2,
//    ),
//    Reminder(
//      drugName: "Citirizine",
//      days: "Sunday,Monday",
//      time: "7.00am",
//      numberOfPills: 2,
//    ),
//  ];

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
      body: Center(
        child: Container(
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
                SizedBox(
                  height: SizeConfig.blockSizeVertical * 2,
                ),
                Container(
                  width: SizeConfig.blockSizeVertical * 12,
                  height: SizeConfig.blockSizeVertical * 12,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    image: DecorationImage(
                      fit: BoxFit.fill,
                      image: AssetImage('assets/icons/medicine.png'),
                    ),
                  ),
                ),
                SizedBox(
                  height: SizeConfig.blockSizeVertical * 2,
                ),
                Text(
                  'Weekly Pill Reminder',
                  style: TextStyle(
                      fontSize: 30.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
                Text(
                  'v1.0.0',
                  style: TextStyle(
                      fontSize: 12.0,
                      fontWeight: FontWeight.w100,
                      color: Colors.white),
                ),
                SizedBox(
                  height: SizeConfig.blockSizeVertical * 2,
                ),
                _showRemindersList(),
              ],
            ),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(_optionsList.length, (int index) {
          Widget child = Container(
            alignment: FractionalOffset.topCenter,
            child: ScaleTransition(
              scale: CurvedAnimation(
                parent: _controller,
                curve: Interval(0.0, 1.0 - index / _optionsList.length / 2.0,
                    curve: Curves.easeOut),
              ),
              child: Card(
                child: FlatButton(
                  onPressed: () {
                    if(_optionsList[index] == "Alendronate"){
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SetReminder("Alendronate"),
                        ),
                      );
                    } else if(_optionsList[index] == "Methotrexate"){
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SetReminder("Methotrexate"),
                        ),
                      );
                    }else{
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SetReminder("Other"),
                        ),
                      );
                    }
                  },
                  child: Text(
                    _optionsList[index],
                  ),
                ),
              ),
            ),
          );
          return child;
        }).toList()
          ..add(
            FloatingActionButton(
              backgroundColor: Colors.white,
              heroTag: null,
              child: AnimatedBuilder(
                animation: _controller,
                builder: (BuildContext context, Widget child) {
                  return Transform(
                    transform:
                        Matrix4.rotationZ(_controller.value * 0.5 * math.pi),
                    alignment: FractionalOffset.center,
                    child: Icon(
                      _controller.isDismissed ? Icons.add : Icons.close,
                      color: Colors.black,
                    ),
                  );
                },
              ),
              onPressed: () {
                if (_controller.isDismissed) {
                  _controller.forward();
                } else {
                  _controller.reverse();
                }
              },
            ),
          ),
      ),
    );
  }

  Widget _showRemindersList(){
    switch (_dbStatus) {
      case DatabaseStatus.LOADING:
        return Center(
          child: CircularProgressIndicator(),
        );
      case DatabaseStatus.COMPLETE:
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Container(
            height: SizeConfig.screenHeight * 0.7,
            width: SizeConfig.screenWidth,
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.25),
              shape: BoxShape.rectangle,
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: _remindersList.isNotEmpty
                ? Padding(
              padding: const EdgeInsets.all(5.0),
              child: ListView.builder(
                itemCount: _remindersList.isEmpty
                    ? 0
                    : _remindersList.length,
                itemBuilder: (BuildContext context, index) {
                  final item = _remindersList[index];
                  return ReminderCard(
                    drugName: item.drugName,
                    days: item.days,
                    time: item.time,
                    numberOfPills: item.numberOfPills,
                    action: (){_deleteReminder(item);},
                  );
                },
              ),
            )
                : Center(
              heightFactor: SizeConfig.blockSizeVertical * 4.4,
              child: Text("No reminders set"),
            ),
          ),
        );
      case DatabaseStatus.FAILED:
        return Center(
          child: Text("Loading from database failed!"),
        );
    }
  }
}

enum DatabaseStatus { LOADING, COMPLETE, FAILED }
