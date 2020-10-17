import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

import 'package:fotojenico/navbar.dart';

class RewardsScreen extends StatefulWidget {
  @override
  _RewardsState createState() {
    return _RewardsState();
  }
}

class _RewardsState extends State<RewardsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Align(
          alignment: Alignment.center,
          child: StaggeredGridView.countBuilder(
            crossAxisCount: 4,
            itemCount: 20,
            itemBuilder: (BuildContext context, int index) => new Container(
                color: Colors.green,
                child: new Center(
                  child: new CircleAvatar(
                    backgroundColor: Colors.white,
                    child: new Text('$index'),
                  ),
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
