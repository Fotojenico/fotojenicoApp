import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:flutter_svg/svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'dart:math';
import 'package:fotojenico/navbar.dart';
import 'package:step_progress_indicator/step_progress_indicator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../globals.dart';

class RewardsScreen extends StatefulWidget {
  @override
  _RewardsState createState() {
    return _RewardsState();
  }
}

class _RewardsState extends State<RewardsScreen> {
  bool loading = false;
  bool start = true;
  List data = [];
  var achievements;

  dynamic loadJson() async {
    String data = await rootBundle.loadString('assets/achievements.json');
    var jsonResult = json.decode(data);
    print(jsonResult);
    achievements = jsonResult;
  }


  Future<Null> getDataList() async {
    setState(() {
      loading = true;
    });
    String _token;
    Future<IdTokenResult> idToken;
    String achievementsUrl = webApiUrl + 'achievement_progress/';

    await user.map((value) => idToken = value.user.getIdTokenResult(), empty: (_) {}, initializing: (_) {});
    await idToken.then((value) => _token = value.token);
    Map<String, String> header = new Map();
    header["auth"] = _token;
    try {
      final request = await http.get(achievementsUrl, headers: header);
      var response = json.decode(request.body);
      setState(() {
        if (start){
          data.insertAll(0, response);
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
  void initState(){
    super.initState();
    if(!loading && start){
      loadJson();
      getDataList();
    }
  }

  Widget rewardWidget(int index){
    var widgetData = data[index];
    String rewardLabel = achievements[widgetData['achievement'].toString()]['label'] ?? '';
    return Column(
      children: [
        CircularStepProgressIndicator(
          totalSteps: widgetData['step_count'] ?? 1,
          currentStep: widgetData['progress_step'],
          stepSize: 10,
          selectedColor: Theme.of(context).accentColor,
          unselectedColor: Theme.of(context).backgroundColor,
          padding: pi / 200,
          width: 150,
          height: 150,
          child: SvgPicture.asset(
              'assets/images/' + achievements[widgetData['achievement'].toString()]['image'],
              semanticsLabel: 'A red up arrow'
          ),
        ),
        Text(rewardLabel),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Align(
          alignment: Alignment.center,
          child: StaggeredGridView.countBuilder(
            crossAxisCount: 4,
            itemCount: data.length,
            itemBuilder: (BuildContext context, int index) => new Container(
                child: new Center(
                  child: rewardWidget(index),
                )),
            staggeredTileBuilder: (int index) => new StaggeredTile.count(2, 2),
            mainAxisSpacing: 4.0,
            crossAxisSpacing: 4.0,
          )),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Visibility(
        visible: false,
        child: GestureDetector(
          onTap: () {
            //fav();
          },
          // ignore: missing_required_param
          child: FloatingActionButton(
            //tooltip: floatingActionTooltip,
            backgroundColor: Theme.of(context).backgroundColor,
            foregroundColor: Theme.of(context).primaryColor,
          ),
        ),
      ),
      bottomNavigationBar: navBar(context, 2),
    );
  }
}
