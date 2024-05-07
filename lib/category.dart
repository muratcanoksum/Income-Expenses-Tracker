// ignore_for_file: prefer_const_constructors, unnecessary_string_interpolations, prefer_const_literals_to_create_immutables, sized_box_for_whitespace, avoid_unnecessary_containers, unused_import, unnecessary_import, unused_element, unused_field, avoid_print, unnecessary_brace_in_string_interps

import 'dart:ffi';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:unilive/core/extensions/l10n.extensions.dart';
import 'package:intl/intl.dart';

import 'db_helper.dart';
import 'expense.dart';
import 'home.dart';

double currencyRate = 1;
String currencySymbol = "\$";

class Category extends StatelessWidget {
  final String categoryName;

  const Category({super.key, required this.categoryName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CategoryBody(categoryName: categoryName),
    );
  }
}

class CategoryBody extends StatefulWidget {
  final String categoryName;

  const CategoryBody({super.key, required this.categoryName});
  @override
  State<CategoryBody> createState() => _CategoryBodyState();
}

List<Map<String, dynamic>> data = [];
List<Map<String, dynamic>> earningData = [];
List<Map<String, dynamic>> expenseData = [];

List<Map<String, dynamic>> expenseToday = [];
List<Map<String, dynamic>> expenseYesterday = [];
List<Map<String, dynamic>> expenseThisWeek = [];

Map<int, bool> clickedMap = {};

class _CategoryBodyState extends State<CategoryBody> {
  double totalExpense = 0.0;
  double thisWeekExpense = 0.0;
  List<double> expenseWeekDayList = [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0];

  int selectedElementID = 0;

  Color notClickedColor = Colors.white;
  Color clickedColor = Colors.white;

  Future<void> getEarning() async {
    DbHelper dbHelper = DbHelper();
    await dbHelper.open();
    data = await dbHelper.getData();
    earningData.clear();
    expenseData.clear();
    expenseToday.clear();
    expenseYesterday.clear();
    expenseThisWeek.clear();

    for (var d in data) {
      if (d["category"] == "salary") {
        earningData.add(d);
      } else {
        expenseData.add(d);
      }
    }

    expenseData = expenseData.reversed.toList();

    await setTotalExpense();
  }

  Future<void> setTotalExpense() async {
    double total = 0.0;
    double thisWeek = 0.0;
    expenseWeekDayList = [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0];

    for (var expense in expenseData) {
      total += expense["expense"];

      clickedMap.addAll({expense["id"]: false});

      expenseWeekDayList[DateTime.parse(expense["expenseDate"]).weekday - 1] +=
          expense["expense"]!;

      if (DateTime.parse(expense["expenseDate"]).day == DateTime.now().day) {
        thisWeek += expense["expense"];

        expenseToday.add(expense);
      } else if (DateTime.parse(expense["expenseDate"])
              .add(Duration(days: 1))
              .day ==
          DateTime.now().day) {
        thisWeek += expense["expense"];

        expenseYesterday.add(expense);
      } else if ((((DateTime.parse(expense["expenseDate"]).month - 1) * 30) +
                  DateTime.parse(expense["expenseDate"]).day) +
              7 >
          (((DateTime.now().month - 1) * 30) + DateTime.now().day)) {
        thisWeek += expense["expense"];

        expenseThisWeek.add(expense);
      }
    }

    setState(() {
      totalExpense = total;
      thisWeekExpense = thisWeek;
    });
  }

