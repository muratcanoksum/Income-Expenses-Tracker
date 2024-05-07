// ignore_for_file: prefer_const_constructors, library_private_types_in_public_api, unnecessary_null_comparison, prefer_const_literals_to_create_immutables, constant_identifier_names, unnecessary_import, unused_import

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:unilive/categorywidget.dart';
import 'package:unilive/core/extensions/l10n.extensions.dart';

import 'db_helper.dart';
import 'home.dart';

const int DF_CLR = 0XFF07873A;
const double SPC_BTW = 15.0;
String expenseValue = '';
String expenseamountValue = '';

class AddExpenes extends StatefulWidget {
  const AddExpenes({super.key});

  @override
  State<AddExpenes> createState() => _MainPageState();
}

class _MainPageState extends State<AddExpenes> {
  @override
  Widget build(BuildContext context) {
    return PopScope(
        canPop: false,
        child: Scaffold(
          appBar: MyAppBar(),
          body: SingleChildScrollView(child: MyBody()),
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
      elevation: 0,
      shadowColor: Colors.white,
      surfaceTintColor: Colors.white,
      centerTitle: true,
      title: Text(
        context.translate.addexpenses,
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
  String? selectedImage;

  @override
  Widget build(BuildContext context) {
    Map<String, String> categoryMap = initMap(context);
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
                    context.translate.enternameexpense,
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
                          expenseValue = value;
                        });
                      },
                    ),
                  ),
                  SizedBox(height: 15),
                  Text(
                    context.translate.selectexpense,
                    style: TextStyle(fontSize: 15),
                  ),
                  SizedBox(height: 15),
                  CategorySelectorWidget(
                    onImageSelected: (imagePath) {
                      setState(() {
                        selectedImage = imagePath;
                      });
                    },
                  ),
                  SizedBox(height: 15),
                  Text(
                    context.translate.enteramountexpense,
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
                              expenseamountValue = value;
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
                addExpense(categoryMap[selectedImage]!);
                print(
                    "Name : $expenseValue Value : $expenseamountValue Choose : ${categoryMap[selectedImage]}");
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

  Future<void> addExpense(String category) async {
    DbHelper dbHelper = DbHelper();
    await dbHelper.open();
    await dbHelper.addData(category, expenseValue, DateTime.now().toString(),
        double.parse(expenseamountValue));
    List<Map<String, dynamic>> data = await dbHelper.getData();
    print(data);
    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => Home(),
        ));
  }

}




Map<String, String> initMap(BuildContext context) {
  return {
    "Choose a icon": context.translate.selecticon,
    "assets/icons/car.png": context.translate.car,
    "assets/icons/clothes.png": context.translate.clothes,
    "assets/icons/shop.png": context.translate.shop,
    "assets/icons/eat.png": context.translate.eat,
    "assets/icons/gifts.png": context.translate.gifts,
    "assets/icons/education.png": context.translate.education,
    "assets/icons/insurance.png": context.translate.insurance,
    "assets/icons/childrensproducts.png": context.translate.childrensproducts,
    "assets/icons/taxes.png": context.translate.taxes,
    "assets/icons/utilities.png": context.translate.utilities,
    "assets/icons/recreationandentertainment.png":
        context.translate.recreationandentertainment,
    "assets/icons/housing.png": context.translate.housing,
    "assets/icons/petsupplies.png": context.translate.petsupplies,
    "assets/icons/medicine.png": context.translate.medicine,
  };
}
