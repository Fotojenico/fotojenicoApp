import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:video_player/video_player.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;

import 'package:fotojenico/globals.dart';
import 'package:fotojenico/navbar.dart';

class SendScreen extends StatefulWidget {
  @override
  _SendScreenState createState() {
    return _SendScreenState();
  }
}

class _SendScreenState extends State<SendScreen> {
  Future uploadFile(String filePath) async {
    Future<IdTokenResult> idToken;
    user.map((value) => idToken = value.user.getIdTokenResult(), empty: (_) {}, initializing: (_) {});

    //create multipart request for POST or PATCH method
    var request = http.MultipartRequest("POST", Uri.parse(webApiUrl + "posts/"));
    //add text fields
    await idToken.then((value) => request.headers["auth"] = value.token);
    //create multipart using filepath, string or bytes
    var pic = await http.MultipartFile.fromPath("file", filePath);
    //add multipart to request
    request.files.add(pic);
    var response = await request.send();

    //Get the response from the server
    var responseData = await response.stream.toBytes();
    var responseString = String.fromCharCodes(responseData);
    print(responseString);
  }

  Widget base(Widget media) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          Container(
            child: Center(
              child: media,
            ),
          ),
          Stack(
            children: <Widget>[
              Align(
                alignment: Alignment.topLeft,
                child: IconButton(
                  icon: Icon(Icons.arrow_back),
                  onPressed: () {
                    setState(() {
                      sentScreenToggle = false;
                    });
                    Navigator.pop(context);
                  },
                ),
              )
            ],
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Visibility(
        visible: true,
        child: GestureDetector(
          onTap: () {
            uploadFile(sentImage);
            setState(() {
              sentImage = null;
              sentVideo = null;
            });
            Navigator.pop(context);
          },
          // ignore: missing_required_param
          child: FloatingActionButton(
            //tooltip: floatingActionTooltip,
            backgroundColor: Theme.of(context).backgroundColor,
            foregroundColor: Theme.of(context).primaryColor,
            child: Icon(Icons.send),
          ),
        ),
      ),
      bottomNavigationBar: navBar(context, 2),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (sentImage != null) {
      return base(Image.file(File(sentImage)));
    } else if (sentVideo != null) {
      VideoPlayerController videoController = VideoPlayerController.file(File(sentVideo));
      return base(Container(
        child: Center(
          child: AspectRatio(
              aspectRatio: videoController.value.size != null ? videoController.value.aspectRatio : 1.0, child: VideoPlayer(videoController)),
        ),
        decoration: BoxDecoration(border: Border.all(color: Colors.pink)),
      ));
    } else {
      return base(Text("There is an error"));
    }
  }
}
