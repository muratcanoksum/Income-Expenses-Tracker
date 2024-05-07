// ignore_for_file: prefer_const_constructors, library_private_types_in_public_api, unnecessary_null_comparison, prefer_const_literals_to_create_immutables, constant_identifier_names, unnecessary_import

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:unilive/core/extensions/l10n.extensions.dart';
import 'package:unilive/db_helper.dart';

import 'home.dart';

const int DF_CLR = 0XFF07873A;
const double SPC_BTW = 15.0;
String incomeValue = '';
String incomeamountValue = '';

class AddEarnings extends StatefulWidget {
  const AddEarnings({super.key});

  @override
  State<AddEarnings> createState() => _MainPageState();
}

class _MainPageState extends State<AddEarnings> {
  @override
  Widget build(BuildContext context) {
    return PopScope(
        canPop: false,
        child: Scaffold(
          appBar: MyAppBar(),
          body: MyBody(),
        ));
  }
}

class MyAppBar extends StatelessWidget implements PreferredSizeWidget {
  const MyAppBar({super.key});

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0, // gölgeyi kaldırır
      centerTitle: true,
      title: Text(
        context.translate.aaddearnings,
        style: TextStyle(color: Colors.black),
      ),
      leading: IconButton(
        icon: Icon(Icons.arrow_back_ios_new, color: Color(DF_CLR)),
        onPressed: () {
          // Geri butonu işlevselliği
          Navigator.of(context).pop();
        },
      ),
    );
  }
}

class MyBody extends StatefulWidget {
  const MyBody({super.key});

  @override
  _MyBodyState createState() => _MyBodyState();
}

class _MyBodyState extends State<MyBody> {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(),
        Row(
          children: [
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    context.translate.enterthenameincome,
                    style: TextStyle(fontSize: 15),
                  ),
                  SizedBox(height: 20),
                  SizedBox(
                    height: 20,
                    width: MediaQuery.of(context).size.width - 40,
                    child: TextField(
                      decoration: InputDecoration(hintText: "..."),
                      onChanged: (value) {
                        setState(() {
                          incomeValue = value;
                        });
                      },
                    ),
                  ),
                  SizedBox(height: 15),
                  Text(
                    context.translate.entertheamountincome,
                    style: TextStyle(fontSize: 15),
                  ),
                  SizedBox(height: 25),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: 20,
                        width: MediaQuery.of(context).size.width - 300,
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: "\$",
                            suffixText: "\$",
                          ),
                          keyboardType: TextInputType.number,
                          onChanged: (value) {
                            setState(() {
                              incomeamountValue = value;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            )
          ],
        ),
        Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
          Padding(
            padding: const EdgeInsets.all(25.0),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(DF_CLR), // Düğme metni rengi
                side: BorderSide(color: Colors.white, width: 2), // Kenarlık
                minimumSize: Size(MediaQuery.of(context).size.width / 3, 50),
                foregroundColor: Color(DF_CLR),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10), // Kenar yuvarlaklığı
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                context.translate.cancel,
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(25.0),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white, // Düğme metni rengi
                side: BorderSide(color: Color(DF_CLR), width: 2), // Kenarlık
                minimumSize: Size(MediaQuery.of(context).size.width / 3, 50),
                foregroundColor: Color(DF_CLR),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10), // Kenar yuvarlaklığı
                ),
              ),
              onPressed: () {
                addEarning();
                print("Name : $incomeValue Value : $incomeamountValue");
              },
              child: Text(
                context.translate.save,
                style: TextStyle(color: Color(DF_CLR)),
              ),
            ),
          ),
        ]),
      ],
    );
  }

  Future<void> addEarning() async {
    DbHelper dbHelper = DbHelper();
    await dbHelper.open();
    await dbHelper.addData("salary", incomeValue, DateTime.now().toString(),
        double.parse(incomeamountValue));
    List<Map<String, dynamic>> data = await dbHelper.getData();
    print(data);
    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => Home(),
        ));
  }
}
