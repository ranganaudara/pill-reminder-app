import 'package:drug_alarm/config/SizeConfig.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'SetupReminderScreen.dart';

class ChooseDrug extends StatefulWidget {
  @override
  _ChooseDrugState createState() => _ChooseDrugState();
}

class _ChooseDrugState extends State<ChooseDrug> {


  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
      body: Container(
        width: SizeConfig.screenWidth,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              "Choose your drug",
              style: Theme.of(context).textTheme.headline4,
            ),
            SizedBox(
              height: 20.0,
            ),
            Card(
              elevation: 7.0,
              color: Theme.of(context).backgroundColor,
              child: ConstrainedBox(
                constraints: BoxConstraints.tightFor(
                    width: SizeConfig.blockSizeHorizontal * 50,
                    height: SizeConfig.blockSizeHorizontal * 50),
                child: FlatButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SetupReminderScreen(),
                      ),
                    );
                  },
                  padding: EdgeInsets.all(0.0),
                  child: Column(
                    children: <Widget>[
                      SizedBox(
                        height: 5.0,
                      ),
                      Text(
                        "Methotrexate",
                        style: Theme.of(context).textTheme.subtitle1,
                      ),
                      SizedBox(
                        height: 5.0,
                      ),
                      Image(
                        fit: BoxFit.cover,
                        image: AssetImage('assets/images/methotrexate.png'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 25.0,
            ),
            Card(
              elevation: 7.0,
              color: Theme.of(context).backgroundColor,
              child: ConstrainedBox(
                constraints: BoxConstraints.tightFor(
                    width: SizeConfig.blockSizeHorizontal * 50,
                    height: SizeConfig.blockSizeHorizontal * 50),
                child: FlatButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SetupReminderScreen(),
                      ),
                    );
                  },
                  padding: EdgeInsets.all(0.0),
                  child: Column(
                    children: <Widget>[
                      SizedBox(
                        height: 5.0,
                      ),
                      Text(
                        "Alendronate",
                        style: Theme.of(context).textTheme.subtitle1,
                      ),
                      SizedBox(
                        height: 5.0,
                      ),
                      Image(
                        fit: BoxFit.cover,
                        image: AssetImage('assets/images/alendronate.jpeg'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
