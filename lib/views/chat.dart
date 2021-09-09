import 'dart:io';

import 'package:chatapp/helper/constants.dart';
import 'package:chatapp/services/database.dart';
import 'package:chatapp/services/firebase_api.dart';
import 'package:chatapp/widget/widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';



class Chat extends StatefulWidget {
  final String chatRoomId;

  Chat({this.chatRoomId});

  @override
  _ChatState createState() => _ChatState();
}

class _ChatState extends State<Chat> {
  Stream<QuerySnapshot> chats;
  TextEditingController messageEditingController = new TextEditingController();

/*
  File _imageOfGallery;
  Future getImagefromGallery() async {
    try {
      final image = await ImagePicker().getImage(source: ImageSource.gallery);
      if (image == null) {
        return;
      }
      final imageTemporary = File(image.path);
      setState(() {
        this._imageOfGallery = imageTemporary;
      });
      print(_imageOfGallery);
      // selectFilefromGallery();
    } on PlatformException catch (e) {
      print("Failed to pick image: $e");
    }
    String fileName = _imageOfGallery.path.split('/').last;
    print(fileName);
  }

  File _imageOfCamera;
  Future getImagefromCamera() async {
    try {
      final image = await ImagePicker().getImage(source: ImageSource.camera);
      if (image == null) {
        return;
      }
      final imageTemporary = File(image.path);
      setState(() {
        this._imageOfCamera = imageTemporary;
      });
    } on PlatformException catch (e) {
      print("Failed to pick image: $e");
    }
  }

  String urlDownloadPhoto;
  String urlDownloadSelfie;

  Future uploadImageOfGallery() async {
    if (_imageOfGallery == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("No Image Selected")));
      return;
    }
    String fileName = _imageOfGallery.path.split('/').last;
    final destination = 'userPhoto/$fileName';

    FirebaseUser user = FirebaseApi.uploadFile(destination, _imageOfGallery);
    if (user == null) {
      return;
    }
    //final snapshot = await user.`(() {});
    var snapshot;
    urlDownloadPhoto = await snapshot.ref.getDownloadURL();
    print(urlDownloadPhoto);
  }

  Future uploadImageOfCamera() async {
    if (_imageOfCamera == null) {
      return;
    }
    String fileName = _imageOfCamera.path.split('/').last;
    final destination = 'userSelfie/$fileName';
    FirebaseUser user = FirebaseApi.uploadFile(destination, _imageOfCamera);
    if (user == null) {
      return;
    }
    //final snapshot = await user.whenComplete(() {});
    var snapshot;
    urlDownloadSelfie = await snapshot.ref.getDownloadURL();
    print(urlDownloadSelfie);
  }

*/

  Widget chatMessages() {
    return StreamBuilder(
      stream: chats,
      builder: (context, snapshot) {
        return snapshot.hasData
            ? ListView.builder(
                itemCount: snapshot.data.documents.length,
                itemBuilder: (context, index) {
                  return MessageTile(
                    message: snapshot.data.documents[index].data["message"],
                    sendByMe: Constants.myName ==
                        snapshot.data.documents[index].data["sendBy"],
                  );
                })
            : Container();
      },
    );
  }

  addMessage() {
    if (messageEditingController.text.isNotEmpty) {
      Map<String, dynamic> chatMessageMap = {
        "sendBy": Constants.myName,
        "message": messageEditingController.text,
        'time': DateTime.now().minute,
      };

      DatabaseMethods().addMessage(widget.chatRoomId, chatMessageMap);

      setState(() {
        messageEditingController.text = "";
      });
    }
  }

