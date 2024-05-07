// ignore_for_file: library_private_types_in_public_api, use_super_parameters, prefer_const_constructors_in_immutables, prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:unilive/addexpenses.dart';
import 'package:unilive/core/extensions/l10n.extensions.dart';

class CategorySelectorWidget extends StatefulWidget {
  final ValueChanged<String>? onImageSelected;

  CategorySelectorWidget({Key? key, this.onImageSelected}) : super(key: key);

  @override
  _CategorySelectorWidgetState createState() => _CategorySelectorWidgetState();
}

class _CategorySelectorWidgetState extends State<CategorySelectorWidget> {
  String? selectedImage;
  List<String> imagePaths = [
    "assets/icons/clothes.png",
    "assets/icons/shop.png",
    "assets/icons/eat.png",
    "assets/icons/gifts.png",
    "assets/icons/education.png",
    "assets/icons/insurance.png",
    "assets/icons/childrensproducts.png",
    "assets/icons/taxes.png",
    "assets/icons/recreationandentertainment.png",
    "assets/icons/utilities.png",
    "assets/icons/housing.png",
    "assets/icons/car.png",
    "assets/icons/medicine.png",
    "assets/icons/petsupplies.png",
  ];

  @override
  Widget build(BuildContext context) {
    Map<String, String> categoryMap = initMap(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: imagePaths.map((path) {
        return GestureDetector(
          onTap: () {
            setState(() {
              selectedImage = path;
            });
            if (widget.onImageSelected != null) {
              widget.onImageSelected!(path);
            }
          },
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 30, // İkon genişliği
                        height: 30, // İkon yüksekliği
                        decoration: BoxDecoration(
                          color: selectedImage == path ? Color(DF_CLR) : null,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Image.asset(
                          path,
                          color: selectedImage == path ? Colors.white : null,
                          fit: BoxFit.cover,
                        ),
                      ),
                      SizedBox(width: 10),
                      Text(
                        categoryMap[path]!,
                        style: TextStyle(
                            fontSize: 16,
                            color: selectedImage == path ? Color(DF_CLR) : null,
                            fontWeight:
                                selectedImage == path ? FontWeight.bold : null),
                      ),
                    ],
                  ),
                ],
              ),
              Container(
                height: 2,
                color: Colors.black,
                margin: EdgeInsets.symmetric(vertical: 5, horizontal: 5),
              ),
            ],
          ),
        );
      }).toList(),
    );
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
