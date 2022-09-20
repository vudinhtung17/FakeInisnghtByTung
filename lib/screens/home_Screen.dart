import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rest_api_login/providers/auth.dart';
import 'package:rest_api_login/screens/login_Screen.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:rest_api_login/assets/light_Color.dart';
import 'package:rest_api_login/widgets/task_column.dart';
import 'package:rest_api_login/widgets/top_container.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:rest_api_login/utils/globals.dart' as globals;
import 'package:rest_api_login/utils/http_exception.dart';
import 'package:rest_api_login/utils/common_utils.dart';

class HomeScreen extends StatelessWidget {
  final navigatorKey = GlobalKey<NavigatorState>();

  Text subheading(String title) {
    return Text(
      title,
      style: TextStyle(
          color: LightColors.kDarkBlue,
          fontSize: 20.0,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.2),
    );
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    Future Checkin(int typeAction) async {
      if (globals.isLoggedIn == false) {
        //invalid
        return;
      }
      try {
        await Provider.of<Auth>(context, listen: false)
            .checkIn(typeAction);
        Utility.getInstance().showAlertDialog(context, 'Checkin thành công', globals.messageAction);
      } on HttpException catch (e) {
        var errorMessage = e.message;
        Utility.getInstance().showAlertDialog(context, 'Lỗi', errorMessage);
      } catch (error) {
        var errorMessage = 'Có lỗi xảy ra. Vui lòng thử lại sau';
        Utility.getInstance().showAlertDialog(context, 'Lỗi', errorMessage);
      }
    }
    Future Checkout(int typeAction) async {
      if (globals.isLoggedIn == false) {
        //invalid
        return;
      }
      try {
        await Provider.of<Auth>(context, listen: false)
            .checkOut(typeAction);
        Utility.getInstance().showAlertDialog(context, 'Checkout thành công', globals.messageAction);
      } on HttpException catch (e) {
        var errorMessage = e.message;
        Utility.getInstance().showAlertDialog(context, 'Lỗi', errorMessage);
      } catch (error) {
        var errorMessage = 'Có lỗi xảy ra. Vui lòng thử lại sau';
        Utility.getInstance().showAlertDialog(context, 'Lỗi', errorMessage);
      }
    }

    return Scaffold(
      /*appBar: AppBar(
        title: Text("Fake2Insight Home"),
        backgroundColor: Colors.orange[500],
        actions: <Widget>[
          FlatButton.icon(
            textColor: Colors.white,
            onPressed: () {
              Navigator.of(context).pushReplacementNamed("/");
              Provider.of<Auth>(context, listen: false).logout();
            },
            icon: Icon(Icons.logout_rounded),
            label: Text("Đăng xuất"),
            shape: CircleBorder(side: BorderSide(color: Colors.transparent)),
          ),
        ],
      ),*/
        backgroundColor: LightColors.kLightYellow,
        body: SafeArea(
          child: Column(
            children: <Widget>[
              TopContainer(
                height: 200,
                width: width,
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Icon(Icons.menu,
                              color: LightColors.kDarkBlue, size: 30.0),
                          /*FlatButton.icon*/
                          TextButton.icon(
                            //textColor: LightColors.kDarkBlue,
                            onPressed: () {
                              Navigator.of(context).pushReplacementNamed("/");
                              Provider.of<Auth>(context, listen: false).logout();
                            },
                            icon: Icon(Icons.logout_rounded),
                            label: Text("Đăng xuất", style: TextStyle(color: LightColors.kDarkBlue),),
                            //shape: CircleBorder(side: BorderSide(color: Colors.transparent)),
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 0, vertical: 0.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: <Widget>[
                            CircleAvatar(
                            backgroundColor: LightColors.kBlue,
                              radius: 35.0,
                              backgroundImage: AssetImage(
                                'assets/images/avatar.png',
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                Container(
                                  child: Text(
                                    globals.fullName,
                                    textAlign: TextAlign.start,
                                    style: TextStyle(
                                      fontSize: 22.0,
                                      color: LightColors.kDarkBlue,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                                Container(
                                  child: Text(
                                    'Mã nhân viên: '+ globals.empID,
                                    textAlign: TextAlign.start,
                                    style: TextStyle(
                                      fontSize: 16.0,
                                      color: Colors.black45,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ),
                              ],
                            )
                          ],
                        ),
                      )
                    ]),
              ),
              /*Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: <Widget>[
                      Container(
                        color: Colors.transparent,
                        padding: EdgeInsets.symmetric(
                            horizontal: 20.0, vertical: 10.0),
                        child: Column(
                          children: <Widget>[
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                subheading('Status'),
                              ],
                            ),
                            SizedBox(height: 15.0),
                            TaskColumn(
                              icon: Icons.alarm,
                              iconBackgroundColor: LightColors.kBlue,
                              title: 'Checkin Status',
                              subtitle: globals.statusCheckin,
                            ),
                            SizedBox(
                              height: 15.0,
                            ),
                            TaskColumn(
                              icon: Icons.blur_circular,
                              iconBackgroundColor: LightColors.kRed,
                              title: 'Checkout Status',
                              subtitle: globals.statusCheckout,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),*/
            ],
          ),
        ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Stack(
        alignment: Alignment.bottomRight,
        fit: StackFit.expand,
        children: [
          Stack(
            alignment: Alignment.bottomLeft,
            children: [
              SpeedDial(
                icon: Icons.login,
                backgroundColor: Colors.amber,
                label: Text('Checkin'),
                children: [
                  SpeedDialChild(
                    child: const Icon(Icons.home),
                    label: 'WFH',
                    backgroundColor: Colors.amberAccent,
                    onTap: () {
                      Checkin(1);
                    },
                  ),
                  SpeedDialChild(
                    child: const Icon(Icons.apartment_outlined),
                    label: 'Onsite',
                    backgroundColor: Colors.amberAccent,
                    onTap: () {
                      Checkin(2);
                    },
                  ),
                  SpeedDialChild(
                    child: const Icon(Icons.business),
                    label: 'Công ty',
                    backgroundColor: Colors.amberAccent,
                    onTap: () {
                      Checkin(0);
                    },
                  ),
                ],
              ),
            ],
          ),
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              SpeedDial(
                icon: Icons.logout,
                backgroundColor: Colors.amber,
                label: Text('Checkout'),
                children: [
                  SpeedDialChild(
                    child: const Icon(Icons.home),
                    label: 'WFH',
                    backgroundColor: Colors.amberAccent,
                    onTap: () {
                      Checkout(1);
                    },
                  ),
                  SpeedDialChild(
                    child: const Icon(Icons.apartment_outlined),
                    label: 'Onsite',
                    backgroundColor: Colors.amberAccent,
                    onTap: () {
                      Checkout(2);
                    },
                  ),
                  SpeedDialChild(
                    child: const Icon(Icons.business),
                    label: 'Công ty',
                    backgroundColor: Colors.amberAccent,
                    onTap: () {
                      Checkout(0);
                    },
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  /*SpeedDial buildSpeedDialCheckin() {
    return SpeedDial(
        icon: Icons.login,
        backgroundColor: Colors.amber,
        label: Text('Checkin'),
        children: [
          SpeedDialChild(
            child: const Icon(Icons.home),
            label: 'WFH',
            backgroundColor: Colors.amberAccent,
            onTap: () {},
          ),
          SpeedDialChild(
            child: const Icon(Icons.apartment_outlined),
            label: 'Onsite',
            backgroundColor: Colors.amberAccent,
            onTap: () {/* Do something */},
          ),
          SpeedDialChild(
            child: const Icon(Icons.business),
            label: 'Công ty',
            backgroundColor: Colors.amberAccent,
            onTap: () {/* Do something */},
          ),
        ],
    );
  }

  SpeedDial buildSpeedDialCheckout() {
    return SpeedDial(
      icon: Icons.logout,
      backgroundColor: Colors.amber,
      label: Text('Checkout'),
      children: [
        SpeedDialChild(
          child: const Icon(Icons.home),
          label: 'WFH',
          backgroundColor: Colors.amberAccent,
          onTap: () {/* Do someting */},
        ),
        SpeedDialChild(
          child: const Icon(Icons.apartment_outlined),
          label: 'Onsite',
          backgroundColor: Colors.amberAccent,
          onTap: () {/* Do something */},
        ),
        SpeedDialChild(
          child: const Icon(Icons.business),
          label: 'Công ty',
          backgroundColor: Colors.amberAccent,
          onTap: () {/* Do something */},
        ),
      ],
    );
  }*/

}
