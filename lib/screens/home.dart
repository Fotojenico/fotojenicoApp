import 'dart:async';
import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:fotojenico/objects/post.dart';
import 'package:http/http.dart' as http;
import 'package:lit_firebase_auth/lit_firebase_auth.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_admob/firebase_admob.dart';
import 'package:fotojenico/globals.dart';
import 'package:fotojenico/navbar.dart';
import 'package:fluttertoast/fluttertoast.dart';

class HomeScreen extends StatefulWidget {
  @override
  CardDemoState createState() => new CardDemoState();
}

class CardDemoState extends State<HomeScreen> with TickerProviderStateMixin {
  AnimationController _buttonController;
  Animation<double> rotate;
  Animation<double> right;
  Animation<double> left;
  Animation<double> bottom;
  Animation<double> width;
  List data = [];
  List dataCache = [];
  bool loading = false;
  bool lastEmpty = false;
  bool start = true;
  String postUrl = webApiUrl + 'posts/';
  String lastFav;
  DateTime watchCounter = DateTime.now();
  Icon floatingIcon = Icon(
    Icons.favorite_border,
    size: 40,
  );
  Post selectedImage;

  Future<Null> getDataList() async {
    setState(() {
      loading = true;
    });
    String _token;
    Future<IdTokenResult> idToken;

    await user.map((value) => idToken = value.user.getIdTokenResult(), empty: (_) {}, initializing: (_) {});
    await idToken.then((value) => _token = value.token);
    Map<String, String> header = new Map();
    header["auth"] = _token;
    try {
      var urlList = [];
      final request = await http.get(postUrl, headers: header);
      List<Post> postList = ((json.decode(request.body) as List).map((i) => Post.fromJson(i)).toList());
      if(postList.length == 0){
        setState(() {
          lastEmpty = true;
        });
      }
      urlList.addAll(postList);
      var urls = dataCache;
      urls.insertAll(0, urlList);
      setState(() {
        dataCache = urls;
        if (start){
          data = dataCache;
          start = false;
        }
      });
    } catch (e) {
      print('caught generic exception');
      print(e);
    }
    setState(() {
      loading = false;
    });
  }

  Future<Null> sendVote(Post post, int voteWeight) async {
    String timeDiff = DateTime.now().difference(watchCounter).inSeconds.toString();
    String _token;
    Future<IdTokenResult> idToken;
    String voteUrl = webApiUrl + 'votes/';
    await user.map((value) => idToken = value.user.getIdTokenResult(), empty: (_) {}, initializing: (_) {});
    await idToken.then((value) => _token = value.token);
    Map<String, String> header = new Map();
    header["auth"] = _token;
    try {
      await http.post(voteUrl, headers: header, body: {
        'post': post.id,
        'vote_weight': voteWeight.toString(),
        'watch_seconds': timeDiff,
      });
    } catch (e) {
      print('caught generic exception');
      print(e);
    }
  }

  Future<Null> sendFav(Post post) async {
    String _token;
    Future<IdTokenResult> idToken;
    String voteUrl = webApiUrl + 'fav/';
    await user.map((value) => idToken = value.user.getIdTokenResult(), empty: (_) {}, initializing: (_) {});
    await idToken.then((value) => _token = value.token);
    Map<String, String> header = new Map();
    header["auth"] = _token;
    try {
      var response = await http.post(voteUrl, headers: header, body: {
        'post': post.id,
      });
      setState(() {
        lastFav = jsonDecode(response.body.toString())['id'].toString();
      });
    } catch (e) {
      print('caught generic exception');
      print(e);
    }
  }

  Future<Null> sendUnFav() async {
    String _token;
    Future<IdTokenResult> idToken;
    String favUrl = webApiUrl + 'fav/';
    await user.map((value) => idToken = value.user.getIdTokenResult(), empty: (_) {}, initializing: (_) {});
    await idToken.then((value) => _token = value.token);
    Map<String, String> header = new Map();
    header["auth"] = _token;
    try {
      await http.delete(favUrl + lastFav + '/', headers: header);
    } catch (e) {
      print('caught generic exception');
      print(e);
    }
  }