  @override
  void initState() {
    DatabaseMethods().getChats(widget.chatRoomId).then((val) {
      setState(() {
        chats = val;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarMain(context),
      body: Stack(
        children: [
          chatMessages(),
          ClipRRect(
            borderRadius: BorderRadius.circular(0),
            child: Container(
              alignment: Alignment.bottomCenter,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 0, vertical: 0),
                child: Card(
                  child: Row(
                    children: [
                      SizedBox(
                        width: 15,
                      ),
                      Expanded(
                          child: TextField(
                        controller: messageEditingController,
                        style: simpleTextStyle(),
                        decoration: InputDecoration(
                            hintText: "Type your message here...",
                            hintStyle: TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                            ),
                            border: InputBorder.none),
                      )),
                      SizedBox(
                        width: 16,
                      ),
                      GestureDetector(
                          onTap: () {},
                          child: Container(
                              height: 40,
                              width: 40,
                              child: Icon(
                                Icons.camera_alt_rounded,
                                color: Colors.black,
                              ))),
                      SizedBox(
                        width: 5,
                      ),
                      Container(
                          height: 40,
                          width: 40,
                          child: Image.asset(
                            "assets/images/line.png",
                            height: 25,
                            width: 25,
                            color: Colors.black,
                          )),
                      SizedBox(
                        width: 5,
                      ),
                      Padding(
                        padding: EdgeInsetsDirectional.only(end: 10),
                        child: GestureDetector(
                          onTap: () {
                            addMessage();
                          },
                          child: Container(
                              height: 20,
                              width: 20,
                              child: Image.asset(
                                "assets/images/send.png",
                                height: 25,
                                width: 25,
                                color: Colors.black,
                              )),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}

class MessageTile extends StatelessWidget {
  final String message;
  final bool sendByMe;
  final int time = DateTime.now().minute;

  MessageTile({
    @required this.message,
    @required this.sendByMe,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          child: Column(
            children: [
              sendByMe
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Stack(
                          children: [
                            Container(
                              width: MediaQuery.of(context).size.width / 2,
                              padding: EdgeInsets.only(
                                  top: 8,
                                  bottom: 8,
                                  left: sendByMe ? 0 : 24,
                                  right: sendByMe ? 24 : 0),
                              alignment: sendByMe
                                  ? Alignment.centerRight
                                  : Alignment.centerLeft,
                              child: Container(
                                margin: sendByMe
                                    ? EdgeInsets.only(left: 30)
                                    : EdgeInsets.only(right: 30),
                                padding: EdgeInsets.only(
                                    top: 17, bottom: 17, left: 20, right: 20),
                                decoration: BoxDecoration(
                                    borderRadius: sendByMe
                                        ? BorderRadius.only(
                                            topLeft: Radius.circular(23),
                                            topRight: Radius.circular(23),
                                            bottomLeft: Radius.circular(23),
                                            bottomRight: Radius.circular(23))
                                        : BorderRadius.only(
                                            topLeft: Radius.circular(23),
                                            topRight: Radius.circular(23),
                                            bottomRight: Radius.circular(23),
                                            bottomLeft: Radius.circular(23)),
                                    gradient: LinearGradient(
                                      colors: sendByMe
                                          ? [
                                              Colors.green[300],
                                              Colors.green[300],
                                            ]
                                          : [
                                              Colors.white,
                                              Colors.white,
                                            ],
                                    )),
                                child: Container(
                                  child: Column(
                                    children: [
                                      Text(message,
                                          textAlign: TextAlign.start,
                                          style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 16,
                                              fontFamily: 'OverpassRegular',
                                              fontWeight: FontWeight.w300)),
                                      SizedBox(
                                        height: 5,
                                      ),
                                      Container(
                                        alignment: Alignment.bottomRight,
                                        margin: EdgeInsetsDirectional.only(
                                            start: 50),
                                        child: Text(
                                          "$time min",
                                          style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            Padding(padding: EdgeInsetsDirectional.only(start: 150),
                            child: Container(
                              //margin: EdgeInsets.symmetric(vertical: 0,horizontal: 150),
                              decoration: BoxDecoration(
                                  border: Border(
                                      right: BorderSide(
                                          color: Colors.grey, width: 2),
                                      bottom: BorderSide(
                                          color: Colors.grey, width: 2),
                                      top: BorderSide(
                                          color: Colors.grey, width: 2),
                                      left: BorderSide(
                                          color: Colors.grey, width: 2)),
                                  borderRadius: BorderRadius.circular(50)),
                              height: 35,
                              width: 35,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(50),
                                child: Image.asset("assets/images/logo.png"),
                              ),
                            ),)
                          ],
                        ),
                      ],
                    )
                  : Column(
                      children: [
                        Container(
                          padding: EdgeInsets.only(
                              top: 8,
                              bottom: 8,
                              left: sendByMe ? 0 : 24,
                              right: sendByMe ? 24 : 0),
                          alignment: sendByMe
                              ? Alignment.centerRight
                              : Alignment.centerLeft,
                          child: Container(
                            margin: sendByMe
                                ? EdgeInsets.only(left: 30)
                                : EdgeInsets.only(right: 30),
                            /*  padding: EdgeInsets.only(
                                top: 17, bottom: 17, left: 20, right: 20)*/
                            decoration: BoxDecoration(
                                borderRadius: sendByMe
                                    ? BorderRadius.only(
                                        topLeft: Radius.circular(23),
                                        topRight: Radius.circular(23),
                                        bottomLeft: Radius.circular(23),
                                        bottomRight: Radius.circular(23))
                                    : BorderRadius.only(
                                        topLeft: Radius.circular(23),
                                        topRight: Radius.circular(23),
                                        bottomRight: Radius.circular(23),
                                        bottomLeft: Radius.circular(23)),
                                gradient: LinearGradient(
                                  colors: sendByMe
                                      ? [
                                          Colors.green[300],
                                          Colors.green[300],
                                        ]
                                      : [
                                          Colors.white,
                                          Colors.white,
                                        ],
                                )),
                            child: Container(
                              child: Column(
                                children: [
                                  Text(message,
                                      textAlign: TextAlign.start,
                                      style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 16,
                                          fontFamily: 'OverpassRegular',
                                          fontWeight: FontWeight.w300)),

                                  Container(
                                    padding:
                                        EdgeInsetsDirectional.only(end: 20),
                                    margin:
                                        EdgeInsetsDirectional.only(start: 50),
                                    child: Text(
                                      "$time min",
                                      style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    )
            ],
          ),
        ),
        SizedBox(
          height: 60,
        )
      ],
    );
  }
}

/*
class FirebaseApi {

  static  UploadTask uploadFile(String destination, File file) {
    try {
      final  ref = FirebaseStorage.instance.ref(destination);

      return ref.putFile(file);
    }  catch ( FirebaseException , e) {
      print(e);
      return null;
    }
  }
}*/
