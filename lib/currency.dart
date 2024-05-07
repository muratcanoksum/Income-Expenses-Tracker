// ignore_for_file: prefer_const_constructors, library_private_types_in_public_api, unnecessary_null_comparison, prefer_const_literals_to_create_immutables, constant_identifier_names, unnecessary_import, unused_import, avoid_print, avoid_function_literals_in_foreach_calls
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:live_currency_rate/live_currency_rate.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:unilive/core/extensions/l10n.extensions.dart';

const int defaultColor = 0xFF07873A;
const double spaceBetween = 15.0;
const String defaultCurrency = "US Dollar";
String? selectedItem;
String selectedItemCode = defaultCurrency;
double currencyRate = 1;

class Currency extends StatefulWidget {
  const Currency({super.key});

  @override
  State<Currency> createState() => _CurrencyState();
}

class _CurrencyState extends State<Currency> {
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    currencyRateCalc(currencies);
  }

  Future<void> currencyRateCalc(Map<String, Map<String, String>> map) async {
    setState(() {
      isLoading = true;
    });
    map.keys.forEach((key) async {
      CurrencyRate rate = await LiveCurrencyRate.convertCurrency("USD", key, 1);
      currencyRates[key] = rate.result;
    });
    await Future.delayed(Duration(seconds: 1));
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        appBar: _buildAppBar(),
        body: isLoading
            ? Center(
                child: CircularProgressIndicator(), // Yükleniyor ekranı
              )
            : _buildBody(),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      foregroundColor: Colors.white,
      shadowColor: Colors.white,
      centerTitle: true,
      title: Text(
        context.translate.currencyconverter,
        style: TextStyle(color: Colors.black),
      ),
      leading: IconButton(
        icon: Icon(Icons.arrow_back_ios_new, color: Color(defaultColor)),
        onPressed: () async {
          Navigator.pop(context);
        },
      ),
    );
  }

  Widget _buildBody() {
    return MyBody();
  }
}

class MyBody extends StatefulWidget {
  const MyBody({super.key});

  @override
  _MyBodyState createState() => _MyBodyState();
}

class _MyBodyState extends State<MyBody> {
  @override
  void initState() {
    super.initState();
    _loadCurrency();
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: currencies.length,
      itemBuilder: (context, index) {
        final currencyCode = currencies.keys.elementAt(index);
        final currencyName = currencies[currencyCode]?["name"];
        final currencySymbol = currencies[currencyCode]?["symbol"];
        return ListTile(
          selectedColor: Colors.white,
          selectedTileColor: Color(defaultColor),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(currencyName!),
              Text(currencyCode),
            ],
          ),
          onTap: () {
            setState(() {
              selectedItem = currencyCode;
              selectedItemCode = currencyName;
            });
            if (currencyRates[currencyCode] == 0) {
              currencyRate = currencyRatesOld[currencyCode]!;
              print("durum1");
            } else {
              currencyRate = currencyRates[currencyCode]!;
              print("durum2");
            }
            if (currencyRate == null || currencyRate == 0) {
              currencyRate = 1;
              print("durum3");
            }
            _saveCurrency(
                currencyName, currencyCode, currencySymbol, currencyRate);

            Navigator.pop(context, [currencyRate, currencySymbol]);
          },
          selected: selectedItemCode == currencyName,
        );
      },
    );
  }

  _loadCurrency() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      selectedItemCode = prefs.getString('currency') ?? defaultCurrency;
    });
  }

  _saveCurrency(String currencyDF, currencyCodeDF, currencySymbolDF,
      double currencyRateDF) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('currency', currencyDF);
    await prefs.setString('currencyCode', currencyCodeDF);
    await prefs.setString('currencySymbol', currencySymbolDF);
    await prefs.setDouble("currencyRate", currencyRateDF);
  }
}