  void initState() {
    super.initState();
    if (user == null) {
      setState(() {
        user = context.getSignedInUser();
        navContext = context; // Saving context to use at account screen
      });
    }
    if (!loading) {
      getDataList();
    }
    if (adToggle) {
      if (myBanner == null) {
        myBanner = BannerAd(
          // Replace the testAdUnitId with an ad unit id from the AdMob dash.
          // https://developers.google.com/admob/android/test-ads
          // https://developers.google.com/admob/ios/test-ads
          adUnitId: 'ca-app-pub-3693041012036990/2470198204',
          size: AdSize.smartBanner,
          listener: (MobileAdEvent event) {
            print("BannerAd event is $event");
          },
        );
      }
      myBanner
        ..load()
        ..show(
          // Banner Position
          anchorType: AnchorType.top,
        );
    }
    _buttonController = new AnimationController(duration: new Duration(milliseconds: 1000), vsync: this);

    rotate = new Tween<double>(
      begin: -0.0,
      end: -40.0,
    ).animate(
      new CurvedAnimation(
        parent: _buttonController,
        curve: Curves.ease,
      ),
    );
    rotate.addListener(() {
      setState(() {
        if (rotate.isCompleted) {
          var i = data.removeLast();
          data.insert(0, i);
          var j = dataCache.removeLast();
          dataCache.insert(0, j);
          if (dataCache != data){
            data = dataCache;
          }
          _buttonController.reset();
        }
      });
    });

    right = new Tween<double>(
      begin: 0.0,
      end: 400.0,
    ).animate(
      new CurvedAnimation(
        parent: _buttonController,
        curve: Curves.ease,
      ),
    );
    left = new Tween<double>(
      begin: 0.0,
      end: -400.0,
    ).animate(
      new CurvedAnimation(
        parent: _buttonController,
        curve: Curves.ease,
      ),
    );
    bottom = new Tween<double>(
      begin: 0.0,
      end: 100.0,
    ).animate(
      new CurvedAnimation(
        parent: _buttonController,
        curve: Curves.ease,
      ),
    );
    width = new Tween<double>(
      begin: 20.0,
      end: 25.0,
    ).animate(
      new CurvedAnimation(
        parent: _buttonController,
        curve: Curves.bounceOut,
      ),
    );
  }

  @override
  void dispose() {
    _buttonController.dispose();
    super.dispose();
  }

