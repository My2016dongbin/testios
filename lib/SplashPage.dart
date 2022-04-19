import 'dart:async';
import 'dart:developer';

import 'package:fireprevention/utils/EventBusUtils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bmflocation/bdmap_location_flutter_plugin.dart';
import 'package:permission_handler/permission_handler.dart';
// import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'LoginPage.dart';
import 'MainPage.dart';
import 'model/CustomerModel.dart';
import 'model/EventBusModel.dart';
import 'network/Api.dart';
import 'network/NetUtil.dart';
import 'utils/CustomRoute.dart';

class SplashPage extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    return SplashPageState();
  }

}

class SplashPageState extends State<SplashPage> {
  String secondIn  = "";

  StreamSubscription subscription;
  @override
  void dispose() {
    super.dispose();
    subscription.cancel();
  }
  Image catchImage;
  @override
  void initState() {
    super.initState();
    subscription =
        EventBusUtil.getInstance().on<Splash>().listen((event) {
          int pushTag = event.tag;
          if(pushTag == 0){
            ///预留（初次进入引导页）
            Navigator.pushAndRemoveUntil(
                context,
                CustomRoute(
                    LoginPage(),timer: 1000),
                    (route) => route == null);
          }else if(pushTag == 1){
            ///token存在，自动登录
            Navigator.pushAndRemoveUntil(
                context,
                CustomRoute(
                    MainPage(),timer: 1000),
                    (route) => route == null);
          }else{
            ///token不存在，未登录
            Navigator.pushAndRemoveUntil(
                context,
                CustomRoute(
                    LoginPage(),timer: 1000),
                    (route) => route == null);
          }
        });

    catchImage = Image.asset("assets/images/common/ic_guodu.jpg",gaplessPlayback: true,);

    ///build完成后申请权限
    WidgetsBinding.instance
        .addPostFrameCallback((_) {
          Future.delayed(Duration(milliseconds: 1200)).then((value) {
            //申请权限
            requestPermission();
          });
    });
  }
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      body: Image.asset("assets/images/common/ic_guodu.jpg",gaplessPlayback: true,fit: BoxFit.fill,width: screenWidth,height: screenHeight,),
    );
  }


  //获取本地缓存
  void getFromCache() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    secondIn = prefs.getString("SecondIn");
    String tokenGet = prefs.getString("token");
    CustomerModel.token = tokenGet;
    CustomerModel.account = prefs.getString("account");
    CustomerModel.passWord = prefs.getString("passWord");
    if (tokenGet == null) {
      EventBusUtil.getInstance().fire(Splash(2));
      return;
    }
    if (tokenGet.length > 0) {
      CustomerModel.fullName = prefs.getString("fullName");
      CustomerModel.headUrl = prefs.getString("headUrl");
      CustomerModel.groupId = prefs.getString("groupId");
      CustomerModel.gridNo = prefs.getString("gridNo");
      CustomerModel.id = prefs.getString("id");
      CustomerModel.appSettingBtnPosition = prefs.getBool("appSettingBtnPosition");
      CustomerModel.isYuYin = prefs.getBool("isYuYin");
      CustomerModel.keepLogin = prefs.getBool("keepLogin");

      CustomerModel.isLogin = true;
    } else {
      CustomerModel.isLogin = false;
    }
    if(CustomerModel.token == null || CustomerModel.token.toString().length == 0 || CustomerModel.keepLogin==false){
      EventBusUtil.getInstance().fire(Splash(2));
      return;
    }
    next();
  }

  Future<void> next() async {
    /*if(secondIn!=null && secondIn == "yes"){*/
      //自动登录 （原项目在这里直接使用登录接口是错误的，应该使用token去获取登录信息，待改善）
      NetUtil.get(Api.Login, (data){
        log("login --> $data");
        if(data!=null && data["access_token"]!=null){
          saveToCache("token", data["access_token"]);
          CustomerModel.token = data["access_token"];
          EventBusUtil.getInstance().fire(Splash(1));
        }else{
          EventBusUtil.getInstance().fire(Splash(2));
        }
      },params: {
        "username":CustomerModel.account,
        "password":CustomerModel.passWord,
        "grant_type":"password",
        "client_id":"client_password",
        "client_secret":"123456",
      },errorCallBack: (e){
        EventBusUtil.getInstance().fire(Splash(2));
      });
    /*}else{
      EventBusUtil.getInstance().fire(Splash(0));
    }*/
  }

  void requestPermission() {
    /*List<PermissionGroup> permissionList = [PermissionGroup.camera,PermissionGroup.storage,PermissionGroup.location,];
    PermissionHandler().requestPermissions(permissionList).then((value) {
      for( PermissionGroup permission in permissionList){
        if(value[permission]!= PermissionStatus.granted){
          requestPermission();
          return;
        }
      }

      ///读取账号信息
      getFromCache();
    });*/

    ///权限申请
    Permission.storage.request().then((value) {
      print("storage ==> ${value.isGranted}");
      Permission.camera.request().then((value) {
        print("camera ==> ${value.isGranted}");
        LocationFlutterPlugin().requestPermission();
      });
    });

    ///读取账号信息
    getFromCache();
  }

}