  Future<void> setCurrencyDetails() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    currencyRate = prefs.getDouble('currencyRate') ?? 1;
    currencySymbol = prefs.getString('currencySymbol') ?? "\$";
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setState(() {
      setCurrencyDetails();
      getEarning();
    });
  }

  var format = NumberFormat("#,##0.0", "tr_TR");

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(10),
            color: Color(0xff07873A),
            height: 50,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Home(),
                        ));
                  },
                  child: Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: Colors.white,
                  ),
                ),
                Text(
                  widget.categoryName,
                  style: TextStyle(color: Colors.white, fontSize: 22),
                ),
                Row(
                  children: [],
                )
              ],
            ),
          ),
          Container(
            height: MediaQuery.of(context).size.height - 80,
            child: Stack(
              children: [
                Container(
                  padding: EdgeInsets.all(10),
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height - 80,
                  color: Color(0xff07873A),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: 8,
                      ),
                      Text(
                        context.translate.totalexpenses,
                        style: TextStyle(color: Colors.white, fontSize: 20),
                      ),
                      SizedBox(
                        height: 8,
                      ),
                      Text(
                        "$currencySymbol${format.format(totalExpense * currencyRate)}",
                        style: TextStyle(color: Colors.white, fontSize: 40),
                      ),
                      SizedBox(
                        height: 8,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            context.translate.expensesforthisweek,
                            style: TextStyle(color: Colors.white, fontSize: 13),
                          ),
                          Text(
                            "$currencySymbol${format.format(thisWeekExpense * currencyRate)}",
                            style: TextStyle(color: Colors.white, fontSize: 13),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 25,
                      ),
                      Container(
                        width: MediaQuery.of(context).size.width,
                        height: 180,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            for (var day in getDayStatistic()) day,
                          ],
                        ),
                      )
                    ],
                  ),
                ),
                SingleChildScrollView(
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    margin: EdgeInsets.only(
                        top: MediaQuery.of(context).size.height / 2.4),
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30),
                      ), // Adjust the radius as needed
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        SizedBox(
                          height: 30,
                        ),
                        for (var container in getExpense("today")) container,
                        for (var container in getExpense("yesterday"))
                          container,
                        for (var container in getExpense("week")) container,
                        SizedBox(
                          height: 500,
                        ),
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  getExpense(String s) {
    List<Column> columnList = [];

    if (s == "today") {
      columnList.add(Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(context.translate.expensestoday),
              GestureDetector(
                onTap: () {},
                child: Text(
                  '+ ${context.translate.addexpense}',
                  style: TextStyle(
                      color: Color(0xff41B746),
                      decoration: TextDecoration.underline,
                      decorationColor: Color(0xff41B746),
                      fontSize: 14),
                ),
              ),
            ],
          ),
          for (int i = 0; i < expenseToday.length; i++)
            GestureDetector(
              onTap: () {
                setState(() {
                  clickedMap.forEach((key, value) {
                    if (value == true) {
                      clickedMap[key] = false;
                    }
                  });
                  clickedMap[expenseToday[i]["id"]] = true;
                  selectedElementID = expenseToday[i]["id"];
                });
                print(clickedMap);
              },
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 5),
                decoration: BoxDecoration(
                  color: clickedMap[expenseToday[i]["id"]]!
                      ? Colors.grey[300]
                      : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(5),
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Image.asset(
                            "assets/icons/${expenseToday[i]["category"].toString().toLowerCase().replaceAll(" ", "")}.png",
                            width: 40,
                          ),
                        ),
                        SizedBox(
                          width: 6,
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("${expenseToday[i]["expenseName"]}"),
                            Text(
                                '${DateTime.parse(expenseToday[i]["expenseDate"]).hour}:${DateTime.parse(expenseToday[i]["expenseDate"]).minute}')
                          ],
                        )
                      ],
                    ),
                    Text(
                      "$currencySymbol${format.format(expenseToday[i]["expense"] * currencyRate)}",
                      style: TextStyle(fontSize: 25),
                    )
                  ],
                ),
              ),
            ),
        ],
      ));
    }
    if (s == "yesterday") {
      columnList.add(Column(
        children: [
          SizedBox(
            height: 15,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(context.translate.expensesyesterday),
            ],
          ),
          for (int i = 0; i < expenseYesterday.length; i++)
            GestureDetector(
              onTap: () {
                setState(() {
                  clickedMap.forEach((key, value) {
                    if (value == true) {
                      clickedMap[key] = false;
                    }
                  });
                  clickedMap[expenseToday[i]["id"]] = true;
                  selectedElementID = expenseToday[i]["id"];
                });
                print(clickedMap);
              },
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 5),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(5),
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Image.asset(
                            "assets/icons/${expenseYesterday[i]["category"].toString().toLowerCase().replaceAll(" ", "")}.png",
                            width: 40,
                          ),
                        ),
                        SizedBox(
                          width: 6,
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("${expenseYesterday[i]["expenseName"]}"),
                            Text(
                                '${DateTime.parse(expenseYesterday[i]["expenseDate"]).hour}:${DateTime.parse(expenseYesterday[i]["expenseDate"]).minute}'),
                          ],
                        )
                      ],
                    ),
                    Text(
                      "$currencySymbol${format.format(expenseYesterday[i]["expense"] * currencyRate)}",
                      style: TextStyle(fontSize: 25),
                    )
                  ],
                ),
              ),
            ),
        ],
      ));
    }
    if (s == "week") {
      columnList.add(Column(
        children: [
          SizedBox(
            height: 15,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("EXPENSES THIS WEEK"),
            ],
          ),
          for (int i = 0; i < expenseThisWeek.length; i++)
            GestureDetector(
              onTap: () {
                setState(() {
                  clickedMap.forEach((key, value) {
                    if (value == true) {
                      clickedMap[key] = false;
                    }
                  });
                  clickedMap[expenseToday[i]["id"]] = true;
                  selectedElementID = expenseToday[i]["id"];
                });
                print(clickedMap);
              },
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 5),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(5),
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Image.asset(
                            "assets/icons/${expenseThisWeek[i]["category"].toString().toLowerCase().replaceAll(" ", "")}.png",
                            width: 40,
                          ),
                        ),
                        SizedBox(
                          width: 6,
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("${expenseThisWeek[i]["expenseName"]}"),
                            Text(
                                '${DateTime.parse(expenseThisWeek[i]["expenseDate"]).hour}:${DateTime.parse(expenseThisWeek[i]["expenseDate"]).minute}'),
                          ],
                        )
                      ],
                    ),
                    Text(
                      "$currencySymbol${format.format(expenseThisWeek[i]["expense"] * currencyRate)}",
                      style: TextStyle(fontSize: 25),
                    )
                  ],
                ),
              ),
            ),
        ],
      ));
    }

    return columnList;
  }

  getDayStatistic() {
    List<Column> columnList = [];
    for (int i = 1; i <= DateTime.now().weekday; i++) {
      print(i);
    }

    for (int i = 1; i <= DateTime.now().weekday; i++) {
      columnList.add(Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(
            '$currencySymbol${format.format(expenseWeekDayList[i - 1] * currencyRate)}',
            style: TextStyle(color: Colors.white),
          ),
          Stack(
            children: [
              Container(
                width: 40,
                height: getHeight(expenseWeekDayList[i - 1]),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.green.shade300,
                ),
              ),
              Positioned(
                bottom: 5,
                left: 0,
                right: 0,
                child: Center(
                  child: Text(
                    findDayOfWeek(i).toUpperCase().substring(0, 3),
                    style: TextStyle(color: Colors.green.shade100),
                  ),
                ),
              ),
            ],
          )
        ],
      ));
    }
    for (int i = 1; i <= 7 - DateTime.now().weekday; i++) {
      columnList.add(Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(
            '${currencySymbol}0.0',
            style: TextStyle(color: Colors.white),
          ),
          Stack(
            children: [
              Container(
                width: 40,
                height: 35,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.green.shade300,
                ),
              ),
              Positioned(
                bottom: 5,
                left: 0,
                right: 0,
                child: Center(
                  child: Text(
                    findDayOfWeek(i).toUpperCase().substring(0, 3),
                    style: TextStyle(color: Colors.green.shade100),
                  ),
                ),
              ),
            ],
          )
        ],
      ));
    }

    return columnList;
  }

  String findDayOfWeek(int dayNumber) {
    switch (dayNumber) {
      case 1:
        return context.translate.monday;
      case 2:
        return context.translate.tuesday;
      case 3:
        return context.translate.wednesday;
      case 4:
        return context.translate.thursday;
      case 5:
        return context.translate.friday;
      case 6:
        return context.translate.saturday;
      case 7:
        return context.translate.sunday;
      default:
        return context.translate.monday;
    }
  }

  getHeight(double expenseWeekDayList) {
    var height = expenseWeekDayList;

    if (height > 1000.0) {
      return 150.0;
    } else {
      if ((height / 10).toDouble() < 30.0) {
        return 35.0;
      }
      return (height / 10).toDouble();
    }
  }

  bool _isVisible = false;
  void _showDeleteConfirmationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Text("Do you really want to delete the shops category?"),
          actions: <Widget>[
            TextButton(
              child: Text("Cancel"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text("Delete"),
              onPressed: () {
                // Perform delete operation here
                // For demonstration, let's just hide the widget
                setState(() {
                  _isVisible = false;
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