  Positioned upperCard(Post post, double bottom, double right, double left, double rotation, double skew) {
    Size screenSize = MediaQuery.of(context).size;

    return new Positioned(
      bottom: bottom,
      child: new Dismissible(
        key: UniqueKey(),
        // Changes curve of dismiss
        crossAxisEndOffset: -0.2,
        onDismissed: (DismissDirection direction) {
          //_swipeAnimation();
          if (direction == DismissDirection.endToStart) {
            likePost(post);
            dismissImg(post);
          } else {
            dislikePost(post);
            dismissImg(post);
          }
          setState(() {
            watchCounter = DateTime.now();
          });
        },
        child: new Transform(
          alignment: Alignment.bottomRight,
          transform: new Matrix4.skewX(skew),
          child: new RotationTransition(
            turns: new AlwaysStoppedAnimation(rotation / 360),
            child: new Hero(
              tag: "img",
              child: new GestureDetector(
                // Widget for detail of image
                //onTap: () {
                //  // Navigator.push(
                //  //     context,
                //  //     new MaterialPageRoute(
                //  //         builder: (context) => new DetailPage(type: img)));
                //  Navigator.of(context).push(new PageRouteBuilder(
                //        pageBuilder: (_, __, ___) => new DetailPage(type: img),
                //      ));
                //},
                child: new Card(
                  color: Colors.transparent,
                  elevation: 0.0,
                  child: new Container(
                    alignment: Alignment.center,
                    width: screenSize.width,
                    height: screenSize.height,
                    decoration: new BoxDecoration(
                      color: Colors.white,
                    ),
                    child: new Column(
                      children: <Widget>[
                        new Container(
                          width: screenSize.width,
                          height: screenSize.height,
                          child: CachedNetworkImage(
                            placeholder: (context, url) => CircularProgressIndicator(),
                            imageUrl: post.file,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Positioned backgroundCard(Post post) {
    Size screenSize = MediaQuery.of(context).size;
    return new Positioned(
      bottom: 0.0,
      child: new Card(
        color: Colors.transparent,
        elevation: 0.0,
        child: new Container(
          alignment: Alignment.center,
          width: screenSize.width,
          height: screenSize.height,
          decoration: new BoxDecoration(
            color: Colors.white,
          ),
          child: new Column(
            children: <Widget>[
              new Container(
                width: screenSize.width,
                height: screenSize.height,
                child: CachedNetworkImage(
                  imageUrl: post.file,
                  fit: BoxFit.cover,
                  progressIndicatorBuilder: (context, url, downloadProgress) =>
                      CircularProgressIndicator(value: downloadProgress.progress),
                  errorWidget: (context, url, error) => Icon(Icons.error),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  dismissImg(Post post) {
    setState(() {
      data.remove(post);
      dataCache.remove(post);
      floatingIcon = Icon(
        Icons.favorite_border,
        size: 40,
      );
    });
  }

  likePost(Post post) {
    sendVote(post, 1);
  }

  dislikePost(Post post) {
    sendVote(post, -1);
  }

  favPost(Post post) {
    setState(() {
      if (floatingIcon.icon != Icons.favorite_border) {
        sendUnFav();
        floatingIcon = Icon(
          Icons.favorite_border,
          size: 40,
        );
      } else {
        sendFav(post);
        floatingIcon = Icon(
          Icons.favorite,
          size: 40,
        );
      }
    });
  }

  Widget homeController() {
    var dataLength = data.length;

    if (dataLength == 3 && !loading && !lastEmpty) {
      getDataList();
    }
    if (dataLength > 0) {
      return Stack(
          alignment: AlignmentDirectional.center,
          children: data.map((item) {
            if (data.indexOf(item) == dataLength - 1) {
              setState(() {
                selectedImage = item;
              });
              return upperCard(item, bottom.value, right.value, left.value, rotate.value, rotate.value < -10 ? 0.1 : 0.0);
            } else {
              return backgroundCard(item);
            }
          }).toList());
    } else if (loading) {
      return Text("Loading...", style: new TextStyle(color: Theme.of(context).hintColor, fontSize: 30.0));
    } else {
      Fluttertoast.showToast(
          msg: "Congratulations",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 5,
          backgroundColor: Colors.amber,
          textColor: Colors.white,
          fontSize: 16.0
      );
      return Column(
        children: [
          Text("Restart"),
          IconButton(
            icon: FaIcon(FontAwesomeIcons.undo),
            onPressed: () {
              setState(() {
                lastEmpty = false;
              });
              getDataList();
            },
          ),
        ],
        mainAxisAlignment: MainAxisAlignment.center,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: new Container(
        color: Colors.white,
        alignment: Alignment.center,
        child: homeController(),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: GestureDetector(
        onTap: () {
          if (selectedImage != null) {
            favPost(selectedImage);
          }
        },
        // ignore: missing_required_param
        child: FloatingActionButton(
          //tooltip: floatingActionTooltip,
          backgroundColor: Theme.of(context).backgroundColor,
          foregroundColor: Theme.of(context).primaryColor,
          child: floatingIcon,
        ),
      ),
      bottomNavigationBar: navBar(context, 1),
    );
  }
}
