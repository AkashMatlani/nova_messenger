import 'package:flutter/material.dart';
import 'package:nova/constant/global.dart';
import 'package:nova/models/contact_data.dart';

class SelectedUserTile extends StatelessWidget {
  final ContactData user;
  final Function() onRemoveUser;

  const SelectedUserTile({@required this.user, @required this.onRemoveUser});

  @override
  Widget build(BuildContext context) {
    return Container(
        height: 80,
        width: 80,
        child: Stack(
          children: [
            Padding(
                padding: EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    user.avatar != ""
                        ? CircleAvatar(
                            radius: 25.0,
                            backgroundColor: Colors.grey,
                            backgroundImage: NetworkImage(user.avatar),
                          )
                        : CircleAvatar(
                            radius: 25.0,
                            backgroundColor: Colors.grey[300],
                            backgroundImage: NetworkImage(noImage),
                            child: Text(
                              "",
                              style: TextStyle(
                                  color: Colors.green,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold),
                            )),
                    Container(
                        padding: EdgeInsets.all(8),
                        child: Text(
                          user.name.length <= 5
                              ? user.name
                              : user.name
                                  .replaceRange(5, user.name.length, '..'),
                          style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                              fontWeight: FontWeight.bold),
                        )),
                  ],
                )),
            Positioned(
                top: 40,
                right: 23,
                child: InkWell(
                  onTap: onRemoveUser, //onDeselect
                  child: Card(
                    color: appColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(80),
                    ),
                    child: Container(
                      alignment: Alignment.center,
                      height: 18,
                      width: 18,
                      decoration: BoxDecoration(),
                      child: Icon(
                        Icons.clear,
                        size: 15,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ))
          ],
        ));
  }

  String sepText(String text, int n) {
    String result = '';

    int currentIndex = 0;

    while (currentIndex < text.length) {
      if (currentIndex % n == 0 && currentIndex != 0) result += '\n';
      result += text[currentIndex];
      currentIndex++;
    }

    return result;
  }
}
