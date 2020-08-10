
import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:time/view_event.dart';
import 'package:time/add_event.dart';
import 'package:time/event.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:table_calendar/table_calendar.dart';
void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Calendar',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomePage(),
      routes: {
        "add_event": (_) => AddEventPage(),
      },
    );
  }
}



class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  CalendarController _controller;
  Map<DateTime, List<dynamic>> _events;
  List<dynamic> _selectedEvents;
  TextEditingController _eventController;

  SharedPreferences prefs;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _controller = CalendarController();
    _eventController = TextEditingController();
    _events = {};
    _selectedEvents = [];
    initPrefs();
  }

  initPrefs() async {
    prefs = await SharedPreferences.getInstance();
    setState(() {
      _events = Map<DateTime, List<dynamic>>.from(
          decodeMap(json.decode(prefs.getString("events") ?? "{}")));
    });
  }

  Map<String,dynamic> encodeMap(Map<DateTime, dynamic> map) {
    Map<String,dynamic> newMap = {};
    map.forEach((key, value) {
      newMap[key.toString()] = map[key];
    });
    return newMap;
  }

  Map<DateTime, dynamic> decodeMap(Map<String, dynamic> map) {
    Map<DateTime, dynamic> newMap = {};
    map.forEach((key, value) {
      newMap[DateTime.parse(key)] = map[key];
    });
    return newMap;
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white24,
        appBar: AppBar(
          title: Text('Flutter Time Boxing Calendar'),
          centerTitle: true,

        ),
        body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                TableCalendar(
                  events: _events,
                  initialCalendarFormat: CalendarFormat.week,
                  calendarStyle: CalendarStyle(
                    todayColor: Colors.lightGreen,
                    selectedColor: Theme.of(context).primaryColor,
                    todayStyle: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18.0,
                      color: Colors.white,
                    ),
                  ),
                  headerStyle: HeaderStyle(
                    centerHeaderTitle: true,
                    formatButtonDecoration: BoxDecoration(
                      color: Colors.orange,
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    formatButtonTextStyle: TextStyle(
                      color: Colors.white,
                    ),
                    formatButtonShowsNext: false,
                  ),
                  startingDayOfWeek: StartingDayOfWeek.monday,
                  onDaySelected: (date, events){
                    setState(() {
                      _selectedEvents = events;
                    });
                    print(date.toIso8601String());
                  },
                  builders: CalendarBuilders(
                    selectedDayBuilder: (context, date, events) => Container(
                      margin: const EdgeInsets.all(4.0),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor,
                        borderRadius: BorderRadius.circular(10),
                        shape: BoxShape.rectangle,
                      ),
                      child: Text(date.day.toString(), style: TextStyle(
                        color: Colors.white,
                      )),
                    ),
                    todayDayBuilder: (context, date, events) => Container(
                      margin: const EdgeInsets.all(4.0),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Colors.orange,
                        borderRadius: BorderRadius.circular(10),
                        shape: BoxShape.rectangle,
                      ),
                      child: Text(date.day.toString(), style: TextStyle(
                        color: Colors.white,
                      )),
                    ),
                  ),
                  calendarController: _controller,),
                ..._selectedEvents.map((event) => ListTile(
                  title: Text(event.title),
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => EventDetailsPage(
                              event: event,
                            )));
                  },
                )),
              ],
            ),
        ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () => Navigator.pushNamed(context, 'add_event'),
      ),
    );
  }
}
