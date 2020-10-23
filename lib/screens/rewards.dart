import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'dart:math';
import 'package:fotojenico/navbar.dart';
import 'package:step_progress_indicator/step_progress_indicator.dart';

class RewardsScreen extends StatefulWidget {
  @override
  _RewardsState createState() {
    return _RewardsState();
  }
}

class _RewardsState extends State<RewardsScreen> {
  Widget rewardWidget(int totalSteps){
    return CircularStepProgressIndicator(
      totalSteps: totalSteps,
      currentStep: 5,
      stepSize: 10,
      selectedColor: Theme.of(context).accentColor,
      unselectedColor: Theme.of(context).backgroundColor,
      padding: pi / 200,
      width: 150,
      height: 150,
      child: Icon(
        FontAwesomeIcons.smile,
        color: Theme.of(context).primaryColor,
        size: 84,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Align(
          alignment: Alignment.center,
          child: StaggeredGridView.countBuilder(
            crossAxisCount: 4,
            itemCount: 20,
            itemBuilder: (BuildContext context, int index) => new Container(
                child: new Center(
                  child: rewardWidget(15),
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
