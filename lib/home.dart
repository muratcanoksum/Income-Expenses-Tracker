// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, sized_box_for_whitespace, avoid_print, duplicate_import, depend_on_referenced_packages, unused_import, unnecessary_brace_in_string_interps

import 'dart:async';
import 'dart:ffi';
import 'package:flutter/cupertino.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:flutter/material.dart';
import 'package:live_currency_rate/live_currency_rate.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:unilive/addcategory.dart';
import 'package:unilive/addearnings.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:unilive/addexpenses.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:unilive/core/extensions/l10n.extensions.dart';
import 'package:unilive/currency.dart';

import 'category.dart';
import 'db_helper.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: HomeBody(),
    );
  }
}

class HomeBody extends StatefulWidget {
  const HomeBody({super.key});

  @override
  State<HomeBody> createState() => _HomeBodyState();
}

List<Map<String, dynamic>> data = [];
List<Map<String, dynamic>> earningData = [];
List<Map<String, dynamic>> expenseData = [];

List<Map<String, dynamic>> firstfiveearningData = [];
List<Map<String, dynamic>> firstfiveexpenseData = [];

double expenseStatisticTotal = 0;
String currencyCode = "USD";
double currencyRate = 1;
String currencySymbol = "\$";

class _HomeBodyState extends State<HomeBody> {
  double e1 = 0.0;
  double e2 = 0.0;
  double e3 = 0.0;
  double e4 = 0.0;

  String e1name = "";
  String e2name = "";
  String e3name = "";
  String e4name = "";

  double appBarIconWidth = 30.0;

  int touchedIndex = -1;

  String selectedCurrency = "";

  String selectedTimeFilter = "day";

  int currentMonth = DateTime.now().month;

  final List<ChartData> chartData = [
    ChartData(2010, 35),
    ChartData(2011, 13),
    ChartData(2012, 34),
    ChartData(2013, 27),
    ChartData(2014, 40),
  ];

  double totalEarning = 0.0;
  double thisDayEarning = 0.0;

  double totalExpense = 0.0;
  double thisDayExpense = 0.0;

  Future<void> getEarning() async {
    DbHelper dbHelper = DbHelper();
    await dbHelper.open();
    data = await dbHelper.getData();
    earningData.clear();
    expenseData.clear();

    for (var d in data) {
      if (d["category"] == "salary") {
        earningData.add(d);
      } else {
        expenseData.add(d);
      }
    }

    earningData = earningData.reversed.toList();

    if (earningData.length > 5) {
      firstfiveearningData = earningData.sublist(0, 5);
    } else {
      firstfiveearningData = earningData;
    }

    expenseData = expenseData.reversed.toList();

    if (expenseData.length > 5) {
      firstfiveexpenseData = expenseData.sublist(0, 5);
    } else {
      firstfiveexpenseData = expenseData;
    }

    await setTotalEarning();
    await setTotalExpense();

    setExpenseStatistics("day");
  }

  Future<void> setTotalEarning() async {
    double total = 0.0;
    double thisDay = 0.0;
    for (var earning in earningData) {
      total += earning["expense"];
      if (DateTime.parse(earning["expenseDate"]).day == DateTime.now().day) {
        thisDay += earning["expense"];
      }
    }

    setState(() {
      totalEarning = total;
      thisDayEarning = thisDay;
    });
  }

  Future<void> setTotalExpense() async {
    double total = 0.0;
    double thisDay = 0.0;
    for (var expense in expenseData) {
      total += expense["expense"];
      if (DateTime.parse(expense["expenseDate"]).day == DateTime.now().day) {
        thisDay += expense["expense"];
      }
    }

    setState(() {
      totalExpense = total;
      thisDayExpense = thisDay;
    });
  }

  Future<void> setCurrencyDetails() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    currencyRate = prefs.getDouble('currencyRate') ?? 1;
    currencySymbol = prefs.getString('currencySymbol') ?? "\$";
    if(currencyRate < 1){
      currencyRate = 1;
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getEarning();
    getCategoryListasync();
    setCurrencyDetails();
    selectedTimeFilter = "day";
  }