Map<String, Map<String, String>> currencies = {
  "EUR": {"name": "Euro", "symbol": "€"},
  "USD": {"name": "US Dollar", "symbol": "\$"},
  "RUB": {"name": "Russian Ruble", "symbol": "₽"},
  "HUF": {"name": "Hungarian forint", "symbol": "Ft"},
  "BRL": {"name": "Brazilian Real", "symbol": "R\$"},
  "AED": {"name": "United Arab Emirates Dirham", "symbol": "AED"},
  "AFN": {"name": "Afghan Afghani", "symbol": "AFN"},
  "ALL": {"name": "Albanian Lek", "symbol": "ALL"},
  "AMD": {"name": "Armenian Dram", "symbol": "AMD"},
  "ANG": {"name": "Netherlands Antillean Guilder", "symbol": "ANG"},
  "AOA": {"name": "Angolan Kwanza", "symbol": "AOA"},
  "ARS": {"name": "Argentine Peso", "symbol": "ARS"},
  "AUD": {"name": "Australian Dollar", "symbol": "A\$"},
  "AZN": {"name": "Azerbaijani Manat", "symbol": "AZN"},
  "BAM": {"name": "Bosnia-Herzegovina Convertible Mark", "symbol": "BAM"},
  "BGN": {"name": "Bulgarian Lev", "symbol": "BGN"},
  "BHD": {"name": "Bahraini Dinar", "symbol": "BHD"},
  "CAD": {"name": "Canadian Dollar", "symbol": "CA\$"},
  "CHF": {"name": "Swiss Franc", "symbol": "CHF"},
  "CNY": {"name": "Chinese Yuan", "symbol": "CN¥"},
  "COP": {"name": "Colombian Peso", "symbol": "COP"},
  "CUP": {"name": "Cuban Peso", "symbol": "CUP"},
  "CZK": {"name": "Czech Republic Koruna", "symbol": "CZK"},
  "DOP": {"name": "Dominican Peso", "symbol": "DOP"},
  "FJD": {"name": "Fijian Dollar", "symbol": "FJD"},
  "FKP": {"name": "Falkland Islands Pound", "symbol": "FKP"},
  "GBP": {"name": "British Pound Sterling", "symbol": "£"},
  "HKD": {"name": "Hong Kong Dollar", "symbol": "HK\$"},
  "IQD": {"name": "Iraqi Dinar", "symbol": "IQD"},
  "JPY": {"name": "Japanese Yen", "symbol": "¥"},
  "KWD": {"name": "Kuwaiti Dinar", "symbol": "KWD"},
  "LYD": {"name": "Libyan Dinar", "symbol": "LYD"},
  "MXN": {"name": "Mexican Peso", "symbol": "MX\$"},
  "NZD": {"name": "New Zealand Dollar", "symbol": "NZ\$"},
  "PGK": {"name": "Papua New Guinean Kina", "symbol": "PGK"},
  "RON": {"name": "Romanian Leu", "symbol": "RON"},
  "SAR": {"name": "Saudi Riyal", "symbol": "SAR"},
  "SDG": {"name": "Sudanese Pound", "symbol": "SDG"},
  "SGD": {"name": "Singapore Dollar", "symbol": "SGD"},
  "TMT": {"name": "Turkmenistani Manat", "symbol": "TMT"},
  "TND": {"name": "Tunisian Dinar", "symbol": "TND"},
  "TRY": {"name": "Turkish Lira", "symbol": "₺"},
  "TWD": {"name": "New Taiwan Dollar", "symbol": "NT\$"},
  "UYU": {"name": "Uruguayan Peso", "symbol": "UYU"},
  "VND": {"name": "Vietnamese Dong", "symbol": "₫"},
  "YER": {"name": "Yemeni Rial", "symbol": "YER"},
  "ZWL": {"name": "Zimbabwean Dollar", "symbol": "ZWL"}
};

Map<String, double> currencyRates = {
  "USD": 1,
  "EUR": 1,
  "RUB": 1,
  "HUF": 1,
  "BRL": 1,
  "AED": 1,
  "AFN": 1,
  "ALL": 1,
  "AMD": 1,
  "ANG": 1,
  "AOA": 1,
  "ARS": 1,
  "AUD": 1,
  "AZN": 1,
  "BAM": 1,
  "BGN": 1,
  "BHD": 1,
  "CAD": 1,
  "CHF": 1,
  "CNY": 1,
  "COP": 1,
  "CUP": 1,
  "CZK": 1,
  "DOP": 1,
  "FJD": 1,
  "FKP": 1,
  "GBP": 1,
  "HKD": 1,
  "IQD": 1,
  "JPY": 1,
  "KWD": 1,
  "LYD": 1,
  "MXN": 1,
  "NZD": 1,
  "PGK": 1,
  "RON": 1,
  "SAR": 1,
  "SDG": 1,
  "SGD": 1,
  "TMT": 1,
  "TND": 1,
  "TRY": 1,
  "TWD": 1,
  "UYU": 1,
  "VND": 1,
  "YER": 1,
  "ZWL": 1
};

Map<String, double> currencyRatesOld = {
  "USD": 1.0,
  "EUR": 0.9341,
  "RUB": 91.9201,
  "HUF": 366.6597,
  "BRL": 5.1234,
  "AED": 3.6725,
  "AFN": 72.1936,
  "ALL": 94.2205,
  "AMD": 389.3097,
  "ANG": 1.79,
  "AOA": 842.4878,
  "ARS": 864.75,
  "AUD": 1.5298,
  "AZN": 1.7035,
  "BAM": 1.827,
  "BGN": 1.827,
  "BHD": 0.376,
  "CAD": 1.3656,
  "CHF": 0.9136,
  "CNY": 7.2655,
  "COP": 3932.4483,
  "CUP": 24.0,
  "CZK": 23.4961,
  "DOP": 58.7339,
  "FJD": 2.2583,
  "FKP": 0.8002,
  "GBP": 0.8001,
  "HKD": 7.8291,
  "IQD": 1310.419,
  "JPY": 157.9455,
  "KWD": 0.3082,
  "LYD": 4.8668,
  "MXN": 17.1808,
  "NZD": 1.682,
  "PGK": 3.8354,
  "RON": 4.6463,
  "SAR": 3.75,
  "SDG": 458.4875,
  "SGD": 1.3621,
  "TMT": 3.5006,
  "TND": 3.1404,
  "TRY": 32.5684,
  "TWD": 32.5869,
  "UYU": 38.6772,
  "VND": 25319.1844,
  "YER": 250.4908,
  "ZWL": 13.4218
};
