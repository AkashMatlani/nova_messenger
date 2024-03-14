import 'package:flutter/material.dart';
import 'package:nova/constant/global.dart';
import 'package:nova/provider/country.dart';

class PhoneAuthWidgets {
  static Widget getLogo({String logoPath, double height}) => Material(
        type: MaterialType.transparency,
        elevation: 1.0,
        child: Image.asset(logoPath, height: height),
      );
}

class SearchCountryTF extends StatelessWidget {
  final TextEditingController controller;

  const SearchCountryTF({Key key, this.controller}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 10, top: 8.0, bottom: 2.0, right: 10),
      child: Card(
        elevation: 0,
        color: Colors.grey.withOpacity(0.2), // Set the grey background color
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Row(
            children: [
              Icon(Icons.search),
              SizedBox(width: 8.0),
              Expanded(
                child: TextFormField(
                  autofocus: false,
                  controller: controller,
                  decoration: InputDecoration(
                    hintText: 'Search for your country',
                    border: InputBorder.none,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class PhoneNumberField extends StatelessWidget {
  final TextEditingController controller;
  final String prefix;

  const PhoneNumberField({Key key, this.controller, this.prefix})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          child: Row(
            children: <Widget>[
              Container(
                  decoration: BoxDecoration(
                    color: inputGrey,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  height: 45,
                  child: Center(child: Text("  " + prefix + "  ",
                      style: TextStyle(color: Colors.black, fontSize: 14)))),
              SizedBox(width: 8.0),
              Expanded(
                  child: TextFormField(
                controller: controller,
                autofocus: false,
                keyboardType: TextInputType.phone,
                key: Key('EnterPhone-TextFormField'),
                style: TextStyle(color: Colors.black),
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: appColor,
                    ),
                    borderRadius: const BorderRadius.all(
                      const Radius.circular(6.0),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: appColor,
                    ),
                    borderRadius: const BorderRadius.all(
                      const Radius.circular(6.0),
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.transparent,
                    ),
                    borderRadius: const BorderRadius.all(
                      const Radius.circular(6.0),
                    ),
                  ),
                  filled: true,
                  contentPadding: EdgeInsets.only(top: 10.0, left: 10),
                  fillColor: Colors.grey.withOpacity(0.2),
                ),
              )),
            ],
          ),
        ),
      ],
    );
  }
}

class SubTitle extends StatelessWidget {
  final String text;

  const SubTitle({Key key, this.text}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Align(
        alignment: Alignment.centerLeft,
        child: Text(' $text',
            style: TextStyle(
                color: Color(0xFF34C759),
                fontSize: 14.0,
                fontWeight: FontWeight.bold)));
  }
}

class ShowSelectedCountry extends StatelessWidget {
  final VoidCallback onPressed;
  final Country country;

  const ShowSelectedCountry({Key key, this.onPressed, this.country})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          color: textFieldBG,
          border: Border.all(
            color: Colors.transparent,
          ),
          borderRadius: BorderRadius.all(Radius.circular(6))),
      child: InkWell(
        onTap: onPressed,
        child: Padding(
          padding: const EdgeInsets.only(
              left: 4.0, right: 4.0, top: 12.0, bottom: 12.0),
          child: Column(
            children: [
              Row(
                children: <Widget>[
                  Expanded(
                      child: Text(
                    ' ${country.flag}  ${country.name} ',
                    style:
                        TextStyle(color: novaDark, fontWeight: FontWeight.bold),
                  )),
                  Icon(Icons.arrow_drop_down, size: 24.0)
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SelectableWidget extends StatelessWidget {
  final Function(Country) selectThisCountry;
  final Country country;

  const SelectableWidget({Key key, this.selectThisCountry, this.country})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      type: MaterialType.canvas,
      child: InkWell(
        onTap: () => selectThisCountry(country), //selectThisCountry(country),
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Text(
            "  " +
                country.flag +
                "  " +
                country.name +
                " (" +
                country.dialCode +
                ")",
            style: TextStyle(
                color: appColor, fontSize: 18.0, fontWeight: FontWeight.w500),
          ),
        ),
      ),
    );
  }
}
