import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:nova/utils/hive_preferences.dart';

class PolicyDialog extends StatelessWidget {
  PolicyDialog(
      {Key key, this.radius = 8, this.contextPolicy, @required this.mdFileName})
      : assert(mdFileName.contains('.md'),
            'The file must contain the .md extension'),
        super(key: key);

  final double radius;
  final String mdFileName;
  final BuildContext contextPolicy;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(radius)),
      child: Column(
        children: [
          Expanded(
            child: FutureBuilder(
              future: Future.delayed(Duration(milliseconds: 150)).then((value) {
                return rootBundle.loadString('assets/$mdFileName');
              }),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return Markdown(
                    data: snapshot.data,
                  );
                }
                return Center(
                  child: CircularProgressIndicator(),
                );
              },
            ),
          ),
          TextButton(
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.zero)),
              backgroundColor: Theme.of(context).buttonColor,
            ),
            onPressed: () async {
              Navigator.of(context).pop();
              final preferences = await HivePreferences.getInstance();
              preferences.setTermsAcceptance(false);
            },
            child: Container(
              alignment: Alignment.center,
              height: 50,
              width: double.infinity,
              child: Text(
                "Do not accept",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.normal,
                  color: Theme.of(context).textTheme.button.color,
                ),
              ),
            ),
          ),
          Container(color: Colors.grey, height: 1.0),
          TextButton(

            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.zero)),
              backgroundColor: Theme.of(context).buttonColor,
            ),
            onPressed: () async {
              Navigator.of(context).pop();
              final preferences = await HivePreferences.getInstance();
              preferences.setTermsAcceptance(true);
            },
            child: Container(
              alignment: Alignment.center,
              height: 50,
              width: double.infinity,
              child: Text(
                "Accept",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.normal,
                  color: Theme.of(context).textTheme.button.color,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
