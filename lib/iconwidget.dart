import 'package:flutter/material.dart';

class ImageSelectorWidget extends StatefulWidget {
  final ValueChanged<String>? onImageSelected;

  ImageSelectorWidget({Key? key, this.onImageSelected}) : super(key: key);

  @override
  _ImageSelectorWidgetState createState() => _ImageSelectorWidgetState();
}

class _ImageSelectorWidgetState extends State<ImageSelectorWidget> {
  String? selectedImage;
  List<String> imagePaths = [
    "assets/icons/clothes.png",
    "assets/icons/shop.png",
    "assets/icons/eat.png",
    "assets/icons/gifts.png",
    "assets/icons/education.png",
    "assets/icons/insurance.png",
    "assets/icons/childrensproducts.png",
  ];

  List<String> imagePaths2 = [
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
    return Column(
      children: [
        Wrap(
          spacing: 19, // Sütunlar arası boşluk
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
              child: Container(
                width: (MediaQuery.of(context).size.width - 50) /
                    10, // Ekran genişliğine göre resim genişliği
                height: (MediaQuery.of(context).size.width - 50) /
                    10, // Ekran genişliğine göre resim yüksekliği
                decoration: BoxDecoration(
                  color: selectedImage == path ? Colors.grey[300] : null,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Image.asset(
                  path,
                  fit: BoxFit.cover,
                ),
              ),
            );
          }).toList(),
        ),
        SizedBox(height: 10),
        Wrap(
          spacing: 19, // Sütunlar arası boşluk
          runSpacing: 10, // Satırlar arası boşluk
          children: imagePaths2.map((path2) {
            return GestureDetector(
              onTap: () {
                setState(() {
                  selectedImage = path2;
                });
                if (widget.onImageSelected != null) {
                  widget.onImageSelected!(path2);
                }
              },
              child: Container(
                width: (MediaQuery.of(context).size.width - 50) /
                    10, // Ekran genişliğine göre resim genişliği
                height: (MediaQuery.of(context).size.width - 50) /
                    10, // Ekran genişliğine göre resim yüksekliği
                decoration: BoxDecoration(
                  color: selectedImage == path2 ? Colors.grey[300] : null,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Image.asset(
                  path2,
                  fit: BoxFit.cover,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
