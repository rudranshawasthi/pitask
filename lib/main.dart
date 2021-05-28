import 'package:flutter/material.dart';
import 'package:pitask/provider/eventProvider.dart';
import 'package:provider/provider.dart';
import 'widgets/calendarWidget.dart';
import 'Page/event_edit.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => EventProvider(),
      child: MaterialApp(
        title: 'Flutter Demo',
        themeMode: ThemeMode.dark,
        darkTheme: ThemeData.dark().copyWith(
            scaffoldBackgroundColor: Colors.black,
            accentColor: Colors.white,
            primaryColor: Colors.black),
        home: MainPage(),
      ),
    );
  }
}

class MainPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'Calendar',
            style: TextStyle(fontSize: 40),
          ),
          centerTitle: true,
          leading: Icon(
            Icons.arrow_back_ios_outlined,
            size: 20,
          ),
        ),
        body: CalendarWidget(),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.of(context)
                .push(MaterialPageRoute(builder: (context) => EventEdit()));
          },
          child: Icon(
            Icons.add,
            color: Colors.white,
          ),
          backgroundColor: Colors.grey,
        ),
      ),
    );
  }
}
