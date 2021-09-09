import 'package:flutter/material.dart';

Widget appBarMain(BuildContext context) {
  return AppBar(
    title: Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Image.asset(
          "assets/images/logo.png",
          height: 40,
        ),

        SizedBox(width: 25,),
        Container(
          child: Text("Musgreet"),
        ),
        Padding(padding:EdgeInsetsDirectional.only(start: 115) ,
        child: InkWell(
          child: Icon(Icons.more_vert,color: Colors.black,),
        ),)
      ],
    ),
    backgroundColor: Colors.white,
    elevation: 2.5,

  );
}

InputDecoration textFieldInputDecoration(String hintText) {
  return InputDecoration(
      hintText: hintText,
      hintStyle: TextStyle(color: Colors.black54),
      focusedBorder:
          UnderlineInputBorder(borderSide: BorderSide(color: Colors.black)),
      enabledBorder:
          UnderlineInputBorder(borderSide: BorderSide(color: Colors.black)));
}

TextStyle simpleTextStyle() {
  return TextStyle(color: Colors.black, fontSize: 16);
}

TextStyle biggerTextStyle() {
  return TextStyle(color: Colors.black, fontSize: 17);
}