  var format = NumberFormat("#,##0.00", "tr_TR");
  var format1 = NumberFormat("#,##0.0", "tr_TR");

  @override
  Widget build(BuildContext context) {
    List<String> abbreviatedMonths = initList(context);



    return Container(
      padding: EdgeInsets.all(16),
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                greetingText(),
                Row(
                  children: [
                    GestureDetector(
                      onTap: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => Currency()),
                        );
                        setState(() {
                          if (result != null) {
                            //selectedCurrency = result;
                            currencyRate = result[0];
                            currencySymbol = result[1];
                          } else {
                            print("NO CHOOSE");
                          }
                        });
                      },
                      child: Image.asset(
                        'assets/icons/exchange.png',
                        width: appBarIconWidth,
                      ), // İkon boyutunu ayarlamak için width özelliğini kullanın
                    ),
                    SizedBox(
                      width: 5,
                    ),
                    GestureDetector(
                      onTap: () {
                        print('american pressed');
                        _saveCurrency("en");
                      },
                      child: Image.asset(
                        'assets/icons/american.png',
                        width: appBarIconWidth,
                      ), // Replace 'image.png' with your image file path
                    ),
                    SizedBox(
                      width: 5,
                    ),
                    GestureDetector(
                      onTap: () {
                        print('russian pressed');
                        _saveCurrency("ru");
                      },
                      child: Image.asset(
                        'assets/icons/russian.png',
                        width: appBarIconWidth,
                      ), // Replace 'image.png' with your image file path
                    ),
                    SizedBox(
                      width: 5,
                    ),
                    GestureDetector(
                      onTap: () {
                        print('brazilian pressed');
                        _saveCurrency("hu");
                      },
                      child: Image.asset(
                        'assets/icons/brazilian.png',
                        width: appBarIconWidth,
                      ), // Replace 'image.png' with your image file path
                    ),
                  ],
                )
              ],
            ),
            SizedBox(
              height: 10,
            ),
            Text(
              context.translate.recentearnings,
              style: TextStyle(fontSize: 25, fontWeight: FontWeight.w700),
            ),
            SizedBox(
              height: 10,
            ),
            Container(
              width: MediaQuery.of(context).size.width,
              height: 130,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    Color(
                        0xFF07873A), // Replace #07873A with your desired color
                    Color(
                        0xFF41B746), // Replace #41B746 with your desired color
                  ],
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 16,
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        context.translate.earnings,
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 17,
                            fontWeight: FontWeight.w400),
                      ),
                      Text(
                        "$currencySymbol${format.format(totalEarning * currencyRate)}",
                        style: TextStyle(
                            color: Colors.white,
                            fontFamily: 'Arial',
                            fontSize: 30,
                            fontWeight: FontWeight.w600),
                      ),
                      Text(
                        "$currencySymbol${format.format(thisDayEarning * currencyRate)} ${context.translate.thisday}",
                        style: TextStyle(
                            color: Colors.white,
                            fontFamily: 'Arial',
                            fontSize: 18,
                            fontWeight: FontWeight.w300),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Text(
              '${context.translate.today} ,  ${abbreviatedMonths[currentMonth - 1]} ${DateTime.now().day}',
              style: TextStyle(color: Colors.grey, fontSize: 16),
            ),
            SizedBox(
              height: 10,
            ),
            for (var i = 0; i < firstfiveearningData.length; i++)
              Container(
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
                            "assets/icons/salary.png",
                            width: 40,
                          ),
                        ),
                        SizedBox(
                          width: 6,
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(earningData[i]["expenseName"]),
                            Text(
                                '${DateTime.parse(earningData[i]["expenseDate"]).hour}:${DateTime.parse(earningData[i]["expenseDate"]).minute}')
                          ],
                        )
                      ],
                    ),
                    Text(
                        "$currencySymbol${format.format(earningData[i]["expense"] * currencyRate)}",
                        style: TextStyle(
                          fontSize: 25,
                          fontFamily: 'Arial',
                        ))
                  ],
                ),
              ),
            SizedBox(
              height: 10,
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AddEarnings(),
                    ));
              },
              child: Text(
                '+ ${context.translate.addearnings}',
                style: TextStyle(
                    color: Color(0xff41B746),
                    decoration: TextDecoration.underline,
                    decorationColor: Color(0xff41B746)),
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Text(
              context.translate.recentexpenses,
              style: TextStyle(fontSize: 25, fontWeight: FontWeight.w700),
            ),
            SizedBox(
              height: 10,
            ),
            Container(
              width: MediaQuery.of(context).size.width,
              height: 130,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    Color(
                        0xFF07873A), // Replace #07873A with your desired color
                    Color(
                        0xFF41B746), // Replace #41B746 with your desired color
                  ],
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 16,
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        context.translate.expenses,
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 17,
                            fontWeight: FontWeight.w400),
                      ),
                      Text(
                        "$currencySymbol${format.format(totalExpense * currencyRate)}",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 30,
                            fontFamily: 'Arial',
                            fontWeight: FontWeight.w600),
                      ),
                      Text(
                        "$currencySymbol${format.format(thisDayExpense * currencyRate)} ${context.translate.thisday}",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontFamily: 'Arial',
                            fontWeight: FontWeight.w300),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Text(
              '${context.translate.today} ,  ${abbreviatedMonths[currentMonth - 1]} ${DateTime.now().day}',
              style: TextStyle(color: Colors.grey, fontSize: 16),
            ),
            SizedBox(
              height: 10,
            ),
            for (var i = 0; i < firstfiveexpenseData.length; i++)
              Container(
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
                            "assets/icons/${firstfiveexpenseData[i]["category"].toString().toLowerCase().replaceAll(" ", "")}.png",
                            width: 40,
                          ),
                        ),
                        SizedBox(
                          width: 6,
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("${firstfiveexpenseData[i]["expenseName"]}"),
                            Text(
                                '${DateTime.parse(firstfiveexpenseData[i]["expenseDate"]).hour}:${DateTime.parse(firstfiveexpenseData[i]["expenseDate"]).minute}')
                          ],
                        )
                      ],
                    ),
                    Text(
                      "$currencySymbol${format.format(firstfiveexpenseData[i]["expense"] * currencyRate)}",
                      style: TextStyle(
                        fontSize: 25,
                        fontFamily: 'Arial',
                      ),
                    )
                  ],
                ),
              ),
            SizedBox(
              height: 10,
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AddExpenes(),
                    ));
              },
              child: Text(
                '+ ${context.translate.addexpense}',
                style: TextStyle(
                    color: Color(0xff41B746),
                    decoration: TextDecoration.underline,
                    decorationColor: Color(0xff41B746)),
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Text(context.translate.expensesbycategory,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "${context.translate.thismonth} - ${abbreviatedMonths[currentMonth - 1]}",
                  style: TextStyle(color: Colors.grey[500]),
                ),
              ],
            ),
            Wrap(
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            Category(categoryName: context.translate.shop),
                      ),
                    );
                  },
                  child: Container(
                    margin: EdgeInsets.all(4),
                    width: MediaQuery.of(context).size.width / 3.5,
                    height: 150,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Color(0xffEBEFF3),
                        width: 2,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          "assets/icons/shop.png",
                          scale: 6,
                        ),
                        Text(context.translate.shop,
                            textAlign: TextAlign.center),
                        SizedBox(
                          height: 5,
                        ),
                        Text(
                          "$currencySymbol${format1.format(getExpenseByCategory("Shop") * currencyRate)}",
                          style: TextStyle(
                            fontSize: 25,
                            fontWeight: FontWeight.w500,
                            fontFamily: 'Arial',
                          ),
                        )
                      ],
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            Category(categoryName: context.translate.car),
                      ),
                    );
                  },
                  child: Container(
                    margin: EdgeInsets.all(4),
                    width: MediaQuery.of(context).size.width / 3.5,
                    height: 150,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Color(0xffEBEFF3),
                        width: 2,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          "assets/icons/car.png",
                          scale: 7,
                        ),
                        Text(context.translate.car,
                            textAlign: TextAlign.center),
                        SizedBox(
                          height: 5,
                        ),
                        Text(
                          "$currencySymbol${format1.format(getExpenseByCategory("Car") * currencyRate)}",
                          style: TextStyle(
                            fontSize: 25,
                            fontWeight: FontWeight.w500,
                            fontFamily: 'Arial',
                          ),
                        )
                      ],
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            Category(categoryName: context.translate.medicine),
                      ),
                    );
                  },
                  child: Container(
                    margin: EdgeInsets.all(4),
                    width: MediaQuery.of(context).size.width / 3.5,
                    height: 150,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Color(0xffEBEFF3),
                        width: 2,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          "assets/icons/medicine.png",
                          scale: 6,
                        ),
                        Text(context.translate.medicine,
                            textAlign: TextAlign.center),
                        SizedBox(
                          height: 5,
                        ),
                        Text(
                          "$currencySymbol${format1.format(getExpenseByCategory("Medicine") * currencyRate)}",
                          style: TextStyle(
                            fontSize: 25,
                            fontWeight: FontWeight.w500,
                            fontFamily: 'Arial',
                          ),
                        )
                      ],
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            Category(categoryName: context.translate.clothes),
                      ),
                    );
                  },
                  child: Container(
                    margin: EdgeInsets.all(4),
                    width: MediaQuery.of(context).size.width / 3.5,
                    height: 150,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Color(0xffEBEFF3),
                        width: 2,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          "assets/icons/clothes.png",
                          scale: 6,
                        ),
                        Text(context.translate.clothes,
                            textAlign: TextAlign.center),
                        SizedBox(
                          height: 5,
                        ),
                        Text(
                          "$currencySymbol${format1.format(getExpenseByCategory("Clothes") * currencyRate)}",
                          style: TextStyle(
                            fontSize: 25,
                            fontWeight: FontWeight.w500,
                            fontFamily: 'Arial',
                          ),
                        )
                      ],
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Category(
                            categoryName: context.translate.petsupplies),
                      ),
                    );
                  },
                  child: Container(
                    margin: EdgeInsets.all(4),
                    width: MediaQuery.of(context).size.width / 3.5,
                    height: 150,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Color(0xffEBEFF3),
                        width: 2,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          "assets/icons/petsupplies.png",
                          scale: 6,
                        ),
                        Text(context.translate.petsupplies,
                            textAlign: TextAlign.center),
                        SizedBox(
                          height: 5,
                        ),
                        Text(
                          "$currencySymbol${format1.format(getExpenseByCategory("Pet Supplies") * currencyRate)}",
                          style: TextStyle(
                            fontSize: 25,
                            fontWeight: FontWeight.w500,
                            fontFamily: 'Arial',
                          ),
                        )
                      ],
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Category(
                            categoryName:
                                context.translate.recreationandentertainment),
                      ),
                    );
                  },
                  child: Container(
                    margin: EdgeInsets.all(4),
                    width: MediaQuery.of(context).size.width / 3.5,
                    height: 150,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Color(0xffEBEFF3),
                        width: 2,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          "assets/icons/recreationandentertainment.png",
                          scale: 6,
                        ),
                        Text(context.translate.recreationandentertainment,
                            textAlign: TextAlign.center),
                        SizedBox(
                          height: 5,
                        ),
                        Text(
                          "$currencySymbol${format1.format(getExpenseByCategory("Recreation and Entertainment") * currencyRate)}",
                          style: TextStyle(
                            fontSize: 25,
                            fontWeight: FontWeight.w500,
                            fontFamily: 'Arial',
                          ),
                        )
                      ],
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            Category(categoryName: context.translate.taxes),
                      ),
                    );
                  },
                  child: Container(
                    margin: EdgeInsets.all(4),
                    width: MediaQuery.of(context).size.width / 3.5,
                    height: 150,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Color(0xffEBEFF3),
                        width: 2,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          "assets/icons/taxes.png",
                          scale: 6,
                        ),
                        Text(context.translate.taxes,
                            textAlign: TextAlign.center),
                        SizedBox(
                          height: 5,
                        ),
                        Text(
                          "$currencySymbol${format1.format(getExpenseByCategory("Taxes") * currencyRate)}",
                          style: TextStyle(
                              fontSize: 25,
                              fontWeight: FontWeight.w500,
                              fontFamily: 'Arial'),
                        )
                      ],
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            Category(categoryName: context.translate.eat),
                      ),
                    );
                  },
                  child: Container(
                    margin: EdgeInsets.all(4),
                    width: MediaQuery.of(context).size.width / 3.5,
                    height: 150,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Color(0xffEBEFF3),
                        width: 2,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          "assets/icons/eat.png",
                          scale: 6,
                        ),
                        Text(context.translate.eat,
                            textAlign: TextAlign.center),
                        SizedBox(
                          height: 5,
                        ),
                        Text(
                          "$currencySymbol${format1.format(getExpenseByCategory("Eat") * currencyRate)}",
                          style: TextStyle(
                              fontSize: 25,
                              fontWeight: FontWeight.w500,
                              fontFamily: 'Arial'),
                        )
                      ],
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            Category(categoryName: context.translate.gifts),
                      ),
                    );
                  },
                  child: Container(
                    margin: EdgeInsets.all(4),
                    width: MediaQuery.of(context).size.width / 3.5,
                    height: 150,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Color(0xffEBEFF3),
                        width: 2,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          "assets/icons/gifts.png",
                          scale: 6,
                        ),
                        Text(context.translate.gifts,
                            textAlign: TextAlign.center),
                        SizedBox(
                          height: 5,
                        ),
                        Text(
                          "$currencySymbol${format1.format(getExpenseByCategory("Gifts") * currencyRate)}",
                          style: TextStyle(
                              fontSize: 25,
                              fontWeight: FontWeight.w500,
                              fontFamily: 'Arial'),
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 10,
            ),
            Text(
              context.translate.expensestatistics,
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(
              height: 10,
            ),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedTimeFilter = "day";
                        setExpenseStatistics("day");
                      });
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: selectedTimeFilter == "day"
                            ? Colors.green
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Color(0xffEBEFF3),
                          width: 2,
                        ),
                      ),
                      width: 120,
                      height: 40,
                      child: Center(
                          child: Text(
                        context.translate.aday,
                        style: TextStyle(
                            color: selectedTimeFilter == "day"
                                ? Colors.white
                                : Colors.grey[500]),
                      )),
                    ),
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        setState(() {
                          selectedTimeFilter = "week";
                          setExpenseStatistics("week");
                        });
                      });
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: selectedTimeFilter == "week"
                            ? Colors.green
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Color(0xffEBEFF3),
                          width: 2,
                        ),
                      ),
                      width: 120,
                      height: 40,
                      child: Center(
                          child: Text(
                        context.translate.aweek,
                        style: TextStyle(
                            color: selectedTimeFilter == "week"
                                ? Colors.white
                                : Colors.grey[500]),
                      )),
                    ),
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        setState(() {
                          selectedTimeFilter = "month";
                          setExpenseStatistics("month");
                        });
                      });
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: selectedTimeFilter == "month"
                            ? Colors.green
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Color(0xffEBEFF3),
                          width: 2,
                        ),
                      ),
                      width: 120,
                      height: 40,
                      child: Center(
                          child: Text(
                        context.translate.amonth,
                        style: TextStyle(
                            color: selectedTimeFilter == "month"
                                ? Colors.white
                                : Colors.grey[500]),
                      )),
                    ),
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        setState(() {
                          selectedTimeFilter = "year";
                          setExpenseStatistics("year");
                        });
                      });
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: selectedTimeFilter == "year"
                            ? Colors.green
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Color(0xffEBEFF3),
                          width: 2,
                        ),
                      ),
                      width: 120,
                      height: 40,
                      child: Center(
                          child: Text(
                        context.translate.ayear,
                        style: TextStyle(
                            color: selectedTimeFilter == "year"
                                ? Colors.white
                                : Colors.grey[500]),
                      )),
                    ),
                  ),
                  SizedBox(
                    width: 10,
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 15,
            ),
            Stack(children: [
              Container(
                width: MediaQuery.of(context).size.width,
                height: 300,
                child: PieChart(
                  PieChartData(
                    pieTouchData: PieTouchData(
                      touchCallback: (FlTouchEvent event, pieTouchResponse) {
                        setState(() {
                          if (!event.isInterestedForInteractions ||
                              pieTouchResponse == null ||
                              pieTouchResponse.touchedSection == null) {
                            touchedIndex = -1;
                            return;
                          }
                          touchedIndex = pieTouchResponse
                              .touchedSection!.touchedSectionIndex;
                        });
                      },
                    ),
                    borderData: FlBorderData(
                      show: false,
                    ),
                    sectionsSpace: 1,
                    centerSpaceRadius: MediaQuery.of(context).size.width / 4,
                    sections: showingSections(),
                  ),
                ),
              ),
              Container(
                  width: MediaQuery.of(context).size.width,
                  height: 300,
                  child: Center(
                      child: Text(
                    "$currencySymbol${format.format(expenseStatisticTotal * currencyRate)}",
                    style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'Arial'),
                  ))),
            ]),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Row(
                    children: [
                      Center(
                        child: Container(
                          width: 40,
                          height: 8,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: Colors.blue,
                          ),
                        ),
                      ),
                      Text(
                        e1name,
                        style: TextStyle(fontSize: 18),
                      ),
                    ],
                  ),
                  SizedBox(width: 15),
                  Row(
                    children: [
                      Center(
                        child: Container(
                          width: 40,
                          height: 8,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: Colors.green,
                          ),
                        ),
                      ),
                      Text(
                        e2name,
                        style: TextStyle(fontSize: 18),
                      ),
                    ],
                  ),
                  SizedBox(width: 15),
                  Row(
                    children: [
                      Center(
                        child: Container(
                          width: 40,
                          height: 8,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: Colors.red,
                          ),
                        ),
                      ),
                      Text(
                        e3name,
                        style: TextStyle(fontSize: 18),
                      ),
                    ],
                  ),
                  SizedBox(width: 15),
                  Row(
                    children: [
                      Center(
                        child: Container(
                          width: 40,
                          height: 8,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: Colors.grey,
                          ),
                        ),
                      ),
                      Text(
                        " ${context.translate.other}",
                        style: TextStyle(fontSize: 18),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 20,
            ),
            GestureDetector(
              onTap: () {
                _launchUrl();
              },
              child: Center(
                child: Text(
                  context.translate.privacy,
                  style: TextStyle(
                      color: Color(0xff41B746),
                      decoration: TextDecoration.underline,
                      decorationColor: Color(0xff41B746),
                      fontSize: 20),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  final Uri _url =
      Uri.parse('https://sites.google.com/view/uni-live-privacy-policy');
  Future<void> _launchUrl() async {
    if (!await launchUrl(_url)) {
      throw Exception('Could not launch $_url');
    }
  }

  Row greetingText() {
    var hour = DateTime.now().hour;
    String greetingText;
    Icon icon = Icon(
      Icons.sunny_snowing,
      color: Colors.green,
    );
    if (hour >= 6 && hour < 12) {
      greetingText = context.translate.gmorning;
      icon = Icon(
        Icons.sunny_snowing,
        color: Colors.green,
      );
    } else if (hour >= 12 && hour < 18) {
      greetingText = context.translate.gday;
      icon = Icon(
        Icons.sunny,
        color: Colors.green,
      );
    } else {
      greetingText = context.translate.gnight;
      icon = Icon(
        Icons.nights_stay,
        color: Colors.green,
      );
    }

    return Row(
      children: [
        icon,
        SizedBox(
          width: 5,
        ),
        Text(greetingText, style: TextStyle(color: Colors.green, fontSize: 16))
      ],
    );
  }

  List<PieChartSectionData> showingSections() {
    return List.generate(4, (i) {
      final isTouched = i == touchedIndex;
      final fontSize = isTouched ? 16.0 : 16.0;
      final radius = isTouched ? 25.0 : 25.0;
      const shadows = [Shadow(color: Colors.black, blurRadius: 2)];
      switch (i) {
        case 0:
          return PieChartSectionData(
            color: Colors.blue,
            value: e1,
            title: '',
            radius: radius,
            titleStyle: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              color: Colors.blue,
              shadows: shadows,
            ),
          );
        case 1:
          return PieChartSectionData(
            color: Colors.green,
            value: e2,
            title: '',
            radius: radius,
            titleStyle: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              color: Colors.blue,
              shadows: shadows,
            ),
          );
        case 2:
          return PieChartSectionData(
            color: Colors.red,
            value: e3,
            title: '',
            radius: radius,
            titleStyle: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              color: Colors.blue,
              shadows: shadows,
            ),
          );
        case 3:
          return PieChartSectionData(
            color: Colors.grey,
            value: e4,
            title: '',
            radius: radius,
            titleStyle: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              color: Colors.blue,
              shadows: shadows,
            ),
          );
        default:
          throw Error();
      }
    });
  }

  _saveCurrency(String language) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('savedLocale', language);
  }

  List<String>? catList = [];
  getCategoryListasync() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    catList = await prefs.getStringList("catList");
    setState(() {});
  }

  double getExpenseByCategory(String category) {
    double totalExpense = 0;
    for (var expense in expenseData) {
      if (expense["category"] == category) {
        totalExpense += expense["expense"];
      }
    }

    if (totalExpense >= e1) {
      e1 = totalExpense;
      e1name = category;
    } else if (totalExpense >= e2) {
      e2 = totalExpense;
      e2name = category;
    } else if (totalExpense >= e3) {
      e3 = totalExpense;
      e3name = category;
    } else if (totalExpense >= e4) {
      e4 = totalExpense;
    }

    return totalExpense;
  }

  void setExpenseStatistics(String filter) {
    expenseStatisticTotal = 0;
    if (filter == "day") {
      setState(() {
        expenseStatisticTotal = 0;
      });
      print(expenseStatisticTotal);
      for (var expense in expenseData) {
        if (DateTime.parse(expense["expenseDate"]).day == DateTime.now().day) {
          setState(() {
            expenseStatisticTotal += expense["expense"];
          });
        }
      }
    } else if (filter == "week") {
      expenseStatisticTotal = 0;
      for (var expense in expenseData) {
        if ((((DateTime.parse(expense["expenseDate"]).month - 1) * 30) +
                    DateTime.parse(expense["expenseDate"]).day) +
                7 >
            (((DateTime.now().month - 1) * 30) + DateTime.now().day)) {
          setState(() {
            expenseStatisticTotal += expense["expense"];
            print(expenseStatisticTotal);
          });
        }
      }
    } else if (filter == "month") {
      expenseStatisticTotal = 0;
      for (var expense in expenseData) {
        if (DateTime.parse(expense["expenseDate"]).month ==
            DateTime.now().month) {
          setState(() {
            expenseStatisticTotal += expense["expense"];
          });
        }
      }
    } else if (filter == "year") {
      expenseStatisticTotal = 0;
      for (var expense in expenseData) {
        if (DateTime.parse(expense["expenseDate"]).year ==
            DateTime.now().year) {
          setState(() {
            expenseStatisticTotal += expense["expense"];
          });
        }
      }
    }

    print(expenseStatisticTotal);
  }
}

class ChartData {
  ChartData(this.x, this.y);
  final int x;
  final double? y;
}

Future<String> _loadCurrency() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getString('currencyCode') ?? "USD";
}

_currencyRateDef() async {
  currencyCode = await _loadCurrency();
  currencyRate = await exchangeCurrency("USD", currencyCode, 1);
}

Future<double> exchangeCurrency(
    String first, String second, double amount) async {
  CurrencyRate rate =
      await LiveCurrencyRate.convertCurrency(first, second, amount);
  return rate.result;
}

List<String> initList(BuildContext context) {
  return [
    context.translate.january.substring(0, 3),
    context.translate.february.substring(0, 3),
    context.translate.march.substring(0, 3),
    context.translate.april.substring(0, 3),
    context.translate.may.substring(0, 3),
    context.translate.june.substring(0, 3),
    context.translate.july.substring(0, 3),
    context.translate.august.substring(0, 3),
    context.translate.september.substring(0, 3),
    context.translate.october.substring(0, 3),
    context.translate.november.substring(0, 3),
    context.translate.october.substring(0, 3),
  ];
}
